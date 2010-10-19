Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B20B96B00AA
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:10:23 -0400 (EDT)
Message-ID: <20101019181021.22456.qmail@kosh.dhis.org>
From: pacman@kosh.dhis.org
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
Date: Tue, 19 Oct 2010 13:10:21 -0500 (GMT+5)
In-Reply-To: <1287483410.2341.66.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt writes:
> > 
> > I thought of that, but as far as I can tell, this CPU doesn't have DABR.
> 
> AFAIK, the 7447 is just a derivative of the 7450 design which -does-
> have a DABR ... Unless it's broken :-)

Hmm. gdb resorts to single-stepping when I set a watchpoint while debugging
some userspace program, which I assumed was caused by lack of hardware
watchpoint support. But that's not important right now.

I made a new discovery. During a test boot while looking at the usual symptom
of a corrupted page cache, I run md5sum /sbin/e2fsck twice and got 2
different results, neither one of them correct. The third time, yet another
different result. A few dozen more times, a few dozen more unique results. I
had somehow managed to get a usable interactive shell while corruption was
ongoing.

So then I ran
  dd if=/dev/mem bs=4 count=1 skip=$((0xfc5c080/4)) | od -t x4
a few times very fast, plucking the first affected word directly out of
memory by its physical address. The result:

The low 16 bits are always zero as before. The high 16 bits are a counter,
being incremented at about 1000Hz (as close as I could measure with a crude
shell script. 1024Hz would also be within the margin of error). And it's
little-endian.

While I was watching this happen, there were only 5 or 6 userspace processes
running, and 3 of them were shells. So I doubt that anything in userspace was
doing it. It went on for a few minutes before I exited the interactive shell
and allowed the boot to continue, while keeping an extra shell running on
tty2 to continue making observations. It stopped incrementing almost
immediately.

So what type of driver, firmware, or hardware bug puts a 16-bit 1000Hz timer
in memory, and does it in little-endian instead of the CPU's native byte
order? And why does it stop doing it some time during the early init scripts,
shortly after the root filesystem fsck?

I have not yet attempted to repeat the experiment. If it is repeatable, I'll
probe more deeply into those init scripts later. I'm looking hard at
/etc/rcS.d/S11hwclock.sh

-- 
Alan Curry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
