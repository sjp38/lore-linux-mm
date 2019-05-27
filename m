Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94E5CC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 05:38:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B51D2175B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 05:38:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B51D2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F46A6B000C; Mon, 27 May 2019 01:38:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A3F26B0266; Mon, 27 May 2019 01:38:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 792E86B026B; Mon, 27 May 2019 01:38:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27D376B000C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 01:38:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t58so26224349edb.22
        for <linux-mm@kvack.org>; Sun, 26 May 2019 22:38:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3JKO27Xp9WsSegQDWWrLwzHPR5pxW3eLEEz6i7ZSbuw=;
        b=oUmtJG0pl4R0H0JjRIsCWls/1ALVyNYtXH+PY5GQKbvQarreJdkTljedngtnSCH9Rp
         tzLnEWb8y4UmDkkdUy5tOS8GR4+mP4IJ7ZV17d4YYpwCKDIBLJWpliHqkH5sh9lr8OeH
         fE9vTWK274xn7+VxndiPRTRGPJ6n1T3oadIBpMJGHyac/frqvkDWOcf/V4+EojB1iO0e
         fnTQblpcdmPNb0Sna5Us8vtFFzvxk4Yirir4xMCv/dDTQKAReurK+aH4hTZ3yDQbdMiP
         TRF8iOCF2xmHamfgfbRa/3ucEYP9F/DHxM/mZF7tlw7vylITM3bbts/ZQbt0Rw7/5Rcb
         ID6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUP9unqi+Nd55XgBk2uXYLEwmMl+f1the+jR3KYJTKiS+XNvRdT
	1mWWJHlI2NcU9Ll6YU/IgOwon42NLTqC28D7FQZ7eBXqLIiQDf66V3sTSHD5KOUMFM4zcZGv/lY
	QqHC80uNPBvE/364j8qSpETQy5T+njZIFzqJCpYoW1IqzJto+7ETNyIWYKGCrZuOSDw==
X-Received: by 2002:a17:906:4ed1:: with SMTP id i17mr27065039ejv.118.1558935528589;
        Sun, 26 May 2019 22:38:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJifAUk8Rn0sb/9GUUzZcp1kXxyJsb7Qxu6NAL8KInS0WsoEvEz31Qx5OTkWW06ddinjij
X-Received: by 2002:a17:906:4ed1:: with SMTP id i17mr27064991ejv.118.1558935527483;
        Sun, 26 May 2019 22:38:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558935527; cv=none;
        d=google.com; s=arc-20160816;
        b=nA6/XMr3hN50ZNjpu9/r7AMoxyHxjb5MESaWcOfIHb6KtIF7ogPSf1L8hrhNgZQvXI
         BU4JjrcgJKQ4or/NUyOR8elr4KW359ZH+s8+K3/RTrGWQUzBU+ld6ogp6Tnigz/RsjLl
         1BY2qXI936qNQgkkupF5H9huU47fbTce5Bl3sN6DOccDoXLCEmbmkxWzWyQ3+FdYa1Lt
         HHjIyMPbLgmYU5WiYPOClnEruAdYtGz7lMazqsuU1LuWnp315NXMLpNp/b3DfWBJsO6D
         PWbd+jpNoOsjcvDde8u/Vi8Cjokn4HLy11jR09YIpTF/Bo6BATAJKLGAaxkfXQVGeZGn
         pXMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3JKO27Xp9WsSegQDWWrLwzHPR5pxW3eLEEz6i7ZSbuw=;
        b=ha/6GbqpuWQXIg0z6I704VOGGPdsu/tVOGrSAgHjaklo9fWkPLtZ5vVqNfhQNum7pf
         A+hi9g51tK8xcvOGinVE6VUwRds1+I77tkS30qkB8+1/mU27yROMPgaPfgvneam4/FCY
         inrE9LvC3tVHKqrGeaz3L3k8ePP9TVIcdJ4I855sCdc8A07XsQZZNTxbQ0X0jALNyDgy
         FjxUOYopbkxEExdzw3QKIRMlQdiho6wH0GJEP1u21+mFL4UzUVn6cdmjBUGL0PsDlTBA
         OEwmaeWSKahhZXbEq1ajc2kdA8UUKEy+eHi2YEDMJ9fBjn6zs5LCzyfuYoV/4pnx2ORe
         jR3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e26si614921edd.76.2019.05.26.22.38.46
        for <linux-mm@kvack.org>;
        Sun, 26 May 2019 22:38:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1783D374;
	Sun, 26 May 2019 22:38:45 -0700 (PDT)
Received: from [10.162.40.17] (p8cg001049571a15.blr.arm.com [10.162.40.17])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3D7E53F690;
	Sun, 26 May 2019 22:38:42 -0700 (PDT)
Subject: Re: [PATCH] mm, compaction: Make sure we isolate a valid PFN
To: Suzuki K Poulose <suzuki.poulose@arm.com>, linux-mm@kvack.org
Cc: mgorman@techsingularity.net, akpm@linux-foundation.org, mhocko@suse.com,
 cai@lca.pw, linux-kernel@vger.kernel.org, marc.zyngier@arm.com,
 kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org
References: <20190524103924.GN18914@techsingularity.net>
 <1558711908-15688-1-git-send-email-suzuki.poulose@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <8068e2e2-e90d-e8b8-55dc-9dee7d73c5e3@arm.com>
Date: Mon, 27 May 2019 11:08:54 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1558711908-15688-1-git-send-email-suzuki.poulose@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/24/2019 09:01 PM, Suzuki K Poulose wrote:
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

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

