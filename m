Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 761036B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 00:09:03 -0400 (EDT)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id n9S490Ao027306
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 21:09:00 -0700
Received: from pwi11 (pwi11.prod.google.com [10.241.219.11])
	by zps75.corp.google.com with ESMTP id n9S48v7S029674
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 21:08:57 -0700
Received: by pwi11 with SMTP id 11so585205pwi.24
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 21:08:57 -0700 (PDT)
Date: Tue, 27 Oct 2009 21:08:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <4AE792B8.5020806@gmail.com>
Message-ID: <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
 <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com>
 <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009, Vedran Furac wrote:

> > This is wrong; it doesn't "emulate oom" since oom_kill_process() always 
> > kills a child of the selected process instead if they do not share the 
> > same memory.  The chosen task in that case is untouched.
> 
> OK, I stand corrected then. Thanks! But, while testing this I lost X
> once again and "test" survived for some time (check the timestamps):
> 
> http://pastebin.com/d5c9d026e
> 
> - It started by killing gkrellm(!!!)
> - Then I lost X (kdeinit4 I guess)
> - Then 103 seconds after the killing started, it killed "test" - the
> real culprit.
> 
> I mean... how?!
> 

Here are the five oom kills that occurred in your log, and notice that the 
first four times it kills a child and not the actual task as I explained:

[97137.724971] Out of memory: kill process 21485 (VBoxSVC) score 1564940 or a child
[97137.725017] Killed process 21503 (VirtualBox)
[97137.864622] Out of memory: kill process 11141 (kdeinit4) score 1196178 or a child
[97137.864656] Killed process 11142 (klauncher)
[97137.888146] Out of memory: kill process 11141 (kdeinit4) score 1184308 or a child
[97137.888180] Killed process 11151 (ksmserver)
[97137.972875] Out of memory: kill process 11141 (kdeinit4) score 1146255 or a child
[97137.972888] Killed process 11224 (audacious2)

Those are practically happening simultaneously with very little memory 
being available between each oom kill.  Only later is "test" killed:

[97240.203228] Out of memory: kill process 5005 (test) score 256912 or a child
[97240.206832] Killed process 5005 (test)

Notice how the badness score is less than 1/4th of the others.  So while 
you may find it to be hogging a lot of memory, there were others that 
consumed much more.

You can get a more detailed understanding of this by doing

	echo 1 > /proc/sys/vm/oom_dump_tasks

before trying your testcase; it will show various information like the 
total_vm and oom_adj value for each task at the time of oom (and the 
actual badness score is exported per-task via /proc/pid/oom_score in 
real-time).  This will also include the rss and show what the end result 
would be in using that value as part of the heuristic on this particular 
workload compared to the current implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
