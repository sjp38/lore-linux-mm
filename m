Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD163800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:58:02 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id r13so1406258lff.22
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 10:58:02 -0800 (PST)
Received: from shrek.podlesie.net (shrek-3s.podlesie.net. [2a00:13a0:3010::1])
        by mx.google.com with ESMTP id h8si1122112lfk.359.2018.01.24.10.58.00
        for <linux-mm@kvack.org>;
        Wed, 24 Jan 2018 10:58:00 -0800 (PST)
Date: Wed, 24 Jan 2018 19:58:00 +0100
From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180124185800.GA11515@shrek.podlesie.net>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Jan 16, 2018 at 05:36:43PM +0100, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> Hi,
> 
> here is my current WIP code to enable PTI on x86-32. It is
> still in a pretty early state, but it successfully boots my
> KVM guest with PAE and with legacy paging. The existing PTI
> code for x86-64 already prepares a lot of the stuff needed
> for 32 bit too, thanks for that to all the people involved
> in its development :)

Hi,

I've waited for this patches for a long time, until I've tried to
exploit meltdown on some old 32-bit CPUs and failed. Pentium M
seems to speculatively execute the second load with eax
always equal to 0:

	movzx (%[addr]), %%eax
	shl $12, %%eax
	movzx (%[target], %%eax), %%eax

And on Pentium 4-based Xeon the second load seems to be never executed,
even without shift (shifts are slow on some or all Pentium 4's). Maybe
not all P6 and Netbursts CPUs are affected, but I'm not sure. Maybe the
kernel, at least on 32-bit, should try to exploit meltdown to test if
the CPU is really affected.


The series boots on Pentium M (and crashes when I've used perf,
but it is an already known issue). However, I don't like
the performance regression with CONFIG_PAGE_TABLE_ISOLATION=n
(about 7.2%), trivial "benchmark":

--- cut here ---
#include <unistd.h>
#include <fcntl.h>

int main(void)
{
	unsigned long i;
	int fd;

	fd = open("/dev/null", O_WRONLY);
	for (i = 0; i < 10000000; i++) {
		char x = 0;
		write(fd, &x, 1);
	}
	return 0;
}
--- cut here ---

Time (on Pentium M 1.73 GHz):

baseline (4.15.0-rc8-gdda3e152):		2.415 s (+/- 0.64%)
patched, without CONFIG_PAGE_TABLE_ISOLATION=n	2.588 s (+/- 0.01%)
patched, nopti					2.597 s (+/- 0.31%)
patched, pti					18.272 s
(some older kernel, pre 4.15)			2.378 s

Thanks,
Krzysiek
--
perf results:

baseline:

 Performance counter stats for './bench' (5 runs):

       2401.539139 task-clock:HG             #    0.995 CPUs utilized            ( +-  0.23% )
                23 context-switches:HG       #    0.009 K/sec                    ( +-  4.02% )
                 0 cpu-migrations:HG         #    0.000 K/sec                  
                30 page-faults:HG            #    0.013 K/sec                    ( +-  1.24% )
        4142375834 cycles:HG                 #    1.725 GHz                      ( +-  0.23% ) [39.99%]
         385110908 stalled-cycles-frontend:HG #    9.30% frontend cycles idle     ( +-  0.06% ) [40.01%]
   <not supported> stalled-cycles-backend:HG
        4142489274 instructions:HG           #    1.00  insns per cycle        
                                             #    0.09  stalled cycles per insn  ( +-  0.00% ) [40.00%]
         802270380 branches:HG               #  334.065 M/sec                    ( +-  0.00% ) [40.00%]
             34278 branch-misses:HG          #    0.00% of all branches          ( +-  1.94% ) [40.00%]

       2.414741497 seconds time elapsed                                          ( +-  0.64% )

patched, without CONFIG_PAGE_TABLE_ISOLATION=n

 Performance counter stats for './bench' (5 runs):

       2587.026405 task-clock:HG             #    1.000 CPUs utilized            ( +-  0.01% )
                28 context-switches:HG       #    0.011 K/sec                    ( +-  5.95% )
                 0 cpu-migrations:HG         #    0.000 K/sec                  
                31 page-faults:HG            #    0.012 K/sec                    ( +-  1.21% )
        4462401079 cycles:HG                 #    1.725 GHz                      ( +-  0.01% ) [39.98%]
         388646121 stalled-cycles-frontend:HG #    8.71% frontend cycles idle     ( +-  0.05% ) [40.01%]
   <not supported> stalled-cycles-backend:HG
        4283638646 instructions:HG           #    0.96  insns per cycle        
                                             #    0.09  stalled cycles per insn  ( +-  0.00% ) [40.03%]
         822484311 branches:HG               #  317.927 M/sec                    ( +-  0.00% ) [40.01%]
             39372 branch-misses:HG          #    0.00% of all branches          ( +-  2.33% ) [39.98%]

       2.587818354 seconds time elapsed                                          ( +-  0.01% )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
