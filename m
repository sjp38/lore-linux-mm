Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70E17C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:52:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02E532190A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:52:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02E532190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FDDA6B0003; Thu, 21 Mar 2019 13:52:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AA2B6B0006; Thu, 21 Mar 2019 13:52:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4833C6B0007; Thu, 21 Mar 2019 13:52:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF7056B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:52:52 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5so2551557edh.2
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:52:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=recM7Cb8jASqyijJ2x1szuM8Mzy7tJqe9u0bEF+/jI0=;
        b=mq7jEDO/2nOaN45Z5wI+Lri1f6ToagpGBbmxCoCswgRQ8KPqmy1TRy5plrBov15p9B
         S6EeFbbBM65zub6+R6y30unRN64dz7Fkgg4MZaYS/A6ePzvjat2ZglTLOWZWwVZCPqnK
         tHTuSvVeh0Hew94LNKgXYBt7Rt8eI2Znb+CWw9ff6vYwOGti6/Br/Pc8nTlewWI3bPkO
         VfXTR4/oCHmjVRtyJh5lK8z/rsxQU0Ni1AvIjFnPfqp8BEhDu/Ie7WbY4fOGkrGbwJKy
         ojEZB40aLiUe2rM57pp2I5630h1nwyBQkSmMEuTlOzgRcS3cDq2ACjicSc1w+gsjyMNe
         pzFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAVsNLTPxKk3FL0KM/5jTfwbX1jsuCTYh0qyUr1prm31LTYWJ6P6
	G2RKFBxCkTt9vIPHjwdnbVheF4ZVQpOg9+PZGgfkQL2flsp6Ix/+Q7x8nNiVmkCesYNTpbDLn2T
	pBM3pzFexm44agofD5xFUrU9DACPUapdFeFG8xu26755PSIMXSEvtxXfLNIbStlLwiw==
X-Received: by 2002:a17:906:58b:: with SMTP id 11mr2992972ejn.211.1553190772411;
        Thu, 21 Mar 2019 10:52:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJCIOE2CxWCrH69KeM22saC2eM+fwc5+Erbw+IbSArKt06UuIJTS/di01iXxnNGIXybFYB
X-Received: by 2002:a17:906:58b:: with SMTP id 11mr2992930ejn.211.1553190771126;
        Thu, 21 Mar 2019 10:52:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553190771; cv=none;
        d=google.com; s=arc-20160816;
        b=r0QGPBkwqj2lUlLL+TYkcOJE9CCvAYVsCup9a6kF9vniEn6M0Xt3FMiYz8y8Hf28qy
         JD4f1LXCBKd6yGX6lDmcspQBk0iTmg21Wl2rHvmYTjnl+ficN3Wupmn+J1aB1V0jlmYQ
         yikAmYQK1HdYe4iPSaa5hORZ2Fg/Kp9p+PGy9hxL0CWihYCGmBxDfeGJczyKtl/C3+TP
         z6PcesmRycs0f/HwnpjJP7QrzXuLMd5y4k+yT79YoybQJvMLJlDFBTvpPeCvJCx71ePG
         Zdcznvp+fRQw5E46tzEC4ROLlmAZSpsBCt7yA3cRcjJGRimt7oVQqaDhA69uwYDHQkSX
         cNbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=recM7Cb8jASqyijJ2x1szuM8Mzy7tJqe9u0bEF+/jI0=;
        b=rLuaCDHd3fXJuSn/vjhCwBMp6sXeUQzEdo1ecQsQ8UGRgQ3n20oiPk9yKPJDyvtl+M
         NlU8aePCuaweuATjyvStMMrr2YTwjDFvtZtkw2bNhyBKNcWf3kXO1rd0W0phZmvu76jy
         UbwbRbiJHVlE6mT1ZPeoPCexJPgpALxzfxu/ct/cGxUyQmo05JsQWUDEO2Fy6osf9wfX
         JYCC0qIBJYK7FkkrfC1mVqT9qwc9NSb9AKX0M91Gl5Cl4eWbuB5suBd49bPu8iAJLKpg
         79AxD48xyHRlM326HTLqHkn/PrsUQMeXLWzxAmVHRuc6A8eZnTmDLaQyCRydmA6EkLTX
         0GBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e24si2184602eda.31.2019.03.21.10.52.50
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 10:52:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D944B374;
	Thu, 21 Mar 2019 10:52:49 -0700 (PDT)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0980C3F614;
	Thu, 21 Mar 2019 10:52:39 -0700 (PDT)
Subject: Re: [PATCH v13 10/20] kernel, arm64: untag user pointers in
 prctl_set_mm*
To: Andrey Konovalov <andreyknvl@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Shuah Khan <shuah@kernel.org>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>,
 "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov
 <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Alex Deucher <alexander.deucher@amd.com>,
 =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>,
 "David (ChunMing) Zhou" <David1.Zhou@amd.com>,
 Yishai Hadas <yishaih@mellanox.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 Jens Wiklander <jens.wiklander@linaro.org>,
 Alex Williamson <alex.williamson@redhat.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org,
 amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
 linux-rdma@vger.kernel.org, linux-media@vger.kernel.org,
 kvm@vger.kernel.org, linux-kselftest@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <c5b9f421-0dd8-d56f-c591-0c841cbdfe3b@arm.com>
Date: Thu, 21 Mar 2019 17:52:37 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20/03/2019 14:51, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
>
> prctl_set_mm() and prctl_set_mm_map() use provided user pointers for vma
> lookups and do some pointer comparisons to perform validation, which can
> only by done with untagged pointers.
>
> Untag user pointers in these functions for vma lookup and validity checks.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>   kernel/sys.c | 44 ++++++++++++++++++++++++++++++--------------
>   1 file changed, 30 insertions(+), 14 deletions(-)
>
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 12df0e5434b8..fe26ccf3c9e6 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1885,11 +1885,12 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
>    * WARNING: we don't require any capability here so be very careful
>    * in what is allowed for modification from userspace.
>    */
> -static int validate_prctl_map(struct prctl_mm_map *prctl_map)
> +static int validate_prctl_map(struct prctl_mm_map *tagged_prctl_map)
>   {
>   	unsigned long mmap_max_addr = TASK_SIZE;
>   	struct mm_struct *mm = current->mm;
>   	int error = -EINVAL, i;
> +	struct prctl_mm_map prctl_map;
>   
>   	static const unsigned char offsets[] = {
>   		offsetof(struct prctl_mm_map, start_code),
> @@ -1905,12 +1906,25 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
>   		offsetof(struct prctl_mm_map, env_end),
>   	};
>   
> +	memcpy(&prctl_map, tagged_prctl_map, sizeof(prctl_map));
> +	prctl_map.start_code	= untagged_addr(prctl_map.start_code);
> +	prctl_map.end_code	= untagged_addr(prctl_map.end_code);
> +	prctl_map.start_data	= untagged_addr(prctl_map.start_data);
> +	prctl_map.end_data	= untagged_addr(prctl_map.end_data);
> +	prctl_map.start_brk	= untagged_addr(prctl_map.start_brk);
> +	prctl_map.brk		= untagged_addr(prctl_map.brk);
> +	prctl_map.start_stack	= untagged_addr(prctl_map.start_stack);
> +	prctl_map.arg_start	= untagged_addr(prctl_map.arg_start);
> +	prctl_map.arg_end	= untagged_addr(prctl_map.arg_end);
> +	prctl_map.env_start	= untagged_addr(prctl_map.env_start);
> +	prctl_map.env_end	= untagged_addr(prctl_map.env_end);
> +
>   	/*
>   	 * Make sure the members are not somewhere outside
>   	 * of allowed address space.
>   	 */
>   	for (i = 0; i < ARRAY_SIZE(offsets); i++) {
> -		u64 val = *(u64 *)((char *)prctl_map + offsets[i]);
> +		u64 val = *(u64 *)((char *)&prctl_map + offsets[i]);
>   
>   		if ((unsigned long)val >= mmap_max_addr ||
>   		    (unsigned long)val < mmap_min_addr)
> @@ -1921,8 +1935,8 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
>   	 * Make sure the pairs are ordered.
>   	 */
>   #define __prctl_check_order(__m1, __op, __m2)				\
> -	((unsigned long)prctl_map->__m1 __op				\
> -	 (unsigned long)prctl_map->__m2) ? 0 : -EINVAL
> +	((unsigned long)prctl_map.__m1 __op				\
> +	 (unsigned long)prctl_map.__m2) ? 0 : -EINVAL
>   	error  = __prctl_check_order(start_code, <, end_code);
>   	error |= __prctl_check_order(start_data, <, end_data);
>   	error |= __prctl_check_order(start_brk, <=, brk);
> @@ -1937,23 +1951,24 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
>   	/*
>   	 * @brk should be after @end_data in traditional maps.
>   	 */
> -	if (prctl_map->start_brk <= prctl_map->end_data ||
> -	    prctl_map->brk <= prctl_map->end_data)
> +	if (prctl_map.start_brk <= prctl_map.end_data ||
> +	    prctl_map.brk <= prctl_map.end_data)
>   		goto out;
>   
>   	/*
>   	 * Neither we should allow to override limits if they set.
>   	 */
> -	if (check_data_rlimit(rlimit(RLIMIT_DATA), prctl_map->brk,
> -			      prctl_map->start_brk, prctl_map->end_data,
> -			      prctl_map->start_data))
> +	if (check_data_rlimit(rlimit(RLIMIT_DATA), prctl_map.brk,
> +			      prctl_map.start_brk, prctl_map.end_data,
> +			      prctl_map.start_data))
>   			goto out;
>   
>   	/*
>   	 * Someone is trying to cheat the auxv vector.
>   	 */
> -	if (prctl_map->auxv_size) {
> -		if (!prctl_map->auxv || prctl_map->auxv_size > sizeof(mm->saved_auxv))
> +	if (prctl_map.auxv_size) {
> +		if (!prctl_map.auxv || prctl_map.auxv_size >
> +						sizeof(mm->saved_auxv))
>   			goto out;
>   	}
>   
> @@ -1962,7 +1977,7 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
>   	 * change /proc/pid/exe link: only local sys admin should
>   	 * be allowed to.
>   	 */
> -	if (prctl_map->exe_fd != (u32)-1) {
> +	if (prctl_map.exe_fd != (u32)-1) {
>   		if (!ns_capable(current_user_ns(), CAP_SYS_ADMIN))
>   			goto out;
>   	}
> @@ -2120,13 +2135,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
>   	if (opt == PR_SET_MM_AUXV)
>   		return prctl_set_auxv(mm, addr, arg4);
>   
> -	if (addr >= TASK_SIZE || addr < mmap_min_addr)
> +	if (untagged_addr(addr) >= TASK_SIZE ||
> +			untagged_addr(addr) < mmap_min_addr)
>   		return -EINVAL;
>   
>   	error = -EINVAL;
>   
>   	down_write(&mm->mmap_sem);
> -	vma = find_vma(mm, addr);
> +	vma = find_vma(mm, untagged_addr(addr));
>   
>   	prctl_map.start_code	= mm->start_code;
>   	prctl_map.end_code	= mm->end_code;

I think this new version is consistent w.r.t. tagged/untagged pointer usage. However, 
I also note that a significant change has been introduced: it is now possible to set 
MM fields to tagged addresses (tags are ignored by validate_prctl_map()). I am not 
opposed to this as such, but have you considered the implications? Does it make sense 
to have a tagged value for e.g. prctl_map.arg_start? Is the kernel able to handle 
tagged values in those fields? I have the feeling that it's safer to discard tags for 
now, and if necessary allow them to be preserved later on.

Kevin

