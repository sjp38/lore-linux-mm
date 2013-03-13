Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 8DD226B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 18:59:53 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 08:53:36 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id EDA832BB0052
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 09:59:44 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2DMkwFM7602562
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 09:46:59 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2DMxhfG025697
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 09:59:43 +1100
Message-ID: <514104D5.9020700@linux.vnet.ibm.com>
Date: Wed, 13 Mar 2013 17:59:33 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: zsmalloc limitations and related topics
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default> <20130313151359.GA3130@linux.vnet.ibm.com> <4ab899f6-208c-4d61-833c-d1e5e8b1e761@default>
In-Reply-To: <4ab899f6-208c-4d61-833c-d1e5e8b1e761@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Robert Jennings <rcj@linux.vnet.ibm.com>, minchan@kernel.org, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

On 03/13/2013 03:02 PM, Dan Magenheimer wrote:
>> From: Robert Jennings [mailto:rcj@linux.vnet.ibm.com]
>> Subject: Re: zsmalloc limitations and related topics
> 
> Hi Robert --
> 
> Thanks for the well-considered reply!
>  
>> * Dan Magenheimer (dan.magenheimer@oracle.com) wrote:
>>> Hi all --
>>>
>>> I've been doing some experimentation on zsmalloc in preparation
>>> for my topic proposed for LSFMM13 and have run across some
>>> perplexing limitations.  Those familiar with the intimate details
>>> of zsmalloc might be well aware of these limitations, but they
>>> aren't documented or immediately obvious, so I thought it would
>>> be worthwhile to air them publicly.  I've also included some
>>> measurements from the experimentation and some related thoughts.
>>>
>>> (Some of the terms here are unusual and may be used inconsistently
>>> by different developers so a glossary of definitions of the terms
>>> used here is appended.)
>>>
>>> ZSMALLOC LIMITATIONS
>>>
>>> Zsmalloc is used for two zprojects: zram and the out-of-tree
>>> zswap.  Zsmalloc can achieve high density when "full".  But:
>>>
>>> 1) Zsmalloc has a worst-case density of 0.25 (one zpage per
>>>    four pageframes).
>>
>> The design of the allocator results in a trade-off between best case
>> density and the worst-case which is true for any allocator.  For zsmalloc,
>> the best case density with a 4K page size is 32.0, or 177.0 for a 64K page
>> size, based on storing a set of zero-filled pages compressed by lzo1x-1.
> 
> Right.  Without a "representative workload", we have no idea
> whether either my worst-case or your best-case will be relevant.
> 
> (As an aside, I'm measuring zsize=28 bytes for a zero page...
> Seth has repeatedly said 103 bytes and I think this is
> reflected in your computation above.  Maybe it is 103 for your
> hardware compression engine?  Else, I'm not sure why our
> numbers would be different.)

I rechecked this and found my measurement was flawed.  It was based on
compressing a zero-filled file with lzop -1.  The file size is 107 but,
as I recently discovered, contains LZO metadata as well.  Using lzop -l,
I got that the compressed size of the data (not the file), is 44 bytes.
 So still not what you are observing but closer.

$ dd if=/dev/zero of=zero.page bs=4k count=1
$ lzop -1 zero.page
$ lzop -l zero.page.lzo
method      compressed  uncompr. ratio uncompressed_name
LZO1X-1(15)        44      4096   1.1% zero.page

>  
>>> 2) When not full and especially when nearly-empty _after_
>>>    being full, density may fall below 1.0 as a result of
>>>    fragmentation.
>>
>> True and there are several ways to address this including
>> defragmentation, fewer class sizes in zsmalloc, aging, and/or writeback
>> of zpages in sparse zspages to free pageframes during normal writeback.
> 
> Yes.  And add pageframe-reclaim to this list of things that
> zsmalloc should do but currently cannot do.

The real question is why is pageframe-reclaim a requirement?  What
operation needs this feature?

AFAICT, the pageframe-reclaim requirements is derived from the
assumption that some external control path should be able to tell
zswap/zcache to evacuate a page, like the shrinker interface.  But this
introduces a new and complex problem in designing a policy that doesn't
shrink the zpage pool so aggressively that it is useless.

Unless there is another reason for this functionality I'm missing.

> 
>>> 3) Zsmalloc has a density of exactly 1.0 for any number of
>>>    zpages with zsize >= 0.8.
>>
>> For this reason zswap does not cache pages which in this range.
>> It is not enforced in the allocator because some users may be forced to
>> store these pages; users like zram.
> 
> Again, without a "representative" workload, we don't know whether
> or not it is important to manage pages with zsize >= 0.8.  You are
> simply dismissing it as unnecessary because zsmalloc can't handle
> them and because they don't appear at any measurable frequency
> in kernbench or SPECjbb.  (Zbud _can_ efficiently handle these larger
> pages under many circumstances... but without a "representative" workload,
> we don't know whether or not those circumstances will occur.)

The real question is not whether any workload would operate on pages
that don't compress to 80%.  Any workload that operates on pages of
already compressed or encrypted data would do this.  The question is, is
it worth it to store those pages in the compressed cache since the
effective reclaim efficiency approaches 0.

> 
>>> 4) Zsmalloc contains several compile-time parameters;
>>>    the best value of these parameters may be very workload
>>>    dependent.
>>
>> The parameters fall into two major areas, handle computation and class
>> size.  The handle can be abstracted away, eliminating the compile-time
>> parameters.  The class-size tunable could be changed to a default value
>> with the option for specifying an alternate value from the user during
>> pool creation.
> 
> Perhaps my point here wasn't clear so let me be more blunt:
> There's no way in hell that even a very sophisticated user
> will know how to set these values.  I think we need to
> ensure either that they are "always right" (which without
> a "representative workload"...) or, preferably, have some way
> so that they can dynamically adapt at runtime.

I think you made the point that if this "representative workload" is
completely undefined, then having tunables for zsmalloc that are "always
right" is also not possible.  The best we can hope for is "mostly right"
which, of course, is difficult to get everyone to agree on and will be
based on usage.

> 
>>> If density == 1.0, that means we are paying the overhead of
>>> compression+decompression for no space advantage.  If
>>> density < 1.0, that means using zsmalloc is detrimental,
>>> resulting in worse memory pressure than if it were not used.
>>>
>>> WORKLOAD ANALYSIS
>>>
>>> These limitations emphasize that the workload used to evaluate
>>> zsmalloc is very important.  Benchmarks that measure data
>>> throughput or CPU utilization are of questionable value because
>>> it is the _content_ of the data that is particularly relevant
>>> for compression.  Even more precisely, it is the "entropy"
>>> of the data that is relevant, because the amount of
>>> compressibility in the data is related to the entropy:
>>> I.e. an entirely random pagefull of bits will compress poorly
>>> and a highly-regular pagefull of bits will compress well.
>>> Since the zprojects manage a large number of zpages, both
>>> the mean and distribution of zsize of the workload should
>>> be "representative".
>>>
>>> The workload most widely used to publish results for
>>> the various zprojects is a kernel-compile using "make -jN"
>>> where N is artificially increased to impose memory pressure.
>>> By adding some debug code to zswap, I was able to analyze
>>> this workload and found the following:
>>>
>>> 1) The average page compressed by almost a factor of six
>>>    (mean zsize == 694, stddev == 474)
>>> 2) Almost eleven percent of the pages were zero pages.  A
>>>    zero page compresses to 28 bytes.
>>> 3) On average, 77% of the bytes (3156) in the pages-to-be-
>>>    compressed contained a byte-value of zero.
>>> 4) Despite the above, mean density of zsmalloc was measured at
>>>    3.2 zpages/pageframe, presumably losing nearly half of
>>>    available space to fragmentation.
>>>
>>> I have no clue if these measurements are representative
>>> of a wide range of workloads over the lifetime of a booted
>>> machine, but I am suspicious that they are not.  For example,
>>> the lzo1x compression algorithm claims to compress data by
>>> about a factor of two.
>>
>> I'm suspicious of the "factor of two" claim.  The reference
>> (http://www.oberhumer.com/opensource/lzo/lzodoc.php) for this would appear
>> to be the results of compressing the Calgary Corpus.  This is fine for
>> comparing compression algorithms but I would be hesitant to apply that
>> to this problem space.  To illustrate the affect of input set, the newer
>> Canterbury Corpus compresses to ~43% of the input size using LZO1X-1.
> 
> Yes, agreed, we have no idea if the Corpus is representative of
> this problem space... because we have no idea what would
> be a "representative workload" for this problem space.
> 
> But for how I was using "factor of two", a factor of 100/43=~2.3 is
> close enough.  I was only trying to say "factor of two" may be
> more "representative" than the "factor of six" in kernbench.

Again, this "representative workload" is undefined to the point of
uselessness.  At this point _any_ actual workload is more useful than
this undefined representative.

> 
> (As an aside, I like the data Nitin collected here:
> http://code.google.com/p/compcache/wiki/CompressedLengthDistribution 
> as it shows how different workloads can result in dramatically
> different zsize distributions.  However, this data includes
> all the pages in a running system, including both anonymous
> and file pages, and doesn't include mean/stddev.)
> 
>> In practice the average for LZO would be workload dependent, as you
>> demonstrate with the kernel build.  Swap page entropy for any given
>> workload will not necessarily fit the distribution present in the
>> Calgary Corpus.  The high density allocation design in zsmalloc allows
>> for workloads that can compress to factors greater than 2 to do so.
> 
> Exactly.  But at what cost on other workloads?  And how do we evaluate
> the cost/benefit of that high density? (... without a "representative
> workload" ;-)
> 
>>> I would welcome ideas on how to evaluate workloads for
>>> "representativeness".  Personally I don't believe we should
>>> be making decisions about selecting the "best" algorithms
>>> or merging code without an agreement on workloads.
>>
>> I'd argue that there is no such thing as a "representative workload".
>> Instead, we try different workloads to validate the design and illustrate
>> the performance characteristics and impacts.
> 
> Sorry for repeatedly hammering my point in the above, but
> there have been many design choices driven by what was presumed
> to be representative (kernbench and now SPECjbb) workload
> that may be entirely wrong for a different workload (as
> Seth once pointed out using the text of Moby Dick as a source
> data stream).

The reality we are going to have to face with the feature of memory
compression is that not every workload can benefit.  The objective
should be to improve known workloads that are able to benefit.  Then
make improvements that grow that set of workloads.

> 
> Further, the value of different designs can't be measured here just
> by the workload because the pages chosen to swap may be completely
> independent of the intended workload-driver... i.e. if you track
> the pid of the pages intended for swap, the pages can be mostly
> pages from long-running or periodic system services, not pages
> generated by kernbench or SPECjbb.  So it is the workload PLUS the
> environment that is being measured and evaluated.  That makes
> the problem especially tough.
> 
> Just to clarify, I'm not suggesting that there is any single
> workload that can be called representative, just that we may
> need both a broad set of workloads (not silly benchmarks) AND
> some theoretical analysis to drive design decisions.  And, without
> this, arguing about whether zsmalloc is better than zbud or not
> is silly.  Both zbud and zsmalloc have strengths and weaknesses.
> 
> That said, it should also be pointed out that the stream of
> pages-to-compress from cleancache ("file pages") may be dramatically 
> different than for frontswap ("anonymous pages"), so unless you
> and Seth are going to argue upfront that cleancache pages should
> NEVER be candidates for compression, the evaluation criteria
> to drive design decisions needs to encompass both anonymous
> and file pages.  It is currently impossible to evaluate that
> with zswap.
> 
>>> PAGEFRAME EVACUATION AND RECLAIM
>>>
>>> I've repeatedly stated the opinion that managing the number of
>>> pageframes containing compressed pages will be valuable for
>>> managing MM interaction/policy when compression is used in
>>> the kernel.  After the experimentation above and some brainstorming,
>>> I still do not see an effective method for zsmalloc evacuating and
>>> reclaiming pageframes, because both are complicated by high density
>>> and page-crossing.  In other words, zsmalloc's strengths may
>>> also be its Achilles heels.  For zram, as far as I can see,
>>> pageframe evacuation/reclaim is irrelevant except perhaps
>>> as part of mass defragmentation.  For zcache and zswap, where
>>> writethrough is used, pageframe evacuation/reclaim is very relevant.
>>> (Note: The writeback implemented in zswap does _zpage_ evacuation
>>> without pageframe reclaim.)
>>
>> zswap writeback without guaranteed pageframe reclaim can occur during
>> swap activity.  Reclaim, even if it doesn't free a physical page, makes
>> room in the page for incoming swap.  With zswap the writeback mechanism
>> is driven by swap activity, so a zpage freed through writeback can be
>> back-filled by a newly compressed zpage.  Fragmentation is an issue when
>> processes exit and block zpages are invalidated and becomes an issue when
>> zswap is idle.  Otherwise the holes provide elasticity to accommodate
>> incoming pages to zswap.  This is the case for both zswap and zcache.
>>
>> At idle we would want defragmentation or aging, either of which has
>> the end result of shrinking the cache and returning pages to the
>> memory manager.  The former only reduces fragmentation while the
>> later has the additional benefit of returning memory for other uses.
>> By adding aging, through periodic writeback, zswap becomes a true cache,
>> it eliminates long-held allocations, and addresses fragmentation for
>> long-held allocations.
> 
> We are definitely on different pages here.  You are still trying to
> push zswap as a separate subsystem that can independently decide how
> to size itself.  I see zcache (and zswap) as a "helper" for the MM
> subsystem which allow MM to store more anonymous/pagecache pages in
> memory than otherwise possible.

IIUC from this and your "Better integration of compression with the
broader linux-mm" thread, you are wanting to allow the MM to tell a
compressed-MM subsystem to free up pages.  There are a few problems I
see here, mostly policy related.  How does the MM know whether is should
reclaim compressed page space or pages from the inactive list?  In the
case of frontswap, the policies feedback on one another in that the
reclaim of an anonymous page from the inactive list via swap results in
an increase in the number of pages on the anonymous zspage list.

I'm not saying I have the solution.  The ideal sizing of the compressed
pool is a complex issue and, like so many other elements of compressed
memory design, depends on the workload.

That being said, just because an ideal policy for every workload doesn't
exist doesn't mean you can't choose one policy (hopefully a simple one)
and improve it as measurable deficiencies are identified.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
