Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id B1A0C6B006E
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 12:44:52 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id va8so14773753obc.3
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:44:52 -0800 (PST)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id os17si366008oeb.32.2015.01.15.09.44.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 09:44:51 -0800 (PST)
Message-ID: <1421342920.2493.8.camel@misato.fc.hp.com>
Subject: Re: [PATCH v7 0/7] Support Write-Through mapping on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 15 Jan 2015 10:28:40 -0700
In-Reply-To: <1420577392-21235-1-git-send-email-toshi.kani@hp.com>
References: <1420577392-21235-1-git-send-email-toshi.kani@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com

Hi Ingo, Peter, Thomas,

Is there anything else I need to do for accepting this patchset? 

Thanks,
-Toshi


On Tue, 2015-01-06 at 13:49 -0700, Toshi Kani wrote:
> This patchset adds support of Write-Through (WT) mapping on x86.
> The study below shows that using WT mapping may be useful for
> non-volatile memory.
> 
>   http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf
> 
> All new/modified interfaces have been tested.
> 
> v7:
>  - Rebased to 3.19-rc3 as Juergen's patchset for the PAT management
>    has been accepted.
> 
> v6:
>  - Dropped the patch moving [set|get]_page_memtype() to pat.c
>    since the tip branch already has this change.
>  - Fixed an issue when CONFIG_X86_PAT is not defined.
> 
> v5:
>  - Clarified comment of why using slot 7. (Andy Lutomirski,
>    Thomas Gleixner)
>  - Moved [set|get]_page_memtype() to pat.c. (Thomas Gleixner)
>  - Removed BUG() from set_page_memtype(). (Thomas Gleixner)
> 
> v4:
>  - Added set_memory_wt() by adding WT support of regular memory.
> 
> v3:
>  - Dropped the set_memory_wt() patch. (Andy Lutomirski)
>  - Refactored the !pat_enabled handling. (H. Peter Anvin,
>    Andy Lutomirski)
>  - Added the picture of PTE encoding. (Konrad Rzeszutek Wilk)
> 
> v2:
>  - Changed WT to use slot 7 of the PAT MSR. (H. Peter Anvin,
>    Andy Lutomirski)
>  - Changed to have conservative checks to exclude all Pentium 2, 3,
>    M, and 4 families. (Ingo Molnar, Henrique de Moraes Holschuh,
>    Andy Lutomirski)
>  - Updated documentation to cover WT interfaces and usages.
>    (Andy Lutomirski, Yigal Korman)
> 
> ---
> Toshi Kani (7):
>   1/7 x86, mm, pat: Set WT to PA7 slot of PAT MSR
>   2/7 x86, mm, pat: Change reserve_memtype() to handle WT
>   3/7 x86, mm, asm-gen: Add ioremap_wt() for WT
>   4/7 x86, mm, pat: Add pgprot_writethrough() for WT
>   5/7 x86, mm, pat: Refactor !pat_enable handling
>   6/7 x86, mm, asm: Add WT support to set_page_memtype()
>   7/7 x86, mm: Add set_memory_wt() for WT
> 
> ---
>  Documentation/x86/pat.txt            |  13 ++-
>  arch/x86/include/asm/cacheflush.h    |   6 +-
>  arch/x86/include/asm/io.h            |   2 +
>  arch/x86/include/asm/pgtable_types.h |   3 +
>  arch/x86/mm/init.c                   |   6 +-
>  arch/x86/mm/iomap_32.c               |  12 +--
>  arch/x86/mm/ioremap.c                |  26 ++++-
>  arch/x86/mm/pageattr.c               |  61 ++++++++++--
>  arch/x86/mm/pat.c                    | 184 ++++++++++++++++++++++++-----------
>  include/asm-generic/io.h             |   9 ++
>  include/asm-generic/iomap.h          |   4 +
>  include/asm-generic/pgtable.h        |   4 +
>  12 files changed, 244 insertions(+), 86 deletions(-)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
