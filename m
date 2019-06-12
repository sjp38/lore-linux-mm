Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA106C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:25:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79B7E20896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:25:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79B7E20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0155B6B0010; Wed, 12 Jun 2019 14:25:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F07296B0266; Wed, 12 Jun 2019 14:25:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF6A76B0269; Wed, 12 Jun 2019 14:25:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7BFB6B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:25:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w31so11880682pgk.23
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:25:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8+ft67gLSM1rrDdnljBHIb0dGMGD+iFhA8XvcJRi9W8=;
        b=lZ5+xXydPlzPKuprGSrJaBAIzv9rNKRMB/HLLzMZY05Eo9xkVpplRSFV97ap3QeNGh
         12wQnqAGLbgwQ6yofxLSXJZ9IOigk2HyOABt2BicA6JQEc3whYf9xGEtEvBia82zHpQ2
         OdCUq0nwQtRtMdQ/XMFpOpu/Q9MpH5MrM/ehXK2ij5OqyCGP9y7acMbYPr31Y2FvOupE
         /COEKB1OpBu8wcvNKfLcs+iofMyt+t6OWshEy3LolHezV3uPxoMgWlsSgBAo9H4a/noc
         26HP1iHMedWFgycU0Lkn4kOcioJTGyZjuGRU+Xb4ufi6Bsii+xHGarhwCY5tykKJ9uXg
         CbOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXyiLoncPRqX0/NzOjyNWJe1fBgZW7fJ5DA4fjoh8xulUjcjKUb
	tIP/2HFSx2gjpUUJdghxa6MGtJQtfjAwSqyrF6vW2cDL4f0fH7+BusFJSN2NK7GVBfy7ETb7ZW/
	cUIKyHAGFaM1TIAt4K8IAdN/Git5TJnvy04MJJoqklfP1xW65oxyvG/l1DIpnDo8qRg==
X-Received: by 2002:a17:902:7c04:: with SMTP id x4mr24004946pll.70.1560363952322;
        Wed, 12 Jun 2019 11:25:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrJjRg836t1v++hYjpHLhPf0CyKYlRdMY9TEfdo1jzduQ7hPlkjqAwNfS+xPK8hbIpLCTf
X-Received: by 2002:a17:902:7c04:: with SMTP id x4mr24004905pll.70.1560363951552;
        Wed, 12 Jun 2019 11:25:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560363951; cv=none;
        d=google.com; s=arc-20160816;
        b=nvnQscGR7PEddNSq464PWBg65BII5j9PBIHGNFarSgNe5ZVXJxGbN4KAC8Us4smaJa
         D7m5ZDtMTIQA1Csz375dhXkyVmisyu4xP5322OCzpNFh1I5KsF/qVbHZujCbPPj3bAIS
         5YwnAN8EbCabQ1TlUR6uQrqUYz6bCVFpj65aeKKA8c8lEVou4aWWNDxB4La4zTiYxJBH
         xmJbalCl1y6+0epaHLr80/22PWdJAburJxk2ztI4Pc4u5aGfd6bmG7fyIyJE7OVv8HSI
         OyfJ3fN8pCsYv96aL4fuSAxVQH93bFGwA7OjNVnsEVxp+JNqZzKFF4L+YF20WJqtSg92
         5ZyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8+ft67gLSM1rrDdnljBHIb0dGMGD+iFhA8XvcJRi9W8=;
        b=fO1bBwsR8i7GAMTiF/b6LZfHSdAH+FS0WTfdt43LdhbRA5HhC5GVyx3aoMjkaoEgGs
         PqsxDSyiNjzcDMcJvIyW5HV/RN8Lg3eAQSWXR95tu3TEG4l7QJi8QlhvLdTqLBDdhrQx
         v+iotnhC4mwnrgSZ1oBPhsCctGdobVjCnvr4REZocBXILKb3jMlkTfPaWo9+mc7r7fEy
         fD/tzmFTrX2qG4Eg39BM/zJ+JkKw8QzlLUy46bySIbCEmCPAlfNwUr4RFNNufh2UEjjA
         5M9C6d9RO2lEWUWXZ7lcy/9Ok4dc7ByugfTIrsnPzPcBDDudyi4J4xqZHUNCFZMtRXXX
         uW9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 129si484333pfy.160.2019.06.12.11.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 11:25:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jun 2019 11:25:50 -0700
X-ExtLoop1: 1
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.36])
  by fmsmga007.fm.intel.com with ESMTP; 12 Jun 2019 11:25:50 -0700
Date: Wed, 12 Jun 2019 11:25:50 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Marius Hillenbrand <mhillenb@amazon.de>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	Alexander Graf <graf@amazon.de>,
	David Woodhouse <dwmw@amazon.co.uk>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
Message-ID: <20190612182550.GI20308@linux.intel.com>
References: <20190612170834.14855-1-mhillenb@amazon.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612170834.14855-1-mhillenb@amazon.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 07:08:24PM +0200, Marius Hillenbrand wrote:
> The Linux kernel has a global address space that is the same for any
> kernel code. This address space becomes a liability in a world with
> processor information leak vulnerabilities, such as L1TF. With the right
> cache load gadget, an attacker-controlled hyperthread pair can leak
> arbitrary data via L1TF. Disabling hyperthreading is one recommended
> mitigation, but it comes with a large performance hit for a wide range
> of workloads.
> 
> An alternative mitigation is to not make certain data in the kernel
> globally visible, but only when the kernel executes in the context of
> the process where this data belongs to.
>
> This patch series proposes to introduce a region for what we call
> process-local memory into the kernel's virtual address space. Page
> tables and mappings in that region will be exclusive to one address
> space, instead of implicitly shared between all kernel address spaces.
> Any data placed in that region will be out of reach of cache load
> gadgets that execute in different address spaces. To implement
> process-local memory, we introduce a new interface kmalloc_proclocal() /
> kfree_proclocal() that allocates and maps pages exclusively into the
> current kernel address space. As a first use case, we move architectural
> state of guest CPUs in KVM out of reach of other kernel address spaces.

Can you briefly describe what types of attacks this is intended to
mitigate?  E.g. guest-guest, userspace-guest, etc...  I don't want to
make comments based on my potentially bad assumptions.
 
> The patch set is a prototype for x86-64 that we have developed on top of
> kernel 4.20.17 (with cherry-picked commit d253ca0c3865 "x86/mm/cpa: Add
> set_direct_map_*() functions"). I am aware that the integration with KVM
> will see some changes while rebasing to 5.x. Patches 7 and 8, in

Ha, "some" :-)

> particular, help make patch 9 more readable, but will be dropped in
> rebasing. We have tested the code on both Intel and AMDs, launching VMs
> in a loop. So far, we have not done in-depth performance evaluation.
> Impact on starting VMs was within measurement noise.

