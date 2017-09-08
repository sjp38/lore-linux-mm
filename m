Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 663FA6B0329
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 03:11:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v82so3674275pgb.5
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 00:11:20 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e8si1074929pgq.168.2017.09.08.00.11.18
        for <linux-mm@kvack.org>;
        Fri, 08 Sep 2017 00:11:19 -0700 (PDT)
Subject: Re: Re: [PATCH] mm/vmstats: add counters for the page frag cache
References: <1504222631-2635-1-git-send-email-kyeongdon.kim@lge.com>
 <d6120888-344a-4449-4ca6-ac98508bb3cf@yandex-team.ru>
From: Kyeongdon Kim <kyeongdon.kim@lge.com>
Message-ID: <a0bf4c5f-3fe6-08c4-a5c4-3be026213f58@lge.com>
Date: Fri, 8 Sep 2017 16:11:15 +0900
MIME-Version: 1.0
In-Reply-To: <d6120888-344a-4449-4ca6-ac98508bb3cf@yandex-team.ru>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, akpm@linux-foundation.org, sfr@canb.auug.org.au
Cc: ying.huang@intel.com, vbabka@suse.cz, hannes@cmpxchg.org, xieyisheng1@huawei.com, luto@kernel.org, shli@fb.com, mhocko@suse.com, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, kemi.wang@intel.com, rientjes@google.com, bigeasy@linutronix.de, iamjoonsoo.kim@lge.com, bongkyu.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev <netdev@vger.kernel.org>

On 2017-09-04 i??i?? 5:30, Konstantin Khlebnikov wrote:
> On 04.09.2017 04:35, Kyeongdon Kim wrote:
> > Thanks for your reply,
> > But I couldn't find "NR_FRAGMENT_PAGES" in linux-next.git .. is that 
> vmstat counter? or others?
> >
>
> I mean rather than adding bunch vmstat counters for operations it 
> might be
> worth to add page counter which will show current amount of these pages.
> But this seems too low-level for tracking, common counters for all 
> network
> buffers would be more useful but much harder to implement.
>
Ok, thanks for the comment.
> As I can see page owner is able to save stacktrace where allocation 
> happened,
> this makes debugging mostly trivial without any counters. If it adds 
> too much
> overhead - just track random 1% of pages, should be enough for finding 
> leak.
>
As I said, we already used page owner tools to resolve the leak issue.
But that's extremely difficult to figure it out,
too much callstack and too much allocation orders(0 or more).
We couldn't easily get a clue event if we track 1% of pages..

In fact, I was writing another email to send a new patch with debug config.
We added a hash function to pick out address with callstack by using 
debugfs,
It could be showing the only page_frag_cache leak with owner.

for exmaple code :
+++ /mm/page_alloc.c
@@ -4371,7 +4371,9 @@ void *page_frag_alloc(struct page_frag_cache *nc,

 A A A A A A A  nc->pagecnt_bias--;
 A A A A A A A  nc->offset = offset;
+#ifdef CONFIG_PGFRAG_DEBUG
+A A A A A A  page_frag_debug_alloc(nc->va + offset);
+#endif
 A A A A A A A  return nc->va + offset;
 A }
 A EXPORT_SYMBOL(page_frag_alloc);
@@ -4382,7 +4384,9 @@ EXPORT_SYMBOL(page_frag_alloc);
 A void page_frag_free(void *addr)
 A {
 A A A A A A A  struct page *page = virt_to_head_page(addr);
+#ifdef CONFIG_PGFRAG_DEBUG
+A A A A A A  page_frag_debug_free(addr);
+#endif
 A A A A A A A  if (unlikely(put_page_testzero(page)))

Those counters that I added may be too much for the linux server or 
something.
However, I think the other systems may need to simple debugging method.
(like Android OS)

So if you can accept the patch with debug feature,
I will send it including counters.
but still thinking those counters don't need. I won't.

Anyway, I'm grateful for your feedback, means a lot to me.

Thanks,
Kyeongdon Kim
> > As you know, page_frag_alloc() directly calls 
> __alloc_pages_nodemask() function,
> > so that makes too difficult to see memory usage in real time even 
> though we have "/meminfo or /slabinfo.." information.
> > If there was a way already to figure out the memory leakage from 
> page_frag_cache in mainline, I agree your opinion
> > but I think we don't have it now.
> >
> > If those counters too much in my patch,
> > I can say two values (pgfrag_alloc and pgfrag_free) are enough to 
> guess what will happen
> > and would remove pgfrag_alloc_calls and pgfrag_free_calls.
> >
> > Thanks,
> > Kyeongdon Kim
> >
>
> >> IMHO that's too much counters.
> >> Per-node NR_FRAGMENT_PAGES should be enough for guessing what's 
> going on.
> >> Perf probes provides enough features for furhter debugging.
> >>
> >> On 01.09.2017 02:37, Kyeongdon Kim wrote:
> >> > There was a memory leak problem when we did stressful test
> >> > on Android device.
> >> > The root cause of this was from page_frag_cache alloc
> >> > and it was very hard to find out.
> >> >
> >> > We add to count the page frag allocation and free with function 
> call.
> >> > The gap between pgfrag_alloc and pgfrag_free is good to to calculate
> >> > for the amount of page.
> >> > The gap between pgfrag_alloc_calls and pgfrag_free_calls is for
> >> > sub-indicator.
> >> > They can see trends of memory usage during the test.
> >> > Without it, it's difficult to check page frag usage so I believe we
> >> > should add it.
> >> >
> >> > Signed-off-by: Kyeongdon Kim <kyeongdon.kim@lge.com>
> >> > ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
