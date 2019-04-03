Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C904C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:53:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D905C21473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:53:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D905C21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 862B86B0008; Wed,  3 Apr 2019 04:53:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 811EC6B000A; Wed,  3 Apr 2019 04:53:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FF176B000C; Wed,  3 Apr 2019 04:53:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5046D6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:53:27 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x58so16213623qtc.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:53:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=6hfWGHoCwAVQU3sP4laaijTierNYeuucSY/HXvPK+Xw=;
        b=JmD6P03oL6AEL+3qtvIMT/Y7jWBX72Ztisul1k2G7d0Q5+EIkA+0zLaOHZyutd2bii
         tgKSGL7t7CXppSgFHU8sRSPmVTz4tqCZ9BxcdlHbpB+MkwdxIQfdVKVan54sSj6WB3SG
         9LbQc9h6UttcCqhCS5i4AMSOkoCslmDBNPAMYvn1SjHJLxhAInnhPK8hT4jVTwPVAJK0
         CC1zAzTmbyq8yMWeGe5metwCB/vOnRcvUGF9K2XbwG4nRHYjEzPAja52BTG180WMGdlX
         fyhkcNuZiupHnUA6G8uiui8m1Amq0pwDdYq22z3HvVVBjDL6m8Q55hswb7fBgFWBZkHD
         WRFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU9T6GrUx9e17eP9dLfqQ+G8kkbUjPQjRfuHrj9ty61LAXsPBFb
	56zdYRhL3LmDDxvSYnmg5FE5XhPTJWJR5KBZPfoX2KlhxNVqIhqsM7oFduVS6TlfDzmYrE0PyIC
	sav4BuOBGbE2twi0ncs3vNZbHuUv6mO6IPUKMHY0ZGN8OxaYsxNyv5ACDrvRQnV0J2g==
X-Received: by 2002:ac8:1a25:: with SMTP id v34mr61392314qtj.337.1554281607095;
        Wed, 03 Apr 2019 01:53:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxK4/2jO5DR8c1WizitB7qRcpxEI7bIbiEwIsj8F1TzORuMvSdBhvsj6Mh2EGaLyCs9jShB
X-Received: by 2002:ac8:1a25:: with SMTP id v34mr61392290qtj.337.1554281606608;
        Wed, 03 Apr 2019 01:53:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554281606; cv=none;
        d=google.com; s=arc-20160816;
        b=lUFQ9y2UDdtVqla/bhBywrlrcENsqe10PWIQbqQj40D6+jwH/kRAGHFOaxTpxcWYZg
         C++E68aHMYG+/+6BBV/KanzuEk6KhcRdA5nAOs3cfQ00aKp1u83vHKeP3HMyJL54tPFX
         zpTwAmRl2tAVKRxqoWLnFzqdt6Sw++0bfPNxHr7maWq1a4qTM87CYdk8d1WU3MZjppV2
         uREDyqUfWBhAv+4JtK9h8dZxqrvfdva3vVkApY1lHE6ouAiT1H67uAIWMSR6CKHYEyGq
         JppEn1pfixejc4M3krEKmmLbD0P4rHZe3CLoLcFmv5HWwb6iv0IOZyofOG1RsV3fdZqT
         gdHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=6hfWGHoCwAVQU3sP4laaijTierNYeuucSY/HXvPK+Xw=;
        b=u34vLFMXDIZC6ghXJzZOfsCbLWpsg2vXszVcrPm+RH3Lxf6kTOD4/d+mjBNOqLsrLG
         h95JzACtlrANhMa87+O3gTk56rO6cIkH0hjTiqGCy64jeKoG8jNiL90k4kn0cNKDSKNZ
         umwyumQiJiyp9bkqRqk2hZmzWioFV4nyY3p82PpMLfjwDniHD8RL3ZuLk9riR5cN6yKl
         v+byzmroI3WWbvJ8uDzsaJGkiV/ablz3UluLC8OqC/rkXFtF2TEJ6sJ4tjDD8VdbBNXG
         lEOAU47KG4aRZpj1XXxYLVyJNkuvBkRKwp8JILfpDoQ1cvBSurPVOt9+pC10Yw9zF6Fn
         atDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f27si3445153qkk.134.2019.04.03.01.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:53:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A5F562DD22;
	Wed,  3 Apr 2019 08:53:25 +0000 (UTC)
Received: from [10.36.117.246] (ovpn-117-246.ams2.redhat.com [10.36.117.246])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 02B9F608A5;
	Wed,  3 Apr 2019 08:53:23 +0000 (UTC)
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org,
 dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
 <d55aa259-56c0-9601-ffce-997ea1fb3ac5@redhat.com>
 <20190403083757.GC15605@dhcp22.suse.cz>
 <04a5b856-c8e0-937b-72bb-b9d17a12ccc7@redhat.com>
 <20190403084915.GF15605@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <e3b151ec-b050-d5bf-0cd1-d8489463c169@redhat.com>
Date: Wed, 3 Apr 2019 10:53:23 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190403084915.GF15605@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 03 Apr 2019 08:53:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.04.19 10:49, Michal Hocko wrote:
> On Wed 03-04-19 10:41:35, David Hildenbrand wrote:
>> On 03.04.19 10:37, Michal Hocko wrote:
> [...]
>>> That being said it should be the caller of the hotplug code to tell
>>> the vmemmap allocation strategy. For starter, I would only pack vmemmaps
>>> for "regular" kernel zone memory. Movable zones should be more careful.
>>> We can always re-evaluate later when there is a strong demand for huge
>>> pages on movable zones but this is not the case now because those pages
>>> are not really movable in practice.
>>
>> Remains the issue with potential different user trying to remove memory
>> it didn't add in some other granularity. We then really have to identify
>> and isolate that case.
> 
> Can you give an example of a sensible usecase that would require this?
> 

The two cases I mentioned are

1. arch/powerpc/platforms/powernv/memtrace.c: memtrace_alloc_node()

AFAIKS, memory that wasn't added by memtrace is tried to be offlined +
removed.

"Remove memory in memory block size chunks so that iomem resources are
always split to the same size and we never try to remove memory that
spans two iomem resources"

2. drivers/acpi/acpi_memhotplug.c:acpi_memory_enable_device()

We might hit "__add_memory() == -EEXIST" and continue. When removing the
devices, __remove_memory() is called. I am still to find out if that
could imply removing in a different granularity than added.

-- 

Thanks,

David / dhildenb

