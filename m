Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E0E6C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:55:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C63320B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:55:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C63320B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7BB36B0010; Wed, 12 Jun 2019 15:55:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C054F6B0266; Wed, 12 Jun 2019 15:55:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA5E06B0269; Wed, 12 Jun 2019 15:55:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 725216B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:55:40 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id l184so12055557pgd.18
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 12:55:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=UVJ3/oXJrDcg98rsXlhaYFhPLO2xG/VlWcVIvNS4vIU=;
        b=oCqg5M2uq/kuK+7zafRMVnCiCqCLEXdT3VliwjDprBWw4x8I4cRiNJZ73XGvoQsws+
         Q3QuZA8penVCTJu5GaYD4q/ewr3MgRL5H9+caYlJZxbjYwQHrVegXpUTWU2LL0I+uiLg
         r7sn7vkv/l22SIdP7tDE1EAmr1no6xl492NI1aijn2EQHSM/d1YWlja9QsupggzwcoOk
         4/BOLYsJOtrNTU1ECUkAcq+F48gtosXmRvSAnwSuIhv0jlyag+9G/1Rvad51gqWRUq6Y
         X7ARlr1NgVAspxXqXzZl9fdDVxOxqmZt9sYRUU1v02RuAWGiIFtK/zlfzWiYXX+udC8v
         FMfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX284CkEzbCB1ahDmyv9eZqHALcxjjVTBIvmPd4ncSPyqB3X5PI
	iVohoNwuwlHJAEjKUoyowlEn/MjO/Gt7DsM90QIiZA+OS82oNP2WoEUTuu/8VuiKEgPYJAzRXwU
	krdqgk1D0ZprfRSneVb3YzjAf72TbjHoQ04i8iuqVCV9mCKtKeqszV8qM1WPbH1FWqw==
X-Received: by 2002:a17:902:b487:: with SMTP id y7mr23298091plr.219.1560369340085;
        Wed, 12 Jun 2019 12:55:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjuEbJR59W+JphLOE6NcCH0VbT6oyOOpiw0lCsSPhK5LIq/fW0/BRjnpeHPEy/ZBymiX4r
X-Received: by 2002:a17:902:b487:: with SMTP id y7mr23298048plr.219.1560369339269;
        Wed, 12 Jun 2019 12:55:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560369339; cv=none;
        d=google.com; s=arc-20160816;
        b=Un6ZStFFD8oUKYvWt+z51ThOA9NZ1hRa1j30EY3J3Ui/slS7lSDsb5bqynEiYlxETf
         MLrRhfolOXHKRvJCqMITXScKm4BpTFD2pRI8zd/zuwHFNWZUrX50uLjUMrx4jBI+06B6
         jAqVo8rG3fQyU2dlARPO8B2t8pb+onZX2FWRxG1w5s8YoUoCK4w7wlMjwH9b5y5jMDKf
         XA/eV5QeJRn5RS6SlulowCXTX0Tb5oDeWyGGRkW/+43HrkRibbKy6lCMMShbotAu9Gpl
         F+R17KKN4GbVPpmQbzYMbhViHoIMAdbPFsvVFtU4twXXllKxRtC3Tcvgt/9mwo4M0c9l
         hJ3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=UVJ3/oXJrDcg98rsXlhaYFhPLO2xG/VlWcVIvNS4vIU=;
        b=E745B5zNIJKgdeaZxgRKfNnBHaQupKpT5dU3DuqPqXuO2eAYrvzCtU8dq1gr6ZrFZ3
         WHJypm9eZiKzLxZ0GpeTRYCng9icE/kUy1sJhX+yW0a3XhBDCqCNALKfN4gbx8gVwiVf
         Ms0eAJVW6HIXaLHRvQLIj6/iKcYranimpRlo91y/4xywIi8Nsl6/zgWQAjAF1IBYIFbF
         u6RFp/HW68nxLcsG8z7DuLslfPhxqyvPDiSJE40umUX3i4S1ZbQxuSagUBAXJzTu5eDx
         JWew8dWC67PXRPqtqK0t+h7OptZjDqh+HIIgonxOyyHHB3237ceoObSvEswy1rY776yV
         iHkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f59si526317plb.107.2019.06.12.12.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 12:55:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jun 2019 12:55:38 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.198.156]) ([10.7.198.156])
  by orsmga007.jf.intel.com with ESMTP; 12 Jun 2019 12:55:38 -0700
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
To: Marius Hillenbrand <mhillenb@amazon.de>, kvm@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, Alexander Graf <graf@amazon.de>,
 David Woodhouse <dwmw@amazon.co.uk>,
 the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirski
 <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
References: <20190612170834.14855-1-mhillenb@amazon.de>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
Date: Wed, 12 Jun 2019 12:55:38 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190612170834.14855-1-mhillenb@amazon.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
> This patch series proposes to introduce a region for what we call
> process-local memory into the kernel's virtual address space. 

It might be fun to cc some x86 folks on this series.  They might have
some relevant opinions. ;)

A few high-level questions:

Why go to all this trouble to hide guest state like registers if all the
guest data itself is still mapped?

Where's the context-switching code?  Did I just miss it?

We've discussed having per-cpu page tables where a given PGD is only in
use from one CPU at a time.  I *think* this scheme still works in such a
case, it just adds one more PGD entry that would have to context-switched.

