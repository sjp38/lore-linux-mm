Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D53D3C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 936EE26F34
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:13:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 936EE26F34
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 470866B0272; Fri, 31 May 2019 17:13:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 421626B0274; Fri, 31 May 2019 17:13:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 336D66B0276; Fri, 31 May 2019 17:13:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F32406B0272
	for <linux-mm@kvack.org>; Fri, 31 May 2019 17:13:49 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o12so7104491pll.17
        for <linux-mm@kvack.org>; Fri, 31 May 2019 14:13:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=V/5dVofbnET34WJi59hoP1Vjo+VNyaneVSJqI0yCbfA=;
        b=LiuKexNzCMy7OYRk9KAUo/pbOr0SOEfKFx3r10vR6DnYKAZuEbDHGCcTyz3GCv9wUO
         FNWg0ahjeyqj1hLYme8dTeULt17s9GX8Bjj4g88Ou/7gf3OmaJi57VAXUPiZMZW8B8lx
         wH4MBruPf0LVYc5WMp5nhHT6dzQMY9vvUYh5YM/ORlKHISn136lm8U2BeItMkRRsqcGj
         zaURfNUj6v4L68CC6zBGeyPudBi/n6EgeTxtVCq/IeLDG89Lin/jssDi7McmKNqTU4KX
         qTMMTmdj34Av3EhGcsbW5jyapD1E6Iqmd6GbIqJlDfAFXosZ5mdmjWOWD+Vbyre/PL5L
         48fQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXlRKhAr/6kYLnwGJdBZWv0KXtFpPeO0kOne8hPEbJDQb3fqUii
	4R+EUU3HCaNMdSxL3i3pAsB1oP0fj0uEzIlGWeUBjNmtc7jHpb4BNwY3bZ5NAwukbFRtMmttEGF
	ISHPOsLcveMF0VjKwCjY8A3y2jWMvZObsVL4SYmMkhVbqnOQhOWxVwYEUunv27TonHA==
X-Received: by 2002:a63:1925:: with SMTP id z37mr7996068pgl.251.1559337229608;
        Fri, 31 May 2019 14:13:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjaxA8ua2niyeb5LygoibSZpCvuNAM84tZQyTSQftLnhgX8wJdgsYvGiMSbsZUMSTeclZN
X-Received: by 2002:a63:1925:: with SMTP id z37mr7995975pgl.251.1559337228677;
        Fri, 31 May 2019 14:13:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559337228; cv=none;
        d=google.com; s=arc-20160816;
        b=V70S4ZKd3FWGDV83i5uBYf/21xATMpjign3HCG5C5BatF9/ViZPNld7NHXOjj5r4ig
         VPVlN/UeL/iDWQw48byiI9Ezq1FhTNYQFB3rAfTQm+Tg324t8hM+Xqx4rhak6wwrJymU
         j98VsiHGfBMBMQ6YBCBhl4+DSzF7bU/GIqDHT8p/9K1DaWWY2HOD4GODz3ePAFPCZc+e
         P+9/FmGJIkE+j+GCKdwrJg0ddVDS1oYGhfEqcSoRjtxo6VK1/+XhWK3XVpZlHfrdyG9U
         G3lW+wlSv/8c5ZD/IJ6QwDmj4ATCnQeSNiE3WipZIdPUEUoBGVNJ96MuOp6HNTnTc+oN
         HNAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=V/5dVofbnET34WJi59hoP1Vjo+VNyaneVSJqI0yCbfA=;
        b=TbR1KL0jHfp0Jm9drQcW2xBBZRAMZDsOg9xRvoOXMUZehfA61CkI0AbhpouAfYkR9l
         S+szuv57Ib0G0zLqt1hfEj4vog5dxfVoyeyR3tn6chq9I0598aVd9j0Vd5SGjR879F5w
         3hCCWrzuAvRpz4TiCToR3ltRgOpGl4k3hfs6qAsT52joDYAZUANRlMfDyFrPrtyVkyj+
         1UGPhQpJ6A1og8qPEEeqZgtSuV46WClThwXiStBLUhSdo+eH24AtmLj83Pbt2/B+tXyg
         GcTv8KgoO6ssnpRGfDMznKevED/GKD3fl9xxjtkEjP7KhveBRJGbfQLUZa38bBmVApK2
         FU8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p11si7081178pgd.65.2019.05.31.14.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 14:13:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 May 2019 14:13:48 -0700
X-ExtLoop1: 1
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga008.jf.intel.com with ESMTP; 31 May 2019 14:13:47 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hWoqQ-000E5Q-Ny; Sat, 01 Jun 2019 05:13:46 +0800
Date: Sat, 1 Jun 2019 05:13:45 +0800
From: kbuild test robot <lkp@intel.com>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [linux-next:master 3880/3985] mm/vmalloc.c:1076:21: sparse: sparse:
 incorrect type in initializer (different address spaces)
Message-ID: <201906010541.Xrg8P8Mi%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   3c09c1950c8483eeeb4bf9615ecdcec7234c6790
commit: 1203396fa708fde7b2bfb892b9f2ce62da485473 [3880/3985] mm/vmalloc.c: preload a CPU with one object for split purpose
reproduce:
        # apt-get install sparse
        # sparse version: v0.6.1-rc1-7-g2b96cd8-dirty
        git checkout 1203396fa708fde7b2bfb892b9f2ce62da485473
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>


sparse warnings: (new ones prefixed by >>)

>> mm/vmalloc.c:1076:21: sparse: sparse: incorrect type in initializer (different address spaces) @@    expected struct vmap_area *[noderef] <asn:3> *__p @@    got [noderef] <asn:3> *__p @@
>> mm/vmalloc.c:1076:21: sparse:    expected struct vmap_area *[noderef] <asn:3> *__p
>> mm/vmalloc.c:1076:21: sparse:    got struct vmap_area **
   mm/vmalloc.c:961:23: sparse: sparse: incorrect type in initializer (different address spaces) @@    expected struct vmap_area *[noderef] <asn:3> *__p @@    got [noderef] <asn:3> *__p @@
   mm/vmalloc.c:961:23: sparse:    expected struct vmap_area *[noderef] <asn:3> *__p
   mm/vmalloc.c:961:23: sparse:    got struct vmap_area **
>> mm/vmalloc.c:1076:21: sparse: sparse: dereference of noderef expression
>> mm/vmalloc.c:1076:21: sparse: sparse: dereference of noderef expression
   mm/vmalloc.c:961:23: sparse: sparse: dereference of noderef expression
   mm/vmalloc.c:961:23: sparse: sparse: dereference of noderef expression

vim +1076 mm/vmalloc.c

  1047	
  1048	/*
  1049	 * Preload this CPU with one extra vmap_area object to ensure
  1050	 * that we have it available when fit type of free area is
  1051	 * NE_FIT_TYPE.
  1052	 *
  1053	 * The preload is done in non-atomic context, thus it allows us
  1054	 * to use more permissive allocation masks to be more stable under
  1055	 * low memory condition and high memory pressure.
  1056	 *
  1057	 * If success it returns 1 with preemption disabled. In case
  1058	 * of error 0 is returned with preemption not disabled. Note it
  1059	 * has to be paired with ne_fit_preload_end().
  1060	 */
  1061	static int
  1062	ne_fit_preload(int nid)
  1063	{
  1064		preempt_disable();
  1065	
  1066		if (!__this_cpu_read(ne_fit_preload_node)) {
  1067			struct vmap_area *node;
  1068	
  1069			preempt_enable();
  1070			node = kmem_cache_alloc_node(vmap_area_cachep, GFP_KERNEL, nid);
  1071			if (node == NULL)
  1072				return 0;
  1073	
  1074			preempt_disable();
  1075	
> 1076			if (__this_cpu_cmpxchg(ne_fit_preload_node, NULL, node))
  1077				kmem_cache_free(vmap_area_cachep, node);
  1078		}
  1079	
  1080		return 1;
  1081	}
  1082	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

