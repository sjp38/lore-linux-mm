Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51B1EC28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:51:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F285520833
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:51:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="CtSxM/iJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F285520833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E7826B0278; Fri,  7 Jun 2019 23:51:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 998FB6B0279; Fri,  7 Jun 2019 23:51:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8604E6B027A; Fri,  7 Jun 2019 23:51:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC506B0278
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 23:51:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id i33so2521307pld.15
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 20:51:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=+sAqEcYebSGTQqNUHJjZvXdBrlSAt8m9jXPFyYB00fA=;
        b=Wx5DggqcCX5t82u2g69m9Fx+OXc/j8s7OKRKqMcwvAs7CCRKhiMvFszsUcQXvk4exE
         SDD88fgeBYWanRWS5FR5r/5Bv02QZ01nbYGMgg0p3TqREJ/fAisiy1tEHIW5osm4reoG
         fS20Ja87kBbrGQxYvdvIBMRq+Righ7NM9LfTPTt/U/f16s8DbBElEJX7vOPcVhkRpqhw
         tcwmWoAOarxt3IuxMCZD+3SyckMrc4M+K/3gKebBc7N17RBQyMxxqGcHbhQtYkGNSoM0
         h4OFfxZFueT8/cdYVjpZnJRGY+5nPG0xPDlhjCnSeDi08D8i4b7Jqw6HXoRYIwcGANyP
         KKyw==
X-Gm-Message-State: APjAAAWpl1Bnt6yqwLAeuo1XeShdNoXyS4JqT0Jf2ie+7NQO3IN92sTd
	LniqgMJK2Mw4YXkRI2z245eP3ChN8SKTTP13t5BJ3EQ0S35dgMxtmGyZN0ONRh+eDqZpimPa4sS
	e7Q8pYxyuj+oaOL3DceZb6Q7XAqkldHi9Bxz1/2s0nDsVi6j+TBiAtWcQohndxlJoDQ==
X-Received: by 2002:a62:e518:: with SMTP id n24mr6246911pff.102.1559965910967;
        Fri, 07 Jun 2019 20:51:50 -0700 (PDT)
X-Received: by 2002:a62:e518:: with SMTP id n24mr6246889pff.102.1559965910274;
        Fri, 07 Jun 2019 20:51:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559965910; cv=none;
        d=google.com; s=arc-20160816;
        b=RnDbO7cne58oJRvLSCJr4s0q+v/2+V7VB1mUFywUF56BcyC9l9bepYziEFxtQzJqvG
         fUJxRKQ2q5vA0U3sGKCgs2g1i5ec9ZCCQP2DtT4vFk/iKmjIYZtpXI0vE/6SOM8i2Gi8
         j1D57P3g3DTxU/MJzJz59d4VESQgATnFTh8QudSAmP6Rb++5FNmTWGi5WR1xGBE1C3ml
         HUZtLj3mXw6CJb7NLd2AqWanNDWyg8K7qZo7rQ4Cf2QYiDYQ2TjG9Lxcspe3p+u0GbEE
         IuRQdZQcknbeJThN29fdN6RlcFSSJoqEZDVra9U4irfdYBgMgUXA0T6yuJiOqMBfBw/6
         mRFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=+sAqEcYebSGTQqNUHJjZvXdBrlSAt8m9jXPFyYB00fA=;
        b=g3OUJrF/Xxh7KxPgy4ydVCJyf6z0JGXPiQjV6nNow/xEVFL+l0eFLARGsa3jvOYt8b
         B065rGpCmOJGCCdiqIJiQgPXnKO40FbIUggg8VollxjwFJlNzatssGrenknOEIpdfrQy
         pv0FLvbS7q6iWjPhabkNE1gvGWPICD6pHkiEgD1vv13IeYc4/kr/kleYu/DjsWU9lZR+
         TqWVVJO6h6S/IOyjav3N9VhbFCWpJwO95ebvv64mFC7/QxqfrdCzRjVSBK7VFrfSrUUA
         9gSPyEbNC0xf1/DpTXgMJ6T+ofrYAHcFy/H5edR2l2/ktjWRgk+knOShcG/CRFPijCn3
         5jmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="CtSxM/iJ";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11sor4717641pjq.26.2019.06.07.20.51.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 20:51:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="CtSxM/iJ";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=+sAqEcYebSGTQqNUHJjZvXdBrlSAt8m9jXPFyYB00fA=;
        b=CtSxM/iJFdFOilMt5IYz49fhtrPJpe1biMjSLL9dNHxYjLjFZgiPdCXtt2Os7+WUWp
         2h97ew7Js16BFPaL91oYsoUi+i2fwl58zxZoJKC+5LpNlJocOwDirIXVuEvjdms0IvZ/
         xj006iO3/Sm/g4St20TSl0BbuhpEFIrb4EXp0=
X-Google-Smtp-Source: APXvYqwaFwR9TdiH8fcP0E7/plCUQ2bJqcAs+FgbmWIC/6eFKnV6hJ+Yk3YTH/8Vcg8+zQmbsZgqwQ==
X-Received: by 2002:a17:90a:b104:: with SMTP id z4mr9232885pjq.102.1559965909964;
        Fri, 07 Jun 2019 20:51:49 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id k13sm3360691pgq.45.2019.06.07.20.51.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 20:51:49 -0700 (PDT)
Date: Fri, 7 Jun 2019 20:51:48 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 05/16] arm64: untag user pointers passed to memory
 syscalls
Message-ID: <201906072051.7B66635BE@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <045a94326401693e015bf80c444a4d946a5c68ed.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <045a94326401693e015bf80c444a4d946a5c68ed.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:07PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch allows tagged pointers to be passed to the following memory
> syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprotect,
> mremap, msync, munlock.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/madvise.c   | 2 ++
>  mm/mempolicy.c | 3 +++
>  mm/mincore.c   | 2 ++
>  mm/mlock.c     | 4 ++++
>  mm/mprotect.c  | 2 ++
>  mm/mremap.c    | 2 ++
>  mm/msync.c     | 2 ++
>  7 files changed, 17 insertions(+)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 628022e674a7..39b82f8a698f 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -810,6 +810,8 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
>  	size_t len;
>  	struct blk_plug plug;
>  
> +	start = untagged_addr(start);
> +
>  	if (!madvise_behavior_valid(behavior))
>  		return error;
>  
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 01600d80ae01..78e0a88b2680 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1360,6 +1360,7 @@ static long kernel_mbind(unsigned long start, unsigned long len,
>  	int err;
>  	unsigned short mode_flags;
>  
> +	start = untagged_addr(start);
>  	mode_flags = mode & MPOL_MODE_FLAGS;
>  	mode &= ~MPOL_MODE_FLAGS;
>  	if (mode >= MPOL_MAX)
> @@ -1517,6 +1518,8 @@ static int kernel_get_mempolicy(int __user *policy,
>  	int uninitialized_var(pval);
>  	nodemask_t nodes;
>  
> +	addr = untagged_addr(addr);
> +
>  	if (nmask != NULL && maxnode < nr_node_ids)
>  		return -EINVAL;
>  
> diff --git a/mm/mincore.c b/mm/mincore.c
> index c3f058bd0faf..64c322ed845c 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -249,6 +249,8 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
>  	unsigned long pages;
>  	unsigned char *tmp;
>  
> +	start = untagged_addr(start);
> +
>  	/* Check the start address: needs to be page-aligned.. */
>  	if (start & ~PAGE_MASK)
>  		return -EINVAL;
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 080f3b36415b..e82609eaa428 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -674,6 +674,8 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
>  	unsigned long lock_limit;
>  	int error = -ENOMEM;
>  
> +	start = untagged_addr(start);
> +
>  	if (!can_do_mlock())
>  		return -EPERM;
>  
> @@ -735,6 +737,8 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
>  {
>  	int ret;
>  
> +	start = untagged_addr(start);
> +
>  	len = PAGE_ALIGN(len + (offset_in_page(start)));
>  	start &= PAGE_MASK;
>  
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index bf38dfbbb4b4..19f981b733bc 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -465,6 +465,8 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
>  	const bool rier = (current->personality & READ_IMPLIES_EXEC) &&
>  				(prot & PROT_READ);
>  
> +	start = untagged_addr(start);
> +
>  	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
>  	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
>  		return -EINVAL;
> diff --git a/mm/mremap.c b/mm/mremap.c
> index fc241d23cd97..1d98281f7204 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -606,6 +606,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>  	LIST_HEAD(uf_unmap_early);
>  	LIST_HEAD(uf_unmap);
>  
> +	addr = untagged_addr(addr);
> +
>  	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
>  		return ret;
>  
> diff --git a/mm/msync.c b/mm/msync.c
> index ef30a429623a..c3bd3e75f687 100644
> --- a/mm/msync.c
> +++ b/mm/msync.c
> @@ -37,6 +37,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
>  	int unmapped_error = 0;
>  	int error = -EINVAL;
>  
> +	start = untagged_addr(start);
> +
>  	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
>  		goto out;
>  	if (offset_in_page(start))
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

