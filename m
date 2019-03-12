Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFA65C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:19:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DB242077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:19:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ihgNATVj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DB242077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECF188E0004; Tue, 12 Mar 2019 15:19:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAF6F8E0002; Tue, 12 Mar 2019 15:19:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D95508E0004; Tue, 12 Mar 2019 15:19:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD95C8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:19:54 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o56so3305236qto.9
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:19:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Fc9YZuIzh6N9HjS8mAKym/k4q5CUcO4B2pCsB919vh0=;
        b=Jbbb6Oed6WycrSqIi1bLkP3IVg1WsGMvbOL6VnIsXjrpqYjTn3O8g+9jKkDluqakIl
         OOz1xt7gEeT8EZI9RyqC+LVPMdPcl/m5ONMNJ6gq6EtSEIhjSrAoBvrgvTg6TbJqZjlf
         JCQlESJIv1t7s0m/aBpfNSSZ0Pov9HWkQIcX86+OGmzKL5rptsc0dj5w6EiC1Z01hBGE
         hAkoRw/Bo5nu4kbWO3xjAfJun1kLn60cNuQBvSbAW4jpjB3Jb811OnKwt1se4LPA/q5y
         3a3VmwUnkWe8lulCjb8VEUG0HIl3COXIouUK+w1qxL/2cZzeW57oAIinZbH2wWGa0MGR
         g47A==
X-Gm-Message-State: APjAAAWP4+UMVrAWJR8UZsnWhiojmagWcTV+Uixe3jbio3gj84grhvh2
	hXkT+nYVwPWD8LJm5WPoMNckM/Eu01Z7UkmKcaW+r2ZDbdStQbONdabX+gPc1WL2sPuFoEOorr+
	hz2b4e/JkfmH9zEQjlW+FtzsrN9+nd+m2yPL9i4S/xaK9x+b4somSxiRhW0n6vQOokeMZ3VeZuP
	AnF6oCWgjbwso6mFazYvjOXo6f3/IzatplBjgZWLVWfXGLSEphLs7AuZmAtSghlXkXUwZJzlmvB
	WY6YW3PDFxzcALLEkfxY7pNn904vgkon2+zBdw8mpzzRpNLAsocVkhp0pzgJt/YqkQyIdS6bYKN
	r7c6dVBO8PIUxQqGQbFRa5VHdE8cReCX16AajyXeVPEcnoPR43WOflLSNgKmCsA4ztpezu1FDAs
	M
X-Received: by 2002:ac8:2d1c:: with SMTP id n28mr7246806qta.159.1552418394468;
        Tue, 12 Mar 2019 12:19:54 -0700 (PDT)
X-Received: by 2002:ac8:2d1c:: with SMTP id n28mr7246755qta.159.1552418393533;
        Tue, 12 Mar 2019 12:19:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552418393; cv=none;
        d=google.com; s=arc-20160816;
        b=PPWO5yoh7YkW+BJEF31FCnRGrq8z+7INct9HI0tWsrGvBs1tZ93xABXHWtp9GOxLDL
         jvzchy0vT0dJuo8Umk9y9TJR/a8OXlvEuEF+KsruP7y5orA3JJwgSGpob2/m/ZbN+IRb
         L+2Yh9g5FFKYBcFgpasqp45wqqeROzMyFQ1Nlo4IkjCe+u9UdlvfLL16fJRAaMXO6wts
         dLrEB36yhF8Q5l89HyUUG5vLROaUgluJ7+Yk9vzbNJ4176VHl22Q/E5G4HTH11+PdRMb
         DNwNDvYY+aAhliXLzjpF/e5oqkRnLnMb7CmWrXMu/h3mtOV3Ck3x+XMei2bEghM/ZnLS
         PMkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=Fc9YZuIzh6N9HjS8mAKym/k4q5CUcO4B2pCsB919vh0=;
        b=kZv9KFy1k/RCJUF9dzLjW/dt313mPIeSNoddwvtvBsBa6ovqmpqrRFUNUvVF3w/TA8
         vbI1dr5B6IUYc/MfjPpHeCv54t7yH3mk4frHwZcxLxzPTmgw5acVh3Za7hIa7enbD+mo
         VnZmQKEWKeInk7eJo8i1ztewMa0qJn/jSWuuhWfuyTH+q9leRNzUj8YGuCHN9877dq93
         /cnr2BvxhjzJ5S2zbmggyOlfK4ROCkXkHEJ0MDR6Tyt7DsZcG+xMSmUAdG0QHNIeCGfC
         WMh9BOCKXfrCS0Jc4KqS2Ktb2P3KqWqvW9SK5J3MvM5LLzPIrF3+ytbnQ8zmBoNE8R2n
         6vrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ihgNATVj;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k33sor11642948qte.66.2019.03.12.12.19.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 12:19:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ihgNATVj;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Fc9YZuIzh6N9HjS8mAKym/k4q5CUcO4B2pCsB919vh0=;
        b=ihgNATVjmlS9eNRpEE+MQmgRwKesa0sr/AEe9v3ZyUlT0D1vTxqICgOyMyi9AyLGCW
         qrhpMT4xIseDx4yBztt98RXbnNv1R2gIo7Z3gJavJRc1a3POX780RlD+EaZoghASSVFu
         8j/c/1mT5FL7twSOBKh01awSA9+NFwy6X7XT2y//VsweODx5JzKljV4CpWcW4hZ/ZSvx
         RAWOvUvmdfCW3p4HhCgXZ4RQbJAQhq5Anyxruf/nZwng/lxax30u/f2gkxnUh28eR8gO
         d5JA9Xq0bhPRGINbNQ4lO4Deo0ETIk25AbOJh7AsxaopnvmIv5Pzfk8628lipKB+1IDG
         187Q==
X-Google-Smtp-Source: APXvYqxduyXOPKXauvGcg5CmEA1uBSzc0dkaSOQAssQYeG1T6kX5lyI5h4vsIwV0RBj4VEZXvx02yg==
X-Received: by 2002:ac8:1aa6:: with SMTP id x35mr32098263qtj.218.1552418393237;
        Tue, 12 Mar 2019 12:19:53 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id w37sm5075030qtw.27.2019.03.12.12.19.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 12:19:52 -0700 (PDT)
Message-ID: <1552418391.26196.1.camel@lca.pw>
Subject: Re: [PATCH] kmemleak: skip scanning holes in the .bss section
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, paulus@ozlabs.org, benh@kernel.crashing.org, 
	mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Date: Tue, 12 Mar 2019 15:19:51 -0400
In-Reply-To: <20190312191412.28656-1-cai@lca.pw>
References: <20190312191412.28656-1-cai@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fixing some email addresses.

On Tue, 2019-03-12 at 15:14 -0400, Qian Cai wrote:
> The commit 2d4f567103ff ("KVM: PPC: Introduce kvm_tmp framework") adds
> kvm_tmp[] into the .bss section and then free the rest of unused spaces
> back to the page allocator.
> 
> kernel_init
>   kvm_guest_init
>     kvm_free_tmp
>       free_reserved_area
>         free_unref_page
>           free_unref_page_prepare
> 
> With DEBUG_PAGEALLOC=y, it will unmap those pages from kernel. As the
> result, kmemleak scan will trigger a panic below when it scans the .bss
> section with unmapped pages.
> 
> Since this is done way before the first kmemleak_scan(), just go
> lockless to make the implementation simple and skip those pages when
> scanning the .bss section. Later, those pages could be tracked by
> kmemleak again once allocated by the page allocator. Overall, this is
> such a special case, so no need to make it a generic to let kmemleak
> gain an ability to skip blocks in scan_large_block().
> 
> BUG: Unable to handle kernel data access at 0xc000000001610000
> Faulting instruction address: 0xc0000000003cc178
> Oops: Kernel access of bad area, sig: 11 [#1]
> LE PAGE_SIZE=64K MMU=Hash SMP NR_CPUS=256 DEBUG_PAGEALLOC NUMA pSeries
> CPU: 3 PID: 130 Comm: kmemleak Kdump: loaded Not tainted 5.0.0+ #9
> REGS: c0000004b05bf940 TRAP: 0300   Not tainted  (5.0.0+)
> NIP [c0000000003cc178] scan_block+0xa8/0x190
> LR [c0000000003cc170] scan_block+0xa0/0x190
> Call Trace:
> [c0000004b05bfbd0] [c0000000003cc170] scan_block+0xa0/0x190 (unreliable)
> [c0000004b05bfc30] [c0000000003cc2c0] scan_large_block+0x60/0xa0
> [c0000004b05bfc70] [c0000000003ccc64] kmemleak_scan+0x254/0x960
> [c0000004b05bfd40] [c0000000003cdd50] kmemleak_scan_thread+0xec/0x12c
> [c0000004b05bfdb0] [c000000000104388] kthread+0x1b8/0x1c0
> [c0000004b05bfe20] [c00000000000b364] ret_from_kernel_thread+0x5c/0x78
> Instruction dump:
> 7fa3eb78 4844667d 60000000 60000000 60000000 60000000 3bff0008 7fbcf840
> 409d00b8 4bfffeed 2fa30000 409e00ac <e87f0000> e93e0128 7fa91840
> 419dffdc
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  arch/powerpc/kernel/kvm.c |  3 +++
>  include/linux/kmemleak.h  |  4 ++++
>  mm/kmemleak.c             | 25 ++++++++++++++++++++++++-
>  3 files changed, 31 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
> index 683b5b3805bd..5cddc8fc56bb 100644
> --- a/arch/powerpc/kernel/kvm.c
> +++ b/arch/powerpc/kernel/kvm.c
> @@ -26,6 +26,7 @@
>  #include <linux/slab.h>
>  #include <linux/of.h>
>  #include <linux/pagemap.h>
> +#include <linux/kmemleak.h>
>  
>  #include <asm/reg.h>
>  #include <asm/sections.h>
> @@ -712,6 +713,8 @@ static void kvm_use_magic_page(void)
>  
>  static __init void kvm_free_tmp(void)
>  {
> +	kmemleak_bss_hole(&kvm_tmp[kvm_tmp_index],
> +			  &kvm_tmp[ARRAY_SIZE(kvm_tmp)]);
>  	free_reserved_area(&kvm_tmp[kvm_tmp_index],
>  			   &kvm_tmp[ARRAY_SIZE(kvm_tmp)], -1, NULL);
>  }
> diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
> index 5ac416e2d339..3d8949b9c6f5 100644
> --- a/include/linux/kmemleak.h
> +++ b/include/linux/kmemleak.h
> @@ -46,6 +46,7 @@ extern void kmemleak_alloc_phys(phys_addr_t phys, size_t
> size, int min_count,
>  extern void kmemleak_free_part_phys(phys_addr_t phys, size_t size) __ref;
>  extern void kmemleak_not_leak_phys(phys_addr_t phys) __ref;
>  extern void kmemleak_ignore_phys(phys_addr_t phys) __ref;
> +extern void kmemleak_bss_hole(void *start, void *stop);
>  
>  static inline void kmemleak_alloc_recursive(const void *ptr, size_t size,
>  					    int min_count, slab_flags_t
> flags,
> @@ -131,6 +132,9 @@ static inline void kmemleak_not_leak_phys(phys_addr_t
> phys)
>  static inline void kmemleak_ignore_phys(phys_addr_t phys)
>  {
>  }
> +static inline void kmemleak_bss_hole(void *start, void *stop)
> +{
> +}
>  
>  #endif	/* CONFIG_DEBUG_KMEMLEAK */
>  
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 707fa5579f66..42349cd9ef7a 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -237,6 +237,10 @@ static int kmemleak_skip_disable;
>  /* If there are leaks that can be reported */
>  static bool kmemleak_found_leaks;
>  
> +/* Skip scanning of a range in the .bss section. */
> +static void *bss_hole_start;
> +static void *bss_hole_stop;
> +
>  static bool kmemleak_verbose;
>  module_param_named(verbose, kmemleak_verbose, bool, 0600);
>  
> @@ -1265,6 +1269,18 @@ void __ref kmemleak_ignore_phys(phys_addr_t phys)
>  }
>  EXPORT_SYMBOL(kmemleak_ignore_phys);
>  
> +/**
> + * kmemleak_bss_hole - skip scanning a range in the .bss section
> + *
> + * @start:	start of the range
> + * @stop:	end of the range
> + */
> +void kmemleak_bss_hole(void *start, void *stop)
> +{
> +	bss_hole_start = start;
> +	bss_hole_stop = stop;
> +}
> +
>  /*
>   * Update an object's checksum and return true if it was modified.
>   */
> @@ -1531,7 +1547,14 @@ static void kmemleak_scan(void)
>  
>  	/* data/bss scanning */
>  	scan_large_block(_sdata, _edata);
> -	scan_large_block(__bss_start, __bss_stop);
> +
> +	if (bss_hole_start) {
> +		scan_large_block(__bss_start, bss_hole_start);
> +		scan_large_block(bss_hole_stop, __bss_stop);
> +	} else {
> +		scan_large_block(__bss_start, __bss_stop);
> +	}
> +
>  	scan_large_block(__start_ro_after_init, __end_ro_after_init);
>  
>  #ifdef CONFIG_SMP

