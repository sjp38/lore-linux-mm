Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EACD86B00AB
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 08:00:33 -0400 (EDT)
Received: by ywh42 with SMTP id 42so2432684ywh.30
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 05:00:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090828205241.fc8dfa51.minchan.kim@barrios-desktop>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
	 <1251449067-3109-2-git-send-email-mel@csn.ul.ie>
	 <20090828205241.fc8dfa51.minchan.kim@barrios-desktop>
Date: Fri, 28 Aug 2009 21:00:25 +0900
Message-ID: <28c262360908280500tb47685btc9f36ca81605d55@mail.gmail.com>
Subject: Re: [PATCH 1/2] page-allocator: Split per-cpu list into
	one-list-per-migrate-type
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 8:52 PM, Minchan Kim<minchan.kim@gmail.com> wrote:
> Hi, Mel.
>
> On Fri, 28 Aug 2009 09:44:26 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
>
>> Currently the per-cpu page allocator searches the PCP list for pages of =
the
>> correct migrate-type to reduce the possibility of pages being inappropri=
ate
>> placed from a fragmentation perspective. This search is potentially expe=
nsive
>> in a fast-path and undesirable. Splitting the per-cpu list into multiple
>> lists increases the size of a per-cpu structure and this was potentially
>> a major problem at the time the search was introduced. These problem has
>> been mitigated as now only the necessary number of structures is allocat=
ed
>> for the running system.
>>
>> This patch replaces a list search in the per-cpu allocator with one list=
 per
>> migrate type. The potential snag with this approach is when bulk freeing
>> pages. We round-robin free pages based on migrate type which has little
>> bearing on the cache hotness of the page and potentially checks empty li=
sts
>> repeatedly in the event the majority of PCP pages are of one type.
>>
>> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> Acked-by: Nick Piggin <npiggin@suse.de>
>> ---
>> =C2=A0include/linux/mmzone.h | =C2=A0 =C2=A05 ++-
>> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0106 +++++++++++=
+++++++++++++++---------------------
>> =C2=A02 files changed, 63 insertions(+), 48 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 008cdcd..045348f 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -38,6 +38,7 @@
>> =C2=A0#define MIGRATE_UNMOVABLE =C2=A0 =C2=A0 0
>> =C2=A0#define MIGRATE_RECLAIMABLE =C2=A0 1
>> =C2=A0#define MIGRATE_MOVABLE =C2=A0 =C2=A0 =C2=A0 2
>> +#define MIGRATE_PCPTYPES =C2=A0 =C2=A0 =C2=A03 /* the number of types o=
n the pcp lists */
>> =C2=A0#define MIGRATE_RESERVE =C2=A0 =C2=A0 =C2=A0 3
>> =C2=A0#define MIGRATE_ISOLATE =C2=A0 =C2=A0 =C2=A0 4 /* can't allocate f=
rom here */
>> =C2=A0#define MIGRATE_TYPES =C2=A0 =C2=A0 =C2=A0 =C2=A0 5
>> @@ -169,7 +170,9 @@ struct per_cpu_pages {
>> =C2=A0 =C2=A0 =C2=A0 int count; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* number of pages in the list */
>> =C2=A0 =C2=A0 =C2=A0 int high; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /* high watermark, emptying needed */
>> =C2=A0 =C2=A0 =C2=A0 int batch; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* chunk size for buddy add/remove */
>> - =C2=A0 =C2=A0 struct list_head list; =C2=A0/* the list of pages */
>> +
>> + =C2=A0 =C2=A0 /* Lists of pages, one per migrate type stored on the pc=
p-lists */
>> + =C2=A0 =C2=A0 struct list_head lists[MIGRATE_PCPTYPES];
>> =C2=A0};
>>
>> =C2=A0struct per_cpu_pageset {
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index ac3afe1..65eedb5 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -522,7 +522,7 @@ static inline int free_pages_check(struct page *page=
)
>> =C2=A0}
>>
>> =C2=A0/*
>> - * Frees a list of pages.
>> + * Frees a number of pages from the PCP lists
>> =C2=A0 * Assumes all pages on list are in same zone, and of same order.
>> =C2=A0 * count is the number of pages to free.
>> =C2=A0 *
>> @@ -532,23 +532,36 @@ static inline int free_pages_check(struct page *pa=
ge)
>> =C2=A0 * And clear the zone's pages_scanned counter, to hold off the "al=
l pages are
>> =C2=A0 * pinned" detection logic.
>> =C2=A0 */
>> -static void free_pages_bulk(struct zone *zone, int count,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct list_head *l=
ist, int order)
>> +static void free_pcppages_bulk(struct zone *zone, int count,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct per_cpu_page=
s *pcp)
>> =C2=A0{
>> + =C2=A0 =C2=A0 int migratetype =3D 0;
>> +
>
> How about caching the last sucess migratetype
> with 'per_cpu_pages->last_alloc_type'?
                                         ^^^^
                                         free
> I think it could prevent a litte spinning empty list.

Anyway, Ignore me.
I didn't see your next patch.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
