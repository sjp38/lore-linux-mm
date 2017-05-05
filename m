Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB21C6B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 14:52:45 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s62so11815332pgc.2
        for <linux-mm@kvack.org>; Fri, 05 May 2017 11:52:45 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id d6si6515855plj.167.2017.05.05.11.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 11:52:44 -0700 (PDT)
Subject: asm/mmu.h using NR_CPUS (was Re: kisskb: FAILED
 linux-next/axs101_defconfig/arcompact Thu May 04, 18:53)
References: <20170504085336.1.21586@5b4f83badeef>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <6aa3877c-9118-88d1-b662-49a455a66258@synopsys.com>
Date: Fri, 5 May 2017 11:52:32 -0700
MIME-Version: 1.0
In-Reply-To: <20170504085336.1.21586@5b4f83badeef>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-snps-arc@lists.infradead.org
Cc: noreply@ellerman.id.au, lkml <linux-kernel@vger.kernel.org>, Alexey.Brodkin@synopsys.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Anton Kolesov <Anton.Kolesov@synopsys.com>

+CC Michal, linux-arch as it potentially affects other arches !

Hi,

On 05/04/2017 01:53 AM, noreply@ellerman.id.au wrote:
> FAILED linux-next/axs101_defconfig/arcompact Thu May 04, 18:53
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/13022475/
> 
> Commit:   Add linux-next specific files for 20170504
>           ef57eb19c96fa099a578aeaed9b9d0dbcc4fe069
> Compiler: arc-buildroot-linux-uclibc-gcc (Buildroot 2015.08.1) 4.8.4
> 
> Possible errors
> ---------------
> 
> arch/arc/include/asm/mmu.h:75:21: error: 'NR_CPUS' undeclared here (not in a function)
> make[3]: *** [arch/arc/mm/ioremap.o] Error 1
> make[2]: *** [arch/arc/mm] Error 2
> make[1]: *** [arch/arc] Error 2
> arch/arc/include/asm/mmu.h:75:21: error: 'NR_CPUS' undeclared here (not in a function)
> make[3]: *** [kernel/irq/generic-chip.o] Error 1
> make[2]: *** [kernel/irq] Error 2
> make[1]: *** [kernel] Error 2
> arch/arc/include/asm/mmu.h:75:21: error: 'NR_CPUS' undeclared here (not in a function)
> make[2]: *** [mm/vmalloc.o] Error 1
> make[1]: *** [mm] Error 2
> make: *** [sub-make] Error 2

I bisected the linux-next ARC build failure (!SMP only) to a subtle side effect of
a950a30220657d ("mm, vmalloc: properly track vmalloc users") which includes
asm/pgtable.h causing the final include chain (for ARC ioremap.c) to have
asm/mmu.h (using NR_CPUS) before linux/threads.h (defining it)

The quick fix is to include linux/threads.h and this is just a heads up other
arches might run into same - although xtensa and mips with similar mm_context_t
seem to build just fine !

-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
