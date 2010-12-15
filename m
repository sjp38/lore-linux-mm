Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 813ED6B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 19:27:21 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBF0RJit003779
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 15 Dec 2010 09:27:19 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B1D045DE64
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:27:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E6D845DE63
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:27:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CCAAE08002
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:27:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EB6891DB803B
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:27:18 +0900 (JST)
Date: Wed, 15 Dec 2010 09:21:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: PROBLEM: __offline_isolated_pages may offline too many pages
Message-Id: <20101215092134.e2c8849f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4D0786D3.7070007@akana.de>
References: <4D0786D3.7070007@akana.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Korb <ingo@akana.de>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, cl@linux-foundation.org, yinghai@kernel.org, andi.kleen@intel.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2010 16:01:39 +0100
Ingo Korb <ingo@akana.de> wrote:

> Hi!
> 
> [1.] One line summary of the problem:
> __offline_isolated_pages may isolate too many pages
> 
> [2.] Full description of the problem/report:
> While experimenting with remove_memory/online_pages, removing as few 
> pages as possible (pageblock_nr_pages, 512 on my box) I noticed that the 
> number of pages marked "reserved" increased even though both functions 
> did not indicate an error. Following the code it was clear that 
> __offline_isolated_pages marked twice as many pages as it should:
> 

It's designed for offline memory section > MAX_ORDER. pageblock_nr_pages
is tend to be smaller than that.

Do you see the problem with _exsisting_ user interface of memory hotplug ?
I think we have no control other than memory section.

> === start paste (from dmesg) ===
> Offlined Pages 512
> remove from free list c00 1024 e00
> === end paste ===
> 
> The issue seems to be that __offline_isolated_pages blindly uses 
> page_order() to determine how many pages it should mark as reserved in 
> the current loop iteration, without checking if this would exceed the 
> limit set by end_pfn.
> 

It's because designed to work under memory section, it's aligned to MAX_ORDER.
Its blindness works correctly.


> I'm not sure what the correct way to fix this would be - is memory 
> isolation supposed to touch the order of a page if it crosses the end 
> (or beginning!) of the range of pages to be isolated?
> 

Nothing to be fixed. If you _need_ another functionality, please add a new
feature. But, in theory, memory offline doesn't work in the range smaller
than MAX_ORDER because of buddy allocator.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
