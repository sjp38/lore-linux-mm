Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D7F6C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:49:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00EF8204EC
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:49:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="iDUWRKy5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00EF8204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 985C48E0003; Tue, 19 Feb 2019 07:49:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 934558E0002; Tue, 19 Feb 2019 07:49:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 824B28E0003; Tue, 19 Feb 2019 07:49:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 21DE88E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:49:03 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id f4so9198006wrg.9
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:49:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MqjVWcBs9b8WoHpqUcdgSfbZ+OOHiEEXKJZ7toKxupY=;
        b=Em5iSWxvvLwzDEyvgIcKSluASNz07s8gfDSjU+iVqMsr/7QpNy17OHlxeRDSFe/nu5
         swqGyBJoNujIjpdZfTYeOzKbm8tYxEHL6wTs4uYo0IJ7jZiyDFto4OHHoLyIUtZulfyD
         q07qEskfLktj7qL26Ev+xianm+eCAISpMn+Ed8o6KIN07TNqWahQ2O1Z6teS9R9C3vOs
         Oibw/kIYP51m/wwiIzJrYsfRNk/R4INT++qHa7JZnXgOF3YvlVHdgnEWkBX2yqhv6mSM
         o3lZVuU1cm42H9XV3Fx9OKsz++FvY+GUaM5KqMCSLcVhx+DPvm9rh3hrf5MZ8wQ3Zxq3
         dLUA==
X-Gm-Message-State: AHQUAub45YcAaOPNHfpyBh9GsTBqW242qBZybZZyeHOHmGpFQOyVJB/D
	ZjdhyrT4V1YwWqHe/lfDil5Nxhxc4MSVWIedYoan2YQVPQ9MuQHzRuI35mSu1SrWRPGWT769bDB
	z5lYGYWX0AbO9i6FLEeCSnaWbkXX2r79wCf3N+L3L0Mumt00edBdFIM0wBY8tbwAmGg==
X-Received: by 2002:adf:f34a:: with SMTP id e10mr17305331wrp.138.1550580542587;
        Tue, 19 Feb 2019 04:49:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaFfDQNZ3mBbf2ccujwkDLynzBr2Z3hOdmKYzfxKBn/JmGheTh3VNyRQoXlrkm6rHoaKXKM
X-Received: by 2002:adf:f34a:: with SMTP id e10mr17305268wrp.138.1550580541310;
        Tue, 19 Feb 2019 04:49:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550580541; cv=none;
        d=google.com; s=arc-20160816;
        b=imXeWU/V50vBsdbDcIopm0lU6JX8FfsNDCvKxPtsuC1yeW76K+h0oMu9M/FIHdJRL4
         IoKVFqSNMaVXBfTN7781nYsiuFuMhQy1RpxM4FcrcSBZwAwvibDG+HNSqC3XiVrNgPvA
         QrJ8Yj7rgw2eFTepvP99lcDPD6w5dMueYfT555QPo7RjnNjTeUxjL3/m3VYDav9aDGlQ
         s5cRT+YEbG8TmgHhDpMrMC95HApNkt0OCmhsqigtIsgG1V0d0e9t1nt2v11Cg+ST+D3x
         sKwUIEck/wpheixwjNO88TfEJGgxDm5NiAH4qR5IVYqGCYnjzbn8W/fCUPxfnxrOics/
         FU9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MqjVWcBs9b8WoHpqUcdgSfbZ+OOHiEEXKJZ7toKxupY=;
        b=PmzE1Y2pMeALzXAcMIgq9HwQdUCVqzDwvQAaoBYHZZBjzgcJla4K0wehvkhKWQRrXG
         xqaZN04N+q8JLOQrINVUkKiINU/3znCSfDvRMSSnU8x0mjSBhwH8HBbUrZlPGxH3bhfP
         yCBoUz0+M4mGsRSpa2Cn3OxX0pC7SbBSrN/n4zaU/9MSI6UK2jP7FA+dvRvIWdQPP2rO
         1agpYEcJCEmmzDo6rQ+WA8UjMqbml/1vFYV9LqgXJ9+T5Pyo5eTC/682zZffcmT533BU
         2/A2eKRIxdxa9SG7/nYAq6jGwcxOIgm64y6Oo81Ht/2hT6tMmH9tOTTrNcC7ZOuXkppI
         jTdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=iDUWRKy5;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id j12si1482104wmh.95.2019.02.19.04.49.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 04:49:01 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=iDUWRKy5;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCDC80098698729851D3663.dip0.t-ipconnect.de [IPv6:2003:ec:2bcd:c800:9869:8729:851d:3663])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 54DF71EC038F;
	Tue, 19 Feb 2019 13:49:00 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1550580540;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=MqjVWcBs9b8WoHpqUcdgSfbZ+OOHiEEXKJZ7toKxupY=;
	b=iDUWRKy5r6wDW969cVJ3LASyyAGHyzgXVuZWlsSE8ST6lK5tMX/W218HDiEKzckI7D3E7X
	HqloDSJb38GCftx9XsEcUeHVtoVHOUXT4d8VnMl7rVoX9Gal1qtUf0zcfZiBeu4/UHGbM0
	sWMnSmM3qquRxRVR3M4JtEeyh77jlak=
Date: Tue, 19 Feb 2019 13:48:53 +0100
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
	kristen@linux.intel.com, deneen.t.dock@intel.com
Subject: Re: [PATCH v2 15/20] vmalloc: New flags for safe vfree on special
 perms
Message-ID: <20190219124853.GB19514@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-16-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-16-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 04:34:17PM -0800, Rick Edgecombe wrote:
> This adds a new flags VM_HAS_SPECIAL_PERMS, for enabling vfree operations

s/This adds/add/ - you get the idea. :)

s/flags/flag/

> to immediately clear executable TLB entries to freed pages, and handle
> freeing memory with special permissions. It also takes care of resetting
> the direct map permissions for the pages being unmapped. So this flag is
> useful for any kind of memory with elevated permissions, or where there can
> be related permissions changes on the directmap. Today this is RO+X and RO
> memory.
> 
> Although this enables directly vfreeing RO memory now, RO memory cannot be
> freed in an interrupt because the allocation itself is used as a node on
> deferred free list. So when RO memory needs to be freed in an interrupt
> the code doing the vfree needs to have its own work queue, as was the case
> before the deferred vfree list handling was added. Today there is only one
> case where this happens.
> 
> For architectures with set_alias_ implementations this whole operation
> can be done with one TLB flush when centralized like this. For others with
> directmap permissions, currently only arm64, a backup method using
> set_memory functions is used to reset the directmap. When arm64 adds
> set_alias_ functions, this backup can be removed.
> 
> When the TLB is flushed to both remove TLB entries for the vmalloc range
> mapping and the direct map permissions, the lazy purge operation could be
> done to try to save a TLB flush later. However today vm_unmap_aliases
> could flush a TLB range that does not include the directmap. So a helper
> is added with extra parameters that can allow both the vmalloc address and
> the direct mapping to be flushed during this operation. The behavior of the
> normal vm_unmap_aliases function is unchanged.
> 
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Suggested-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  include/linux/vmalloc.h |  13 +++++
>  mm/vmalloc.c            | 122 +++++++++++++++++++++++++++++++++-------
>  2 files changed, 116 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 398e9c95cd61..9f643f917360 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -21,6 +21,11 @@ struct notifier_block;		/* in notifier.h */
>  #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
>  #define VM_NO_GUARD		0x00000040      /* don't add guard page */
>  #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
> +/*
> + * Memory with VM_HAS_SPECIAL_PERMS cannot be freed in an interrupt or with
> + * vfree_atomic.

Please end function names with parentheses. You should go over the whole
patchset - there are a bunch of places.

> + */
> +#define VM_HAS_SPECIAL_PERMS	0x00000200      /* Reset directmap and flush TLB on unmap */

After 0x00000080 comes 0x00000100. 0x00000010 is free too. What's up?

>  /* bits [20..32] reserved for arch specific ioremap internals */
>  
>  /*
> @@ -135,6 +140,14 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
>  extern struct vm_struct *remove_vm_area(const void *addr);
>  extern struct vm_struct *find_vm_area(const void *addr);
>  
> +static inline void set_vm_special(void *addr)

You need a different name than "special" for a vm which needs to flush
and clear mapping perms on removal. VM_RESET_PERMS or whatever is more
to the point than "special", for example, which could mean a lot of
things.

> +{
> +	struct vm_struct *vm = find_vm_area(addr);
> +
> +	if (vm)
> +		vm->flags |= VM_HAS_SPECIAL_PERMS;
> +}
> +
>  extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
>  			struct page **pages);
>  #ifdef CONFIG_MMU
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 871e41c55e23..d459b5b9649b 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -18,6 +18,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
> +#include <linux/set_memory.h>
>  #include <linux/debugobjects.h>
>  #include <linux/kallsyms.h>
>  #include <linux/list.h>
> @@ -1055,24 +1056,11 @@ static void vb_free(const void *addr, unsigned long size)
>  		spin_unlock(&vb->lock);
>  }
>  
> -/**
> - * vm_unmap_aliases - unmap outstanding lazy aliases in the vmap layer
> - *
> - * The vmap/vmalloc layer lazily flushes kernel virtual mappings primarily
> - * to amortize TLB flushing overheads. What this means is that any page you
> - * have now, may, in a former life, have been mapped into kernel virtual
> - * address by the vmap layer and so there might be some CPUs with TLB entries
> - * still referencing that page (additional to the regular 1:1 kernel mapping).
> - *
> - * vm_unmap_aliases flushes all such lazy mappings. After it returns, we can
> - * be sure that none of the pages we have control over will have any aliases
> - * from the vmap layer.
> - */
> -void vm_unmap_aliases(void)
> +static void _vm_unmap_aliases(unsigned long start, unsigned long end,
> +				int must_flush)

Align arguments on the opening brace. There's more places below, pls fix
them all.

>  {
> -	unsigned long start = ULONG_MAX, end = 0;
>  	int cpu;
> -	int flush = 0;
> +	int flush = must_flush;

You can't use must_flush directly because...?

gcc produces the same asm here, with or without the local "flush" var.

>  
>  	if (unlikely(!vmap_initialized))
>  		return;
> @@ -1109,6 +1097,27 @@ void vm_unmap_aliases(void)
>  		flush_tlb_kernel_range(start, end);
>  	mutex_unlock(&vmap_purge_lock);
>  }
> +
> +/**
> + * vm_unmap_aliases - unmap outstanding lazy aliases in the vmap layer
> + *
> + * The vmap/vmalloc layer lazily flushes kernel virtual mappings primarily
> + * to amortize TLB flushing overheads. What this means is that any page you
> + * have now, may, in a former life, have been mapped into kernel virtual
> + * address by the vmap layer and so there might be some CPUs with TLB entries
> + * still referencing that page (additional to the regular 1:1 kernel mapping).
> + *
> + * vm_unmap_aliases flushes all such lazy mappings. After it returns, we can
> + * be sure that none of the pages we have control over will have any aliases
> + * from the vmap layer.
> + */
> +void vm_unmap_aliases(void)
> +{
> +	unsigned long start = ULONG_MAX, end = 0;
> +	int must_flush = 0;
> +
> +	_vm_unmap_aliases(start, end, must_flush);
> +}
>  EXPORT_SYMBOL_GPL(vm_unmap_aliases);
>  
>  /**
> @@ -1494,6 +1503,79 @@ struct vm_struct *remove_vm_area(const void *addr)
>  	return NULL;
>  }
>  
> +static inline void set_area_alias(const struct vm_struct *area,
> +			int (*set_alias)(struct page *page))
> +{
> +	int i;
> +
> +	for (i = 0; i < area->nr_pages; i++) {
> +		unsigned long addr =
> +			(unsigned long)page_address(area->pages[i]);
> +
> +		if (addr)
> +			set_alias(area->pages[i]);

What's wrong with simply:

        for (i = 0; i < area->nr_pages; i++) {
                if (page_address(area->pages[i]))
                        set_alias(area->pages[i]);
        }

?

> +	}
> +}
> +
> +/* This handles removing and resetting vm mappings related to the vm_struct. */

s/This handles/Handle/

> +static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
> +{
> +	unsigned long addr = (unsigned long)area->addr;
> +	unsigned long start = ULONG_MAX, end = 0;
> +	int special = area->flags & VM_HAS_SPECIAL_PERMS;
> +	int i;
> +
> +	/*
> +	 * The below block can be removed when all architectures that have
> +	 * direct map permissions also have set_alias_ implementations. This is
> +	 * to do resetting on the directmap for any special permissions (today
> +	 * only X), without leaving a RW+X window.
> +	 */
> +	if (special && !IS_ENABLED(CONFIG_ARCH_HAS_SET_ALIAS)) {
> +		set_memory_nx(addr, area->nr_pages);
> +		set_memory_rw(addr, area->nr_pages);

That's two not very cheap calls to the underlying worker function, for
example change_memory_common() on ARM64, instead of calling it once with
the respective flags. You allude to that in the commit message but you
might wanna run it by ARM folks first.

> +	}
> +
> +	remove_vm_area(area->addr);
> +
> +	/* If this is not special memory, we can skip the below. */
> +	if (!special)
> +		return;
> +
> +	/*
> +	 * If we are not deallocating pages, we can just do the flush of the VM
> +	 * area and return.
> +	 */
> +	if (!deallocate_pages) {
> +		vm_unmap_aliases();
> +		return;
> +	}
> +
> +	/*
> +	 * If we are here, we need to flush the vm mapping and reset the direct
> +	 * map.
> +	 * First find the start and end range of the direct mappings to make
> +	 * sure the vm_unmap_aliases flush includes the direct map.
> +	 */
> +	for (i = 0; i < area->nr_pages; i++) {
> +		unsigned long addr =
> +			(unsigned long)page_address(area->pages[i]);
> +		if (addr) {

		if (page_address(area->pages[i]))

as above.

> +			start = min(addr, start);
> +			end = max(addr, end);
> +		}
> +	}
> +
> +	/*
> +	 * First we set direct map to something not valid so that it won't be

Above comment says "First" too. In general, all those "we" formulations
do not make the comments as easy to read as when you make them
impersonal and imperative:

	/*
	 * Set the direct map to something invalid...

Just like Documentation/process/submitting-patches.rst says:

 "Describe your changes in imperative mood, e.g. "make xyzzy do frotz"
  instead of "[This patch] makes xyzzy do frotz" or "[I] changed xyzzy
  to do frotz", as if you are giving orders to the codebase to change
  its behaviour."

you simply order your code to do stuff. :-)

> +	 * cached if there are any accesses after the TLB flush, then we flush
> +	 * the TLB, and reset the directmap permissions to the default.
> +	 */
> +	set_area_alias(area, set_alias_nv_noflush);
> +	_vm_unmap_aliases(start, end, 1);
> +	set_area_alias(area, set_alias_default_noflush);
> +}
> +
>  static void __vunmap(const void *addr, int deallocate_pages)
>  {
>  	struct vm_struct *area;

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

