Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 675866B038B
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 21:36:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f21so340111474pgi.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:36:26 -0700 (PDT)
Subject: Re: [RFC PATCH 10/13] mm: Introduce first class virtual address
 spaces
References: <20170313221415.9375-1-till.smejkal@gmail.com>
 <20170313221415.9375-11-till.smejkal@gmail.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <cd1adda8-bf6a-47ad-bff3-5bc6626ac100@synopsys.com>
Date: Mon, 13 Mar 2017 18:35:27 -0700
MIME-Version: 1.0
In-Reply-To: <20170313221415.9375-11-till.smejkal@gmail.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Till Smejkal <till.smejkal@googlemail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J.  Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin  Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@synopsys.COM>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org, Ingo Molnar <mingo@kernel.org>, Thomas
 Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@amacapital.net>

+CC Ingo, tglx

Hi Till,

On 03/13/2017 03:14 PM, Till Smejkal wrote:
> Introduce a different type of address spaces which are first class citizens
> in the OS. That means that the kernel now handles two types of AS, those
> which are closely coupled with a process and those which aren't. While the
> former ones are created and destroyed together with the process by the
> kernel and are the default type of AS in the Linux kernel, the latter ones
> have to be managed explicitly by the user and are the newly introduced
> type.
> 
> Accordingly, a first class AS (also called VAS == virtual address space)
> can exist in the OS independently from any process. A user has to
> explicitly create and destroy them in the system. Processes and VAS can be
> combined by attaching a previously created VAS to a process which basically
> adds an additional AS to the process that the process' threads are able to
> execute in. Hence, VAS allow a process to have different views onto the
> main memory of the system (its original AS and the attached VAS) between
> which its threads can switch arbitrarily during their lifetime.
> 
> The functionality made available through first class virtual address spaces
> can be used in various different ways. One possible way to utilize VAS is
> to compartmentalize a process for security reasons. Another possible usage
> is to improve the performance of data-centric applications by being able to
> manage different sets of data in memory without the need to map or unmap
> them.
> 
> Furthermore, first class virtual address spaces can be attached to
> different processes at the same time if the underlying memory is only
> readable. This mechanism allows sharing of whole address spaces between
> multiple processes that can both execute in them using the contained
> memory.

I've not looked at the patches closely (or read the references paper fully yet),
but at first glance it seems on ARC architecture, we can can potentially
use/leverage this mechanism to implement the shared TLB entries. Before anyone
shouts these are not same as the IA64/x86 protection keys which allow TLB entries
with different protection bits across processes etc. These TLB entries are
actually *shared* by processes.

Conceptually there's shared address spaces, independent of processes. e.g. ldso
code is shared address space #1, libc (code) #2 .... System can support a limited
number of shared addr spaces (say 64, enough for typical embedded sys).

While Normal TLB entries are tagged with ASID (Addr space ID) to keep them unique
across processes, Shared TLB entries are tagged with Shared address space ID.

A process MMU context consists of ASID (a single number) and a SASID bitmap (to
allow "subscription" to multiple Shared spaces. The subscriptions are set up bu
userspace ld.so which knows about the libs process wants to map.

The restriction ofcourse is that the spaces are mapped at *same* vaddr is all
participating processes. I know this goes against whole security, address space
randomization - but it gives much better real time performance. Why does each
process need to take a MMU exception for libc code...

So long story short - it seems there can be multiple uses of this infrastructure !

-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
