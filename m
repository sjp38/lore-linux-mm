Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9B87C04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:55:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B86B2075C
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:55:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B86B2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F3DA6B0010; Wed, 29 May 2019 03:55:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A5AB6B026C; Wed, 29 May 2019 03:55:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 051026B026D; Wed, 29 May 2019 03:55:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA8706B0010
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:55:49 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 140so1248965pfa.23
        for <linux-mm@kvack.org>; Wed, 29 May 2019 00:55:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=XxvXQySp9RUxzlS9rObZdxAHoPUzc1886C+g7JPHhcY=;
        b=REUL3e4TIOAqAuW6loK8S1ydtmwpJj2fxuH8QWGXO89osM5Ssm1TtZsOHGF0YNE600
         Za+eftf4NqUlmkay5KSVF2bystm5/0KC71ra3qVuEw56IxSdSRmgW5Rfw5SHmNYjtlA9
         yj/GUX/UaajWZ/oZFBgtn4QhV8B/piUrD/pUHFbIyTlSULuy+ZmaWu0JknnjenlDvlOK
         eTYW1xb8ZHzpcgxftQXhJFDTrr+mxUaYg1uOy92MxUZsxGVriPY1SyryLpmXIx2x3jdh
         ypYZwmLxQDozStAz/AZqPWBjCeYdUX7t63k+V25I/Litq2Flryu7eIH1fGUv3ZUo05l7
         6epg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWfJRBiIyjLjc0pPFfxJ1HS3x2Hh6Bw6MCj6ZaQTxeda/9fVRFz
	CshRqbYMS/vGuCyhbAEdXYIalJKi4mx3w12oXOET/kEGUC0TXUy3Tau0Cz7OyzELUMm2oIwyg3b
	2xb7QqPmv8T/YYMHsew5i30Rh5XtTAokgpgmoAdgQwgRaUL5ZDX/2JhxrjCxSG6zYZg==
X-Received: by 2002:a65:608a:: with SMTP id t10mr135020328pgu.155.1559116549128;
        Wed, 29 May 2019 00:55:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCtRKlIpwagYXg+k8s1ieD5Naoz9IiyAO56lRUq4nLZezWtCm6dpJq6Sfv0K15j3+WS2Wv
X-Received: by 2002:a65:608a:: with SMTP id t10mr135020264pgu.155.1559116547854;
        Wed, 29 May 2019 00:55:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559116547; cv=none;
        d=google.com; s=arc-20160816;
        b=Dcg8rO4tIIlUkgOg5ULMMjGeB7czhTHl0NSq2h6lsx854A62gHlQqGgbQ5rHWOqXYn
         bNOg0snOnX1JdyHF215VgsbhB2+0WPnTUrsfOm08lc+Pmlt4QRwVm42KskTeR6gw/2BS
         AUHmh2gnXFLV2nJ7szI84Z2dIcG8CDItx0Z6iSYthtpZUi4Q5ex9udpi+p2xuZezm6X1
         9s99mLU41dW6lAajw32AYZ8/z6ikwJ6dB3C3MYyHmZRND+zY1JlQyiDgK91oUvZn9e2S
         mhC2s3oHig13magYuGvULS5FH2L7ZIja/PFyRg3oc5250WZ27h07fRg3hTSSX+LvI2ws
         G9/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=XxvXQySp9RUxzlS9rObZdxAHoPUzc1886C+g7JPHhcY=;
        b=g5FB2DBSWUNEr3JG/ji5Tof5hc8DkIq7GqENGgj5GOrfG5GHk31CQUpf0HA+d+3j17
         sFZjyBDOyHs5jdVNIqZoJae1XycD9+12NQsrwhomiUWzcwarsFjtMgytIl9juUhGLGPU
         XBire3Z2itE16UA6gQ6vlzyWOnyjaeWNlCJ4ky6vD2uw3ZQX/4AR/glJr84993b0OlGA
         5BVulTy8sn1XO5I1vAVW8CWzLcLpoISG6Lv+3ifbn9akT08g1AUjePCeZXI4TcsqslMc
         8Xqfxx3ZXWzmVzYioiv/Xdf63K/xU9OsxUbYCb+0Q0xI5jcLBQfGsi3Hh1hbTmrf+oVC
         tkBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q15si6202172pjp.95.2019.05.29.00.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 00:55:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 May 2019 00:55:46 -0700
X-ExtLoop1: 1
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga005.fm.intel.com with ESMTP; 29 May 2019 00:55:45 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hVtR2-00083K-G8; Wed, 29 May 2019 15:55:44 +0800
Date: Wed, 29 May 2019 15:54:52 +0800
From: kbuild test robot <lkp@intel.com>
To: Robin Murphy <robin.murphy@arm.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [liu-song6-linux:uprobe-thp 92/185]
 arch/arm64/include/asm/pgtable.h:93:27: error: expected identifier or '('
 before '!' token
Message-ID: <201905291549.xlVZd4Ss%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://github.com/liu-song-6/linux.git uprobe-thp
head:   950e997c620db50b4f7e578631f6c8b0e1315778
commit: 5760548d3bd197b0858ccaf3ec8039aedba5832f [92/185] arm64: mm: Implement pte_devmap support
config: arm64-allnoconfig (attached as .config)
compiler: aarch64-linux-gcc (GCC) 7.4.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 5760548d3bd197b0858ccaf3ec8039aedba5832f
        # save the attached .config to linux build tree
        GCC_VERSION=7.4.0 make.cross ARCH=arm64 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>

All error/warnings (new ones prefixed by >>):

   In file included from include/linux/mm.h:99:0,
                    from arch/arm64/kernel/asm-offsets.c:23:
>> arch/arm64/include/asm/pgtable.h:93:27: error: expected identifier or '(' before '!' token
    #define pte_devmap(pte)  (!!(pte_val(pte) & PTE_DEVMAP))
                              ^
>> arch/arm64/include/asm/pgtable.h:390:26: note: in expansion of macro 'pte_devmap'
    #define pmd_devmap(pmd)  pte_devmap(pmd_pte(pmd))
                             ^~~~~~~~~~
>> include/linux/mm.h:540:19: note: in expansion of macro 'pmd_devmap'
    static inline int pmd_devmap(pmd_t pmd)
                      ^~~~~~~~~~
   In file included from arch/arm64/kernel/asm-offsets.c:23:0:
>> include/linux/mm.h:544:19: error: redefinition of 'pud_devmap'
    static inline int pud_devmap(pud_t pud)
                      ^~~~~~~~~~
   In file included from include/linux/mm.h:99:0,
                    from arch/arm64/kernel/asm-offsets.c:23:
   arch/arm64/include/asm/pgtable.h:549:19: note: previous definition of 'pud_devmap' was here
    static inline int pud_devmap(pud_t pud)
                      ^~~~~~~~~~
   In file included from arch/arm64/kernel/asm-offsets.c:23:0:
>> include/linux/mm.h:548:19: error: redefinition of 'pgd_devmap'
    static inline int pgd_devmap(pgd_t pgd)
                      ^~~~~~~~~~
   In file included from include/linux/mm.h:99:0,
                    from arch/arm64/kernel/asm-offsets.c:23:
   arch/arm64/include/asm/pgtable.h:641:19: note: previous definition of 'pgd_devmap' was here
    static inline int pgd_devmap(pgd_t pgd)
                      ^~~~~~~~~~
   make[2]: *** [arch/arm64/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +93 arch/arm64/include/asm/pgtable.h

    83	
    84	/*
    85	 * The following only work if pte_present(). Undefined behaviour otherwise.
    86	 */
    87	#define pte_present(pte)	(!!(pte_val(pte) & (PTE_VALID | PTE_PROT_NONE)))
    88	#define pte_young(pte)		(!!(pte_val(pte) & PTE_AF))
    89	#define pte_special(pte)	(!!(pte_val(pte) & PTE_SPECIAL))
    90	#define pte_write(pte)		(!!(pte_val(pte) & PTE_WRITE))
    91	#define pte_user_exec(pte)	(!(pte_val(pte) & PTE_UXN))
    92	#define pte_cont(pte)		(!!(pte_val(pte) & PTE_CONT))
  > 93	#define pte_devmap(pte)		(!!(pte_val(pte) & PTE_DEVMAP))
    94	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--cWoXeonUoKmBZSoM
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
11Z1AAA=

--cWoXeonUoKmBZSoM--

