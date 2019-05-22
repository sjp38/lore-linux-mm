Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2E50C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 11:49:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D5CC2173C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 11:49:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D5CC2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E76016B0003; Wed, 22 May 2019 07:49:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E27A16B0006; Wed, 22 May 2019 07:49:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D15D26B0007; Wed, 22 May 2019 07:49:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83B166B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 07:49:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f41so3330394ede.1
        for <linux-mm@kvack.org>; Wed, 22 May 2019 04:49:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=07zo5bUGbCrcFqWvLhX7HHQq+iwmUl+VvWQFGqImRa4=;
        b=W6UXh6P2IJm5SDGtzDL7YsA1t71JHP32oltr5wLo6DqtePa6ui9msGgD+gvi3ypMam
         cwx59XOtDRw+yqiKnQJ8tRvhRVo3dpfwvsMBzkSFzMH+YWDqJg0TFbn/1uuv/Tih+BQi
         s5Cnv3s54juB+V1rluyYND1NYP+dFqcs40iDzV207m9s0arv4GXClfpdfn+WZcllG1vy
         UBQcei/noUd++Y9tKQINutomduzKc8yqzBHi7RkieyxQAfNSIqwo8I7Qv9sBsUeqhexG
         3hhKX4aR22dhM85AT84CfM3fJTD4VQ0kNjqq7Aw6vNv05+kNexfbU9xjfQphZTaCEo4r
         JQPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVefluS+rZMiYRiKlWnOxVbvH3cS30j5IwNzCxERSAGU0YqLCOs
	0WKA19qrCRzRHFL8As2vsoSv4xTyLwzHyjcJaEcP4LAzRF4IOGWR0bzXzl2Y/xgc9gqy5C1BKAS
	ktiawapCLOGumg1C1H+80E13DBTOfUhaO5DmyptZGDDwUvJC6wepm55PtE/7C3nvVHQ==
X-Received: by 2002:a50:f9cc:: with SMTP id a12mr89528449edq.272.1558525762101;
        Wed, 22 May 2019 04:49:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHs43vT8tGPG3ezoScrjxTBaWi8s1IlnWgyvwzgqXIqdyNUR3w4az3TyZVcv/GkJnLHJIk
X-Received: by 2002:a50:f9cc:: with SMTP id a12mr89528358edq.272.1558525760838;
        Wed, 22 May 2019 04:49:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558525760; cv=none;
        d=google.com; s=arc-20160816;
        b=xYp5Tdwf+DqTB5eZVIaCCnd3G5Qo5bkAkYuYInTTRAUpKr+hglCky6wVFB2kzTQzE8
         LesSTq2kwoNjo5tIhU6QUALb+MGLKeds2uzCMvuAXHbmFx4O9dn2fsrWtI4Hz12lMXMW
         DIodDM9RvHxdBaMeHmxIeqtXUWLQ7uQpCmTjIwFFZhOsB5/8XmNt+3Uw0K7gEwiJ+uKv
         pjo9VUAffC2aeU/qC5vA0T2xJpJKbr4reFKHc8qwb+9eVk60jgbvHBnbBfHdC6QVTTZI
         CNet1RpojKmMriq2MeY4JK33PC7cmumlicqOon7ACgmvYfRi3YgbWwMYltVi/tO4I7Un
         6BhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=07zo5bUGbCrcFqWvLhX7HHQq+iwmUl+VvWQFGqImRa4=;
        b=VvQgTHsQVxOlcgYepyUeS10tssYjdaUbK8UMMdGIi43rZzo2X9TJGgw/1j4gzZ2CU9
         rCtoYPc1wCDtIdZwIeOL6T9oCoG/i8rkkiLCBeBH2+2uuV50VlQwdXLatcM2K45235u1
         bWzikCmRzK0esW/r2ZYdB4Zz96DpOywIpueMDs2gCBR9hGaGy3MZPqPTYN6SAKECF0sU
         X01OAv/73G8MRJOEuLV3yyqBtFso0ijYBe6OIk9CaG4gcn6yy04P6WT+uB7AwYNsEOkA
         e9KMhvulVMyn9aJoQRwGFF57cZvJAnUxY+O26Sd5aQ5J/YIG/sJxchWSbh695oVJwSSe
         tYdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f5si7190316edb.93.2019.05.22.04.49.20
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 04:49:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7DC8180D;
	Wed, 22 May 2019 04:49:19 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AE7643F575;
	Wed, 22 May 2019 04:49:13 -0700 (PDT)
Date: Wed, 22 May 2019 12:49:10 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190522114910.emlckebwzv2qz42i@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch allows tagged pointers to be passed to the following memory
> syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock, mlock2,
> mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
> remap_file_pages, shmat and shmdt.
> 
> This is done by untagging pointers passed to these syscalls in the
> prologues of their handlers.

I'll go through them one by one to see if we can tighten the expected
ABI while having the MTE in mind.

> diff --git a/arch/arm64/kernel/sys.c b/arch/arm64/kernel/sys.c
> index b44065fb1616..933bb9f3d6ec 100644
> --- a/arch/arm64/kernel/sys.c
> +++ b/arch/arm64/kernel/sys.c
> @@ -35,10 +35,33 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
>  {
>  	if (offset_in_page(off) != 0)
>  		return -EINVAL;
> -
> +	addr = untagged_addr(addr);
>  	return ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
>  }

If user passes a tagged pointer to mmap() and the address is honoured
(or MAP_FIXED is given), what is the expected return pointer? Does it
need to be tagged with the value from the hint?

With MTE, we may want to use this as a request for the default colour of
the mapped pages (still under discussion).

> +SYSCALL_DEFINE6(arm64_mmap_pgoff, unsigned long, addr, unsigned long, len,
> +		unsigned long, prot, unsigned long, flags,
> +		unsigned long, fd, unsigned long, pgoff)
> +{
> +	addr = untagged_addr(addr);
> +	return ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
> +}

We don't have __NR_mmap_pgoff on arm64.

> +SYSCALL_DEFINE5(arm64_mremap, unsigned long, addr, unsigned long, old_len,
> +		unsigned long, new_len, unsigned long, flags,
> +		unsigned long, new_addr)
> +{
> +	addr = untagged_addr(addr);
> +	new_addr = untagged_addr(new_addr);
> +	return ksys_mremap(addr, old_len, new_len, flags, new_addr);
> +}

Similar comment as for mmap(), do we want the tag from new_addr to be
preserved? In addition, should we check that the two tags are identical
or mremap() should become a way to repaint a memory region?

> +SYSCALL_DEFINE2(arm64_munmap, unsigned long, addr, size_t, len)
> +{
> +	addr = untagged_addr(addr);
> +	return ksys_munmap(addr, len);
> +}

This looks fine.

> +SYSCALL_DEFINE1(arm64_brk, unsigned long, brk)
> +{
> +	brk = untagged_addr(brk);
> +	return ksys_brk(brk);
> +}

I wonder whether brk() should simply not accept tags, and should not
return them (similar to the prctl(PR_SET_MM) discussion). We could
document this in the ABI requirements.

> +SYSCALL_DEFINE5(arm64_get_mempolicy, int __user *, policy,
> +		unsigned long __user *, nmask, unsigned long, maxnode,
> +		unsigned long, addr, unsigned long, flags)
> +{
> +	addr = untagged_addr(addr);
> +	return ksys_get_mempolicy(policy, nmask, maxnode, addr, flags);
> +}
> +
> +SYSCALL_DEFINE3(arm64_madvise, unsigned long, start,
> +		size_t, len_in, int, behavior)
> +{
> +	start = untagged_addr(start);
> +	return ksys_madvise(start, len_in, behavior);
> +}
> +
> +SYSCALL_DEFINE6(arm64_mbind, unsigned long, start, unsigned long, len,
> +		unsigned long, mode, const unsigned long __user *, nmask,
> +		unsigned long, maxnode, unsigned int, flags)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mbind(start, len, mode, nmask, maxnode, flags);
> +}
> +
> +SYSCALL_DEFINE2(arm64_mlock, unsigned long, start, size_t, len)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mlock(start, len, VM_LOCKED);
> +}
> +
> +SYSCALL_DEFINE2(arm64_mlock2, unsigned long, start, size_t, len)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mlock(start, len, VM_LOCKED);
> +}
> +
> +SYSCALL_DEFINE2(arm64_munlock, unsigned long, start, size_t, len)
> +{
> +	start = untagged_addr(start);
> +	return ksys_munlock(start, len);
> +}
> +
> +SYSCALL_DEFINE3(arm64_mprotect, unsigned long, start, size_t, len,
> +		unsigned long, prot)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mprotect_pkey(start, len, prot, -1);
> +}
> +
> +SYSCALL_DEFINE3(arm64_msync, unsigned long, start, size_t, len, int, flags)
> +{
> +	start = untagged_addr(start);
> +	return ksys_msync(start, len, flags);
> +}
> +
> +SYSCALL_DEFINE3(arm64_mincore, unsigned long, start, size_t, len,
> +		unsigned char __user *, vec)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mincore(start, len, vec);
> +}

These look fine.

> +SYSCALL_DEFINE5(arm64_remap_file_pages, unsigned long, start,
> +		unsigned long, size, unsigned long, prot,
> +		unsigned long, pgoff, unsigned long, flags)
> +{
> +	start = untagged_addr(start);
> +	return ksys_remap_file_pages(start, size, prot, pgoff, flags);
> +}

While this has been deprecated for some time, I presume user space still
invokes it?

> +SYSCALL_DEFINE3(arm64_shmat, int, shmid, char __user *, shmaddr, int, shmflg)
> +{
> +	shmaddr = untagged_addr(shmaddr);
> +	return ksys_shmat(shmid, shmaddr, shmflg);
> +}
> +
> +SYSCALL_DEFINE1(arm64_shmdt, char __user *, shmaddr)
> +{
> +	shmaddr = untagged_addr(shmaddr);
> +	return ksys_shmdt(shmaddr);
> +}

Do we actually want to allow shared tagged memory? Who's going to tag
it? If not, we can document it as not supported.

-- 
Catalin

