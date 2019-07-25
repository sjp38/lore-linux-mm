Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A4A2C76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:56:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BB5120679
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:56:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BB5120679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6B778E003F; Thu, 25 Jul 2019 02:56:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1B848E0031; Thu, 25 Jul 2019 02:56:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C31528E003F; Thu, 25 Jul 2019 02:56:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 761E08E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:56:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l14so31576098edw.20
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:56:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=duacowBxDXsblwgZP9NOnpzPKF6qsiuHtWNgqHWtqPc=;
        b=uF2iG7349nBx3w0knpA/XGL+hAFH/7q6Bdix07+23dYIy1/vC9scf7+4V6nYfhfJaf
         KQzCbpuFWmcimEhyEk80wsLiXIKi6tUOo6/MHM4nL52/y+tRkMu+QXo8pujJ8lFeAJNw
         pRuvn2cWIISrNOIJUX78uZA2hgBagOHACm7GxKnF7u89dh+qtv3rtxddrlFZW3lH9RNg
         THtLhdcuN5BFu9gbp5lClbhr1MumcHlytngqKuGj97GEHsUSUNoQrgXt+i/dOk0sLmyq
         j25c7ljLebKAUx6wU82xWQGraJZcQxT5taGBC9386yrl02Cp1jhFayMIEmnDae8Im2Or
         q+nQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUc2Mb0+OuXM24CH2e3CXjoA537R24ejvlgAp2HlpuavuIAANFH
	g5BrSw40Dwn3w7jXj7nWGFnyK006w10RO0g06fksPGsaZ8zkkgvJ9wokn64T/6GVg3JEXU/gqC9
	UHz549lqQRIrXkl4gvEt/CglWtedStUdsgej0ymUcNn8gcj5jYXSedS6PbxPD/7OXVg==
X-Received: by 2002:a50:976d:: with SMTP id d42mr75013551edb.77.1564037780015;
        Wed, 24 Jul 2019 23:56:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxgvM5sxCRzY8rSkcIdfQWdtA4BApkUcNsh6auc/dQkOP2dBDdi7pU0cRYPJZlCxnYEeIv
X-Received: by 2002:a50:976d:: with SMTP id d42mr75013516edb.77.1564037779202;
        Wed, 24 Jul 2019 23:56:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564037779; cv=none;
        d=google.com; s=arc-20160816;
        b=ceW9kMzUAuKShtks2EABgTitiKNfwvFlJ+olMQtPc7wZBYh/NIaB7elSF4hI+9Cqvx
         ff2+84yxhV+nf6fupagP9vWZEX0arbqfRAc8np+YT2wnKlgrO1950Jzd8f6pvQons4w6
         A/VeZvGRoLqd8fy2OE6k0U67cZVBfdyUQC9rb4doUoZfD3hYgTgM+0o58t0bNP+Aal91
         /6t9vUeEidX12Ng91WSqZi6VliHgZObggH42Xz88B0I5gNfbDBbstM16h3yblEjeQ4hW
         8IQMlvojK+140T2m8wZjlf6BuI6UuGUCe1QLmJ5mDxf5BYTe5jA9rYh1Yx6C1HLWDcUU
         D7gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=duacowBxDXsblwgZP9NOnpzPKF6qsiuHtWNgqHWtqPc=;
        b=TRBSKAMJ871cR+fe9xxlZMa38T2ywF6M/xueIASEmBTFTPnyVRNdHD+xDwGroFAMHa
         fBF3b7fZM/HeIk6iTxFaNWFydjA089mYrt2N+Ue2iZ6+UdVpHb854ngLz2IIOWSk010T
         1rZhu6r3gGgUo6oPjTTaX9Nnyxp4oOdxKduqe5Y6xQ6OJo3WwUCWYdgVDxTGWdnB56Pt
         W03kqBzUm3MIAq+kflLsVIfUOHppRTIxsn6NAcobi/RsP5NWVlSpSnS6CpLqd+niVakW
         VYEnnADK5iOZIvCnzloUpM7IaEHulSlHFsNelZKFjofmwPz8W4/Q7SUzs2jjwRIlLn9i
         eEhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l32si11535870eda.124.2019.07.24.23.56.18
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 23:56:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1CCBE344;
	Wed, 24 Jul 2019 23:56:18 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.42.109])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 4FEA03F71F;
	Wed, 24 Jul 2019 23:58:17 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <Mark.Brown@arm.com>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Matthew Wilcox <willy@infradead.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	linux-arm-kernel@lists.infradead.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC] mm/debug: Add tests for architecture exported page table helpers
Date: Thu, 25 Jul 2019 12:25:22 +0530
Message-Id: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series adds a test validation for architecture exported page table
helpers. Patch in the series add basic transformation tests at various
level of the page table.

This test was originally suggested by Catalin during arm64 THP migration
RFC discussion earlier. Going forward it can include more specific tests
with respect to various generic MM functions like THP, HugeTLB etc and
platform specific tests.

https://lore.kernel.org/linux-mm/20190628102003.GA56463@arrakis.emea.arm.com/

Issues:

Does not build on arm64 as a module and fails with following errors. This
is primarily caused by set_pgd() called from pgd_clear() and pgd_populate().

ERROR: "set_swapper_pgd" [lib/test_arch_pgtable.ko] undefined!
ERROR: "swapper_pg_dir" [lib/test_arch_pgtable.ko] undefined!

These symbols need to be visible for driver usage or will have to disable
loadable module option for this test on arm64 platform.

Testing:

Build and boot tested on arm64 and x86 platforms. While arm64 clears all
these tests, following errors were reported on x86.

1. WARN_ON(pud_bad(pud)) in pud_populate_tests()
2. WARN_ON(p4d_bad(p4d)) in p4d_populate_tests()

I would really appreciate if folks can help validate this test in other
platforms and report back problems if any. Suggestions, comments and
inputs welcome. Thank you.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Mark Brown <Mark.Brown@arm.com>
Cc: Steven Price <Steven.Price@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Sri Krishna chowdary <schowdary@nvidia.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org

Anshuman Khandual (1):
  mm/pgtable/debug: Add test validating architecture page table helpers

 lib/Kconfig.debug       |  14 +++
 lib/Makefile            |   1 +
 lib/test_arch_pgtable.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 305 insertions(+)
 create mode 100644 lib/test_arch_pgtable.c

-- 
2.7.4

