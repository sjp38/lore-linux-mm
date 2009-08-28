Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D2D466B00BE
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:46:51 -0400 (EDT)
Received: by gxk12 with SMTP id 12so2559238gxk.4
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 06:46:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090828125559.GD5054@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
	 <1251449067-3109-2-git-send-email-mel@csn.ul.ie>
	 <20090828205241.fc8dfa51.minchan.kim@barrios-desktop>
	 <28c262360908280500tb47685btc9f36ca81605d55@mail.gmail.com>
	 <20090828125559.GD5054@csn.ul.ie>
Date: Fri, 28 Aug 2009 22:46:54 +0900
Message-ID: <28c262360908280646s506db2ccsa3842ee33b241120@mail.gmail.com>
Subject: Re: [PATCH 1/2] page-allocator: Split per-cpu list into
	one-list-per-migrate-type
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 9:56 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> On Fri, Aug 28, 2009 at 09:00:25PM +0900, Minchan Kim wrote:
>> On Fri, Aug 28, 2009 at 8:52 PM, Minchan Kim<minchan.kim@gmail.com> wrot=
e:
>> > Hi, Mel.
>> >
>> > On Fri, 28 Aug 2009 09:44:26 +0100
>> > Mel Gorman <mel@csn.ul.ie> wrote:
>> >
>> >> Currently the per-cpu page allocator searches the PCP list for pages =
of the
>> >> correct migrate-type to reduce the possibility of pages being inappro=
priate
>> >> placed from a fragmentation perspective. This search is potentially e=
xpensive
>> >> in a fast-path and undesirable. Splitting the per-cpu list into multi=
ple
>> >> lists increases the size of a per-cpu structure and this was potentia=
lly
>> >> a major problem at the time the search was introduced. These problem =
has
>> >> been mitigated as now only the necessary number of structures is allo=
cated
>> >> for the running system.
>> >>
>> >> This patch replaces a list search in the per-cpu allocator with one l=
ist per
>> >> migrate type. The potential snag with this approach is when bulk free=
ing
>> >> pages. We round-robin free pages based on migrate type which has litt=
le
>> >> bearing on the cache hotness of the page and potentially checks empty=
 lists
>> >> repeatedly in the event the majority of PCP pages are of one type.
>> >>
>> >> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> >> Acked-by: Nick Piggin <npiggin@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

>> >> =C2=A0 */
>> >> -static void free_pages_bulk(struct zone *zone, int count,
>> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct list_hea=
d *list, int order)
>> >> +static void free_pcppages_bulk(struct zone *zone, int count,
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct per_cpu_=
pages *pcp)
>> >> =C2=A0{
>> >> + =C2=A0 =C2=A0 int migratetype =3D 0;
>> >> +
>> >
>> > How about caching the last sucess migratetype
>> > with 'per_cpu_pages->last_alloc_type'?
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0^^^^
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0free
>> > I think it could prevent a litte spinning empty list.
>>
>> Anyway, Ignore me.
>> I didn't see your next patch.
>>
>
> Nah, it's a reasonable suggestion. Patch 2 was one effort to reduce
> spinning but the comment was in patch 1 in case someone thought of
> something better. I tried what you suggested before but it didn't work
> out. For any sort of workload that varies the type of allocation (very
> frequent), it didn't reduce spinning significantly.

Thanks for good information.

> --
> Mel Gorman
> Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
> University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
