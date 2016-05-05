Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 493886B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 11:54:32 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id e35so134210499qge.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 08:54:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b2si6392815qka.220.2016.05.05.08.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 08:54:31 -0700 (PDT)
Subject: Re: [dm-devel] [4.4, 4.5, 4.6] Regression: encrypted swap (dm-crypt)
 freezes system while under memory pressure and swapping
References: <8125260b-30b0-e80d-c451-8194e6866227@binary-island.eu>
From: Ondrej Kozina <okozina@redhat.com>
Message-ID: <572B6CB3.10802@redhat.com>
Date: Thu, 5 May 2016 17:54:27 +0200
MIME-Version: 1.0
In-Reply-To: <8125260b-30b0-e80d-c451-8194e6866227@binary-island.eu>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dm-devel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthias Dahl <ml_linux-dm-devel@binary-island.eu>, rientjes@google.com

On 04/21/2016 09:48 AM, Matthias Dahl wrote:
> Hello @all,
>
> first of all, I sent this exact msg also to the lkml a few days ago but
> since I received no reaction, I thought this list might be a better
> place for this problem -- or I might at least reach the right persons to
> get this fixed/debugged/... . :-)
>
> Recently I started seeing freezes while compiling bigger packages that
> do require lots of memory (I use Gentoo).
>
> The freezes where in the form that while in Xorg, the system would just
> completely hang -- no magic sysrq keys, no mouse movement, nothing.
> While in a terminal, one could still issue a magic sysrq command but it
> would only echo the command itself but not execute it -- except for the
> reboot command. So there was no way to get a backtrace or states or
> anything alike.
>
> After debugging this further, it became clear that the system always
> froze when it started hitting the encrypted swap. It worked absolutely
> fine as soon as you took the encryption out of the picture.
>
> My setup then was: A 8 GiB swap on S/W-RAID5 for my 8 GiB physical ram
> that was encrypted with dm-crypt and AES256-CBC-ESSIV.
>
> I debugged this further and changed my setup to several swap partitions
> on the physical disks w/o a RAID in-between to isolate the culprit. This
> made no difference -- neither did switching ciphers and so forth.
>
> Since this setup had worked for ages, I started looking into what had
> changed the weeks before and noticed I had done several kernel upgrades.
>
> To make a long story short, here my findings:
>
> 4.3.0, 4.4.0-final, 4.5-rc1 to 4.5-rc2:
> No problems, except for the usual sluggishness with encrypted swap that
> has been there since forever (it is like the encryption has the highest
> priority and takes over the system, e.g. no terminal input is accepted
> on a different terminal while high memory pressure is going on which is
> in contrast with the encrypted swap, where this still works fine).
>
> 4.4.x, >= 4.5-rc3 (incl. 4.6-rcX and master):
> The system freezes under memory pressure as soon as it starts swapping
> out. 4.6 master is an exception here, it still responds to magic sysrq
> commands properly but after some time though completely freezes hard.
>
> I hadn't had the time to test all 4.3.x and 4.4.x releases, I am afraid.
> What I can say though is that 4.4.6 is affected as well.
>
> A git bisect between 4.5-rc2 and 4.5-rc3, lead me to the following commit:
>
> 564e81a57f9788b1475127012e0fd44e9049e342 is the first bad commit
> commit 564e81a57f9788b1475127012e0fd44e9049e342
> Author: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Date:   Fri Feb 5 15:36:30 2016 -0800
>
>      mm, vmstat: fix wrong WQ sleep when memory reclaim doesn't make any
> progress
>
> This is obviously not the real culprit in my opinion but a trigger.
> Reverting that commit on 4.5.1 for example, makes the encrypted swap
> work flawlessly again (except for the usual system sluggishness).
>
> Reverting it on 4.6 master@c3b46c73264b03000d1e18b22f5caf63332547c9,
> does show a different picture though: The system freezes while the sysrq
> keys do still work and usually recovers after some while if the
> corresponding task that triggered the swapping in the first place, gets
> killed. It sometimes does a bit of swapping, and sometimes don't while
> it hangs there -- while usually with the other kernels in the "frozen"
> state, the swapping stops completely.
>
> I managed to get a bit more information out of 4.6 master though since
> it sometimes recovers after quite some time and I can copy backtraces
> and such to the disk, which I have attached.
>
> I hope this helps in finding the real issue behind this. I am sorry I
> could not provide more information but this has been a rather time
> consuming task thus far. :-)
>
> If there is anything else I can do to help or test, please let me know
> and I will gladly do so.
>
> Thanks in advance.
>
> So long,
> Matthias
>

Hello,

I second the observation that something is wrong and it doesn't seem to 
be related to dm-crypt target. My test setup is as follows:

2 CPUs
system ram: 1 GB
swap on top of dm-crypt: 2 GB

Whenever I start workload that consumes more memory than system ram but 
much less than total memory including the swap I end with following OOM 
message that I found to be premature and unexpected:
- 
https://okozina.fedorapeople.org/bugs/swap_on_dmcrypt/vmlog-1462458369-00000/sample-00011/dmesg

the important snippet in-before the oom:

active_anon:4096kB inactive_anon:4636kB, writeback:4636kB

and also:

Free swap  = 2039832kB
Total swap = 2097148kB

you can find more details in sample-* directories located in:
https://okozina.fedorapeople.org/bugs/swap_on_dmcrypt/vmlog-1462458369-00000/

each sample directory contains stats collection taken approximately each 
second after I started the workload (it's a script from 
http://linux-mm.org/OOM site).

For me OOM killer message can be observed starting with this commit:
commit f9054c70d28bc214b2857cf8db8269f4f45a5e23
Author: David Rientjes <rientjes@google.com>
Date:   Thu Mar 17 14:19:19 2016 -0700

     mm, mempool: only set __GFP_NOMEMALLOC if there are free elements

(...)

Kind regards
Ondrej

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
