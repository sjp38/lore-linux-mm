Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D88F0C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:31:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 962B021773
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:31:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 962B021773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 282B78E0003; Mon, 18 Feb 2019 13:31:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20A5C8E0002; Mon, 18 Feb 2019 13:31:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 085EB8E0003; Mon, 18 Feb 2019 13:31:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CDF9B8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:31:57 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b40so1999164qte.1
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:31:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=/CqTnhJcvsyBRODsiJzC5lOHCfRLwh2bQ5MoCsBltvo=;
        b=ULRlF9hE9nL/Q18qDTbhcYPSLO95k5STPveZPBJbEdKiBZHgpLWV1I6fixCt6RT9LT
         a5+dTjjn/kI6e6+Xr8bslX/sCFcLpGxqrEfabPSokBYxDTqYcaS1Qi6LN+UnCuo+NveD
         fzaK/LjJpW875JK827jUn4y1pkpHHrXA1nR4Qb5eQC4D/coGEGuYTXcqBpzj+nKYCtc1
         R936/FXXS7NiINvpaw7Ea7NnBlz+KAIU0Of9Hphes4uszmFI0WStM8X1zWwzmGA1AuUv
         OE4iLl/E4u3QOb03QeglseUTbzpMuY4h1zmjyxmJyLB/0OCWWWv4y5p+j3fZLKQ3uhJd
         1j/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubrtvT51oFcuTU8UC0kNN3aDWV1AbXyGgT/sXNzJLOOvxy2pLo2
	uJoaKq5LjOsmp8khM+VhbLxE4fNzIy81D0BikSdgPRmwk1dzgpRJKedUGu0eErlZC+hK3+iJWlM
	suy7j+Q3TiPWlXVfPYb6Z7CrrtODgb4KGfqcfwmW7fToT4xiGWtV4mU39DghP5Xnpsw==
X-Received: by 2002:a37:d492:: with SMTP id s18mr16846903qks.343.1550514717528;
        Mon, 18 Feb 2019 10:31:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZo6hk0nAForbwpxQwR846mY4T5H+Fy5GU5/UeGiMaL7K/E6QMBWmcaC6Hp4/n/mBgXWlQO
X-Received: by 2002:a37:d492:: with SMTP id s18mr16846860qks.343.1550514716761;
        Mon, 18 Feb 2019 10:31:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550514716; cv=none;
        d=google.com; s=arc-20160816;
        b=WgYiKxAzLbOO8CrNKa4ouH5GI4mCw+Kq4ecAtELyHoQSyHHtUm7r7mneuO51JMT5PM
         5/gqka3aks5GyRPHDllX4sj+Bf3UR+ADy1mJhMDbdxfXMtlIfBAX0WRMyw0aS36785JM
         SFR+dTOYJv+cqcyLuPzbIsxe1gGaNHFE8YjVHDwt4/Yi40nJipXgG8jnN5XFvXZEBEY6
         FWG+Jf2lqis4yLkkfuxcQC4qGv40tklQA2uE5b4ghCbG3BswRLE9vnK9r2KqJZgxEbrP
         V5IPoqIMVNNWkZK70RE1Git4PwZZtMfUq8sH4oW89Jlq09kBTVnDOSLlDaglG8DeHpb1
         H0eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=/CqTnhJcvsyBRODsiJzC5lOHCfRLwh2bQ5MoCsBltvo=;
        b=bIlrrqEE3/2+FTkOtJ66cbHJwU67xjF3XBUKGlDCv1J/t/mp4SjZwSE45Wg/6tuH3f
         iEpWpZi1R6IVgYko0KaSsZxvy8fdQ6eRx4IE+Tynq6S0918HwQJW271arQZBk0O/RQbI
         oSdP1MVsaaQKm4f4Fin2tEsYi6g5l3vBFl3jdJ7kNB2NlRk+mlsjMewZ910xvWUIvCo3
         jaCUoSacEj/IgLNch2nIG18wVnIAENgFXHqiqMfs6dvvvto4kxcjt8tpHyw7k+l5o0D4
         I6qGoBbKlo9tXMo+dk0vaiuC6tLYoVSlBtGhaEyqt5Nf8TC4ucNP5lLN/rTB1XpGScEZ
         G++Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r48si4105596qtr.9.2019.02.18.10.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 10:31:56 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1IITHsn131958
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:31:56 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qr06f5v6e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:31:55 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 18 Feb 2019 18:31:53 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 18 Feb 2019 18:31:50 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1IIVn9926607702
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 18 Feb 2019 18:31:50 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D4A7EAE058;
	Mon, 18 Feb 2019 18:31:49 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 901C9AE045;
	Mon, 18 Feb 2019 18:31:48 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.239])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 18 Feb 2019 18:31:48 +0000 (GMT)
Date: Mon, 18 Feb 2019 20:31:45 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Matthew Wilcox <willy@infradead.org>,
        Oscar Salvador <OSalvador@suse.com>, linux-mm@kvack.org,
        LKML <linux-kernel@vger.kernel.org>, lkp@01.org,
        Michal Hocko <mhocko@suse.com>, rong.a.chen@intel.com
Subject: Re: [RFC PATCH] mm, memory_hotplug: fix off-by-one in
 is_pageblock_removable
References: <20190218052823.GH29177@shao2-debian>
 <20190218181544.14616-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218181544.14616-1-mhocko@kernel.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021818-0008-0000-0000-000002C1E991
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021818-0009-0000-0000-0000222E1935
Message-Id: <20190218183144.GI25446@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902180137
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 07:15:44PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Rong Chen has reported the following boot crash
> [   40.305212] PGD 0 P4D 0
> [   40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
> [   40.313055] CPU: 1 PID: 239 Comm: udevd Not tainted 5.0.0-rc4-00149-gefad4e4 #1
> [   40.321348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   40.330813] RIP: 0010:page_mapping+0x12/0x80
> [   40.335709] Code: 5d c3 48 89 df e8 0e ad 02 00 85 c0 75 da 89 e8 5b 5d c3 0f 1f 44 00 00 53 48 89 fb 48 8b 43 08 48 8d 50 ff a8 01 48 0f 45 da <48> 8b 53 08 48 8d 42 ff 83 e2 01 48 0f 44 c3 48 83 38 ff 74 2f 48
> [   40.356704] RSP: 0018:ffff88801fa87cd8 EFLAGS: 00010202
> [   40.362714] RAX: ffffffffffffffff RBX: fffffffffffffffe RCX: 000000000000000a
> [   40.370798] RDX: fffffffffffffffe RSI: ffffffff820b9a20 RDI: ffff88801e5c0000
> [   40.378830] RBP: 6db6db6db6db6db7 R08: ffff88801e8bb000 R09: 0000000001b64d13
> [   40.386902] R10: ffff88801fa87cf8 R11: 0000000000000001 R12: ffff88801e640000
> [   40.395033] R13: ffffffff820b9a20 R14: ffff88801f145258 R15: 0000000000000001
> [   40.403138] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
> [   40.412243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   40.418846] CR2: 0000000000000006 CR3: 000000001fa82000 CR4: 00000000000006a0
> [   40.426951] Call Trace:
> [   40.429843]  __dump_page+0x14/0x2c0
> [   40.433947]  is_mem_section_removable+0x24c/0x2c0
> [   40.439327]  removable_show+0x87/0xa0
> [   40.443613]  dev_attr_show+0x25/0x60
> [   40.447763]  sysfs_kf_seq_show+0xba/0x110
> [   40.452363]  seq_read+0x196/0x3f0
> [   40.456282]  __vfs_read+0x34/0x180
> [   40.460233]  ? lock_acquire+0xb6/0x1e0
> [   40.464610]  vfs_read+0xa0/0x150
> [   40.468372]  ksys_read+0x44/0xb0
> [   40.472129]  ? do_syscall_64+0x1f/0x4a0
> [   40.476593]  do_syscall_64+0x5e/0x4a0
> [   40.480809]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> [   40.486195]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> and bisected it down to efad4e475c31 ("mm, memory_hotplug:
> is_mem_section_removable do not pass the end of a zone"). The reason for
> the crash is that the mapping is garbage for poisoned (uninitialized) page.
> This shouldn't happen as all pages in the zone's boundary should be
> initialized. Later debugging revealed that the actual problem is an
> off-by-one when evaluating the end_page. start_pfn + nr_pages resp.
> zone_end_pfn refers to a pfn after the range and as such it might belong
> to a differen memory section. This along with CONFIG_SPARSEMEM then
> makes the loop condition completely bogus because a pointer arithmetic
> doesn't work for pages from two different sections in that memory model.
> 
> Fix the issue by reworking is_pageblock_removable to be pfn based and
> only use struct page where necessary. This makes the code slightly
> easier to follow and we will remove the problematic pointer arithmetic
> completely.
> 
> Fixes: efad4e475c31 ("mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone")
> Reported-by: <rong.a.chen@intel.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/memory_hotplug.c | 27 +++++++++++++++------------
>  1 file changed, 15 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 124e794867c5..1ad28323fb9f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1188,11 +1188,13 @@ static inline int pageblock_free(struct page *page)
>  	return PageBuddy(page) && page_order(page) >= pageblock_order;
>  }
>  
> -/* Return the start of the next active pageblock after a given page */
> -static struct page *next_active_pageblock(struct page *page)
> +/* Return the pfn of the start of the next active pageblock after a given pfn */
> +static unsigned long next_active_pageblock(unsigned long pfn)
>  {
> +	struct page *page = pfn_to_page(pfn);
> +
>  	/* Ensure the starting page is pageblock-aligned */
> -	BUG_ON(page_to_pfn(page) & (pageblock_nr_pages - 1));
> +	BUG_ON(pfn & (pageblock_nr_pages - 1));
>  
>  	/* If the entire pageblock is free, move to the end of free page */
>  	if (pageblock_free(page)) {
> @@ -1200,16 +1202,16 @@ static struct page *next_active_pageblock(struct page *page)
>  		/* be careful. we don't have locks, page_order can be changed.*/
>  		order = page_order(page);
>  		if ((order < MAX_ORDER) && (order >= pageblock_order))
> -			return page + (1 << order);
> +			return pfn + (1 << order);
>  	}
>  
> -	return page + pageblock_nr_pages;
> +	return pfn + pageblock_nr_pages;
>  }
>  
> -static bool is_pageblock_removable_nolock(struct page *page)
> +static bool is_pageblock_removable_nolock(unsigned long pfn)
>  {
> +	struct page *page = pfn_to_page(pfn);
>  	struct zone *zone;
> -	unsigned long pfn;
>  
>  	/*
>  	 * We have to be careful here because we are iterating over memory
> @@ -1232,13 +1234,14 @@ static bool is_pageblock_removable_nolock(struct page *page)
>  /* Checks if this range of memory is likely to be hot-removable. */
>  bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>  {
> -	struct page *page = pfn_to_page(start_pfn);
> -	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> -	struct page *end_page = pfn_to_page(end_pfn);
> +	unsigned long end_pfn, pfn;
> +
> +	end_pfn = min(start_pfn + nr_pages,
> +			zone_end_pfn(page_zone(pfn_to_page(start_pfn))));
>  
>  	/* Check the starting page of each pageblock within the range */
> -	for (; page < end_page; page = next_active_pageblock(page)) {
> -		if (!is_pageblock_removable_nolock(page))
> +	for (pfn = start_pfn; pfn < end_pfn; pfn = next_active_pageblock(pfn)) {
> +		if (!is_pageblock_removable_nolock(pfn))
>  			return false;
>  		cond_resched();
>  	}
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

