Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED5E5C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 13:01:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFB6B2173B
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 13:01:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFB6B2173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43F786B0008; Fri, 19 Jul 2019 09:01:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EDD38E0003; Fri, 19 Jul 2019 09:01:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B7688E0001; Fri, 19 Jul 2019 09:01:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0F2E6B0008
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 09:01:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z20so22025053edr.15
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 06:01:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gpRGflTbpMBYYocaH2hBQ/mkY2iaabyN2ehDaDPcGQY=;
        b=MRPe5g5Lb5rIn1bbXRpwMIGP6Tndoa9EoGkBZmDTOKpy1vHOQjYSyEa9p3CZ0AKYx8
         X/Chwq8V5wwG46Y5FyNYBGrGWkqXpPt8dzJcJeMHOt/HxAyJ5tGliEffIb5+tK+DLZ3S
         t+1pHANt9l+AYa8gvCDRuLcS6huy/BwvJ9Pe0VgMUrRp0CeW26dcO4X9cOo0na86CiU9
         N38Rweb9/916PD1aAecCUipbQmqYSG0Q4OWl1cfYEwqv6NAfUrvTm/wfQF4hcpU/zoYR
         Nj/cVO1oHWRYZoJ2rhpRaG46URo2EwgXrk5m3tPqPIANWQGwbeQA4qaQuwjuH0zr75xe
         lCxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXewL1p/+XLBe7UxZTlPlQL8kTM6AqEtnhn/8WtYc5wCVDNgW/t
	P0MHFTWqsMGqVFtExwf/8Y8E8drEcjZe1IM9/dPMn8PbShJudS30igsYyjSRgS0QfakTvvZu/F6
	E0LeRrpwp/a2kSsBh6qwIvtgtv3U50WYYxUMStxrSWyWwNG3xyy902c7OBHvkn/K8Vw==
X-Received: by 2002:a17:906:19c6:: with SMTP id h6mr40633652ejd.262.1563541279409;
        Fri, 19 Jul 2019 06:01:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0OXMu6rTVS+Oz3GMPfwcM4uZdQ5dvlSq7a0NQu5E2tKloN54CLazPq8LfMnwQhj3NlJ1v
X-Received: by 2002:a17:906:19c6:: with SMTP id h6mr40633573ejd.262.1563541278639;
        Fri, 19 Jul 2019 06:01:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563541278; cv=none;
        d=google.com; s=arc-20160816;
        b=oaX7U10K6melSTYOgxJFuasfod9NgBSl//CORAxroZ4oG4zkIJqJsYtIYnEMfGqXUz
         buMl7Ev9B1Az5xm6x70F5DplxL4zrHvTbzdZ2E0tXjo25oSNR/JkaDilBMHY8OXmGoeJ
         DEZv/HRLj/JLP7CCngYEGekLX61M6jI/FYdSoKPsRZMQxMhN+Yl7Srr0vaSVh1Kw4rJd
         kitEgTtI30Hgtb5k9kt9w8Kdw+LGMV3WOOrEoMp4LbWyce+J0pz2H47BLnD08Oc3aoHP
         zjm3m/KEehFy9fZmf6oeJEggnueZW2FIPjvBuLcnjMZBZ6kWphaxtz+dSr4/Qk0JUifr
         xnBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gpRGflTbpMBYYocaH2hBQ/mkY2iaabyN2ehDaDPcGQY=;
        b=xbLcWGsqmi54u24eYovkFPPQNfjuC0MEBc3JDLoPU8odDL6ZdI1BGeKf8P25NZtveb
         9uTwlE6u0wWK5sNAJRBOCXsFY7SjPrNNy7hUkrS73ykBxFEilYIRdFNFYdxIJK2osuxD
         sUEoAkPgFNQA6SQjgDuS6Qouoej4vvK1g4Ax7MkIftZx4JxfTPepimmyHnYYL7GUM9iN
         Wg3L/ZkJDxKPAI6QQOkvx4B0nKoqcik8bLf8GDn5TkqZP14N7cYEt+puE0YtTRYpuqcE
         VFt8gTEiJStCdQQOxjkz9K2JDp66IQzpqPFFL2CSG8fEB66/vNjuTi3+NksECIO/1Ds9
         u1GA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bq3si930606ejb.272.2019.07.19.06.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 06:01:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2A731AF8F;
	Fri, 19 Jul 2019 13:01:18 +0000 (UTC)
Subject: Re: [v3 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-api@vger.kernel.org
References: <1563470274-52126-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563470274-52126-3-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6ba72e56-9f62-36bf-ded7-f337522715d5@suse.cz>
Date: Fri, 19 Jul 2019 15:01:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1563470274-52126-3-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/18/19 7:17 PM, Yang Shi wrote:
> When running syzkaller internally, we ran into the below bug on 4.9.x
> kernel:
> 
> kernel BUG at mm/huge_memory.c:2124!
> invalid opcode: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 1518 Comm: syz-executor107 Not tainted 4.9.168+ #2
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 0.5.1 01/01/2011
> task: ffff880067b34900 task.stack: ffff880068998000
> RIP: 0010:[<ffffffff81895d6b>]  [<ffffffff81895d6b>] split_huge_page_to_list+0x8fb/0x1030 mm/huge_memory.c:2124
> RSP: 0018:ffff88006899f980  EFLAGS: 00010286
> RAX: 0000000000000000 RBX: ffffea00018f1700 RCX: 0000000000000000
> RDX: 1ffffd400031e2e7 RSI: 0000000000000001 RDI: ffffea00018f1738
> RBP: ffff88006899f9e8 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: fffffbfff0d8b13e R12: ffffea00018f1400
> R13: ffffea00018f1400 R14: ffffea00018f1720 R15: ffffea00018f1401
> FS:  00007fa333996740(0000) GS:ffff88006c600000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020000040 CR3: 0000000066b9c000 CR4: 00000000000606f0
> Stack:
>  0000000000000246 ffff880067b34900 0000000000000000 ffff88007ffdc000
>  0000000000000000 ffff88006899f9e8 ffffffff812b4015 ffff880064c64e18
>  ffffea00018f1401 dffffc0000000000 ffffea00018f1700 0000000020ffd000
> Call Trace:
>  [<ffffffff818490f1>] split_huge_page include/linux/huge_mm.h:100 [inline]
>  [<ffffffff818490f1>] queue_pages_pte_range+0x7e1/0x1480 mm/mempolicy.c:538
>  [<ffffffff817ed0da>] walk_pmd_range mm/pagewalk.c:50 [inline]
>  [<ffffffff817ed0da>] walk_pud_range mm/pagewalk.c:90 [inline]
>  [<ffffffff817ed0da>] walk_pgd_range mm/pagewalk.c:116 [inline]
>  [<ffffffff817ed0da>] __walk_page_range+0x44a/0xdb0 mm/pagewalk.c:208
>  [<ffffffff817edb94>] walk_page_range+0x154/0x370 mm/pagewalk.c:285
>  [<ffffffff81844515>] queue_pages_range+0x115/0x150 mm/mempolicy.c:694
>  [<ffffffff8184f493>] do_mbind mm/mempolicy.c:1241 [inline]
>  [<ffffffff8184f493>] SYSC_mbind+0x3c3/0x1030 mm/mempolicy.c:1370
>  [<ffffffff81850146>] SyS_mbind+0x46/0x60 mm/mempolicy.c:1352
>  [<ffffffff810097e2>] do_syscall_64+0x1d2/0x600 arch/x86/entry/common.c:282
>  [<ffffffff82ff6f93>] entry_SYSCALL_64_after_swapgs+0x5d/0xdb
> Code: c7 80 1c 02 00 e8 26 0a 76 01 <0f> 0b 48 c7 c7 40 46 45 84 e8 4c
> RIP  [<ffffffff81895d6b>] split_huge_page_to_list+0x8fb/0x1030 mm/huge_memory.c:2124
>  RSP <ffff88006899f980>

...

> @@ -532,7 +531,14 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  				has_unmovable |= true;
>  				break;
>  			}
> -			migrate_page_add(page, qp->pagelist, flags);
> +
> +			/*
> +			 * Do not abort immediately since there may be
> +			 * temporary off LRU pages in the range.  Still
> +			 * need migrate other LRU pages.
> +			 */
> +			if (migrate_page_add(page, qp->pagelist, flags))
> +				has_unmovable |= true;

Also = instead of |=

>  		} else
>  			break;
>  	}
> @@ -961,10 +967,21 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  /*
>   * page migration, thp tail pages can be passed.
>   */
> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>  				unsigned long flags)
>  {
>  	struct page *head = compound_head(page);
> +
> +	/*
> +	 * Non-movable page may reach here.  And, there may be
> +	 * temporary off LRU pages or non-LRU movable pages.
> +	 * Treat them as unmovable pages since they can't be
> +	 * isolated, so they can't be moved at the moment.  It
> +	 * should return -EIO for this case too.
> +	 */
> +	if (!PageLRU(head) && (flags & MPOL_MF_STRICT))
> +		return -EIO;

As this test is racy, why not just use the result of isolate_lru_page().

> +
>  	/*
>  	 * Avoid migrating a page that is shared with others.
>  	 */
> @@ -976,6 +993,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>  				hpage_nr_pages(head));
>  		}
>  	}
> +
> +	return 0;
>  }
>  
>  /* page allocation callback for NUMA node migration */
> @@ -1178,9 +1197,10 @@ static struct page *new_page(struct page *page, unsigned long start)
>  }
>  #else
>  
> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>  				unsigned long flags)
>  {
> +	return -EIO;
>  }
>  
>  int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
> 

