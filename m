Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4FC5B6B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 00:57:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S4vrqx011094
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Oct 2009 13:57:54 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 795C745DE4F
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:57:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D14745DD70
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:57:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 357F3E38002
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:57:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C64DE1DB803E
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:57:49 +0900 (JST)
Date: Wed, 28 Oct 2009 13:55:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org>
	<20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>
	<hb2cfu$r08$2@ger.gmane.org>
	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	<4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910271843510.11372@sister.anvils>
	<alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com>
	<4AE78B8F.9050201@gmail.com>
	<alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com>
	<4AE792B8.5020806@gmail.com>
	<alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009 21:08:56 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 28 Oct 2009, Vedran Furac wrote:
> 
> > > This is wrong; it doesn't "emulate oom" since oom_kill_process() always 
> > > kills a child of the selected process instead if they do not share the 
> > > same memory.  The chosen task in that case is untouched.
> > 
> > OK, I stand corrected then. Thanks! But, while testing this I lost X
> > once again and "test" survived for some time (check the timestamps):
> > 
> > http://pastebin.com/d5c9d026e
> > 
> > - It started by killing gkrellm(!!!)
> > - Then I lost X (kdeinit4 I guess)
> > - Then 103 seconds after the killing started, it killed "test" - the
> > real culprit.
> > 
> > I mean... how?!
> > 
> 
> Here are the five oom kills that occurred in your log, and notice that the 
> first four times it kills a child and not the actual task as I explained:
> 
> [97137.724971] Out of memory: kill process 21485 (VBoxSVC) score 1564940 or a child
> [97137.725017] Killed process 21503 (VirtualBox)
> [97137.864622] Out of memory: kill process 11141 (kdeinit4) score 1196178 or a child
> [97137.864656] Killed process 11142 (klauncher)
> [97137.888146] Out of memory: kill process 11141 (kdeinit4) score 1184308 or a child
> [97137.888180] Killed process 11151 (ksmserver)
> [97137.972875] Out of memory: kill process 11141 (kdeinit4) score 1146255 or a child
> [97137.972888] Killed process 11224 (audacious2)
> 
> Those are practically happening simultaneously with very little memory 
> being available between each oom kill.  Only later is "test" killed:
> 
> [97240.203228] Out of memory: kill process 5005 (test) score 256912 or a child
> [97240.206832] Killed process 5005 (test)
> 
> Notice how the badness score is less than 1/4th of the others.  So while 
> you may find it to be hogging a lot of memory, there were others that 
> consumed much more.

not related to child-parent problem.

Seeing this number more.
==
[97137.709272] Active_anon:671487 active_file:82 inactive_anon:132316
[97137.709273]  inactive_file:82 unevictable:50 dirty:0 writeback:0 unstable:0
[97137.709273]  free:6122 slab:17179 mapped:30661 pagetables:8052 bounce:0
==

acitve_file + inactive_file is very low. Almost all pages are for anon.
But "mapped(NR_FILE_MAPPED)" is a little high. This implies remaining file caches
are mapped by many processes OR some mega bytes of shmem is used.

# of pagetables is 8052, this means
  8052x4096/8*4k bytes = 16Gbytes of mapped area.

Total available memory is near to be active/inactive + slab 
671487+82+132316+82+50+6122+17179+8052=835370x4k= 3.2Gbytes ?
(this system is swapless)

Then, considering the pmap kosaki shows,
I guess killed ones had big total_vm but has not much real rss,
and no helps for oom.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
