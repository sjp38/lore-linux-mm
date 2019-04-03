Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77F1CC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:48:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C5BD21473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:48:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C5BD21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9A886B0008; Wed,  3 Apr 2019 04:48:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B228D6B000A; Wed,  3 Apr 2019 04:48:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C31D6B000C; Wed,  3 Apr 2019 04:48:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7641B6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:48:52 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id i124so14061922qkf.14
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:48:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=iJ7U2hKWHcQ2nsGNMbZUj5C+vrS9qlM8J7q7lfLSOl4=;
        b=fi3X2AeKxf+hi3CUUs7slw0uiBBgNAspt/3mhoBz3C5LVjNWtsA3ouCDt6MOD9UOpw
         c1wtlx+9PIPRUrz3RzdqM3TJDcrB4zpJAQuUkVXZpBPzTOunFAzK2/9bbnxJM7o/Sljp
         eb+RuGphQO2tMxZb1V32vgt+pAAGUTu7yJDtqq71IaMK/OsWXP6K4Zn2yrV4AA8W7TzZ
         T/J4JYoduu3kDcA+c8JkGXpmfeXQK47O+jBapuAeulfWQo1PuKRMtmN41Bg2RhafXqnA
         SnCMLSD8LYnqR/MvaOtMGVnvseFbZpgAzSLgTJLRespBFujjcmQMx7mfvSTNbGRfUihy
         p+xw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV3lncjAOajeLuWWDa1ELN+yOWq++97LgFPgEcJ8WAhYrAfPmKl
	jeUEOBoyCXG5nRuIjDSAgN/GweRMvEn3PT7NEle3PsH6wMowB4P2C5EXNPU9w/Uab/d3t4f+ked
	23Ho7NzTbisUABkeIhd6D7RMudAPIUhj1W9QBT+ZD8b/1f90be/f6l5NpZaqaySJksA==
X-Received: by 2002:a37:451:: with SMTP id 78mr32461709qke.315.1554281332245;
        Wed, 03 Apr 2019 01:48:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyufaEIUPsNvYPDHs7ZxpDWgEZ0puRamXBDdJsVygFdeOYv+mxixcdgFlNfuAaM8cg8ueH/
X-Received: by 2002:a37:451:: with SMTP id 78mr32461687qke.315.1554281331791;
        Wed, 03 Apr 2019 01:48:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554281331; cv=none;
        d=google.com; s=arc-20160816;
        b=KdaUiPfG5Qugx/dpX5FfL58WACDpxxoCD4LCSLEIRVtt0BWYEg6ksiDxfkpZgnTcGT
         8e5DfaAX+rgT1feiKIv8CyqPYfAhY+s9ztwp4ZW/nZDZ38iPcq/AU99IQ8I7ZGTMDZDP
         zRQTpsb7hF6X/vbB8kzm7Ef3HQKVL5VcBwr7gA/lz8pdCx2p1EVAeCNi0sFX6rf89hFx
         A1fpdqTJkio73Rp7vJkmky+62ebn3C8QMBn6a8lEGCKIzdxliWaFrBdern9+56MWwJZU
         srW/sd4AfFtLf5CsxjWjIXsps6IshO9WRU4eJR89bSPMvmuusv4JDxHCc0pBC2aMovzR
         iAeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=iJ7U2hKWHcQ2nsGNMbZUj5C+vrS9qlM8J7q7lfLSOl4=;
        b=nrEmIP8HeKERo6mVFRVFksFFDeiSvyu9zAbVBGO78A4139yCQqRI5dJi3nvDS7T+hN
         xLKkE/b4UD60ISDT0b1N0GHrTe3FHKmw6tFFSi+yfVks+H8q7srwTZCd8IsFO4tvUZr0
         aItRBnYE2ZArwfnBaApUPpQDTrDS4mnvVEvsnRUxpj0vMMSCPBEB16Ei4L0BDb1F+D5h
         IeHUbq1lT3eOpVtWOSeWo94sNraGU8PgGk5mz9QFGscg3dnZQxVmD/1H42sdLe2fMryo
         /BLnnLp+0XeXjlI1teAlAAOcOCJ8OdhD/tyYfTpQQsMOqaWWWHgHs3PJEnMypgVc2vwe
         3qMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i29si2037337qte.360.2019.04.03.01.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:48:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DE2E330917AB;
	Wed,  3 Apr 2019 08:48:50 +0000 (UTC)
Received: from [10.36.117.246] (ovpn-117-246.ams2.redhat.com [10.36.117.246])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0FC3B60240;
	Wed,  3 Apr 2019 08:48:48 +0000 (UTC)
Subject: Re: [PATCH 2/4] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
To: Michal Hocko <mhocko@kernel.org>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190328134320.13232-1-osalvador@suse.de>
 <20190328134320.13232-3-osalvador@suse.de>
 <20190403084603.GE15605@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <6902abad-4519-3a61-14ec-57f3d4a342bc@redhat.com>
Date: Wed, 3 Apr 2019 10:48:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190403084603.GE15605@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 03 Apr 2019 08:48:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.04.19 10:46, Michal Hocko wrote:
> On Thu 28-03-19 14:43:18, Oscar Salvador wrote:
>> From: Michal Hocko <mhocko@suse.com>
>>
>> arch_add_memory, __add_pages take a want_memblock which controls whether
>> the newly added memory should get the sysfs memblock user API (e.g.
>> ZONE_DEVICE users do not want/need this interface). Some callers even
>> want to control where do we allocate the memmap from by configuring
>> altmap.
>>
>> Add a more generic hotplug context for arch_add_memory and __add_pages.
>> struct mhp_restrictions contains flags which contains additional
>> features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
>> currently) and altmap for alternative memmap allocator.
>>
>> Please note that the complete altmap propagation down to vmemmap code
>> is still not done in this patch. It will be done in the follow up to
>> reduce the churn here.
>>
>> This patch shouldn't introduce any functional change.
> 
> Is there an agreement on the interface here? Or do we want to hide almap
> behind some more general looking interface? If the former is true, can
> we merge it as it touches a code that might cause merge conflicts later on
> as multiple people are working on this area.
> 
I was wondering if instead of calling it "mhp_restrctions" we should
call it something like "mhp_options", so other stuff might be easier to
fit in. Especially, so we don't have to touch all these functions
whenever we simply want to pass yet another paraemeter down to the core
- or remove one.

-- 

Thanks,

David / dhildenb

