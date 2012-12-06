Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 13A4F6B00A1
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:18:17 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so8232724oag.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:18:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1354033730-850-1-git-send-email-js1304@gmail.com>
References: <1354033730-850-1-git-send-email-js1304@gmail.com>
Date: Fri, 7 Dec 2012 01:18:16 +0900
Message-ID: <CAAmzW4Ng8S_O4SEoANCWz3jsW3h3ucGSM9=Ld-n9aLuHcdgprw@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] introduce static_vm for ARM-specific static mapped area
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>

2012/11/28 Joonsoo Kim <js1304@gmail.com>:
> In current implementation, we used ARM-specific flag, that is,
> VM_ARM_STATIC_MAPPING, for distinguishing ARM specific static mapped area.
> The purpose of static mapped area is to re-use static mapped area when
> entire physical address range of the ioremap request can be covered
> by this area.
>
> This implementation causes needless overhead for some cases.
> For example, assume that there is only one static mapped area and
> vmlist has 300 areas. Every time we call ioremap, we check 300 areas for
> deciding whether it is matched or not. Moreover, even if there is
> no static mapped area and vmlist has 300 areas, every time we call
> ioremap, we check 300 areas in now.
>
> If we construct a extra list for static mapped area, we can eliminate
> above mentioned overhead.
> With a extra list, if there is one static mapped area,
> we just check only one area and proceed next operation quickly.
>
> In fact, it is not a critical problem, because ioremap is not frequently
> used. But reducing overhead is better idea.
>
> Another reason for doing this work is for removing architecture dependency
> on vmalloc layer. I think that vmlist and vmlist_lock is internal data
> structure for vmalloc layer. Some codes for debugging and stat inevitably
> use vmlist and vmlist_lock. But it is preferable that they are used
> as least as possible in outside of vmalloc.c
>
> Changelog
> v1->v2:
>   [2/3]: patch description is improved.
>   Rebased on v3.7-rc7
>
> Joonsoo Kim (3):
>   ARM: vmregion: remove vmregion code entirely
>   ARM: static_vm: introduce an infrastructure for static mapped area
>   ARM: mm: use static_vm for managing static mapped areas
>
>  arch/arm/include/asm/mach/static_vm.h |   51 ++++++++
>  arch/arm/mm/Makefile                  |    2 +-
>  arch/arm/mm/ioremap.c                 |   69 ++++-------
>  arch/arm/mm/mm.h                      |   10 --
>  arch/arm/mm/mmu.c                     |   55 +++++----
>  arch/arm/mm/static_vm.c               |   97 ++++++++++++++++
>  arch/arm/mm/vmregion.c                |  205 ---------------------------------
>  arch/arm/mm/vmregion.h                |   31 -----
>  8 files changed, 208 insertions(+), 312 deletions(-)
>  create mode 100644 arch/arm/include/asm/mach/static_vm.h
>  create mode 100644 arch/arm/mm/static_vm.c
>  delete mode 100644 arch/arm/mm/vmregion.c
>  delete mode 100644 arch/arm/mm/vmregion.h
>
> --
> 1.7.9.5
>

Hello, Russell.

Could you review this patchset, please?
I send another patchset to mm community on top of this.
That one is related to this patchset,
so I want to get a review about this patchset :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
