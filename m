Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 814736B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 07:30:02 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e5-v6so13941768eda.4
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:30:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z22-v6si3192788ejm.80.2018.10.16.04.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 04:30:01 -0700 (PDT)
Subject: Re: [PATCH 2/4] mm: speed up mremap by 500x on large regions (v2)
References: <20181013013200.206928-1-joel@joelfernandes.org>
 <20181013013200.206928-3-joel@joelfernandes.org>
 <20181015094209.GA31999@infradead.org>
 <20181015223303.GA164293@joelaf.mtv.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <35b9c85a-b366-9ca3-5647-c2568c811961@suse.cz>
Date: Tue, 16 Oct 2018 13:29:52 +0200
MIME-Version: 1.0
In-Reply-To: <20181015223303.GA164293@joelaf.mtv.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>, Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, mhocko@kernel.org, linux-mm@kvack.org, lokeshgidra@google.com, linux-riscv@lists.infradead.org, elfring@users.sourceforge.net, Jonas Bonn <jonas@southpole.se>, kvmarm@lists.cs.columbia.edu, dancol@google.com, Yoshinori Sato <ysato@users.sourceforge.jp>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, hughd@google.com, "James E.J. Bottomley" <jejb@parisc-linux.org>, kasan-dev@googlegroups.com, anton.ivanov@kot-begemot.co.uk, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-snps-arc@lists.infradead.org, kernel-team@android.com, Sam Creasey <sammy@sammy.net>, Fenghua Yu <fenghua.yu@intel.com>, linux-s390@vger.kernel.org, Jeff Dike <jdike@addtoit.com>, linux-um@lists.infradead.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Julia Lawall <Julia.Lawall@lip6.fr>, linux-m68k@lists.linux-m68k.org, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, nios2-dev@lists.rocketboards.org, kirill@shutemov.name, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, Richard Weinberger <richard@nod.at>, linux-parisc@vger.kernel.org, pantin@google.com, Max Filippov <jcmvbkbc@gmail.com>, minchan@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-alpha@vger.kernel.org, Ley Foon Tan <lftan@altera.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On 10/16/18 12:33 AM, Joel Fernandes wrote:
> On Mon, Oct 15, 2018 at 02:42:09AM -0700, Christoph Hellwig wrote:
>> On Fri, Oct 12, 2018 at 06:31:58PM -0700, Joel Fernandes (Google) wrote:
>>> Android needs to mremap large regions of memory during memory management
>>> related operations.
>>
>> Just curious: why?
> 
> In Android we have a requirement of moving a large (up to a GB now, but may
> grow bigger in future) memory range from one location to another.

I think Christoph's "why?" was about the requirement, not why it hurts
applications. I admit I'm now also curious :)

> This move
> operation has to happen when the application threads are paused for this
> operation. Therefore, an inefficient move like it is now (for example 250ms
> on arm64) will cause response time issues for applications, which is not
> acceptable. Huge pages cannot be used in such memory ranges to avoid this
> inefficiency as (when the application threads are running) our fault handlers
> are designed to process 4KB pages at a time, to keep response times low. So
> using huge pages in this context can, again, cause response time issues.
> 
> Also, the mremap syscall waiting for quarter of a second for a large mremap
> is quite weird and we ought to improve it where possible.
