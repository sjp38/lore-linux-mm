Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 067A26B0095
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 13:16:40 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MK800FZW7ZRAQA0@mailout3.samsung.com> for
 linux-mm@kvack.org; Tue, 26 Mar 2013 02:16:39 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
Date: Mon, 25 Mar 2013 18:16:16 +0100
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
In-reply-to: <1363073915-25000-1-git-send-email-minchan@kernel.org>
MIME-version: 1.0
Message-id: <201303251816.16715.b.zolnierkie@samsung.com>
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>


Hi,

On Tuesday 12 March 2013 08:38:24 Minchan Kim wrote:
> First of all, let's define the term.
> From now on, I'd like to call it as vrange(a.k.a volatile range)
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

Could you please make the modified jemalloc/ebizzy available somewhere so
there is a easy way to test your patchset?

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
