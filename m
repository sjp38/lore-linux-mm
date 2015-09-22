Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0946B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:35:13 -0400 (EDT)
Received: by obbda8 with SMTP id da8so10563999obb.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 08:35:13 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id u193si1416366oif.28.2015.09.22.08.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 08:35:12 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so12475341pac.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 08:35:11 -0700 (PDT)
Date: Wed, 23 Sep 2015 00:36:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/2] prepare zbud to be used by zram as underlying
 allocator
Message-ID: <20150922153640.GA14817@bbox>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
 <20150917013007.GB421@swordfish>
 <CAMJBoFP5LfoKwzDbSJMmOVOfq=8-7AaoAOV5TVPNt-JcUvZ0eA@mail.gmail.com>
 <20150921041837.GF27729@bbox>
 <CAMJBoFN0KocBQLSMJkxYS2JS+jSPR3Y5gGdceoKTYJWbm06t1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFN0KocBQLSMJkxYS2JS+jSPR3Y5gGdceoKTYJWbm06t1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi Vitaly,

On Mon, Sep 21, 2015 at 11:11:00PM +0200, Vitaly Wool wrote:
> Hello Minchan,
> 
> > Sorry, because you wrote up "zram" in the title.
> > As I said earlier, we need several numbers to investigate.
> >
> > First of all, what is culprit of your latency?
> > It seems you are thinking about compaction. so compaction what?
> > Frequent scanning? lock collision? or frequent sleeping in compaction
> > code somewhere? And then why does zbud solve it? If we use zbud for zram,
> > we lose memory efficiency so there is something to justify it.
> 
> The data I've got so far strongly suggests that in some use cases (see
> below) with zsmalloc
> * there are more allocstalls
> * memory compaction is triggered more frequently
> * allocstalls happen more often
> * page migrations are way more frequent, too.
> 
> Please also keep in mind that I do not advise you or anyone to use
> zbud instead of zsmalloc. The point I'm trying to make is that zbud
> fits my particular case better and I want to be able to choose it in
> the kernel without hacking it with my private patches.

I understand your goal well. ;-) But, please understand my goal which
is to find fundamental reason why zbud removes latency.

You gave some compaction-related stats but it is just one of result,
not the cause. I guess you could find another stats as well as compaction
stats which affect your workload. Once you find them all, please
investigate what is major factor for your latency among them.
Then, we should think over what is best solution for it and if zbud is
best to remove the cause, yes, why not. I can merge it into zram.

IOW, I should maintain zram so I need to know when,where,how to use zbud
with zram is useful so that I can guide it to zram users and you should
*justify* the overhead to me. Overhead means I should maintain two allocators
for zram from now on. It means when I want to add some feature for zsmalloc,
I should take care of zbud and I should watch zbud patches, too which could
be very painful and starting point of diverge for zram.

Compared to zsmalloc, zsmalloc packs lots of compressed objects into
a page while zbud just stores two objects so if there are different
life time objects in a page, zsmalloc may make higher fragmentation
but zbud is not a good choice for memory efficiency either so my concern
starts from here.

For solving such problem, we added compaction into recent zram to
reduce waste memory space so it should solve internal fragment problem.
Other problem we don't solve now is external fragmentation which
is related to compaction stats you are seeing now.
Although you are seeing mitigation with zbud, it would be still problem
if you begin to use more memory for zbud. One of example, a few years
ago, some guys tried to support zbud page migration.

If external fragmentation is really problem in here, we should proivde
a feature VM can migrate zsmalloc page and it was alomost done as I told
you previous thread and I think it is really way to go.

Even, we are trying to add zlib which is better compress ratio algorithm
to reduce working memory size so without the feature, the problem would be
more severe.

So, I am thinking now we should enhance it rather than hiding a problem
by merging zbud.


> FWIW, given that I am not an author of either, I don't see why anyone
> would consider me biased. :-)
> 
> As of the memory efficiency, you seem to be quite comfortable with
> storing uncompressed pages when they compress to more than 3/4 of a
> page. I observed ~13% reported ratio increase (3.8x to 4.3x) when I
> increased max_zpage_size to PAGE_SIZE / 32 * 31. Doesn't look like a
> fight for every byte to me.

Thanks for the report. It could be another patch. :)

> 
> > The reason I am asking is I have investigated similar problems
> > in android and other plaforms and the reason of latency was not zsmalloc
> > but agressive high-order allocations from subsystems, watermark check
> > race, deferring of compaction, LMK not working and too much swapout so
> > it causes to reclaim lots of page cache pages which was main culprit
> > in my cases. When I checks with perf, compaction stall count is increased,
> > the time spent in there is not huge so it was not main factor of latency.
> 
> The main use case where the difference is seen is switching between
> users on an Android device. It does cause a lot of reclaim, too, as
> you say, but this is in the nature of zbud that reclaim happens in a
> more deterministic way and worst-case looks substantially nicer. That

Interesting!
Why is reclaim more deterministic with zbud?
That's really one of part what I want with data.


> said, the standard deviation calculated over 20 iterations of a
> change-user-multiple-times-test is 2x less for zbud than the one of
> zsmalloc.

One thing I can guess is a page could be freed easily if just two objects
in a page are freed by munmap or kill. IOW, we could remove pinned page
easily so we could get higher-order page easily.

However, it would be different once zbud's memory usgae is higher
as I mentioned. As well, we lose memory efficieny significantly for zram. :(

IMO, more fundamentatal solution is to support VM-aware compaction of
zsmalloc/zbud rather than hiding a problem with zbud.

Thanks.

> 
> I'll post some numbers in the next patch respin so they won't get lost :)
> 
> ~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
