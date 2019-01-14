Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2039CC43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 15:53:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9511206B7
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 15:53:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9511206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81A9D8E0009; Mon, 14 Jan 2019 10:53:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A36A8E0002; Mon, 14 Jan 2019 10:53:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66D8C8E0009; Mon, 14 Jan 2019 10:53:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E7A0C8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 10:53:46 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id z5-v6so5606076ljb.13
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 07:53:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=wZITMFUMV0zEIamJ3VVbE4heK6bK4WYzVzsFXzCFVH0=;
        b=V784TSfn0ALfEjoCyOgtJrVEyLBxeVEXGsX0E4F+PORhGCi3OoE0YdrvWAtNBTyMKb
         4LnsG9T01P+jIOu+pjZth43MfyuKN5fVVk0H/Px9+H2X6e3CcuZ7RJlKoy7VKtiTNuCc
         1LuWEWaA5z/L+qvdOd8JQG2PiGNWkwnmunwGBCm9Wb4zB+2HBngyNt7v7CX58v2C/IXz
         wa65CMw51beBLXxCk1kTTi0LTrP5ZbWksIeMbfHRWcrvwNjLiBpi7w0jjpjnF3pZ+ytx
         pcpPammcIY8C2VVq/a72ih05I4mVzx9f3Qz1plRVLELHTYAviXn/rY/+QYomI7khVR25
         EcvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeXK5u8ZdsGVRt61Fu4mjxN55MOhvm4H4kSwZ1M5+BXAA61Vpbv
	pjYUKFQJupn/xugL/yX4gSb3Ad+WhdgTRlpXZ6AQ1j7Kd5L4SXHclI5cs/XEdOJWLb7WygISEdZ
	my5FNaLeY47TSzJ1Vjb2CiHOpf4vtWoZ0o7NkYP1WrBBN5eTgPCtrDKbU+noja2G0s9VSu6ayc7
	7HV00hcwOi5qhFb+FpPtpmGEMumPZOY2cmNcAVkY8EckGoEk4cbUhWtWVfHR/UENcVnyTbEVEMe
	j1tkqTbZej9OPBvgYmyMii9aoQndusg3i/B10Bf8Tx8e8Q/+n+vygwL/x9eya95a7lK4wcyepGr
	Dqf6yHz+OumDvnm70O6xVnMwHIe1hHbdjTn1PU+DpaL1ISVcLLVirRwlFfB0obQVQMBEtkNt117
	l
X-Received: by 2002:ac2:42c5:: with SMTP id n5mr7283669lfl.115.1547481226286;
        Mon, 14 Jan 2019 07:53:46 -0800 (PST)
X-Received: by 2002:ac2:42c5:: with SMTP id n5mr7283626lfl.115.1547481225419;
        Mon, 14 Jan 2019 07:53:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547481225; cv=none;
        d=google.com; s=arc-20160816;
        b=jXYPHphXoag5+UiLNraGFMR4wiOo7Jkk+/YRxgXUfDF8a2RbLjlrown6hQZwazxivT
         CxRbf3Umu9jxx/Z9p/EjQdMU5NBHCXCvvmx0qYzxcHQZC/CA0PM1rmT47H0bbxezYcMi
         dZntrDUyU75s98eaDCts1AwoZ99+0SrtxJnmX/GGkd8qKMrbXZq2HBAV8KBLNBJ0myqw
         n6XoDRATxgFY2VBDNsYpPt/pPX0E8TZXL3XhH1keZial3nF8fqlaCfevy0Y/U0GNTL3y
         NvhQl5We7ZabQ7yohR9xQt+6mM05nRJ1sjWTeAINKm8xZ0s5Ws7KO/Kcv7/Q6SXOezi6
         zoPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=wZITMFUMV0zEIamJ3VVbE4heK6bK4WYzVzsFXzCFVH0=;
        b=SUxuU58EDJ2ubxoRt96ACkabNNzLgcMtkpqTinWTSzJXTIBUSmgvAZsJEAmnAKbnc7
         Npuxy9hjQErJp6yb2X5mx24+iImx4JZKDAmSFDRYxGKErs2a8eZSkuVaaSlU9LUGBD3a
         EtwTwaQ8SJAFsnLzBLjLGP3ZgYSvLSkRFnt7xBAJCFkXX2y0qt4OYXTyyH3Qxg51E2WQ
         oEP4ZItJSXLuNElAn2zD1QSEjb1LtjS1zWmVptze4WEam9UR7IieXXKI0bthYQmbfZF3
         +RDPZFLq8CMuWV7nQbCLrK2r9lF+6Q10xa3wI/t6Tk9nB/hWR7JdolcLrCj4W9Um5ecO
         ADnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j188sor272350lfj.72.2019.01.14.07.53.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 07:53:45 -0800 (PST)
Received-SPF: pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: ALg8bN74ZQTuDIjsqUhLgFMGYUxSw81lMr9Ia6Rp9LV1zOdpgU9nkrJsrZPjHC4E0QC4PQUfRTidFXCqru+uICR4BPA=
X-Received: by 2002:ac2:51af:: with SMTP id f15mr13329880lfk.44.1547481224807;
 Mon, 14 Jan 2019 07:53:44 -0800 (PST)
MIME-Version: 1.0
References: <20190114125903.24845-1-david@redhat.com> <20190114125903.24845-8-david@redhat.com>
In-Reply-To: <20190114125903.24845-8-david@redhat.com>
From: Bhupesh Sharma <bhsharma@redhat.com>
Date: Mon, 14 Jan 2019 21:22:49 +0530
Message-ID:
 <CACi5LpPphoJzfKXPN5kSV42aF27=2ZjqXSVLQjEtMdSN8+6bsA@mail.gmail.com>
Subject: Re: [PATCH v2 7/9] arm64: kdump: No need to mark crashkernel pages
 manually PG_reserved
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-m68k@lists.linux-m68k.org, 
	linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, 
	linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, 
	Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	James Morse <james.morse@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Dave Kleikamp <dave.kleikamp@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, 
	Florian Fainelli <f.fainelli@gmail.com>, Stefan Agner <stefan@agner.ch>, 
	Laura Abbott <labbott@redhat.com>, Greg Hackmann <ghackmann@android.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Kristina Martsenko <kristina.martsenko@arm.com>, 
	CHANDAN VN <chandan.vn@samsung.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, 
	Logan Gunthorpe <logang@deltatee.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114155249.uuvkR4B5c22dK_4K6hgSBciphFGN_-B-Jmme9bVXj_o@z>

Hi David,

On Mon, Jan 14, 2019 at 6:30 PM David Hildenbrand <david@redhat.com> wrote:
>
> The crashkernel is reserved via memblock_reserve(). memblock_free_all()
> will call free_low_memory_core_early(), which will go over all reserved
> memblocks, marking the pages as PG_reserved.
>
> So manually marking pages as PG_reserved is not necessary, they are
> already in the desired state (otherwise they would have been handed over
> to the buddy as free pages and bad things would happen).
>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: James Morse <james.morse@arm.com>
> Cc: Bhupesh Sharma <bhsharma@redhat.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Dave Kleikamp <dave.kleikamp@oracle.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Stefan Agner <stefan@agner.ch>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Greg Hackmann <ghackmann@android.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Kristina Martsenko <kristina.martsenko@arm.com>
> Cc: CHANDAN VN <chandan.vn@samsung.com>
> Cc: AKASHI Takahiro <takahiro.akashi@linaro.org>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Reviewed-by: Matthias Brugger <mbrugger@suse.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/arm64/kernel/machine_kexec.c |  2 +-
>  arch/arm64/mm/init.c              | 27 ---------------------------
>  2 files changed, 1 insertion(+), 28 deletions(-)
>
> diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
> index 6f0587b5e941..66b5d697d943 100644
> --- a/arch/arm64/kernel/machine_kexec.c
> +++ b/arch/arm64/kernel/machine_kexec.c
> @@ -321,7 +321,7 @@ void crash_post_resume(void)
>   * but does not hold any data of loaded kernel image.
>   *
>   * Note that all the pages in crash dump kernel memory have been initially
> - * marked as Reserved in kexec_reserve_crashkres_pages().
> + * marked as Reserved as memory was allocated via memblock_reserve().
>   *
>   * In hibernation, the pages which are Reserved and yet "nosave" are excluded
>   * from the hibernation iamge. crash_is_nosave() does thich check for crash
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 7205a9085b4d..c38976b70069 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -118,35 +118,10 @@ static void __init reserve_crashkernel(void)
>         crashk_res.start = crash_base;
>         crashk_res.end = crash_base + crash_size - 1;
>  }
> -
> -static void __init kexec_reserve_crashkres_pages(void)
> -{
> -#ifdef CONFIG_HIBERNATION
> -       phys_addr_t addr;
> -       struct page *page;
> -
> -       if (!crashk_res.end)
> -               return;
> -
> -       /*
> -        * To reduce the size of hibernation image, all the pages are
> -        * marked as Reserved initially.
> -        */
> -       for (addr = crashk_res.start; addr < (crashk_res.end + 1);
> -                       addr += PAGE_SIZE) {
> -               page = phys_to_page(addr);
> -               SetPageReserved(page);
> -       }
> -#endif
> -}
>  #else
>  static void __init reserve_crashkernel(void)
>  {
>  }
> -
> -static void __init kexec_reserve_crashkres_pages(void)
> -{
> -}
>  #endif /* CONFIG_KEXEC_CORE */
>
>  #ifdef CONFIG_CRASH_DUMP
> @@ -586,8 +561,6 @@ void __init mem_init(void)
>         /* this will put all unused low memory onto the freelists */
>         memblock_free_all();
>
> -       kexec_reserve_crashkres_pages();
> -
>         mem_init_print_info(NULL);
>
>         /*
> --
> 2.17.2

LGTM, so:
Reviewed-by: Bhupesh Sharma <bhsharma@redhat.com>

