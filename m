Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31602C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:38:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3DF720866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:38:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="KGGpG8Iz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3DF720866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F5046B0269; Wed, 12 Jun 2019 15:38:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77EF56B026A; Wed, 12 Jun 2019 15:38:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6464C6B026B; Wed, 12 Jun 2019 15:38:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36EAB6B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:38:03 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id d204so5905796oib.9
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 12:38:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0Vsa8HyqC2oPVjqlWmiidGbfDST1iKBAlh+u3suUXlA=;
        b=of4GSGtxvrzXoEnbRtZAgLb/ZBjv9OZSXfI0fNfyofMbv2zQP6bGXuUp7825dVIR40
         3O654VLny2nETTHOeD1cTqyR+NvICez/e2Yy3EaI9r/CxMMfZBEAjXDJ3aHSbBwR3+9c
         cHT4Jf2hXE3op7g5zr8l0Zo5yonvA/5fQAkeZp4jLxi9bUaa9fnVn9yRLlU0rd6eZKgX
         HibJuk6Pwe9vCHaeWRRa/Urvoh6FJPVhGa5mN2vyCTr2wqKyS+blin8m2s/fBtTNQllO
         sdn2KxaldNREg2/nc5ri2kxnuHZa/K5rGJyCvs+CbJ7j90Vh02aiZqba82WviePuzr0w
         Cegw==
X-Gm-Message-State: APjAAAXYr6mWMKAQrIxDQurnMvZSr2mLrzw6rwUn26a+Y+wqrCu6a0zP
	xa3jB0TpT8lhPQ32rB2+wGf3tI91Q1VdPwk7rn25eMaQ/twydiRaTO+wIFA0jB3qOYrj+vavXpw
	94q0qSdUGkZv5LDcKyOmr/ijUwzLqz6/dYbXedyUhLCMKuQgCRnHS+NXXRSsGiI+NMQ==
X-Received: by 2002:aca:e1c6:: with SMTP id y189mr586747oig.92.1560368282781;
        Wed, 12 Jun 2019 12:38:02 -0700 (PDT)
X-Received: by 2002:aca:e1c6:: with SMTP id y189mr586717oig.92.1560368281993;
        Wed, 12 Jun 2019 12:38:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560368281; cv=none;
        d=google.com; s=arc-20160816;
        b=oPSjLn97bkNoI1g9p6uMJe8gUkjW3/3FoNjUpiJO+GB+8jX55xfZz765cBlXhdGOSs
         59c52X5ChOSRqw9RMcZHmMAGkzBK3x2j0ubsdJ3rur2Z4b36HYQcg3gsC0lVC12pTe2Q
         w4vo46pt4vMCmUW1qbeR+0vmMvv7RumHC8cLI3qWVpUmGa0L77Wz6/vcQ1JBD7gyOCKK
         zNhPHUauiT0VQWLm7sDvQ+mfBygnnUH5Sib6GASVuOsi8qdextKtbusswBe4WX1qdObj
         f2KJUFHm58blZ9v3Q2tjLzOmtH4Fn9MQSQsxvN1teFnCcJ/a19SojWmkANtXMOuWy54C
         f2Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0Vsa8HyqC2oPVjqlWmiidGbfDST1iKBAlh+u3suUXlA=;
        b=Gm91ZcK0aB2afsYgG8Ft32r656vdV6ByL3rLgGHyo/juA7G2rXZZLIIt3ney4BNXtB
         DSXNdCE02/g/U0Ww9Jb2t+HenrYnPj3U6oIIVkZqFguAQNHvrPhh2sLMn17IEKhFL+6z
         5E/U7meh/JNZmXOnLy6MmgB3wig+yFgDBTxd2S+YVEX4YDu3yITvN/3wKzVNVN271QYV
         RbTtMfjCBRcfs+GYkGM6w1ktwyQo0Q52aa7X+GORMg8nn+On9DxZtlvpEX42wP8M8urO
         BorLihlXpFPkdHrvyRXU07YgZ2qh7rNdxEEodXywE11fnOgu9MX6nXhpWQwwhVXP3cHm
         +PQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KGGpG8Iz;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 186sor455459oih.101.2019.06.12.12.38.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 12:38:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KGGpG8Iz;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0Vsa8HyqC2oPVjqlWmiidGbfDST1iKBAlh+u3suUXlA=;
        b=KGGpG8IzSmQohtF+bMSMFl4GFI15MvmdWRIlvGpQyOPp35DsSAu2JozT3LGhHlQ1ra
         FNFgVxOVWVBq7FOtyKPIdP04Myv72GdGJDG/s4L7Mb6s3JvP+6MBMgEFXX5molJ7old0
         6si/wHUAvzULxk8fzjD1TWJvwttYJbt+mBabkmLGSrfCl/NoFalC9FCSfvjjeeqANhG8
         ouCGKedWKozURrDF2xKTG1yTWv9gz0MUFNadg/r0qBcUA5mNVxL/KhXg7SqNxGbX094l
         O/yrR7vV4ZPh5idL0/z0TmmYhtzd+dhOi0QEo1kktO976505BmdBaX4Ld6+H5PqzWf8I
         RRMw==
X-Google-Smtp-Source: APXvYqzW5RJxhzCoPftf/A/PNavKGkuPNW5LiOizI6LRDGXLVwIJ9/ouGmWX6jQxJ6p1DBRxRCBCrKftesSOqV/nJ+E=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr618670oii.0.1560368281476;
 Wed, 12 Jun 2019 12:38:01 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
In-Reply-To: <1560366952-10660-1-git-send-email-cai@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Jun 2019 12:37:49 -0700
Message-ID: <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 12:16 PM Qian Cai <cai@lca.pw> wrote:
>
> The linux-next commit "mm/sparsemem: Add helpers track active portions
> of a section at boot" [1] causes a crash below when the first kmemleak
> scan kthread kicks in. This is because kmemleak_scan() calls
> pfn_to_online_page(() which calls pfn_valid_within() instead of
> pfn_valid() on x86 due to CONFIG_HOLES_IN_ZONE=n.
>
> The commit [1] did add an additional check of pfn_section_valid() in
> pfn_valid(), but forgot to add it in the above code path.
>
> page:ffffea0002748000 is uninitialized and poisoned
> raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> ------------[ cut here ]------------
> kernel BUG at include/linux/mm.h:1084!
> invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
> CPU: 5 PID: 332 Comm: kmemleak Not tainted 5.2.0-rc4-next-20190612+ #6
> Hardware name: Lenovo ThinkSystem SR530 -[7X07RCZ000]-/-[7X07RCZ000]-,
> BIOS -[TEE113T-1.00]- 07/07/2017
> RIP: 0010:kmemleak_scan+0x6df/0xad0
> Call Trace:
>  kmemleak_scan_thread+0x9f/0xc7
>  kthread+0x1d2/0x1f0
>  ret_from_fork+0x35/0x4
>
> [1] https://patchwork.kernel.org/patch/10977957/
>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  include/linux/memory_hotplug.h | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 0b8a5e5ef2da..f02be86077e3 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -28,6 +28,7 @@
>         unsigned long ___nr = pfn_to_section_nr(___pfn);           \
>                                                                    \
>         if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr) && \
> +           pfn_section_valid(__nr_to_section(___nr), pfn) &&      \
>             pfn_valid_within(___pfn))                              \
>                 ___page = pfn_to_page(___pfn);                     \
>         ___page;                                                   \

Looks ok to me:

Acked-by: Dan Williams <dan.j.williams@intel.com>

...but why is pfn_to_online_page() a multi-line macro instead of a
static inline like all the helper routines it invokes?

