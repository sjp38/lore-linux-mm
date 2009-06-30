Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9638E6B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 05:56:41 -0400 (EDT)
Date: Tue, 30 Jun 2009 11:58:19 +0200
From: Attila Kinali <attila@kinali.ch>
Subject: Long lasting MM bug when swap is smaller than RAM
Message-Id: <20090630115819.38b40ba4.attila@kinali.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Moin,

There has been a bug back in the 2.4.17 days that is somehow
triggered by swap being smaller than RAM, which i thought had
been fixed long ago, reappeared on one of the machines i manage.

<history>
Back in 2002, i had a few machines, running 2.4.x kernels, which
i upgraded heavily from some 16-64MB RAM to a couple 100MB
(changing mainboards at times, but keeping the harddisks).
Due to the upgrade of RAM, the swap size became a lot smaller
than RAM size, sometimes not even half as much.
Under most conditions these machines worked fine, but sometimes,
they showed a strange behavior: At times, the swap use would grow
(depending on the machine and its use faster or slower, sometimes
at 1MB/minute) until it was full. I couldnt figure out what filled
swap back then, couldnt find any programm that used a lot of memory.
And even more, the RAM portion that was used as cache and buffers
was most times still very large, ie it didnt seem like something using
a lot of memory.
After swap was full, nothing happend. No programms crashing, no errors
in the logs, nothing.... Until later (between hours and a few weeks),
the OOM would suddenly start to kick in and kill applications. This
time, something would use a lot of memory, but i couldn't figure out
what. None of the applications running would use more than usual.
And even killing the usual culprits (Mozilla, X11,...) wouldnt help.
The only cure was to reboot.

All the machines back then were running Debian, a vanilla kernel,
and had more RAM than swap and were x86 boxes. Other than that,
they didnt had much in common. One was a machine with an Adaptec
2940UW, others had IDE, one had a K6-III CPU, others were Intel.
Some had a lot of disk, others very little. Machine usage was
fileserver, firewall/router, desktop, laptop.

I reported this bug back then but never got an answer, so i used
the only fix i had available back then: disable swap completely.
</history>

Now, 7 years later, i have a machine that shows the same behavior.

Some data:

We have a HP DL380 G4 currently running a 2.6.29.4 vanilla kernel,
compiled for x86 32 bit.
It was originaly purchased in 2005 with 2GB RAM and a few weeks
ago upgraded to 6GB (no other changes beside this and a kernel upgrade).
The machine, being the MPlayer main server, runs a lighttpd, svnserve,
mailman, postfix, bind. Ie nothing unusual and the applications didn't
change in the last months (since the update from debian/etch to lenny).

---
root@natsuki:/home/attila# uname -a
Linux natsuki 2.6.29.4 #1 SMP Sun May 31 22:13:21 CEST 2009 i686 GNU/Linux
root@natsuki:/home/attila# uptime
 11:41:07 up 29 days, 13:17,  5 users,  load average: 0.15, 0.36, 0.54
root@natsuki:/home/attila# free -m
             total       used       free     shared    buffers     cached
Mem:          6023       5919        103          0        415       3873
-/+ buffers/cache:       1630       4393
Swap:         3812        879       2932
---

I want to point your attention at the fact that the machine has now
more RAM installed than it previously had RAM+Swap (ie before the upgrade).
Ie there is no reason it would need to swap out, at least not so much.

What is even more interesting is the amount of swap used over time.
Sampled every day at 10:00 CEST:

---
Date: Wed, 17 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5893        130          0        405       3834
Swap:         3812        190       3622

Date: Thu, 18 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5793        229          0        340       3939
Swap:         3812        225       3586

Date: Fri, 19 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5820        203          0        341       3899
Swap:         3812        275       3536

Date: Sun, 21 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5264        758          0        459       3181
Swap:         3812        325       3486

Date: Sat, 20 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5761        262          0        348       3865
Swap:         3812        297       3514

Date: Mon, 22 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5875        147          0        397       3681
Swap:         3812        353       3458

Date: Tue, 23 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5748        275          0        193       3949
Swap:         3812        415       3396

Date: Wed, 24 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5779        244          0        176       3924
Swap:         3812        519       3292

Date: Thu, 25 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5812        210          0        345       3856
Swap:         3812        611       3200

Date: Fri, 26 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5830        192          0        431       3688
Swap:         3812        682       3129

Date: Sat, 27 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5697        326          0        442       3621
Swap:         3812        719       3093

Date: Sun, 28 Jun 2009 10:00:02 +0200 (CEST)
Mem:          6023       5890        132          0        402       3886
Swap:         3812        784       3028

Date: Mon, 29 Jun 2009 10:00:01 +0200 (CEST)
Mem:          6023       5388        635          0        425       3321
Swap:         3812        826       2985
---

As you can see, although memory usage didnt change much over time,
swap usage increased from 190MB to 826MB in about two weeks.

As i'm pretty much clueless when it commes to how the linux VM works,
i would appreciate it if someone could give me some pointers on how
to figure out what causes this bug so that it could be fixed finally.

Thanks a lot in advance

			Attila Kinali

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
