Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4BCCC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 06:05:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FD65218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 06:05:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YIBkx3NH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FD65218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B98AF6B0005; Sat, 23 Mar 2019 02:05:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B47C76B0006; Sat, 23 Mar 2019 02:05:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E90F6B0007; Sat, 23 Mar 2019 02:05:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9816B0005
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 02:05:53 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z14so4102329pgu.1
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 23:05:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=hKQ8kZEdSmog1++4ymlzwB1elhI7efPVvOFvmYPwcMA=;
        b=dPGux3p28M9O+6r1F5Acul7OCZ0yPxGaB5suAL3L/uh4FA0atJYM7JAy5axdWGZRUC
         Cdo1YNV+bEBmijhZexCmUGHsUFLWauuVA7b8epTV6siBBudnysgR3T1PwfRCUaR8kD9+
         SMNv24iTAgAooT8dOyjbdaMWV1PfPZSd7gRxwz7MhAM40TFZ8GYicWwXrcYO8fx9IDhc
         l7AMujg9NB+UJRlYmiig2/PlivZeXWM3L8w76neOTKZLV3Z3DUx2Py3dtlrKg8+g6EbU
         t212Uddrb7V0qx3zyuQpKfs9E3BLfjTqtKXZ+L5xySmH1qWkWSnTIFUNXt/7GPSzDHO3
         VcOg==
X-Gm-Message-State: APjAAAU1VWoxfNz+snzF8T8K4bfWgdVK8AvRFoNIK9PbxRG0HgyRm1uD
	XfNXsvF9QGwxMh0t7nbz46ge1IunBH1OAmYRjBYR4lt9L+M4Mck/PXSumtaC0i4TbbPadFrcZr2
	8DJYLszqIkEhS4rMPQUrjQMzorTzTnmeS+wX88PXZ0IqOfafQd2i1J3azcQQowGsBww==
X-Received: by 2002:a17:902:b698:: with SMTP id c24mr13141487pls.221.1553321152826;
        Fri, 22 Mar 2019 23:05:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh15VkQ5VQxMB0cZaEuFCu+PsLK9cj70EiH5I61ehT4I8ZdRUwpe+Na5hb+VlIKaqpld8N
X-Received: by 2002:a17:902:b698:: with SMTP id c24mr13141437pls.221.1553321151694;
        Fri, 22 Mar 2019 23:05:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553321151; cv=none;
        d=google.com; s=arc-20160816;
        b=lCjD2SfdL6BtGkIHtMCtejdVabhi2de+BjfU/loFs3v0EC0Q2SFoxhR7cG91WrIen/
         T7e6DDFKwdyN3CpVOgvKvKPqls0GWQNQidyX69IJj89fJgzflRorKxEP8FdNE3T9osQQ
         846ONhvRsLqARq/YMg7NTwYBskN5pMwbSgMSFumTLqIZGUTUasnnBE7UxwOOzNWr3H++
         qaNHNtHP5EUpd9WQTgTpiJofaM2s2QjoKO4cAlHvDtwx23rReLIrDmJlsbYnXG+Fds/1
         WNhKLwJzO3shdethXtYWJmODKFaNF0dmc2O3gEUIdKhT90DIuP+/DVoYYE8bv3/yViEK
         Kqgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=hKQ8kZEdSmog1++4ymlzwB1elhI7efPVvOFvmYPwcMA=;
        b=P0Fx13xRicmacIjDAC5WzkOIPEFum346FaTpicJVUkED8i2voJnFdiONQ3dqSfw1kw
         4wjoTlN5e7tGL4J0ft9X85Arlh5+HYvvOTa7sLSZZj+LDYtq24XuC437dVlnP9rB3UlA
         1UZbhKUk1ghtR7AXJgqiVyfgw71De9p5PCzL/tFI6DlDWsIoMVFxjWZXQGR5NwZawpY7
         BwjjS9xpw2Mu04QzINJ5tiu129mnQw9VCjyfjnN+Jt1850SY/wTlptLyOBRq5aaAfO3w
         VXjtqX/rImul1uWLrNDidabnFLESaSmECRgb1U/JSVY9Xt+9hr4BrLrZowL8u/z/4uaa
         2OIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YIBkx3NH;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id i18si8079928pfa.205.2019.03.22.23.05.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 23:05:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YIBkx3NH;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c95ccc10000>; Fri, 22 Mar 2019 23:05:53 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 22 Mar 2019 23:05:50 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 22 Mar 2019 23:05:50 -0700
Received: from [10.2.160.106] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 23 Mar
 2019 06:05:50 +0000
From: Zi Yan <ziy@nvidia.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
CC: <mhocko@suse.com>, <mgorman@techsingularity.net>, <riel@surriel.com>,
	<hannes@cmpxchg.org>, <akpm@linux-foundation.org>, <dave.hansen@intel.com>,
	<keith.busch@intel.com>, <dan.j.williams@intel.com>,
	<fengguang.wu@intel.com>, <fan.du@intel.com>, <ying.huang@intel.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
Date: Fri, 22 Mar 2019 23:03:13 -0700
X-Mailer: MailMate (1.12.4r5614)
Message-ID: <B4EB750E-482B-4E4D-A679-4821E57C172E@nvidia.com>
In-Reply-To: <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_05B36A0E-F195-4C84-A85B-41F79D06720F_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553321153; bh=hKQ8kZEdSmog1++4ymlzwB1elhI7efPVvOFvmYPwcMA=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=YIBkx3NHxrN3JTF4Qe+FxQPpwHMCUpdy12HqzkmIj8UgIfFu8oO3bX+1DB4yOd+5U
	 tgU9ImjesCIbrJH9O471bUF7DGVrJZX0PHGIl2wf3egz3INTB7HT38DOpNUFA+DcBY
	 qsF5pqptWkDVlc/n4D91eFRx627L3Kszz17QP6PE4PHjRb6Bwsq4rHSPQx7OhbdBV+
	 r8PeZDHBbONL5eHTZirUfdj1/5+xThDwgj1p1XwV6Ia3B55MMKbXgfTBlC1FCpomjs
	 T6RLK65gBwg3vN+VZr7n30MpOrz3eEis8/sheEFDTNlGaVLP7U1GUU+zioohe6ev0k
	 xfL6EISCS+PWQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_05B36A0E-F195-4C84-A85B-41F79D06720F_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 22 Mar 2019, at 21:44, Yang Shi wrote:

> Since PMEM provides larger capacity than DRAM and has much lower
> access latency than disk, so it is a good choice to use as a middle
> tier between DRAM and disk in page reclaim path.
>
> With PMEM nodes, the demotion path of anonymous pages could be:
>
> DRAM -> PMEM -> swap device
>
> This patch demotes anonymous pages only for the time being and demote
> THP to PMEM in a whole.  However this may cause expensive page reclaim
> and/or compaction on PMEM node if there is memory pressure on it.  But,=

> considering the capacity of PMEM and allocation only happens on PMEM
> when PMEM is specified explicity, such cases should be not that often.
> So, it sounds worth keeping THP in a whole instead of splitting it.
>
> Demote pages to the cloest non-DRAM node even though the system is
> swapless.  The current logic of page reclaim just scan anon LRU when
> swap is on and swappiness is set properly.  Demoting to PMEM doesn't
> need care whether swap is available or not.  But, reclaiming from PMEM
> still skip anon LRU is swap is not available.
>
> The demotion just happens between DRAM node and its cloest PMEM node.
> Demoting to a remote PMEM node is not allowed for now.
>
> And, define a new migration reason for demotion, called MR_DEMOTE.
> Demote page via async migration to avoid blocking.
>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  include/linux/migrate.h        |  1 +
>  include/trace/events/migrate.h |  3 +-
>  mm/debug.c                     |  1 +
>  mm/internal.h                  | 22 ++++++++++
>  mm/vmscan.c                    | 99 ++++++++++++++++++++++++++++++++++=
--------
>  5 files changed, 107 insertions(+), 19 deletions(-)
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index e13d9bf..78c8dda 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -25,6 +25,7 @@ enum migrate_reason {
>  	MR_MEMPOLICY_MBIND,
>  	MR_NUMA_MISPLACED,
>  	MR_CONTIG_RANGE,
> +	MR_DEMOTE,
>  	MR_TYPES
>  };
>
> diff --git a/include/trace/events/migrate.h b/include/trace/events/migr=
ate.h
> index 705b33d..c1d5b36 100644
> --- a/include/trace/events/migrate.h
> +++ b/include/trace/events/migrate.h
> @@ -20,7 +20,8 @@
>  	EM( MR_SYSCALL,		"syscall_or_cpuset")		\
>  	EM( MR_MEMPOLICY_MBIND,	"mempolicy_mbind")		\
>  	EM( MR_NUMA_MISPLACED,	"numa_misplaced")		\
> -	EMe(MR_CONTIG_RANGE,	"contig_range")
> +	EM( MR_CONTIG_RANGE,	"contig_range")			\
> +	EMe(MR_DEMOTE,		"demote")
>
>  /*
>   * First define the enums in the above macros to be exported to usersp=
ace
> diff --git a/mm/debug.c b/mm/debug.c
> index c0b31b6..cc0d7df 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -25,6 +25,7 @@
>  	"mempolicy_mbind",
>  	"numa_misplaced",
>  	"cma",
> +	"demote",
>  };
>
>  const struct trace_print_flags pageflag_names[] =3D {
> diff --git a/mm/internal.h b/mm/internal.h
> index 46ad0d8..0152300 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -303,6 +303,19 @@ static inline int find_next_best_node(int node, no=
demask_t *used_node_mask,
>  }
>  #endif
>
> +static inline bool has_nonram_online(void)
> +{
> +	int i =3D 0;
> +
> +	for_each_online_node(i) {
> +		/* Have PMEM node online? */
> +		if (!node_isset(i, def_alloc_nodemask))
> +			return true;
> +	}
> +
> +	return false;
> +}
> +
>  /* mm/util.c */
>  void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,=

>  		struct vm_area_struct *prev, struct rb_node *rb_parent);
> @@ -565,5 +578,14 @@ static inline bool is_migrate_highatomic_page(stru=
ct page *page)
>  }
>
>  void setup_zone_pageset(struct zone *zone);
> +
> +#ifdef CONFIG_NUMA
>  extern struct page *alloc_new_node_page(struct page *page, unsigned lo=
ng node);
> +#else
> +static inline struct page *alloc_new_node_page(struct page *page,
> +					       unsigned long node)
> +{
> +	return NULL;
> +}
> +#endif
>  #endif	/* __MM_INTERNAL_H */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a5ad0b3..bdcab6b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1094,6 +1094,19 @@ static void page_check_dirty_writeback(struct pa=
ge *page,
>  		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
>  }
>
> +static inline bool is_demote_ok(struct pglist_data *pgdat)
> +{
> +	/* Current node is not DRAM node */
> +	if (!node_isset(pgdat->node_id, def_alloc_nodemask))
> +		return false;
> +
> +	/* No online PMEM node */
> +	if (!has_nonram_online())
> +		return false;
> +
> +	return true;
> +}
> +
>  /*
>   * shrink_page_list() returns the number of reclaimed pages
>   */
> @@ -1106,6 +1119,7 @@ static unsigned long shrink_page_list(struct list=
_head *page_list,
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> +	LIST_HEAD(demote_pages);
>  	unsigned nr_reclaimed =3D 0;
>
>  	memset(stat, 0, sizeof(*stat));
> @@ -1262,6 +1276,22 @@ static unsigned long shrink_page_list(struct lis=
t_head *page_list,
>  		}
>
>  		/*
> +		 * Demote DRAM pages regardless the mempolicy.
> +		 * Demot anonymous pages only for now and skip MADV_FREE

s/Demot/Demote

> +		 * pages.
> +		 */
> +		if (PageAnon(page) && !PageSwapCache(page) &&
> +		    (node_isset(page_to_nid(page), def_alloc_nodemask)) &&
> +		    PageSwapBacked(page)) {
> +
> +			if (has_nonram_online()) {
> +				list_add(&page->lru, &demote_pages);
> +				unlock_page(page);
> +				continue;
> +			}
> +		}
> +
> +		/*
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
>  		 * Lazyfree page could be freed directly
> @@ -1477,6 +1507,25 @@ static unsigned long shrink_page_list(struct lis=
t_head *page_list,
>  		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
>  	}
>
> +	/* Demote pages to PMEM */
> +	if (!list_empty(&demote_pages)) {
> +		int err, target_nid;
> +		nodemask_t used_mask;
> +
> +		nodes_clear(used_mask);
> +		target_nid =3D find_next_best_node(pgdat->node_id, &used_mask,
> +						 true);
> +
> +		err =3D migrate_pages(&demote_pages, alloc_new_node_page, NULL,
> +				    target_nid, MIGRATE_ASYNC, MR_DEMOTE);
> +
> +		if (err) {
> +			putback_movable_pages(&demote_pages);
> +
> +			list_splice(&ret_pages, &demote_pages);
> +		}
> +	}
> +

I like your approach here. It reuses the existing migrate_pages() interfa=
ce without
adding extra code. I also would like to be CC=E2=80=99d in your future ve=
rsions.

Thank you.

--
Best Regards,
Yan Zi

--=_MailMate_05B36A0E-F195-4C84-A85B-41F79D06720F_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAlyVzCEPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKzIQP/Rs4EavZA7quvdXZxp6jlABmAeeSw3BiYEwL
98gsh5fjHXDNos3fvyvlLRtMIKuES8ob7F96aApHFPYonfrLWTMuvsHjvE4gZBkK
nCKJMUq7+PzhBRGhr6nIBcvD6/3sctoF8J0RboTCtAcSdpUhUFT6jVe4Z6brwql4
eJtKpWDCeXduiMJKaLEEjkIfvr7blzjPRJiPvn60ySCxbZaEYaXT3fmVoUSLvoMh
bf7po9Gfjbx+hf8WuvlHGDjv8bQ1C0krN4xreerPecso7vI1AGCyJ0I4HxMw8iat
yKsUZlz/ee+edM3uJ3U7AnWlHV/Z2bP2D/xoTlwFodLgDHvf9V7X8/Mqkmj3H1Tz
PgUeywfzjMe6f0ihqj/fufTbG1Cx5ZRF8C9OJJ4Ix2g9Nz/ptD3gLlOywYUACWbI
Q/9E4zh50sliNP0tPAUjGsiRumawxjeRoHM/f5kkDA/ab5+F7yV9XoEjmoc3UNLg
omcDHDIMIeva0/7Nnj7+jtgzRegJE6lUT8vKDmBLPCRLPa3fC3b7INfmSHo5VBQK
an6GJmibx0WW82eIyLPTI9oChQ00g18x+MtGivqWTOI5BeN0gFaXJrEdBMT5z2BY
5v9eCo7kibDdygYvmJtepplUursw9UJNt7QkDsME1aRZOfqTy1k39C8gooShIPPz
xmuI8jmc
=VPuK
-----END PGP SIGNATURE-----

--=_MailMate_05B36A0E-F195-4C84-A85B-41F79D06720F_=--

