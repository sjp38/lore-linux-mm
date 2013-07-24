Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id AEFCF6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 09:52:26 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id up14so13215070obb.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:52:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130722150702.GB4706@variantweb.net>
References: <1374331018-11045-1-git-send-email-bob.liu@oracle.com>
	<20130722150702.GB4706@variantweb.net>
Date: Wed, 24 Jul 2013 21:52:25 +0800
Message-ID: <CAA_GA1dUdNzwPFJdPr6Ysvf4t+08t9A=tcE4SGL8K73m27meNw@mail.gmail.com>
Subject: Re: [PATCH 0/2] zcache: a new start for upstream
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>

Hi Seth,

On Mon, Jul 22, 2013 at 11:07 PM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> Sorry for the dup Bob, last reply only went to linux-mm
>
> On Sat, Jul 20, 2013 at 10:36:56PM +0800, Bob Liu wrote:
>> We already have zswap helps reducing the swap out/in IO operations by
>> compressing anon pages.
>> It has been merged into v3.11-rc1 together with the zbud allocation layer.
>>
>> However there is another kind of pages(clean file pages) suitable for
>> compression as well. Upstream has already merged its frontend(cleancache).
>> Now we are lacking of a backend of cleancache as zswap to frontswap.
>>
>> Furthermore, we need to balance the number of compressed anon and file pages,
>> E.g. it's unfair to normal file pages if zswap pool occupies too much memory for
>> the storage of compressed anon pages.
>>
>> Although the current version of zcache in staging tree has already done those
>> works mentioned above, the implementation is too complicated to be merged into
>> upstream.
>>
>> What I'm looking for is a new way for zcache towards upstream.
>> The first change is no more staging tree.
>> Second is implemented a simple cleancache backend at first, which is based on
>> the zbud allocation same as zswap.
>
> I like the approach of distilling zcache down to only page cache compression
> as a start.
>

Thank you for your review!

> However, there is still the unresolved issue of the streaming read regression.
> If the workload does streaming reads (i.e. reads from a set much larger than
> RAM and does no rereads), zcache will regress that workload because it will
> be compressing pages that will quickly be tossed out of the second chance
> cache too.
>
> This is a difficult problem when it comes to page cache compression: how
> to know whether a page will be used again.  In the case of zswap, the
> page is persistent in memory and therefore MUST be maintained.  With
> page cache compression, that isn't that case.  There is the option to
> just toss it and reread from disk.

Probably we can add checking whether the file page used to at the active list!
Only putting reclaimed file pages which are from active list to cleancache!

Of course this way can't fix this problem totally, but I think we can
get a higher hit rate!

>
> The assumption is that keeping as many cached pages as possible, regardless
> of the overhead to do so, is always a win.  But this is not always true.
>
>>
>> At the end, I hope we can combine the new cleancache backend with
>> zswap(frontswap backend), in order to have a generic in-kernel memory
>> compression solution in upstream.
>
> I don't see a need to combine them since, afaict, you'd really never use them
> at the same time as zswap (anon memory pressure in general) shreds the page
> cache and would aggressively shrink zcache to the point of uselessness.
>

Make sense, but is there any way to share the compression functions
and per-cpu functions?

>>
>> Bob Liu (2):
>>   zcache: staging: %s/ZCACHE/ZCACHE_OLD
>>   mm: zcache: core functions added
>>
>>  drivers/staging/zcache/Kconfig  |   12 +-
>>  drivers/staging/zcache/Makefile |    4 +-
>>  mm/Kconfig                      |   18 +
>>  mm/Makefile                     |    1 +
>>  mm/zcache.c                     |  840 +++++++++++++++++++++++++++++++++++++++
>>  5 files changed, 867 insertions(+), 8 deletions(-)
>>  create mode 100644 mm/zcache.c
>
> No code?
>
> Seth

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
