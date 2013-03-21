Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id E23AD6B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 21:29:44 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id un15so1799522pbc.38
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 18:29:44 -0700 (PDT)
Message-ID: <514A6282.8020406@linaro.org>
Date: Wed, 20 Mar 2013 18:29:38 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Content-Type: multipart/mixed;
 boundary="------------060607070003080607080805"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

This is a multi-part message in MIME format.
--------------060607070003080607080805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 03/12/2013 12:38 AM, Minchan Kim wrote:
> First of all, let's define the term.
>  From now on, I'd like to call it as vrange(a.k.a volatile range)
> for anonymous page. If you have a better name in mind, please suggest.
>
> This version is still *RFC* because it's just quick prototype so
> it doesn't support THP/HugeTLB/KSM and even couldn't build on !x86.
> Before further sorting out issues, I'd like to post current direction
> and discuss it. Of course, I'd like to extend this discussion in
> comming LSF/MM.
>
> In this version, I changed lots of thing, expecially removed vma-based
> approach because it needs write-side lock for mmap_sem, which will drop
> performance in mutli-threaded big SMP system, KOSAKI pointed out.
> And vma-based approach is hard to meet requirement of new system call by
> John Stultz's suggested semantic for consistent purged handling.
> (http://linux-kernel.2935.n7.nabble.com/RFC-v5-0-8-Support-volatile-for-anonymous-range-tt575773.html#none)
>
> I tested this patchset with modified jemalloc allocator which was
> leaded by Jason Evans(jemalloc author) who was interest in this feature
> and was happy to port his allocator to use new system call.
> Super Thanks Jason!
>
> The benchmark for test is ebizzy. It have been used for testing the
> allocator performance so it's good for me. Again, thanks for recommending
> the benchmark, Jason.
> (http://people.freebsd.org/~kris/scaling/ebizzy.html)
>
> The result is good on my machine (12 CPU, 1.2GHz, DRAM 2G)
>
> 	ebizzy -S 20
>
> jemalloc-vanilla: 52389 records/sec
> jemalloc-vrange: 203414 records/sec
>
> 	ebizzy -S 20 with background memory pressure
>
> jemalloc-vanilla: 40746 records/sec
> jemalloc-vrange: 174910 records/sec
>
> And it's much improved on KVM virtual machine.
>
> This patchset is based on v3.9-rc2
>
> - What's the sys_vrange(addr, length, mode, behavior)?
>
>    It's a hint that user deliver to kernel so kernel can *discard*
>    pages in a range anytime. mode is one of VRANGE_VOLATILE and
>    VRANGE_NOVOLATILE. VRANGE_NOVOLATILE is memory pin operation so
>    kernel coudn't discard any pages any more while VRANGE_VOLATILE
>    is memory unpin opeartion so kernel can discard pages in vrange
>    anytime. At a moment, behavior is one of VRANGE_FULL and VRANGE
>    PARTIAL. VRANGE_FULL tell kernel that once kernel decide to
>    discard page in a vrange, please, discard all of pages in a
>    vrange selected by victim vrange. VRANGE_PARTIAL tell kernel
>    that please discard of some pages in a vrange. But now I didn't
>    implemented VRANGE_PARTIAL handling yet.


So I'm very excited to see this new revision! Moving away from the VMA 
based approach I think is really necessary, since managing the volatile 
ranges on a per-mm basis really isn't going to work when we want shared 
volatile ranges between processes (such as the shmem/tmpfs case Android 
uses).

Just a few questions and observations from my initial playing around 
with the patch:

1) So, I'm not sure I understand the benefit of VRANGE_PARTIAL. Why 
would VRANGE_PARTIAL be useful?

2) I've got a trivial test program that I've used previously with ashmem 
& my earlier file based efforts that allocates 26megs of page aligned 
memory, and marks every other meg as volatile. Then it forks and the 
child generates a ton of memory pressure, causing pages to be purged 
(and the child killed by the OOM killer). Initially I didn't see my test 
purging any pages with your patches. The problem of course was the 
child's COW pages were not also marked volatile, so they could not be 
purged. Once I over-wrote the data in the child, breaking the COW links, 
the data in the parent was purged under pressure.  This is good, because 
it makes sure we don't purge cow pages if the volatility state isn't 
consistent, but it also brings up a few questions:

     - Should volatility be inherited on fork? If volatility is not 
inherited on fork(), that could cause some strange behavior if the data 
was purged prior to the fork, and also its not clear what the behavior 
of the child should be with regards to data that was volatile at fork 
time.  However, we also don't want strange behavior on exec if 
overwritten volatile pages were unexpectedly purged.

     - At this moment, maybe not having thought it through enough, I'm 
wondering if it makes sense to have  volatility inherited on fork, but 
cleared on exec? What are your thoughts here?  Its been awhile, so I'm 
not sure if that's consistent with my earlier comments on the topic.


3) Oddly, in my test case, once I changed the child to over-write the 
volatile range and break the COW pages, the OOM killer more frequently 
seems to favor killing the parent process, instead of the memory hogging 
child process. I need to spend some more time looking at this, and I 
know the OOM killer may go for the parent process sometimes, but it 
definitely happens more frequently then when the COW pages are not 
broken and no data is purged. Again, I need to dig in more here.


4) One of the harder aspects I'm trying to get my head around is how 
your patches seem to use both the page list shrinkers (discard_vpage) to 
purge ranges when particular pages selected, and a zone shrinker 
(discard_vrange_pages) which manages its own lru of vranges. I get that 
this is one way to handle purging anonymous pages when we are on a 
swapless system, but the dual purging systems definitely make the code 
harder to follow. Would something like my earlier attempts at changing 
vmscan to shrink anonymous pages be simpler? Or is that just not going 
to fly w/ the mm folks?


I'll continue working with the patches and try to get tmpfs support 
added here soon.

Also, attached is a simple cleanup patch that you might want to fold in.

thanks
-john


--------------060607070003080607080805
Content-Type: text/x-patch;
 name="0001-vrange-Make-various-vrange.c-local-functions-static.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-vrange-Make-various-vrange.c-local-functions-static.pat";
 filename*1="ch"


--------------060607070003080607080805--
