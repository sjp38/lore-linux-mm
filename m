Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 99E0B6B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 19:46:24 -0400 (EDT)
Received: by vcbfl17 with SMTP id fl17so6269003vcb.14
        for <linux-mm@kvack.org>; Mon, 17 Sep 2012 16:46:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e5d08804-a542-4778-a103-b14b553b0747@default>
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<e33a2c0e-3b51-4d89-a2b2-c1ed9c8f862c@default>
	<20120907143751.GB4670@phenom.dumpdata.com>
	<504C1100.2050300@vflare.org>
	<e5d08804-a542-4778-a103-b14b553b0747@default>
Date: Mon, 17 Sep 2012 16:46:23 -0700
Message-ID: <CAPkvG_cqcrsokD20T0cn=K6X=Ynd0oGbRDXCKseeiuvAZByJ3Q@mail.gmail.com>
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, Sep 17, 2012 at 1:42 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> From: Nitin Gupta [mailto:ngupta@vflare.org]
>> Subject: Re: [RFC] mm: add support for zsmalloc and zcache
>>
>> The problem is that zbud performs well only when a (compressed) page is
>> either PAGE_SIZE/2 - e or PAGE_SIZE - e, where e is small. So, even if
>> the average compression ratio is 2x (which is hard to believe), a
>> majority of sizes can actually end up in PAGE_SIZE/2 + e bucket and zbud
>> will still give bad performance.  For instance, consider these histograms:
>
> Whoa whoa whoa.  This is very wrong.  Zbud handles compressed pages
> of any range that fits in a pageframe (same, almost, as zsmalloc).
> Unless there is some horrible bug you found...
>
> Zbud _does_ require the _distribution_ of zsize to be roughly
> centered around PAGE_SIZE/2 (or less).  Is that what you meant?

Yes, I meant this only: though zbud can handle any size, it isn't
efficient for any size not centered around PAGESIZE/2.

> If so, the following numbers you posted don't make sense to me.
> Could you be more explicit on what the numbers mean?
>

This is a histogram of the compressed sizes when files were
compressed in 4K chunks. The first number is the lower limit of
bin size, second number of upper limit and third number is the
number of pages that fall in that bin.

> Also, as you know, unlike zram, the architecture of tmem/frontswap
> allows zcache to reject any page, so if the distribution of zsize
> exceeds PAGE_SIZE/2, some pages can be rejected (and thus passed
> through to swap).  This safety valve already exists in zcache (and zcache2)
> to avoid situations where zpages would otherwise significantly
> exceed half of total pageframes allocated.  IMHO this is a
> better policy than accepting a large number of poorly-compressed pages,

Long time back zram had the ability of forwarding poorly compressed
pages to a backing swap device but that was removed to cleanup the
code and help with upstream promotion.  Once zram goes out of staging,
I will try getting that functionality back if there is enough demand.


> i.e. if every data page compresses down from 4096 bytes to 4032
> bytes, zsmalloc stores them all (thus using very nearly one pageframe
> per zpage), whereas zbud avoids the anomalous page sequence altogether.
>

This ability to letting pages go to physical device is not really
highlighting anything
of zbud vs zsmalloc.  That ability is really zram vs frontswap stuff
which is a different
thing.


>> # Created tar of /usr/lib (2GB) on a fairly loaded Linux system and
>> compressed page-by-page using LZO:
>>
>> # first two fields: bin start, end.  Third field: compressed size
>> 32 286 7644
>> :
>> 3842 4096 3482
>>
>> The only (approx) sweetspots for zbud are 1810-2064 and 3842-4096 which
>> covers only a small fraction of pages.
>>
>> # same page-by-page compression for 220MB ISO from project Gutenberg:
>> 32 286 70
>> :
>> 3842 4096 804
>>
>> Again very few pages in zbud favoring bins.
>>
>> So, we really need zsmalloc style allocator which handles sizes all over
>> the spectrum. But yes, compaction remains far easier to implement on zbud.
>
> So it remains to be seen if a third choice exists (which might be either
> an enhanced zbud or an enhanced zsmalloc), right?
>

Yes, definitely. At least for non-ephemeral pages (zram), zsmalloc seems to be
a better choice even without compaction. As for zcache, I don't understand its
codebase anyways so not sure how exactly compaction would interact with it,
so I think zcache should stay with zbud.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
