Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D88A3C31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:21:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A91E92054F
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:21:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A91E92054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 456BB6B0006; Thu, 13 Jun 2019 11:21:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4083D6B026A; Thu, 13 Jun 2019 11:21:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F6E36B026B; Thu, 13 Jun 2019 11:21:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4CC96B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:21:04 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so31324046edb.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:21:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=47YRuKWEAOA7Z5tDQ9E5Sxr/55qVvAI8YJY5aFGGR1Y=;
        b=U7duJq5qLQ4emu69u1tv6O+87O+zQEJz/BWaGCRpU2IWrprxruUgMrnJDSrH44deqb
         Tn8KM8Orb+k5an1yKtTEQyf51o3peU0AE9SDlsNQgDP6PuziInbmycYm0HdZgx4We0xE
         GWpnAajfohZvx0Sb3B1haABZv3XjXgB+OdNATEHxJjDYMsQG3wcUZC3mrhKjio3tBKvS
         QaejAMEoI/V2ctD0czdZlffVuhYT/FlpW1iSgIwXiFLaBJudthfFpQ+y5pcD+fHS4N9t
         uKivxOM8H+2svN4NsbMz8M3+Jqvxf8PbSAP1WW2ggRz80JTrMURl/Kvg3sBK5Muoswoz
         G7rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAV9OVm34sf2luuMlUBXUuZoZs7t2qUE5D9awvLca61R9Xrz8uJQ
	9U4P6uRd4dUMEU4cx08Fy1pQ13pfYMvLP7GnRrxl4zW858qVZzITYumuQ+uUDwaZ9EoWWBNucRX
	6i/Dpyn6lHjD/rQjPxcXxANkfUof8pfKZbcLOxJpMrRsqXYCsXlFbiSyGuRv1GU75hw==
X-Received: by 2002:a17:906:d053:: with SMTP id bo19mr74883163ejb.86.1560439264199;
        Thu, 13 Jun 2019 08:21:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6Udsm3clWUap4Aoa1xqysAI4D0LRJGcQVUXkuNxhBhyNDfUZNRnGSClOoBazpiNVy3Kwc
X-Received: by 2002:a17:906:d053:: with SMTP id bo19mr74883095ejb.86.1560439263402;
        Thu, 13 Jun 2019 08:21:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560439263; cv=none;
        d=google.com; s=arc-20160816;
        b=fcdu7l+kjaArMS1RhbrxXipkh45kO5iGpJ5YH3zTdWSXSkKgBB2ZGbjZFeU4mhxjpy
         y8dd62x8G8LFjcyQ/YDf8HCs2wJennsZ+il2epyzegZPMIPSffrOnLbLCJgFUaGDeiwl
         w7zRoPJycR+UYy5c38OxdIcFOt1EOOQfsyXDPSjBP7C4RkFALNNp/rfQv4L6hDuuTm/u
         IMs6/T7jBHYz8CX/N8SnyS1vyL63TNL6mRZUxwYzMQp6RIxNdZqL3MF4tCS7ORzCzj/W
         0ZfmVGL7XnHejU3yPmOX0Rdw91NlPdTBDiBmKBmoAiDRhCQgT+V6QnZmNoQD5Y6x572U
         R2BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=47YRuKWEAOA7Z5tDQ9E5Sxr/55qVvAI8YJY5aFGGR1Y=;
        b=fWZ2Qpw+N6uUlbVM2cJPfVroLURK0Lys1YWUwwATgXc1Zffcy62ePe430hHgMn9T0G
         0cNYCuA0WPU1pbjpzbd/HJJMVdkPodE8O16zI0m9by1cJHiI5eQ+t5SUbgfyEN/aPWBu
         wgnTshAho4NodHjsuzOf5zm2hiBthynzDyN/jCgql7Awvw+VzjNZLLywsGukY4vMk2AW
         HcpCpQO9Sym8DzEXgDqUZL4e6Z6ysYRB0DfxDmIbLi4xrMfmcwEMOzXOt9emYp0Z4sT3
         kEX6M5D9kaI+qUvOAOZj8oSLvhEvXumMA4qiPshOGnBfmwxfov+B3EsvXZ/gshPqXkzQ
         BR7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h45si2733690edh.35.2019.06.13.08.21.03
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 08:21:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 77F3B367;
	Thu, 13 Jun 2019 08:21:02 -0700 (PDT)
Received: from [10.162.40.191] (p8cg001049571a15.blr.arm.com [10.162.40.191])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 15B0F3F718;
	Thu, 13 Jun 2019 08:20:58 -0700 (PDT)
Subject: Re: [PATCH] mm/vmalloc: Check absolute error return from
 vmap_[p4d|pud|pmd|pte]_range()
To: Roman Penyaev <rpenyaev@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, Mike Rapoport
 <rppt@linux.ibm.com>, Roman Gushchin <guro@fb.com>,
 Michal Hocko <mhocko@suse.com>, "Uladzislau Rezki (Sony)"
 <urezki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
References: <1560413551-17460-1-git-send-email-anshuman.khandual@arm.com>
 <7cc6a46c50c2008bfb968c5e48af5a49@suse.de>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <406afc57-5a77-a77c-7f71-df1e6837dae1@arm.com>
Date: Thu, 13 Jun 2019 20:51:17 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <7cc6a46c50c2008bfb968c5e48af5a49@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/13/2019 03:03 PM, Roman Penyaev wrote:
> On 2019-06-13 10:12, Anshuman Khandual wrote:
>> vmap_pte_range() returns an -EBUSY when it encounters a non-empty PTE. But
>> currently vmap_pmd_range() unifies both -EBUSY and -ENOMEM return code as
>> -ENOMEM and send it up the call chain which is wrong. Interestingly enough
>> vmap_page_range_noflush() tests for the absolute error return value from
>> vmap_p4d_range() but it does not help because -EBUSY has been merged with
>> -ENOMEM. So all it can return is -ENOMEM. Fix this by testing for absolute
>> error return from vmap_pmd_range() all the way up to vmap_p4d_range().
> 
> I could not find any real external caller of vmap API who really cares
> about the errno, and frankly why they should?  This is allocation path,

map_vm_area() which is an exported symbol suppose to provide the right
error code regardless whether it's current users care for it or not.

> allocation failed - game over.  When you step on -EBUSY case something
> has gone completely wrong in your kernel, you get a big warning in
> your dmesg and it is already does not matter what errno you get.

Its true that vmap_pte_range() does warn during error conditions. But if
we really dont care about error return code then we should just remove
specific error details (ENOMEM/EBUSY) and instead replace them with simple
boolean false/true or (0/1/-1) return values at each level. Will that be
acceptable ? What we have currently is wrong where vmap_pmd_range() could
just wrap EBUSY as ENOMEM and send up the call chain.

