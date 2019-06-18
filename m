Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39D21C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:03:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0AE120665
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:02:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0AE120665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E9986B0003; Tue, 18 Jun 2019 09:02:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 799C28E0005; Tue, 18 Jun 2019 09:02:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B1258E0001; Tue, 18 Jun 2019 09:02:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6676B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:02:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so21184286eda.9
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:02:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZnYddHVsss/yjZIqJqEgfigmxJOdBmw0DT6tbwJE5aI=;
        b=H1PbF4hHBViGmaPRGeLgyodxhBdNkZFQ7P7XQcyH3K2Dr8SvgZv7BiXBPEii1n4TuV
         dHMSO9PxznqOhQVa+yCQAlzOqJq0J4Ve3gru/WtLPWqO+5tfKDXoxKHcb8j/b1TAu7re
         LG3t6VJd82F+MQBc5HSGUNBVRKw14aNVPOjtto4XDR9wC89imlUgM8Q050E3qTNZhEph
         cszHmfcR8KjdWWXFCxsDRdi9DkDi0vJimJxtAyyMlggac/MiELgtJig6rd9u7CUEmsw6
         9YQW+pvB+7beWM0iwC49V7wfI8bJ4pDHUdKfQ6PuppChBLaucR39cRXlPbUESct6/yfA
         am+w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWg7Eycdsr3njf67gzaP0egYA+MI62lBXGSCxxqCtA5PWDpcypl
	2dQukyDyPX2qCAajWrEaIi48S/432vvi1SnbRaLp4By56K1mRENj8Sw+SeBEjOmpkDziEqOjHNH
	YXn5sRf6VDcoB8ovdhkHwUqzWJl2f2SEGZdJcKo/sgPMSQeocolSRlebuSZADvyI=
X-Received: by 2002:a50:d751:: with SMTP id i17mr124779666edj.121.1560862978634;
        Tue, 18 Jun 2019 06:02:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnwtwKsacq0XROPYaFxh8GLSXKuZ+QW58MJTtsI/PN62ieBf7XTgaFyiEaqpF/qgRDjZiX
X-Received: by 2002:a50:d751:: with SMTP id i17mr124779530edj.121.1560862977514;
        Tue, 18 Jun 2019 06:02:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560862977; cv=none;
        d=google.com; s=arc-20160816;
        b=iRQJIv/lCBzONbSjAqoYV4YuVX4VwvHWv/u5RgKE+EaRJQljD5C9T8hs0es8aX6eoy
         0sv6tTCcPqTTPxXskGx1m9dgMbC/uqmsIJ/1QCM2ClwWpO93Idmr3T+1tdrlG/9bESA/
         5oqEvvYMJ+x8EYQNzon/7f1+IOWkGHAANBBMtPyDNO69L3c5OGzNCcIkxYGPmoKduxfd
         EZKk+4/Q2pvFedeMWyGyN63WjNA2LQBvgS6ZW5tpMElwDrRF3Qap/IA12aphDG+oZkyb
         fQ0u3IoCaTvu0O3xB8plpkhHsW8uINa/C2Jz3rx4W2swnpR+9WI1FI5gDdD9Ss+z0wPN
         3i+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZnYddHVsss/yjZIqJqEgfigmxJOdBmw0DT6tbwJE5aI=;
        b=chcfqODjd/qyT+MG3cWYIPqyng7xU7PdvoR56AozALa39ROGW3wQeOJR3zO172b+a8
         ICQrGm5qNTlfzQy6dn2HA6hUHcI9BMz8dXeRQGY9JqE70ZGctnfhs8GTO2qPdHHzWMVv
         PC1XxQ8E1SNGFzMEvzwoDsVbuVDLZyl8gNd2WHxWrhvkyeFQLSOC+Vzx0weJ+0laFKSz
         g8g6zYZL7eJOd36RDeGMacaMZib+FhiXkDZIqBW6wLMxYIya5kGhXWsX1JYfNbOT4ora
         jCYIgXOIHw6yCaDKx++0rPVdBpjBN4m4ikDnSZ5RF+NxwhdbKwYXT8CfwvtD9xILIAWr
         xIYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si10850674edb.419.2019.06.18.06.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 06:02:57 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EAD26B034;
	Tue, 18 Jun 2019 13:02:54 +0000 (UTC)
Date: Tue, 18 Jun 2019 15:02:53 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Subject: Re: [PATCH] mm: mempolicy: handle vma with unmovable pages mapped
 correctly in mbind
Message-ID: <20190618130253.GH3318@dhcp22.suse.cz>
References: <1560797290-42267-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560797290-42267-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc networking people - see a question about setsockopt below]

On Tue 18-06-19 02:48:10, Yang Shi wrote:
> When running syzkaller internally, we ran into the below bug on 4.9.x
> kernel:
> 
> kernel BUG at mm/huge_memory.c:2124!

What is the BUG_ON because I do not see any BUG_ON neither in v4.9 nor
the latest stable/linux-4.9.y

> invalid opcode: 0000 [#1] SMP KASAN
[...]
> Code: c7 80 1c 02 00 e8 26 0a 76 01 <0f> 0b 48 c7 c7 40 46 45 84 e8 4c
> RIP  [<ffffffff81895d6b>] split_huge_page_to_list+0x8fb/0x1030 mm/huge_memory.c:2124
>  RSP <ffff88006899f980>
> 
> with the below test:
> 
> ---8<---
> 
> uint64_t r[1] = {0xffffffffffffffff};
> 
> int main(void)
> {
> 	syscall(__NR_mmap, 0x20000000, 0x1000000, 3, 0x32, -1, 0);
> 				intptr_t res = 0;
> 	res = syscall(__NR_socket, 0x11, 3, 0x300);
> 	if (res != -1)
> 		r[0] = res;
> *(uint32_t*)0x20000040 = 0x10000;
> *(uint32_t*)0x20000044 = 1;
> *(uint32_t*)0x20000048 = 0xc520;
> *(uint32_t*)0x2000004c = 1;
> 	syscall(__NR_setsockopt, r[0], 0x107, 0xd, 0x20000040, 0x10);
> 	syscall(__NR_mmap, 0x20fed000, 0x10000, 0, 0x8811, r[0], 0);
> *(uint64_t*)0x20000340 = 2;
> 	syscall(__NR_mbind, 0x20ff9000, 0x4000, 0x4002, 0x20000340,
> 0x45d4, 3);
> 	return 0;
> }
> 
> ---8<---
> 
> Actually the test does:
> 
> mmap(0x20000000, 16777216, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x20000000
> socket(AF_PACKET, SOCK_RAW, 768)        = 3
> setsockopt(3, SOL_PACKET, PACKET_TX_RING, {block_size=65536, block_nr=1, frame_size=50464, frame_nr=1}, 16) = 0
> mmap(0x20fed000, 65536, PROT_NONE, MAP_SHARED|MAP_FIXED|MAP_POPULATE|MAP_DENYWRITE, 3, 0) = 0x20fed000
> mbind(..., MPOL_MF_STRICT|MPOL_MF_MOVE) = 0

Ughh. Do I get it right that that this setsockopt allows an arbitrary
contiguous memory allocation size to be requested by a unpriviledged
user? Or am I missing something that restricts there any restriction?

> The setsockopt() would allocate compound pages (16 pages in this test)
> for packet tx ring, then the mmap() would call packet_mmap() to map the
> pages into the user address space specifed by the mmap() call.
> 
> When calling mbind(), it would scan the vma to queue the pages for
> migration to the new node.  It would split any huge page since 4.9
> doesn't support THP migration, however, the packet tx ring compound
> pages are not THP and even not movable.  So, the above bug is triggered.
> 
> However, the later kernel is not hit by this issue due to the commit
> d44d363f65780f2ac2ec672164555af54896d40d ("mm: don't assume anonymous
> pages have SwapBacked flag"), which just removes the PageSwapBacked
> check for a different reason.
> 
> But, there is a deeper issue.  According to the semantic of mbind(), it
> should return -EIO if MPOL_MF_MOVE or MPOL_MF_MOVE_ALL was specified and
> the kernel was unable to move all existing pages in the range.  The tx ring
> of the packet socket is definitely not movable, however, mbind returns
> success for this case.
> 
> Although the most socket file associates with non-movable pages, but XDP
> may have movable pages from gup.  So, it sounds not fine to just check
> the underlying file type of vma in vma_migratable().
> 
> Change migrate_page_add() to check if the page is movable or not, if it
> is unmovable, just return -EIO.  We don't have to check non-LRU movable
> pages since just zsmalloc and virtio-baloon support this.  And, they
> should be not able to reach here.

You are not checking whether the page is movable, right? You only rely
on PageLRU check which is not really an equivalent thing. There are
movable pages which are not LRU and also pages might be off LRU
temporarily for many reasons so this could lead to false positives.
So I do not think this fix is correct. Blowing up on a BUG_ON is
definitely not a right thing to do but we should rely on migrate_pages
to fail the migration and report the failure based on that.

> With this change the above test would return -EIO as expected.
> 
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  include/linux/mempolicy.h |  3 ++-
>  mm/mempolicy.c            | 22 +++++++++++++++++-----
>  2 files changed, 19 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 5228c62..cce7ba3 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -198,7 +198,8 @@ static inline bool vma_migratable(struct vm_area_struct *vma)
>  	if (vma->vm_file &&
>  		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
>  								< policy_zone)
> -			return false;
> +		return false;
> +

Any reason to make this change?

>  	return true;
>  }
>  
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 2219e74..4d9e17d 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -403,7 +403,7 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
>  	},
>  };
>  
> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>  				unsigned long flags);
>  
>  struct queue_pages {
> @@ -467,7 +467,9 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>  			goto unlock;
>  		}
>  
> -		migrate_page_add(page, qp->pagelist, flags);
> +		ret = migrate_page_add(page, qp->pagelist, flags);
> +		if (ret)
> +			goto unlock;
>  	} else
>  		ret = -EIO;
>  unlock:
> @@ -521,7 +523,9 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
>  			if (!vma_migratable(vma))
>  				break;
> -			migrate_page_add(page, qp->pagelist, flags);
> +			ret = migrate_page_add(page, qp->pagelist, flags);
> +			if (ret)
> +				break;
>  		} else
>  			break;
>  	}
> @@ -940,10 +944,15 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  /*
>   * page migration, thp tail pages can be passed.
>   */
> -static void migrate_page_add(struct page *page, struct list_head *pagelist,
> +static int migrate_page_add(struct page *page, struct list_head *pagelist,
>  				unsigned long flags)
>  {
>  	struct page *head = compound_head(page);
> +
> +	/* Non-movable page may reach here. */
> +	if (!PageLRU(head))
> +		return -EIO;
> +
>  	/*
>  	 * Avoid migrating a page that is shared with others.
>  	 */
> @@ -955,6 +964,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>  				hpage_nr_pages(head));
>  		}
>  	}
> +
> +	return 0;
>  }
>  
>  /* page allocation callback for NUMA node migration */
> @@ -1157,9 +1168,10 @@ static struct page *new_page(struct page *page, unsigned long start)
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
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

