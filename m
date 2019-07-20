Return-Path: <SRS0=pjJT=VR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8B70C76186
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 22:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E13F20823
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 22:54:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E13F20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0925C6B0005; Sat, 20 Jul 2019 18:54:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0437D6B0006; Sat, 20 Jul 2019 18:54:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E73B48E0001; Sat, 20 Jul 2019 18:54:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF0866B0005
	for <linux-mm@kvack.org>; Sat, 20 Jul 2019 18:54:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j12so17689556pll.14
        for <linux-mm@kvack.org>; Sat, 20 Jul 2019 15:54:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:user-agent:mime-version
         :content-transfer-encoding;
        bh=bmigF1P+hJsg7B0ufTfy/cz1G7pwoMZqVpczRqS9FZI=;
        b=QCKUbmLEx1X5zDPG73qKxZPS4Nhd7LDp9Kn43dpmFBzNZgAou4vYX/JTqVoYwJ3tzd
         wG9KG5nlJqNGU52jd9spVvPwGl+JScQ8TRVcBSQcLdW79eR3xex8+LajC7u/x0qUO/62
         1rTSRhoW57Rb5i3nefF+AZJo3U9696cMgJ7EyBOhb6DKYCIVzxhFHptAp37iXYM5ITxM
         JdvU9gI0BjYF/CbTvvZe3beYtzTT7itdQ33oK0sWcN+XxkdmD0DVoixml/DCHBZmZSuF
         1mtifdFK9e66u0Vj3Nr+K2x1dGxMObBhKv/qhcpuxhTSvUPCDFLdwm6XI/D7nKBY9F69
         iUSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXNbdpdSdxpnvJcuAaHAcLXQ1BIMYzYReWx4AUzWB1JKttr9xH4
	LxI9bri5w1KwIVEIuNmYZAEA2o42q6bhcDmKlbG2Nzl+X6k1CG73s4oZL5+iiKnWFfG85mJ5KaB
	jUu2Xke9G6irIan3afKh0H2c2BqRCygMa5sedKva8XBFsgLkCS5+JAJBUqHxxxpQk9w==
X-Received: by 2002:a17:902:8c98:: with SMTP id t24mr67421887plo.320.1563663285333;
        Sat, 20 Jul 2019 15:54:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKFRB9l3ZaicTTsvZ5Gffvf3Rrjfs8A/UiuVGW5eIq90nI2FWqPUTYJkRPeUpU7Tl2B37f
X-Received: by 2002:a17:902:8c98:: with SMTP id t24mr67421822plo.320.1563663284503;
        Sat, 20 Jul 2019 15:54:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563663284; cv=none;
        d=google.com; s=arc-20160816;
        b=EGK3Cl9mT4Z9W8AU8FAZlbqvMh/gPFE1nEANyQqekQQiBl2vS3fZvaew0qcs9kN98N
         FE3AfS1Wc3pjtIyPR9Pq7zHXsnxCump4VEobWnOVI0fIf73gSgfKfHGD1qjVaI8gKf0W
         gw0EuRMB9dsRajIiHJaTsHAYQngA2YQkxPiUSYLMnG8BUV3F16Q3FXK9znTsIEKu5KQ9
         vPdZSeAZ+xGcpeNDrMtwgLzsh27V3A9E5jOxjOJqoJYrmuxTKIsaSIc6Ak+/j5ZQEGqp
         pgI0y7l2BicLOwDaKmq262Z19Me13na9/I2vc9wtt5Q7oi+Zg8dhUlU+5aldBU7pNFwI
         nmWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:date:cc:to:from
         :subject:message-id;
        bh=bmigF1P+hJsg7B0ufTfy/cz1G7pwoMZqVpczRqS9FZI=;
        b=edy4RMzCA9IGzK9C1gYVhRYsNw6zwvmeSyhZh5ii78qwLWeMGxvnd0LalQDd2Yb98H
         2HgJ1SqjOnAFNs1eJ7YCfyXJPzBchCaZfVGwou5sP+UMiqFMsMHedN4QZQIw+FexgRoT
         btR6HqPCoQSPqzcInSiiyzffCt70tdb7AAh7NVKbwMQ+mj6+AvNXn/qCLD06lRTWie0H
         NFhzccVLHkpnaJPjESxSvMOt+NCReh7ZtxgnzxKwgM/IpASHWKmDcyEOnvZulo75s9Zj
         kqht5fchhZcKL+dmUNhXQvVVI8bWOsyRN3fxmqzc3c/WORsApCyCSF0dTzPzWnpy1Gc5
         xrWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p1si5424496plq.286.2019.07.20.15.54.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jul 2019 15:54:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jul 2019 15:54:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,288,1559545200"; 
   d="scan'208";a="367626781"
Received: from sai-dev-mach.sc.intel.com ([143.183.140.153])
  by fmsmga005.fm.intel.com with ESMTP; 20 Jul 2019 15:54:43 -0700
Message-ID: <cfee410c5dd4b359ee395ad075f31133387def70.camel@intel.com>
Subject: Why does memblock only refer to E820 table and not EFI Memory Map?
From: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
To: linux-mm@kvack.org, linux-efi@vger.kernel.org
Cc: mingo@kernel.org, bp@alien8.de, peterz@infradead.org, 
	ard.biesheuvel@linaro.org, rppt@linux.ibm.com, pj@sgi.com
Date: Sat, 20 Jul 2019 15:52:04 -0700
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

Disclaimer:
1. Please note that this discussion is x86 specific
2. Below stated things are my understanding about kernel and I could have
missed somethings, so please let me know if I understood something wrong.
3. I have focused only on memblock here because if I understand correctly,
memblock is the base that feeds other memory management subsystems in kernel
(like the buddy allocator).

On x86 platforms, there are two sources through which kernel learns about
physical memory in the system namely E820 table and EFI Memory Map. Each table
describes which regions of system memory is usable by kernel and which regions
should be preserved (i.e. reserved regions that typically have BIOS code/data)
so that no other component in the system could read/write to these regions. I
think they are duplicating the information and hence I have couple of
questions regarding these

1. I see that only E820 table is being consumed by kernel [1] (i.e. memblock
subsystem in kernel) to distinguish between "usable" vs "reserved" regions.
Assume someone has called memblock_alloc(), the memblock subsystem would
service the caller by allocating memory from "usable" regions and it knows
this *only* from E820 table [2] (it does not check if EFI Memory Map also says
that this region is usable as well). So, why isn't the kernel taking EFI
Memory Map into consideration? (I see that it does happen only when
"add_efi_memmap" kernel command line arg is passed i.e. passing this argument
updates E820 table based on EFI Memory Map) [3]. The problem I see with
memblock not taking EFI Memory Map into consideration is that, we are ignoring
the main purpose for which EFI Memory Map exists.

2. Why doesn't the kernel have "add_efi_memmap" by default? From the commit
"200001eb140e: x86 boot: only pick up additional EFI memmap if add_efi_memmap
flag", I didn't understand why the decision was made so. Shouldn't we give
more preference to EFI Memory map rather than E820 table as it's the latest
and E820 is legacy?

3. Why isn't kernel checking that both the tables E820 table and EFI Memory
Map are in sync i.e. is there any *possibility* that a buggy BIOS could report
a region as usable in E820 table and as reserved in EFI Memory Map?

[1] 
https://elixir.bootlin.com/linux/latest/source/arch/x86/kernel/setup.c#L1106
[2] 
https://elixir.bootlin.com/linux/latest/source/arch/x86/kernel/e820.c#L1265
[3] 
https://elixir.bootlin.com/linux/latest/source/arch/x86/platform/efi/efi.c#L129

Regards,
Sai

