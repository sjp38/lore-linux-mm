Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A56416B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 01:35:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S5ZWRI006610
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 28 Apr 2009 14:35:32 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3891F45DE67
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 14:35:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 333CD45DE62
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 14:35:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F2D7FE38005
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 14:35:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8323A1DB8038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 14:35:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Swappiness vs. mmap() and interactive response
In-Reply-To: <20090428044426.GA5035@eskimo.com>
References: <20090428044426.GA5035@eskimo.com>
Message-Id: <20090428143019.EBBF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 14:35:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Elladan <elladan@eskimo.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

(cc to linux-mm and Rik)


> Hi,
> 
> So, I just set up Ubuntu Jaunty (using Linux 2.6.28) on a quad core phenom box,
> and then I did the following (with XFS over LVM):
> 
> mv /500gig/of/data/on/disk/one /disk/two
> 
> This quickly caused the system to. grind.. to... a.... complete..... halt.
> Basically every UI operation, including the mouse in Xorg, started experiencing
> multiple second lag and delays.  This made the system essentially unusable --
> for example, just flipping to the window where the "mv" command was running
> took 10 seconds on more than one occasion.  Basically a "click and get coffee"
> interface.

I have some question and request.

1. please post your /proc/meminfo
2. Do above copy make tons swap-out? IOW your disk read much faster than write?
3. cache limitation of memcgroup solve this problem?
4. Which disk have your /bin and /usr/bin?



> 
> There was no particular kernel CPU load -- the SATA DMA seemed fine.
> 
> If I actively used the GUI, then the pieces I was using would work better, but
> they'd start experiencing astonishing latency again if I just let the UI sit
> for a little while.  From this, I diagnosed that the problem was probably
> related to the VM paging out my GUI.
> 
> Next, I set the following:
> 
> echo 0 > /proc/sys/vm/swappiness
> 
> ... hoping it would prevent paging out of the UI in favor of file data that's
> only used once.  It did appear to help to a small degree, but not much.  The
> system is still effectively unusable while a file copy is going on.
> 
> From this, I diagnosed that most likely, the kernel was paging out all my
> application file mmap() data (such as my executables and shared libraries) in
> favor of total garbage VM load from the file copy.
> 
> I don't know how to verify that this is true definitively.  Are there some
> magic numbers in /proc I can look at?  However, I did run latencytop, and it
> showed massive 2000+ msec latency in the page fault handler, as well as in
> various operations such as XFS read.  
> 
> Could this be something else?  There were some long delays in latencytop from
> various apps doing fsync as well, but it seems unlikely that this would destroy
> latency in Xorg, and again, latency improved whenever I touched an app, for
> that app.
> 
> Is there any way to fix this, short of rewriting the VM myself?  For example,
> is there some way I could convince this VM that pages with active mappings are
> valuable?
> 
> Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
