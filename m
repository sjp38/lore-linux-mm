Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A44C1C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 618BD2075E
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:51:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 618BD2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 094366B000A; Fri, 24 May 2019 11:51:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06CAC6B000C; Fri, 24 May 2019 11:51:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E77456B0266; Fri, 24 May 2019 11:51:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1106B000A
	for <linux-mm@kvack.org>; Fri, 24 May 2019 11:51:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p14so14836292edc.4
        for <linux-mm@kvack.org>; Fri, 24 May 2019 08:51:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VIze2iBGaJH6DRuZZ+HkDVlqe6aoAL2eu78GhYDgnfc=;
        b=XZKbpV7EwgehjHsYn7/2IC5KPopoZCfs9niIsHhnzRa8ue+AINSpeBmSHWREjB5+jV
         6juhx8Sc783KYDt1T6+DjEENX90zRHl9lSTfipatyoVzOymAKdLiziAknLuH91IyfyHc
         //I9cMQ9TdxLmGi3upW7cw7IuLcHIQZ+Zi0YL2uNLvRjwsNblhwKOEzZD5VaCY2vtWGd
         QYZHlRJiVWenyp3syCh1/HOR9Mgkr6pWHZQG9R1fnEr6+F9ab9/UbMttajkAM6bkFTDM
         O6x+Lt6NiSYzvCmoHyXfublIRJ1tpGEfv6Qw9eEqgdyjNV5oLgX/EphHW8PwjwXi5U+2
         pHYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXavKBeJEK6cr2DnRMRGTjQZbae/51D6quxE1VfbNPrHxRgxB/l
	qa9AQQZ+mXvg70qGWsKzJUvhyJnCKkjnWsuBahIxf8HsHVibQ9YrIJ7i/oC6p2enLyfxrhfk4Q2
	f2GeoRDl3z2NDiJKzndhRj1L3tY5ZZJfOM1pEVYng1Xb0Q6gyFY4kZq53f4QLqT1fzg==
X-Received: by 2002:a17:906:fc6:: with SMTP id c6mr15827425ejk.218.1558713118180;
        Fri, 24 May 2019 08:51:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKAArwYlnLD+Vfkrq2bKA1InHNqZqQjvrTkDCxdDBpTJ+RGjK+Dq5WWaYu6mX/Z6FgdToa
X-Received: by 2002:a17:906:fc6:: with SMTP id c6mr15827356ejk.218.1558713117378;
        Fri, 24 May 2019 08:51:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558713117; cv=none;
        d=google.com; s=arc-20160816;
        b=VkoSpckKEs2Tdpa8XRP+H/yUAZ8E55r6qRVe3oDJy56NHjVb7dS2/DAJUkji/g3PGL
         Lx7jRRUjpsk+n2+RuH2oQ97hOZTypLeey4VXF8NVQRKpSAWKVW7fqEz+ux3/I7rm4fUP
         genZ5vXDUENqcsdyEmJN/wRuD70bu4UIU65+BWqH/2U/NgEiS+cv/xIl8ngod9jcNECS
         jGn/Zrk5Jsd/Fc49Qvs90e+EwIi1zcRJMMP9ETMPj895+JSgr4CqaC4dO2c79Fw8T21C
         CtCvFdU9/I/YZhNrejQmjFRLVLuYR5ysmLKM0yazljgW+uyvrSyh3OWziDoOc8M3iE8J
         xLTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VIze2iBGaJH6DRuZZ+HkDVlqe6aoAL2eu78GhYDgnfc=;
        b=K+Yc2iDCihGhXKMA1E4cPlQO21AYuATJiML9k0bCKKq/cqyRzaG9z18NSSNsjH4oXm
         lXtNvoUqgWubeQ9dVH9xTEJn3adGKzfDRumFQ9575FJxTngrQU/xxIoQjFY5ZwOhVABe
         aBrfG+drxah9V4g4RZJJeFX0T/2/qT7U29l7PW70pdRNEeVXWzZT8KfFthTH0b9OYGN9
         54eVvrNu05z2WkI7HRdkUuXOLDAX2kUNNCKi7i9S3yK8zVLLDr2jRuBHZ5Xlt8ESray5
         63U/EUzJ+9teHWXcObD0kurDvbzsw7gVnCpz2TYnY77AkrqQVah5DTqVbHeKSfAW+BZ5
         /ijw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp19.blacknight.com (outbound-smtp19.blacknight.com. [46.22.139.246])
        by mx.google.com with ESMTPS id c15si1898202ejk.217.2019.05.24.08.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 08:51:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) client-ip=46.22.139.246;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp19.blacknight.com (Postfix) with ESMTPS id E324C1C28BF
	for <linux-mm@kvack.org>; Fri, 24 May 2019 16:51:56 +0100 (IST)
Received: (qmail 32091 invoked from network); 24 May 2019 15:51:56 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 24 May 2019 15:51:56 -0000
Date: Fri, 24 May 2019 16:51:55 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Suzuki K Poulose <suzuki.poulose@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com,
	cai@lca.pw, linux-kernel@vger.kernel.org, marc.zyngier@arm.com,
	kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org
Subject: Re: [PATCH] mm, compaction: Make sure we isolate a valid PFN
Message-ID: <20190524155155.GQ18914@techsingularity.net>
References: <20190524103924.GN18914@techsingularity.net>
 <1558711908-15688-1-git-send-email-suzuki.poulose@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1558711908-15688-1-git-send-email-suzuki.poulose@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 04:31:48PM +0100, Suzuki K Poulose wrote:
> When we have holes in a normal memory zone, we could endup having
> cached_migrate_pfns which may not necessarily be valid, under heavy memory
> pressure with swapping enabled ( via __reset_isolation_suitable(), triggered
> by kswapd).
> 
> Later if we fail to find a page via fast_isolate_freepages(), we may
> end up using the migrate_pfn we started the search with, as valid
> page. This could lead to accessing NULL pointer derefernces like below,
> due to an invalid mem_section pointer.
> 
> Unable to handle kernel NULL pointer dereference at virtual address 0000000000000008 [47/1825]
>  Mem abort info:
>    ESR = 0x96000004
>    Exception class = DABT (current EL), IL = 32 bits
>    SET = 0, FnV = 0
>    EA = 0, S1PTW = 0
>  Data abort info:
>    ISV = 0, ISS = 0x00000004
>    CM = 0, WnR = 0
>  user pgtable: 4k pages, 48-bit VAs, pgdp = 0000000082f94ae9
>  [0000000000000008] pgd=0000000000000000
>  Internal error: Oops: 96000004 [#1] SMP
>  ...
>  CPU: 10 PID: 6080 Comm: qemu-system-aar Not tainted 510-rc1+ #6
>  Hardware name: AmpereComputing(R) OSPREY EV-883832-X3-0001/OSPREY, BIOS 4819 09/25/2018
>  pstate: 60000005 (nZCv daif -PAN -UAO)
>  pc : set_pfnblock_flags_mask+0x58/0xe8
>  lr : compaction_alloc+0x300/0x950
>  [...]
>  Process qemu-system-aar (pid: 6080, stack limit = 0x0000000095070da5)
>  Call trace:
>   set_pfnblock_flags_mask+0x58/0xe8
>   compaction_alloc+0x300/0x950
>   migrate_pages+0x1a4/0xbb0
>   compact_zone+0x750/0xde8
>   compact_zone_order+0xd8/0x118
>   try_to_compact_pages+0xb4/0x290
>   __alloc_pages_direct_compact+0x84/0x1e0
>   __alloc_pages_nodemask+0x5e0/0xe18
>   alloc_pages_vma+0x1cc/0x210
>   do_huge_pmd_anonymous_page+0x108/0x7c8
>   __handle_mm_fault+0xdd4/0x1190
>   handle_mm_fault+0x114/0x1c0
>   __get_user_pages+0x198/0x3c0
>   get_user_pages_unlocked+0xb4/0x1d8
>   __gfn_to_pfn_memslot+0x12c/0x3b8
>   gfn_to_pfn_prot+0x4c/0x60
>   kvm_handle_guest_abort+0x4b0/0xcd8
>   handle_exit+0x140/0x1b8
>   kvm_arch_vcpu_ioctl_run+0x260/0x768
>   kvm_vcpu_ioctl+0x490/0x898
>   do_vfs_ioctl+0xc4/0x898
>   ksys_ioctl+0x8c/0xa0
>   __arm64_sys_ioctl+0x28/0x38
>   el0_svc_common+0x74/0x118
>   el0_svc_handler+0x38/0x78
>   el0_svc+0x8/0xc
>  Code: f8607840 f100001f 8b011401 9a801020 (f9400400)
>  ---[ end trace af6a35219325a9b6 ]---
> 
> The issue was reported on an arm64 server with 128GB with holes in the zone
> (e.g, [32GB@4GB, 96GB@544GB]), with a swap device enabled, while running 100 KVM
> guest instances.
> 
> This patch fixes the issue by ensuring that the page belongs to a valid PFN
> when we fallback to using the lower limit of the scan range upon failure in
> fast_isolate_freepages().
> 
> Fixes: 5a811889de10f1eb ("mm, compaction: use free lists to quickly locate a migration target")
> Reported-by: Marc Zyngier <marc.zyngier@arm.com>
> Signed-off-by: Suzuki K Poulose <suzuki.poulose@arm.com>

Reviewed-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

