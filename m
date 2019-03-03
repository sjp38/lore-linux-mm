Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C53A0C43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 22:07:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7185D20842
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 22:07:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7185D20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA6DA8E0003; Sun,  3 Mar 2019 17:07:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C54CE8E0001; Sun,  3 Mar 2019 17:07:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B44D78E0003; Sun,  3 Mar 2019 17:07:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 75C668E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 17:07:27 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 19so3058621pfo.10
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 14:07:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=Jh1RrHS/0Qn0+szMfe9763lhRMqIScGFPVsAnFBaE7Y=;
        b=fMTWrdr7EZXvgI2WrkiCnW8LrVSUaJhF858mdCILcCxs0pkn62zlgZnaG5oxQG899a
         J0xnWFnNh7DBR//ujXdk7iQVHQg8Mx1PIBfcnD+kniK1z/r4Nj1gniN0r7pk121gdQfp
         bf6WUPPm8zApi1ceIGIdxmNyeOf4GhSLM7Pb20e3/qB3NBdfkrM+6d2Gz1ugCYvMIr+O
         HvZhDZ2Wwmu6GPtxFYgSnihNYVyxaayjM9ZP+lkg/UgXwsU6pAKSDeijFqqH6AG0mMRg
         /K3szSBbN4byl/CCMaYpU3JPPNIDlEyY8sXM1NIlrlVKKNWfY3uTpUTP2LSBEpgEurV0
         x6ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUQSbx0KaswU1H9n7ZQyzyoIOEt3tdMqZSfM7dMVuHb4ZJ7cS/c
	ueO/n1Cor5PelsZGNri19bZcRfVsCDKq4VVr797pkriQbwZIuAP4h9Q9uPz0GEazFo4v2u7sYpz
	xsuGTCSgm7GWoQxobUe9gouoCGks/VRnEjtaGQlPo5gPxuD6b434umSf37ogcc2//Ng==
X-Received: by 2002:a17:902:42e:: with SMTP id 43mr17389111ple.88.1551650847100;
        Sun, 03 Mar 2019 14:07:27 -0800 (PST)
X-Google-Smtp-Source: APXvYqybXSlgyzbIuCGMWyupJvAY12059o/2570Pj0RRokpeVRIC+wlO0BPATr11Y8TMOxP9DhEF
X-Received: by 2002:a17:902:42e:: with SMTP id 43mr17389022ple.88.1551650845814;
        Sun, 03 Mar 2019 14:07:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551650845; cv=none;
        d=google.com; s=arc-20160816;
        b=eR5jFB3VI8XzvC7S0TtjNtYdlvxBngb3YNQBNlqfprvFwrq6B/EvgIfOXDc6bb1f5b
         DWJkjML/c2dbjjTGsWeZPpKr2nYvl0xPvKlGN7Tm+/nvyfdhqLvP/OS0bKYaldTuhrXi
         5sW3pbB7NVReNIQqULU/dfbPeqT0f3svhXu5BTczVV2w+Xk5vDUVFTNy3lY7Xdj6iTFT
         00vPnmyw0GA06TIGDnP6QmQeh5/gnn97utXZ6qWHRIr3/SkAoXAOXTgpLhwixAUSCJnr
         FwDZid90HTDzj/pIn+XVbV8UWJ34aKLtI4XAOUsaPlW2u/LgMNyBQVL+sx/aQbOWyUBP
         BJeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=Jh1RrHS/0Qn0+szMfe9763lhRMqIScGFPVsAnFBaE7Y=;
        b=tLlXgNfvXQY0xUfOPTizMM/trMbE+2b14U1CqAzd9qLPjVH3Zj5AlbvfGF9Axh51zH
         jxSm5C9zZaiaSMTkrEOo4jBMgqnXvWSAfKMtyi7CGBE4X0N4oHCnMe1t64bpMs4PPZ7K
         /XC15p9tuKWC9wvUZUjb3TUE2MwDVmktrxxZrsSQeQhhfl7/dgBzZU2fiblzTgNYNTzS
         O3FOVcTailqBlc/SRH0GH+sxGerbMrE1r+0mRrptkwRx+DbXkmkf/XqOL180ungBa+V4
         5ohQaCqo+d5JkVrLJUft+K8+OiqEc6FK/GVU1kIZQ6c8zgT6LjN+IZ2JN7BXtact0SDc
         oXuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a23si3810082pls.338.2019.03.03.14.07.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 14:07:25 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Mar 2019 14:07:24 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,437,1544515200"; 
   d="scan'208";a="122332855"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga008.jf.intel.com with ESMTP; 03 Mar 2019 14:07:23 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1h0ZGU-0009JX-G5; Mon, 04 Mar 2019 06:07:22 +0800
Date: Mon, 4 Mar 2019 06:07:18 +0800
From: kbuild test robot <lkp@intel.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: mm/kasan/init.c:44:8-9: WARNING: return of 0/1 in function
 'kasan_p4d_table' with return type bool
Message-ID: <201903040615.AFuPIoDo%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrey,

First bad commit (maybe != root cause):

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   c027c7cf1577bc2333449447c6e48c93126a56b0
commit: b938fcf42739de8270e6ea41593722929c8a7dd0 kasan: rename source files to reflect the new naming scheme
date:   9 weeks ago


coccinelle warnings: (new ones prefixed by >>)

>> mm/kasan/init.c:44:8-9: WARNING: return of 0/1 in function 'kasan_p4d_table' with return type bool
>> mm/kasan/init.c:68:8-9: WARNING: return of 0/1 in function 'kasan_pmd_table' with return type bool
>> mm/kasan/init.c:56:8-9: WARNING: return of 0/1 in function 'kasan_pud_table' with return type bool

vim +/kasan_p4d_table +44 mm/kasan/init.c

69786cdb3 mm/kasan/kasan_init.c Andrey Ryabinin    2015-08-13  34  
c2febafc6 mm/kasan/kasan_init.c Kirill A. Shutemov 2017-03-09  35  #if CONFIG_PGTABLE_LEVELS > 4
c65e774fb mm/kasan/kasan_init.c Kirill A. Shutemov 2018-02-14  36  p4d_t kasan_zero_p4d[MAX_PTRS_PER_P4D] __page_aligned_bss;
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  37  static inline bool kasan_p4d_table(pgd_t pgd)
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  38  {
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  39  	return pgd_page(pgd) == virt_to_page(lm_alias(kasan_zero_p4d));
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  40  }
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  41  #else
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  42  static inline bool kasan_p4d_table(pgd_t pgd)
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  43  {
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17 @44  	return 0;
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  45  }
c2febafc6 mm/kasan/kasan_init.c Kirill A. Shutemov 2017-03-09  46  #endif
69786cdb3 mm/kasan/kasan_init.c Andrey Ryabinin    2015-08-13  47  #if CONFIG_PGTABLE_LEVELS > 3
69786cdb3 mm/kasan/kasan_init.c Andrey Ryabinin    2015-08-13  48  pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  49  static inline bool kasan_pud_table(p4d_t p4d)
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  50  {
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  51  	return p4d_page(p4d) == virt_to_page(lm_alias(kasan_zero_pud));
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  52  }
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  53  #else
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  54  static inline bool kasan_pud_table(p4d_t p4d)
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  55  {
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17 @56  	return 0;
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  57  }
69786cdb3 mm/kasan/kasan_init.c Andrey Ryabinin    2015-08-13  58  #endif
69786cdb3 mm/kasan/kasan_init.c Andrey Ryabinin    2015-08-13  59  #if CONFIG_PGTABLE_LEVELS > 2
69786cdb3 mm/kasan/kasan_init.c Andrey Ryabinin    2015-08-13  60  pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  61  static inline bool kasan_pmd_table(pud_t pud)
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  62  {
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  63  	return pud_page(pud) == virt_to_page(lm_alias(kasan_zero_pmd));
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  64  }
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  65  #else
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  66  static inline bool kasan_pmd_table(pud_t pud)
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  67  {
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17 @68  	return 0;
0207df4fa mm/kasan/kasan_init.c Andrey Ryabinin    2018-08-17  69  }
69786cdb3 mm/kasan/kasan_init.c Andrey Ryabinin    2015-08-13  70  #endif
69786cdb3 mm/kasan/kasan_init.c Andrey Ryabinin    2015-08-13  71  pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
69786cdb3 mm/kasan/kasan_init.c Andrey Ryabinin    2015-08-13  72  

:::::: The code at line 44 was first introduced by commit
:::::: 0207df4fa1a869281ddbf72db6203dbf036b3e1a kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN

:::::: TO: Andrey Ryabinin <aryabinin@virtuozzo.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

