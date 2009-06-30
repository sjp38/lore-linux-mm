Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 642316B0055
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 13:57:02 -0400 (EDT)
Date: Tue, 30 Jun 2009 18:58:29 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Long lasting MM bug when swap is smaller than RAM
In-Reply-To: <20090630115819.38b40ba4.attila@kinali.ch>
Message-ID: <Pine.LNX.4.64.0906301801500.9988@sister.anvils>
References: <20090630115819.38b40ba4.attila@kinali.ch>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Attila Kinali <attila@kinali.ch>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jun 2009, Attila Kinali wrote:
> 
> There has been a bug back in the 2.4.17 days that is somehow
> triggered by swap being smaller than RAM, which i thought had
> been fixed long ago, reappeared on one of the machines i manage.

Snipped <history>, which I hope won't be repeated to the point of OOM.

> 
> Now, 7 years later, i have a machine that shows the same behavior.
> 
> Some data:
> 
> We have a HP DL380 G4 currently running a 2.6.29.4 vanilla kernel,
> compiled for x86 32 bit.
> It was originaly purchased in 2005 with 2GB RAM and a few weeks
> ago upgraded to 6GB (no other changes beside this and a kernel upgrade).
> The machine, being the MPlayer main server, runs a lighttpd, svnserve,
> mailman, postfix, bind. Ie nothing unusual and the applications didn't
> change in the last months (since the update from debian/etch to lenny).
> 
> ---
> root@natsuki:/home/attila# uname -a
> Linux natsuki 2.6.29.4 #1 SMP Sun May 31 22:13:21 CEST 2009 i686 GNU/Linux
> root@natsuki:/home/attila# uptime
>  11:41:07 up 29 days, 13:17,  5 users,  load average: 0.15, 0.36, 0.54
> root@natsuki:/home/attila# free -m
>              total       used       free     shared    buffers     cached
> Mem:          6023       5919        103          0        415       3873
> -/+ buffers/cache:       1630       4393
> Swap:         3812        879       2932
> ---
> 
> I want to point your attention at the fact that the machine has now
> more RAM installed than it previously had RAM+Swap (ie before the upgrade).
> Ie there is no reason it would need to swap out, at least not so much.
> 
> What is even more interesting is the amount of swap used over time.
> Sampled every day at 10:00 CEST:
> 
> ---
> Date: Wed, 17 Jun 2009 10:00:01 +0200 (CEST)
> Mem:          6023       5893        130          0        405       3834
> Swap:         3812        190       3622
> 
> Date: Thu, 18 Jun 2009 10:00:01 +0200 (CEST)
> Mem:          6023       5793        229          0        340       3939
> Swap:         3812        225       3586
> 
...
> 
> Date: Sun, 28 Jun 2009 10:00:02 +0200 (CEST)
> Mem:          6023       5890        132          0        402       3886
> Swap:         3812        784       3028
> 
> Date: Mon, 29 Jun 2009 10:00:01 +0200 (CEST)
> Mem:          6023       5388        635          0        425       3321
> Swap:         3812        826       2985
> ---
> 
> As you can see, although memory usage didnt change much over time,
> swap usage increased from 190MB to 826MB in about two weeks.
> 
> As i'm pretty much clueless when it commes to how the linux VM works,
> i would appreciate it if someone could give me some pointers on how
> to figure out what causes this bug so that it could be fixed finally.

I'm not sure that there's any problem here at all.  Beyond hibernation
to disk wanting enough swapspace to write its image, I can't think of
any reason why the kernel would misbehave if your swapspace is smaller
than your RAM.

One possibility is that this steady rise in swap usage just reflects
memory pressure (a nightly cron job?) pushing pages out to swap,
slightly different choices each time, and what's not modified later
gets left with a copy on swap.  That would tend to rise (at a slower
and slower rate) until swap is 50% full, then other checks should
keep it around that level.

If you do see it at more than 50% full in the morning, then yes,
I think you do have a leak: but it's more likely to be an
application than the kernel itself.  When kernel leaks occur,
they're often of "Slab:" memory - is that rising in /proc/meminfo?

Are you sure this steady rise in swap usage wasn't happening before
you added that RAM?  It's possible that you have an application which
decides how much memory to use, based on the amount of RAM in the
machine, itself assuming there's more than that of swap.

Do you have unwanted temporary files accumulating in a tmpfs?
Their pages get pushed out to swap.  Or a leak in shared memory:
does ipcs show increasing usage of shared memory?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
