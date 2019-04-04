Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC1D5C10F05
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:21:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86437206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:21:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86437206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 259B36B000D; Thu,  4 Apr 2019 01:21:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 208806B000E; Thu,  4 Apr 2019 01:21:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F7DA6B026A; Thu,  4 Apr 2019 01:21:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3ADA6B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:21:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n24so731403edd.21
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:21:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=fmaH86uMKBvFuGQSW0kMXgrFgfs3DyvOSphebP+hgLA=;
        b=CFRCrYfrRYGYpRCS0/DYEpg5VDbN4WJUp7eA2y18sCwfidjTbVizNfbTIOIigYHBLO
         0wiYSLA6a4zgYsK0I6bjFPWseXADVbTf5t8bfQRRSfiZ3re+JyOm77Q2B1+2s418JfgE
         EnchMXbaIN1Yy5zXQSyb0l9IJdjo2XvG7EtF9DUXsE5dN3V+fy6wAvaNshuGPfMACGFP
         pEQ1QJmraU1q002VNh9KGBFfwdp6qMlTFYqqeq87uISROCystuYBztlNC/brrUHZfGVW
         h1NrmmKBNyQc2z2VdQEeFzCkyYtTapO20fvSROQM27f8c4DKAPndVXgxSv7nuNpv/A75
         coTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX52Im/0MPpdkhOraQv23m8ykxAyws2UQ6dwiTMZjHcphOIBocW
	hwiHL7U5ce4bnGORIB26aey8K+sOgFe5mjW4LhDU77GZMumW5fAQvm+LWYeKcD99c6Aw5PTgZ7q
	/mfxC0on4rNejdy2MBolibnsGlAjVeCWcUhagvD2vXDWm/Efp0zm6CXl5FK+X+dVCkQ==
X-Received: by 2002:a17:906:c2d0:: with SMTP id ch16mr2220084ejb.197.1554355270283;
        Wed, 03 Apr 2019 22:21:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyl34LSOIScXLfI4AhHG/y3LWhnhWPsoUze96ETqisFtnDnpHTuHKXw3KE9W9jWpEn+0R8J
X-Received: by 2002:a17:906:c2d0:: with SMTP id ch16mr2220033ejb.197.1554355269266;
        Wed, 03 Apr 2019 22:21:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554355269; cv=none;
        d=google.com; s=arc-20160816;
        b=ZI5EFXUCTS3Vml8y0lZ23FMSnpAZIcXBTfj7Ynv7+a2G/vMc+NBvJBYJ8J8XSk3nZP
         6+0lHAzXgIoA2iJEOv0x6IMaKtuNuY2qHd1m4Jo991LwzFa597UQ08W8YMTSv76GLI5q
         EdpuWmYMOhma99um3lknbxfScIO6vcF91zOVNzJq5PTlMxI2V0K+OCshX9DVnlmow/qY
         cfcaw0a5hXwmE9zdF16Y0ArycWGw87Rr97cgMb9iGgIY6KoI0x2lU2mNVOwfqCkBh55I
         X2v/Hhl+GepczHbLfkuIxSpkMGzwbnHJxB/+lhkgy+JpfVw3mbrbGlaUZU8d1TlpdsCn
         AJXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=fmaH86uMKBvFuGQSW0kMXgrFgfs3DyvOSphebP+hgLA=;
        b=vnTpbi5fRRkTMfjixJPHCVYcNCDSdWB8WsTk85xhNBV5VxwbowcbgyMOT4MN3dvId5
         NEHoT8ZVMUVW/DDY/PMA1QhvBKGUmJQ0zfAFnsT96q6pg2LDVd44HVO/MCakjQRkCiBZ
         OG2dDDkWGxWPgWpNCF8Q4p7TcCqMYunI1Ar/YDNMeUKCz4IOqq2KW9sj6tBELahDv5oz
         b1f+fUR7GEC2MHfiHioDBTUD4NsdBO3R8HFfP7TNMFiyM7fDSM5oj2RHRdR/iYw0y7f2
         GmGwVXH68BUQ7n3eoUW8tCIQbeV/fUsqWExabEEk1+p3A5axyrRthtQvDpPp3LKXG2QO
         fbYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r21si705104eji.134.2019.04.03.22.21.08
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 22:21:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B22B8A78;
	Wed,  3 Apr 2019 22:21:07 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CC0153F721;
	Wed,  3 Apr 2019 22:21:01 -0700 (PDT)
Subject: Re: [PATCH 1/6] arm64/mm: Enable sysfs based memory hot add interface
To: Robin Murphy <robin.murphy@arm.com>, David Hildenbrand
 <david@redhat.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, osalvador@suse.de, logang@deltatee.com, cai@lca.pw
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-2-git-send-email-anshuman.khandual@arm.com>
 <4b9dd2b0-3b11-608c-1a40-9a3d203dd904@redhat.com>
 <e5665673-60ab-eee8-bc05-53dafb941039@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <514d246d-2619-08a9-bd1d-92d6b70b5a01@arm.com>
Date: Thu, 4 Apr 2019 10:51:03 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <e5665673-60ab-eee8-bc05-53dafb941039@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 06:42 PM, Robin Murphy wrote:
> On 03/04/2019 09:20, David Hildenbrand wrote:
>> On 03.04.19 06:30, Anshuman Khandual wrote:
>>> Sysfs memory probe interface (/sys/devices/system/memory/probe) can accept
>>> starting physical address of an entire memory block to be hot added into
>>> the kernel. This is in addition to the existing ACPI based interface. This
>>> just enables it with the required config CONFIG_ARCH_MEMORY_PROBE.
>>>
>>
>> We recently discussed that the similar interface for removal should
>> rather be moved to a debug/test module
>>
>> I wonder if we should try to do the same for the sysfs probing
>> interface. Rather try to get rid of it than open the doors for more users.
> 
> Agreed - if this option even exists in a released kernel, there's a risk that distros will turn it on for the sake of it, and at that point arm64 is stuck carrying the same ABI baggage as well.

True. Only if we really dont like that interface.

> 
> If users turn up in future with a desperate and unavoidable need for the legacy half-an-API on arm64, we can always reconsider adding it at that point. It was very much deliberate that my original hot-add support did not include a patch like this one.

Sure. Will drop this one next time around.

