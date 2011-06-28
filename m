Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D22B89000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 22:06:45 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 19CE43EE0B5
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 11:06:42 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F3C2445DEA0
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 11:06:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA90145DE7E
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 11:06:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB6991DB803B
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 11:06:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 97CCD1DB8038
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 11:06:41 +0900 (JST)
Message-ID: <4E093725.7010002@jp.fujitsu.com>
Date: Tue, 28 Jun 2011 11:06:29 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUG] Invalid return address of mmap() followed by mbind() in
 multithreaded context
References: <4DFB710D.7000902@cslab.ece.ntua.gr> <20110627171842.GA7554@solar.cslab.ece.ntua.gr>
In-Reply-To: <20110627171842.GA7554@solar.cslab.ece.ntua.gr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kkourt@cslab.ece.ntua.gr
Cc: bkk@cslab.ece.ntua.gr, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org

(2011/06/28 2:18), Kornilios Kourtis wrote:
> 
> Hi,
> 
> On Fri, Jun 17, 2011 at 06:21:49PM +0300, Vasileios Karakasis wrote:
>> Hi,
>>
>> I am implementing a multithreaded numa aware code where each thread
>> mmap()'s an anonymous private region and then mbind()'s it to its local
>> node. The threads are performing a series of such mmap() + mbind()
>> operations. My program crashed with SIGSEGV and I noticed that mmap()
>> returned an invalid address.
> 
> I've taken a closer look at this issue.
> 
> As Vasileios said, it can be reproduced by having two threads doing the
> following loop:
> | for {
> | 	addr = mmap(4096, MAP_ANONUMOUS)
> | 	if (addr == (void *)-1)
> | 		continue
> | 	mbind(addr, 4096, 0x1) // do mbind on first NUMA node
> | }
> After a couple of iterations, mbind() will return EFAULT, although the addr is
> valid.
> 
> Doing a bisect, pins it down to the following commit (Author added to To:):
> 	9d8cebd4bcd7c3878462fdfda34bbcdeb4df7ef4
> 	mm: fix mbind vma merge problem
> Which adds merging of vmas in the mbind() path.
> Reverting this commit, seems to fix the issue.
> 
> I 've added some printks to track down the issue, and EFAULT is returned on:
> mm/mempolicy.c: mbind_range()
> |   vma = find_vma_prev(mm. start, &prev);
> |   if (!vma |vma->vm_start > start)
> |       return EFAULT;
> Where: vma->start > start
> 
> I am not sure what exactly happens, but concurrent merges and splits
> of (already mapped) VMAs do not seem to work well together.

Hi

Thank you for digging this! I look it at soon as far as possible.

 - kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
