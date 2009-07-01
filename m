Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 453EA6B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 03:53:29 -0400 (EDT)
Date: Wed, 1 Jul 2009 09:55:02 +0200
From: Attila Kinali <attila@kinali.ch>
Subject: Re: Long lasting MM bug when swap is smaller than RAM
Message-Id: <20090701095502.5689e603.attila@kinali.ch>
In-Reply-To: <Pine.LNX.4.64.0906301801500.9988@sister.anvils>
References: <20090630115819.38b40ba4.attila@kinali.ch>
	<Pine.LNX.4.64.0906301801500.9988@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Good morning,

On Tue, 30 Jun 2009 18:58:29 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> One possibility is that this steady rise in swap usage just reflects
> memory pressure (a nightly cron job?) pushing pages out to swap,

That might be true, if we wouldn't have now a lot more RAM than
swap+RAM before. Ie if we now would have memory pressure, then
we would have run out of swap space before and hence triggered the OOM
which didnt happen.

Tough, i did enable logging of the memory usage and swap space in
mrtg: http://natsuki.mplayerhq.hu/cgi-bin/mrtg-rrd.cgi/localmem.html
(blue is free mem w/o buffers/cache, red is used swap space).
The daily/weekly/monthly cron jobs are run between 6:25 and 7:00
but we dont have any increase in memory usage then.
What is interesting is the step at 4:10, which is exactly the time
when an rsync based backup of the mailman archives (lot of small files)
is started. But swap usage didnt increase at that time.
What is strange though, is that the backup takes about 13 minutes.
Most of that time is spend on traversing the directory tree and
stat'ing files. But the increase in memory usage is a sharp step
at the beginning only.

> slightly different choices each time, and what's not modified later
> gets left with a copy on swap.  That would tend to rise (at a slower
> and slower rate) until swap is 50% full, then other checks should
> keep it around that level.

I don't want to wait that long.

> 
> If you do see it at more than 50% full in the morning, then yes,
> I think you do have a leak: but it's more likely to be an
> application than the kernel itself.  When kernel leaks occur,
> they're often of "Slab:" memory - is that rising in /proc/meminfo?

I havent monitored /proc/meminfo yet.

> Are you sure this steady rise in swap usage wasn't happening before
> you added that RAM?  

Yes. I semi-regularly checked memory usage by hand and we never had
more than a couple MB of swap used.

> It's possible that you have an application which
> decides how much memory to use, based on the amount of RAM in the
> machine, itself assuming there's more than that of swap.

I dont think we have any application that does this. As I said, it's only a
web/mail/dns/svn server. There isnt anything fancy running.
Even the webpages are static only (beside the mailman interface).
The number of users on the machine is limited and none runs anything
directly on the machine (they are all just maintenance accounts).

> Do you have unwanted temporary files accumulating in a tmpfs?
> Their pages get pushed out to swap.  Or a leak in shared memory:
> does ipcs show increasing usage of shared memory?

/tmp is on a hard disk and thus doesnt add to memory usage.
The two tmpfs mounts (/dev/shm and /lib/init/rw) are completely
unused and empty.


			Attila Kinali

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
