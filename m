Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FB2BC282DA
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 09:59:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 407EF20844
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 09:59:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="sN+VAMR/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 407EF20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEEFA8E007E; Tue,  5 Feb 2019 04:59:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9E978E001C; Tue,  5 Feb 2019 04:59:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8D0E8E007E; Tue,  5 Feb 2019 04:59:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 665078E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 04:59:06 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f6so989232wmj.5
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 01:59:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4WLWE+J0DRMfgxDveUBu3Q4pEbwtQo3nPkdUwTDOryU=;
        b=A+3cJAGqEsflVHn40GwLK8uU4AAaDEsZkkyMUk05W4Ds+9iiUh/53fHHPF5CRPLlQL
         vvQUBcv33fvhRsjE33ageTwghO5C8Faqu5VF6ppSmGcjlAA8vOv79CeY9P5Zcn9BaoOz
         uvNOG2S8Geg11wgJdbSXQAqnkeyjyFHhlyHXfncvpXRbcw1qJfFYgB2M1c2uUxL2O/er
         AwYuQc/WeMmfRwwi1rgGXP045G+FDBvCOPjqokOC+eihhxIaT34bZVdZhpdEANEQlmoo
         9ZroNSslENqiXiyGwBA8iKVLGBSNSq3GqR4rx17qZm9i9qP2LDXxGj2YaWP15E32Ezh6
         OW5Q==
X-Gm-Message-State: AHQUAuYs46eM5hwZ/M6tf0GbRWeX6xyZUEMBrjISj2VApZ8z+iWtfJkN
	O3t93zaa8LhIMqYKE+BUr6Lc9BwffNMKIEiltnWqQAuEpmdgKJnyNCevXxg3PqiC1B8LiyrFlW6
	+COKH2ywVXxc1LK1Ci9FJj0e7aOc112UGQuiKlg+yI9r7XRp5yUKsHf+YWy5SgSadOA==
X-Received: by 2002:a1c:a895:: with SMTP id r143mr2853129wme.95.1549360745667;
        Tue, 05 Feb 2019 01:59:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaVKgRbjdn5RjRNTUUA6ATMyE/CgoNlQZ4lxV+KLkJ9hDNPJudswK7/FsLFXfczyH1pfN99
X-Received: by 2002:a1c:a895:: with SMTP id r143mr2853046wme.95.1549360744241;
        Tue, 05 Feb 2019 01:59:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549360744; cv=none;
        d=google.com; s=arc-20160816;
        b=l19L5LzytT1bylWhHie72XqwGI/5S0l4WmaSwdRRuElU/hiE8n/fnjTTfU978+AoPo
         6IIgAe5JBNPc/IQ44BDaSxsCscpVkFMGMuuOopNBPKBLhzbYWEuYw0fbUWs4PyhN9pwK
         BP07uwvTZr4nN+qxFHD7PLJLoWP1/+/0uUpg8lo26fzKBKguOWL3X3q6F+G1Feddbt0h
         Izg1zCx+FfPSNM/nMR4rX2l8/GIjJnTG3lvWJRQd0A0/wFz0xy2U9lNxTS/w2hnjz9d+
         HDeHQIdvlfdU76bOef+l4AwFe0kSPBcOsDH44u+Wq+EJawLK8S3TBuezw23Bx3hBg3+7
         3U+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4WLWE+J0DRMfgxDveUBu3Q4pEbwtQo3nPkdUwTDOryU=;
        b=ux1lkiEW1JFdXglJqCw3ac8ZJ4Dy3d386XE0daUy/Gx80zjBkt9KR/2H3MQpsrdtoi
         RS+lhizoLOkJ8H74++6D4vK24tTXwI8JK7nTZrfZYaXq8e6SXOi3u0XXw/hjKCdEw5DY
         /2GoKycaB1Ez4/UlEe3HvxqsosYRZ593+ClQUak7GU4sfc9ZncMUFBPeER/3Ny4RFfv7
         IKA49S2JCc8i/lmiG1nttOXHjXgR8nJu3Ub8hTa+dzQZjGRdjwwT0UkEAoWMaieCF4dF
         N2XFapAwM0wTuxUhNYE3K4p3JMhmhEB1Wh3QtSs9IlEgohflJW59+1dDnc9hKiOzY/SK
         JNsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="sN+VAMR/";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id o81si8720570wma.31.2019.02.05.01.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 01:59:04 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="sN+VAMR/";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCB6B0041C3B5D5EB4D55D2.dip0.t-ipconnect.de [IPv6:2003:ec:2bcb:6b00:41c3:b5d5:eb4d:55d2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 617901EC02AE;
	Tue,  5 Feb 2019 10:59:03 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549360743;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=4WLWE+J0DRMfgxDveUBu3Q4pEbwtQo3nPkdUwTDOryU=;
	b=sN+VAMR/+p82N2cesfhrBJmbYaaoU6yls9h3YT7v4jao9kNIG/tcUSCbuxKb/0uVV9erWV
	4hRsw4aqxnrrRj4e8lwlE5VFodJOJK/dg/QuzXN/u4AmU8FxMDHrO8Yi/CrlUmQLYakWNr
	BlG/qnD7KImItVvOV94cFbrLYko4xMg=
Date: Tue, 5 Feb 2019 10:58:53 +0100
From: Borislav Petkov <bp@alien8.de>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 06/20] x86/alternative: use temporary mm for text
 poking
Message-ID: <20190205095853.GJ21801@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-7-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-7-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 04:34:08PM -0800, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> text_poke() can potentially compromise the security as it sets temporary

s/the //

> PTEs in the fixmap. These PTEs might be used to rewrite the kernel code
> from other cores accidentally or maliciously, if an attacker gains the
> ability to write onto kernel memory.

Eww, sneaky. That would be a really nasty attack.

> Moreover, since remote TLBs are not flushed after the temporary PTEs are
> removed, the time-window in which the code is writable is not limited if
> the fixmap PTEs - maliciously or accidentally - are cached in the TLB.
> To address these potential security hazards, we use a temporary mm for
> patching the code.
> 
> Finally, text_poke() is also not conservative enough when mapping pages,
> as it always tries to map 2 pages, even when a single one is sufficient.
> So try to be more conservative, and do not map more than needed.
> 
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Masami Hiramatsu <mhiramat@kernel.org>
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/include/asm/fixmap.h |   2 -
>  arch/x86/kernel/alternative.c | 106 +++++++++++++++++++++++++++-------
>  arch/x86/xen/mmu_pv.c         |   2 -
>  3 files changed, 84 insertions(+), 26 deletions(-)
> 
> diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
> index 50ba74a34a37..9da8cccdf3fb 100644
> --- a/arch/x86/include/asm/fixmap.h
> +++ b/arch/x86/include/asm/fixmap.h
> @@ -103,8 +103,6 @@ enum fixed_addresses {
>  #ifdef CONFIG_PARAVIRT
>  	FIX_PARAVIRT_BOOTMAP,
>  #endif
> -	FIX_TEXT_POKE1,	/* reserve 2 pages for text_poke() */
> -	FIX_TEXT_POKE0, /* first page is last, because allocation is backward */

Two fixmap slots less - good riddance. :)

>  #ifdef	CONFIG_X86_INTEL_MID
>  	FIX_LNW_VRTC,
>  #endif
> diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
> index ae05fbb50171..76d482a2b716 100644
> --- a/arch/x86/kernel/alternative.c
> +++ b/arch/x86/kernel/alternative.c
> @@ -11,6 +11,7 @@
>  #include <linux/stop_machine.h>
>  #include <linux/slab.h>
>  #include <linux/kdebug.h>
> +#include <linux/mmu_context.h>
>  #include <asm/text-patching.h>
>  #include <asm/alternative.h>
>  #include <asm/sections.h>
> @@ -683,41 +684,102 @@ __ro_after_init unsigned long poking_addr;
>  
>  static void *__text_poke(void *addr, const void *opcode, size_t len)
>  {
> +	bool cross_page_boundary = offset_in_page(addr) + len > PAGE_SIZE;
> +	temporary_mm_state_t prev;
> +	struct page *pages[2] = {NULL};
>  	unsigned long flags;
> -	char *vaddr;
> -	struct page *pages[2];
> -	int i;
> +	pte_t pte, *ptep;
> +	spinlock_t *ptl;
> +	pgprot_t prot;
>  
>  	/*
> -	 * While boot memory allocator is runnig we cannot use struct
> -	 * pages as they are not yet initialized.
> +	 * While boot memory allocator is running we cannot use struct pages as
> +	 * they are not yet initialized.
>  	 */
>  	BUG_ON(!after_bootmem);
>  
>  	if (!core_kernel_text((unsigned long)addr)) {
>  		pages[0] = vmalloc_to_page(addr);
> -		pages[1] = vmalloc_to_page(addr + PAGE_SIZE);
> +		if (cross_page_boundary)
> +			pages[1] = vmalloc_to_page(addr + PAGE_SIZE);
>  	} else {
>  		pages[0] = virt_to_page(addr);
>  		WARN_ON(!PageReserved(pages[0]));
> -		pages[1] = virt_to_page(addr + PAGE_SIZE);
> +		if (cross_page_boundary)
> +			pages[1] = virt_to_page(addr + PAGE_SIZE);
>  	}
> -	BUG_ON(!pages[0]);
> +	BUG_ON(!pages[0] || (cross_page_boundary && !pages[1]));

checkpatch fires a lot for this patchset and I think we should tone down
the BUG_ON() use.

WARNING: Avoid crashing the kernel - try using WARN_ON & recovery code rather than BUG() or BUG_ON()
#116: FILE: arch/x86/kernel/alternative.c:711:
+       BUG_ON(!pages[0] || (cross_page_boundary && !pages[1]));

While the below BUG_ON makes sense, this here could be a WARN_ON or so.

Which begs the next question: AFAICT, nothing looks at text_poke*()'s
retval. So why are we even bothering returning something?

> +
>  	local_irq_save(flags);
> -	set_fixmap(FIX_TEXT_POKE0, page_to_phys(pages[0]));
> -	if (pages[1])
> -		set_fixmap(FIX_TEXT_POKE1, page_to_phys(pages[1]));
> -	vaddr = (char *)fix_to_virt(FIX_TEXT_POKE0);
> -	memcpy(&vaddr[(unsigned long)addr & ~PAGE_MASK], opcode, len);
> -	clear_fixmap(FIX_TEXT_POKE0);
> -	if (pages[1])
> -		clear_fixmap(FIX_TEXT_POKE1);
> -	local_flush_tlb();
> -	sync_core();
> -	/* Could also do a CLFLUSH here to speed up CPU recovery; but
> -	   that causes hangs on some VIA CPUs. */
> -	for (i = 0; i < len; i++)
> -		BUG_ON(((char *)addr)[i] != ((char *)opcode)[i]);
> +
> +	/*
> +	 * The lock is not really needed, but this allows to avoid open-coding.
> +	 */
> +	ptep = get_locked_pte(poking_mm, poking_addr, &ptl);
> +
> +	/*
> +	 * This must not fail; preallocated in poking_init().
> +	 */
> +	VM_BUG_ON(!ptep);
> +
> +	/*
> +	 * flush_tlb_mm_range() would be called when the poking_mm is not
> +	 * loaded. When PCID is in use, the flush would be deferred to the time
> +	 * the poking_mm is loaded again. Set the PTE as non-global to prevent
> +	 * it from being used when we are done.
> +	 */
> +	prot = __pgprot(pgprot_val(PAGE_KERNEL) & ~_PAGE_GLOBAL);

So

				_KERNPG_TABLE | _PAGE_NX

as this is pagetable page, AFAICT.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

