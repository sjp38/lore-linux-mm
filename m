Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7019DC742A2
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 22:38:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32E9E2084B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 22:38:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32E9E2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B94C88E00FE; Thu, 11 Jul 2019 18:38:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6C618E00DB; Thu, 11 Jul 2019 18:38:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0CA28E00FE; Thu, 11 Jul 2019 18:38:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 692788E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 18:38:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t2so4436219pgs.21
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 15:38:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=qJ/D1kljI1FpNOCkzgQtUC/F6rOQ+MJjYXweaFKXIzg=;
        b=r158uOSokbToz89OA/1T+/QGxpDb3phlWi68DOECCPNhG4R8rfUJGJT6h4faW+D63d
         xf/CPxBFgR4399UMGCie/YllADf4ieRNBdzTUVJL9uGB45GbXYR36YJpayeyU9R7QyJn
         VEa2uICezJikpkLTUGPqiEhcxIEDSb/g843oZST3H7llvAwkLz3iY6iNTBnZVz2G6gXR
         di1xEXrg1DhZOSRrfqPZ5+ZkpVrtzRXzBM3kB2x8yNCYIa2NZY9b7Ulx9ZHZvp9PxS+l
         r/Kb2wJedzVlpRbNDb88Q8KIzapHJCqYeNWeqZclcaxjzA8AAJmTG14My9Og22Gnw7lk
         v19A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUdU0G/sgqipvn0RD6HUeLHEOeY6UqdXD7lhPDc0zQWpKh/pekm
	S4+eoJe0KDBWtr10qLNEwMwhzOZqcUZiOwauElRfIICrwNlTX4z+CwpNzR69zt1PGTHWVMvDQHq
	OdB3ZsZSoI0C6AtxqkECq4+uTahrnZdjv/KJh0j3VZiQe8sT8kNs2od9Uyu2Iw4ADiA==
X-Received: by 2002:a17:90a:ad86:: with SMTP id s6mr7593312pjq.42.1562884728089;
        Thu, 11 Jul 2019 15:38:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8x9G8Qev/2FyESUmDEAzii3vg4HY43YDNVtg9ZUzN7dVIRKP/WB5SIrVmzM8mODNmq0Pu
X-Received: by 2002:a17:90a:ad86:: with SMTP id s6mr7593255pjq.42.1562884727309;
        Thu, 11 Jul 2019 15:38:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562884727; cv=none;
        d=google.com; s=arc-20160816;
        b=fQbUVLg+Hs1eXNWAC+CYtII6oTv26+KY4NPVOrkDc2y6qiZ/gVIJV45CCZpy5OWYbZ
         Je960CmrNinbWy1SoSjlIieXTAjQ9B5P6BDXRfGV/vktwGZSSDDFlge2lGMH9oEqjs78
         dM0/H5ZJSvogFI1F7oY1nN0LuQdB0oz6GiOuDiY//4X14aMJNyO9ZcaGNjW+777KOO7c
         5gR0qg04/DqjKGWi1kHC1Nq44wv4zJIqDzRUoc2UjDlpfETEH5O3EKtNBcq8HrNEWqkz
         Cc0YXhHoUG1y/pYuVFAbrgXu4VNjYsE1/ocvpZMlAhA/AJ57hYflshm2xp6I2Vs3+GHl
         JlwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=qJ/D1kljI1FpNOCkzgQtUC/F6rOQ+MJjYXweaFKXIzg=;
        b=udXmnit0yKy4A/DR/fJIob6aDSkovLSlVGkrQ0lKT+27NmcB5Wd4Sc17SrI4igl0ng
         DKEzqCcNU87h59hOoKgulwUgFkMz2tUX76CTWxpuIpphu4cgKkPiJ5O8zQqEsoZK1kBy
         2UHHlRGtG8A57pVzbu+Wv3N5quFp3QvPR2cQFhjZz/augzl7fVUiTIdmpo/zaw+HBsNP
         NUyXXQpkeUzalDj2pIpOlnmZWDsYh/QrBDBE8yzEYepIn5QV67lB2teavJkGBrM3FVl8
         UsobR7OE2uKfKconCEhyfTXALgmKduqsiTrSdsUd7cyj8fz5dZ34MFd98htqcO1/pzeT
         JU6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b5si6115701pjo.26.2019.07.11.15.38.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 15:38:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jul 2019 15:38:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,480,1557212400"; 
   d="scan'208";a="156961083"
Received: from ray.jf.intel.com (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga007.jf.intel.com with ESMTP; 11 Jul 2019 15:38:46 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Alexandre Chartre <alexandre.chartre@oracle.com>, pbonzini@redhat.com,
 rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
 peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
 liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
 rppt@linux.vnet.ibm.com
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
Date: Thu, 11 Jul 2019 15:38:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/11/19 7:25 AM, Alexandre Chartre wrote:
> - Kernel code mapped to the ASI page-table has been reduced to:
>   . the entire kernel (I still need to test with only the kernel text)
>   . the cpu entry area (because we need the GDT to be mapped)
>   . the cpu ASI session (for managing ASI)
>   . the current stack
> 
> - Optionally, an ASI can request the following kernel mapping to be added:
>   . the stack canary
>   . the cpu offsets (this_cpu_off)
>   . the current task
>   . RCU data (rcu_data)
>   . CPU HW events (cpu_hw_events).

I don't see the per-cpu areas in here.  But, the ASI macros in
entry_64.S (and asi_start_abort()) use per-cpu data.

Also, this stuff seems to do naughty stuff (calling C code, touching
per-cpu data) before the PTI CR3 writes have been done.  But, I don't
see anything excluding PTI and this code from coexisting.

