Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 43EBC900146
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 02:47:52 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by uplift.swm.pp.se (Postfix) with ESMTP id 862419A
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 08:47:48 +0200 (CEST)
Date: Sat, 3 Sep 2011 08:47:48 +0200 (CEST)
From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: copying files stops after a while in laptop mode on 2.6.38
In-Reply-To: <alpine.DEB.2.00.1108230822480.4709@uplift.swm.pp.se>
Message-ID: <alpine.DEB.2.00.1109030822110.13538@uplift.swm.pp.se>
References: <alpine.DEB.2.00.1108230822480.4709@uplift.swm.pp.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Tue, 23 Aug 2011, Mikael Abrahamsson wrote:

> I'm running ubuntu 11.04 on my thinkpad X200 laptop with their 2.6.38 kernel. 
> Whenever I copy a lot of data to my harddrive without the power connected 
> (cryptsetup:ed drive and ubuntus eCryptfs for home directory (yeah I know, 
> that's two levels of encryption))) the copy stops after 500-1000 megabyte. 
> It'll just sit there, nothing more happening, my firefox goes into blocking 
> (greys out). If I then issue a "sync" command in the terminal, things resume 
> just as normal, until another 500-1000 megabyte has been copied. This doesn't 
> happen if I have the power cable connected.
>
> I interpret this as when the laptop is in laptop-mode, it doesn't flush data 
> to drive when memory is "full". Is this a known problem with 2.6.38 kernel, 
> or might it be something ubuntu specific? I find it strange that not more 
> people are hit by this...

When doing backups to an external USB drive with dmcrypt->lwm->xfs I saw 
the same problem just now. I have to keep a "watch -n 60 sync" running to 
keep the copy (and the computer) working properly.

$ uname -a
Linux laptop 2.6.38-11-generic-pae #49-Ubuntu SMP Mon Aug 29 21:07:33 UTC 2011 i686 i686 i386 GNU/Linux

~$ ps -eo 
user,pid,tid,class,rtprio,ni,pri,psr,pcpu,vsz,rss,pmem,stat,wchan:28,cmd | grep firefox
swmike    3541  3541 TS       -   0  19   1 11.1 664868 238764  5.9 Sl  futex_wait_queue_me          /usr/lib/firefox-6.0.1/firefox-bin
swmike    3733  3733 TS       -   0  19   0  0.1 106320 17920  0.4 Sl   poll_schedule_timeout        /usr/lib/firefox-6.0.1/plugin-container /usr/lib/flashplugin-installer/libflashplayer.so -greomni /usr/lib/firefox-6.0.1/omni.jar 3541 true plugin

$ ps -eo 
user,pid,tid,class,rtprio,ni,pri,psr,pcpu,vsz,rss,pmem,stat,wchan:28,cmd | grep ddrescue
root      3380  3380 TS       -   0  19   0  0.0   5492  1136  0.0 S+   poll_schedule_timeout        sudo ddrescue /dev/sdd /t/win7stationar.110903.img
root      3381  3381 TS       -   0  19   0  4.6   3104   760  0.0 D+   sync_page                    ddrescue /dev/sdd /t/win7stationar.110903.img

$ free
              total       used       free     shared    buffers     cached
Mem:       4012036    3996012      16024          0     660936    2657452
-/+ buffers/cache:     677624    3334412
Swap:            0          0          0

The copy is still running (I think ddrescue does more than dd, with dd it 
would be blocked as well). Firefox is blocked (and has been for a few 
minutes).

I then issue "sync", flushing commences, and firefox comes back:

~$ ps -eo 
user,pid,tid,class,rtprio,ni,pri,psr,pcpu,vsz,rss,pmem,stat,wchan:28,cmd | grep firefox
swmike    3541  3541 TS       -   0  19   0 10.7 673316 239816  5.9 Sl  poll_schedule_timeout        /usr/lib/firefox-6.0.1/firefox-bin
swmike    3733  3733 TS       -   0  19   0  0.1 106320 17900  0.4 Sl   poll_schedule_timeout        /usr/lib/firefox-6.0.1/plugin-container /usr/lib/flashplugin-installer/libflashplayer.so -greomni /usr/lib/firefox-6.0.1/omni.jar 3541 true plugin

I wait 30-60 seconds, firefox goes into blocking again, same remedy, same 
behaviour.

Any other diagnosis I can do to help narrow down what's going on?

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
