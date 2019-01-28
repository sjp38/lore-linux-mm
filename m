Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FECEC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:50:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AC932175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:50:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AC932175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB6DF8E0002; Mon, 28 Jan 2019 11:50:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8E728E0001; Mon, 28 Jan 2019 11:50:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C55FD8E0002; Mon, 28 Jan 2019 11:50:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85BE18E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:50:54 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a10so12189011plp.14
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:50:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=WgCcQJddOY+dCGW5R8sEKJyyDQNLAI+E82uo1GlW1E8=;
        b=sNKcfbNA7kxM7500AITK5Mg5IGswJeIbsf4ih+z2Xsbs1OPqAeFXb3rAxYiNQfJUm0
         jlnv87V2phus/TNoxfsQj3ZpDiAGxC7mguv1UWSYcCrdqrWAZlB80eUObQkr9Q/kt0jH
         Z1UZy/e5rRiLCsZvlyyYc9bwXa06QLRPRDlT6tgO1vrAagTcQFsdX0BTBc4YGEXV9Lby
         +f8opLsSnpwGvVXqvbWX78LlSCVaRpqyEHXdo8fYGibIeV1BnJ3u8Z+WZF+eGzKCIcHm
         JOEpaI080sxVtSvkX3HA7+wbpsexShYz0t9xDPrqUaSIyvLdj0iO2Wmjn/WDIzW10fD7
         6wkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukckc4lp03mvJucZ+DjsUmfjTj+V+Lwe5RGC90gQyHNccyfRnyBY
	hq22rMjUllSygAha7xakcWkSNeq3QZlc5Ps1NHwp1Om2hXx1kREs1tX7mmEbNMXrrn7Q89oEnHj
	DT5vGKWLyMxejKk8VN/Klemk+OOqf8wYJhHCBkY4p+qE/pfuWq6KK00fCHG1QALuEVg==
X-Received: by 2002:a17:902:9691:: with SMTP id n17mr23115661plp.9.1548694254151;
        Mon, 28 Jan 2019 08:50:54 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Z7s3HU9s/+oQTfytUsh5Y7vc5ijjZAytSfxcYtEq+tdD1UjUwN5CpeCTaIPi2LK9tkZN5
X-Received: by 2002:a17:902:9691:: with SMTP id n17mr23115623plp.9.1548694253344;
        Mon, 28 Jan 2019 08:50:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548694253; cv=none;
        d=google.com; s=arc-20160816;
        b=tFkLa+M7aFlygW/KKDlRHl6w496YMJlUsr8dGSUoINl7kwPEinB2pqUgVmk7v39IdM
         07xa+ICCPwWfFg7CDCJwpoXBErxzlWqXhsPOtfR8gMU2VEoDQbcJewSb8s38ZksEqwjL
         397BbFqYWSXYy7zUVIa92UAsDW2dcJJ54T7fUu/0Sa1AOj0SrWSFQFlbbDy/U+DgUhmp
         fTnjosQ1bk21s8hsqzuyYt/c5E2lT3KJZTKp3NuLPwNZXF9gjDA/bWGM/bIEwCM4thpC
         FK9TPFa2BhWZjJI34OgQ/5h7YV2/5yY1H2Y2ZYP5heqmRRJpuifvNE+s1g9EySZDBngY
         WliQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=WgCcQJddOY+dCGW5R8sEKJyyDQNLAI+E82uo1GlW1E8=;
        b=olTOBSpByroMwA4C5tS3xVqJbYqsK7n8Of4JFmCUtQxuRvFewyBVdNSm6in+tA2h1U
         cZEWt5BFG3Fg53wzaaAg/ZEyBwyhrAeLPLHRPx300RPejOYV5sfVrAjDgjdr7Tgv8eT8
         zY30CL4f3o07CEWwIVNkEq0V4o49SjfQud2QawdJ7RBPOLNy2zI1vCgv4JzyuBTwgs/R
         9XuXDOV8zsH8lQr6r0Crxeu53PugjTb3J0RpguoXgOBnqIwmDi/N0UTquKKzNjl1hu01
         4Cf+JiNxmaIg8t9QwSQjCidy1idY47Sx7vNOvIqOZS4synlJjvoeN0cyzJAf6pts2XlF
         FaPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 32si18971578ple.72.2019.01.28.08.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:50:53 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 08:50:49 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,534,1539673200"; 
   d="scan'208";a="133807746"
Received: from ray.jf.intel.com (HELO [10.7.201.16]) ([10.7.201.16])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 08:50:49 -0800
Subject: Re: [PATCH 0/5] [v4] Allow persistent memory to be used like normal
 RAM
To: Balbir Singh <bsingharora@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, thomas.lendacky@amd.com, mhocko@suse.com,
 linux-nvdimm@lists.01.org, tiwai@suse.de, ying.huang@intel.com,
 linux-mm@kvack.org, jglisse@redhat.com, bp@suse.de,
 baiyaowei@cmss.chinamobile.com, zwisler@kernel.org, bhelgaas@google.com,
 fengguang.wu@intel.com, akpm@linux-foundation.org
References: <20190124231441.37A4A305@viggo.jf.intel.com>
 <20190128110958.GH26056@350D>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <3ea28fe1-1828-1017-fa0f-da626d773440@intel.com>
Date: Mon, 28 Jan 2019 08:50:49 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20190128110958.GH26056@350D>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128165049.IW-5r3bj0zyBizDwNO9nSByDBYYzsYabEM29L-JR0n8@z>

On 1/28/19 3:09 AM, Balbir Singh wrote:
>> This is intended for Intel-style NVDIMMs (aka. Intel Optane DC
>> persistent memory) NVDIMMs.  These DIMMs are physically persistent,
>> more akin to flash than traditional RAM.  They are also expected to
>> be more cost-effective than using RAM, which is why folks want this
>> set in the first place.
> What variant of NVDIMM's F/P or both?

I'd expect this to get used in any cases where the NVDIMM is
cost-effective vs. DRAM.  Today, I think that's only NVDIMM-P.  At least
from what Wikipedia tells me about F vs. P vs. N:

	https://en.wikipedia.org/wiki/NVDIMM

>> == Patch Set Overview ==
>>
>> This series adds a new "driver" to which pmem devices can be
>> attached.  Once attached, the memory "owned" by the device is
>> hot-added to the kernel and managed like any other memory.  On
>> systems with an HMAT (a new ACPI table), each socket (roughly)
>> will have a separate NUMA node for its persistent memory so
>> this newly-added memory can be selected by its unique NUMA
>> node.
> 
> NUMA is distance based topology, does HMAT solve these problems?

NUMA is no longer just distance-based.  Any memory with different
properties, like different memory-side caches or bandwidth properties
can be in its own, discrete NUMA node.

> How do we prevent fallback nodes of normal nodes being pmem nodes?

NUMA policies.

> On an unexpected crash/failure is there a scrubbing mechanism
> or do we rely on the allocator to do the right thing prior to
> reallocating any memory.

Yes, but this is not unique to persistent memory.  On a kexec-based
crash, there might be old, sensitive data in *RAM* when the kernel comes
up.  We depend on the allocator to zero things there.  We also just
plain depend on the allocator to zero things so we don't leak
information when recycling pages in the first place.

I can't think of a scenario where some kind of "leak" of old data
wouldn't also be a bug with normal, volatile RAM.

> Will frequent zero'ing hurt NVDIMM/pmem's life times?

Everybody reputable that sells things with limited endurance quantifies
the endurance.  I'd suggest that folks know what the endurance of their
media is before enabling this.

