Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C76A2C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 11:47:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A26420854
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 11:47:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A26420854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 227286B0006; Mon, 18 Mar 2019 07:47:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B0826B0007; Mon, 18 Mar 2019 07:47:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0526B6B0008; Mon, 18 Mar 2019 07:47:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA55D6B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 07:47:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e55so2171598edd.6
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 04:47:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=cAjTK3lSVPrV3KWiYH4fM9uStQ4aYws3H7LOYwr+AhA=;
        b=Q2TrW0ux4sISeLlIGyy26x5fx7hvRCXHgOZlSsWpSRsTf7I5acIMoYYwnmpAFeaqhM
         J0bWOnBjaA9IZRRkZtk4vmfVjkRriwAaasrPUfmGoBmY1Vqx+RXzVLxAoaaQoeAitq26
         yq2ZloKFdBrS99P+gM/Gz7DuFIVH22K8G5MlLDB96fk/y7ACiw0y41zGpY8qL+ZBxzOb
         mK/ceh+Z8P4Jg9FvJx8WMtqVEmyHvD4sC80LmxZv+PVIhQWSfo+3MbIEzoiqoBOhT+K0
         YtJIdd5MqhQPpVZfOcSfRwiH6r2reiuSXXqP2fFkEiVgPP8H3teOQKHNa2z/kcTRALgi
         Mf4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAU0tOKtS9edpEiIi5pFxInoJip5901GEAsBYFvvCQrWh2eF0SyQ
	XYm7qux/IR26yeIfrdOs1YdYF6LfYefsNWWC3qLom5SKy7SkLX7ZU+5zEh+zPCxj5gn9LOJ7Mbg
	lbnYQJ0S6XE3teciEWg7/TQ2hWXWw4N6RF/WoJtq8mjqqGkDisY/EKKl4TG8G9o/8Gw==
X-Received: by 2002:a50:c016:: with SMTP id r22mr12721185edb.77.1552909646275;
        Mon, 18 Mar 2019 04:47:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5Fh/v4Ww958+oDWnhCngcoQi8Pr4jxULlWbDG+jiJ+Jo33sSprZXjq+/cObIG4EoxgHlj
X-Received: by 2002:a50:c016:: with SMTP id r22mr12721126edb.77.1552909645296;
        Mon, 18 Mar 2019 04:47:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552909645; cv=none;
        d=google.com; s=arc-20160816;
        b=u/IhYZ5oFx+fyQrn6u3GHiJH51hMTVlaX4T6AoJgpefGy/3nuHbgwBu7z7R0180qIQ
         Xbw+ry7qMkBMP05hXRImqGi+UnQt4dpDqo003ToAlQdDCXz/tU9dK+TRfoeCtKTRYV+Q
         TB5AYAevHdUaT0ySCL+9WWqDvJyIvEEiuC0kxuBoAtEEiJWJxAKfxsYFXAmwUnlEu7US
         COD1sWPiIsqbOZfjo7fkMzufKMdL2kyqrqN+E5fDSN+kArHx0OoJI6XksnMMaEo2FphT
         yJ3pAku7TG72cAyaOjqeZyfht7ukq0mSXSnZ+lvcKchMyfTPS+43XOGJaKiHYR3Zzwg5
         SIkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cAjTK3lSVPrV3KWiYH4fM9uStQ4aYws3H7LOYwr+AhA=;
        b=ANSDMbWhTDxK1N7bt84NkiR/l31UFxUL2+1yGyUHxZHCZMmawt+VZswOIe45AN7udU
         1dCijKEF9XuJdRAH6dKdsixBqcUOTcvScUgvc8nro3el+1Ly/65QKS58fPdIQc+ZDMdb
         Uy3lRS1EbGTNxodqQmoXz4r+zuFq7WRuvhhbqSz5oM0yY41LoTvR38tZxohT/z4hA+Un
         wjqCurZp07z2mGWy6iDYCzZUrcv/KO/7t2sGaIWftBbuCnGSy5tBqrkqROGhjk+k+yXL
         QjZGc4rKhyVHK5S0kCk5B0kij7q2PBPBi2Onzd40KgXdmZukyF+ynJcnC/CmLzHbgNwE
         36NA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y5si3943537edh.152.2019.03.18.04.47.24
        for <linux-mm@kvack.org>;
        Mon, 18 Mar 2019 04:47:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 02AC81650;
	Mon, 18 Mar 2019 04:47:24 -0700 (PDT)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D824F3F614;
	Mon, 18 Mar 2019 04:47:17 -0700 (PDT)
Subject: Re: [PATCH v11 09/14] kernel, arm64: untag user pointers in
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
 linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org,
 bpf@vger.kernel.org, linux-kselftest@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <c4d65de9867cb3349af6800242da0de751260c6c.1552679409.git.andreyknvl@google.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <96675b72-d325-0682-4864-b6a96f63f8fd@arm.com>
Date: Mon, 18 Mar 2019 11:47:15 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <c4d65de9867cb3349af6800242da0de751260c6c.1552679409.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 15/03/2019 19:51, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
>
> prctl_set_mm() and prctl_set_mm_map() use provided user pointers for vma
> lookups, which can only by done with untagged pointers.
>
> Untag user pointers in these functions.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>   kernel/sys.c | 14 ++++++++++++++
>   1 file changed, 14 insertions(+)
>
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 12df0e5434b8..8e56d87cc6db 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1993,6 +1993,18 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>   	if (copy_from_user(&prctl_map, addr, sizeof(prctl_map)))
>   		return -EFAULT;
>   
> +	prctl_map->start_code	= untagged_addr(prctl_map.start_code);
> +	prctl_map->end_code	= untagged_addr(prctl_map.end_code);
> +	prctl_map->start_data	= untagged_addr(prctl_map.start_data);
> +	prctl_map->end_data	= untagged_addr(prctl_map.end_data);
> +	prctl_map->start_brk	= untagged_addr(prctl_map.start_brk);
> +	prctl_map->brk		= untagged_addr(prctl_map.brk);
> +	prctl_map->start_stack	= untagged_addr(prctl_map.start_stack);
> +	prctl_map->arg_start	= untagged_addr(prctl_map.arg_start);
> +	prctl_map->arg_end	= untagged_addr(prctl_map.arg_end);
> +	prctl_map->env_start	= untagged_addr(prctl_map.env_start);
> +	prctl_map->env_end	= untagged_addr(prctl_map.env_end);

As the buildbot suggests, those -> should be . instead :) You might want to check 
your local build with CONFIG_CHECKPOINT_RESTORE=y.

> +
>   	error = validate_prctl_map(&prctl_map);
>   	if (error)
>   		return error;
> @@ -2106,6 +2118,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
>   			      opt != PR_SET_MM_MAP_SIZE)))
>   		return -EINVAL;
>   
> +	addr = untagged_addr(addr);

This is a bit too coarse, addr is indeed used for find_vma() later on, but it is also 
used to access memory, by prctl_set_mm_mmap() and prctl_set_auxv().

Kevin

> +
>   #ifdef CONFIG_CHECKPOINT_RESTORE
>   	if (opt == PR_SET_MM_MAP || opt == PR_SET_MM_MAP_SIZE)
>   		return prctl_set_mm_map(opt, (const void __user *)addr, arg4);

