Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 476FAC41517
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:41:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0EAF2173B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:41:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0EAF2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EB506B0007; Wed, 24 Jul 2019 14:41:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99C216B000A; Wed, 24 Jul 2019 14:41:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88B4D6B000E; Wed, 24 Jul 2019 14:41:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67FC96B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:41:53 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s25so40030311qkj.18
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:41:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=+BBmQYwWUkEhSmugHLPKU6zl5sPwdniXx4hPovNQH9Q=;
        b=Gbu8aMbSbjUzbAyySkYMjOifbPdx7qaWi6rix0jWtMk1JBneT9X7o62+8gCczlytiW
         oOjGQDsyiQdSBA/xc4/+Eg0d7eAW4clbHkXffDlXr1v3kgct+2W3Zj4VgIbWGuKdBvQ2
         tQfS6OQM8kUKy1jk1ri3RI4lTfBqgCrOEJwgsF5FVCnSfJy2ws1cLib0rH4Jgm/t4gv+
         daRvkXEdRXkJarLdry4u0Gcs8y9fLEn54NlXIULBb+ebgIUNsSUVCKbQO/AfbEoMr/f7
         QjFnKzBJ3Ckbtn/hi5X2IRaf7VHrixxgkl5PRlk11dg2bIeMEDjFKPDvZwtygqZMV0Jw
         yJCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWeNraeMEUs2oGwRKSFLpSo3CRAzTI6nucktztKHPnjQMdjRdW4
	E74fuJW6H6EVLeiIgS2HBRtUlKfePrB4KVCAbZmnzmaH+3svzSGShqDKSd6Ba/dy429bsBhJKnz
	w0NFYl8eIuEZFhlNqqJsf1b6z+Oe2OoUr74RO2yqJp+ndgETLT0HgCfTyj0xIe9KCCw==
X-Received: by 2002:aed:2389:: with SMTP id j9mr59120732qtc.244.1563993713137;
        Wed, 24 Jul 2019 11:41:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4mgw7AKJQFzkzDEia1yraNG6y6z3wJlLHpu1fjLmqvTKgpsGZWaooP3yGE9w9GG2mDOv0
X-Received: by 2002:aed:2389:: with SMTP id j9mr59120707qtc.244.1563993712481;
        Wed, 24 Jul 2019 11:41:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563993712; cv=none;
        d=google.com; s=arc-20160816;
        b=I1SudzZXQUugHN2lW2QRxjMIKV0sseZ+nlmp+hAXEE99Gs3C9nG8obiKn4K9tkInN0
         dA59u9lu4r9yLB7oWB/Bl8PiZdwxIzYs6YrePQls864jKA+4yHrRq7ROspr8rHCPBTYV
         Ckc9wUJUhxcY0JMFO0w9TmVKLFIppFelTEdrIlgFRhvSlVemN9bC7vlg0nOXwyHEWjWY
         d5X1Iyc8OfYBVKhVa4lAshfjBq4Cid1GEyT2qdijF17Ev7/uJnoVKMRmrwQLVbQZ0pFK
         dGoRg/2cL5IPNXITEcRWHclPosgtaDYFmdtOlQALaiFv1SzIb+F8TkjxIAyo7j3KL3eG
         m/Dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=+BBmQYwWUkEhSmugHLPKU6zl5sPwdniXx4hPovNQH9Q=;
        b=eXy0nQIXQ1hC4vswYlBeN3Hh26nkkR2ial+aT5Fobk0jxCtGtaARMCQXVm5piXYt1V
         Jfi4CK7O/MlR8tpk0afYb+sE8oGQaBTF2jJaQAPO2KNVX2sJTb/gmi2bO6WZmL6QcXTA
         /fPEhUKVvzvYl84QaZd9XuZk9b1UfMWtvsFDUAoXuP/bP2Hjs1MhL6+G3v8uN5Yat3Tl
         2CyGkFolMPTKJOrUm1NY52bdM5DBsAFhvsiS5wx21Kp/pJdWSimItL3eyLUW6RFBszIp
         mQVN6gJnodMNfmZeDjp9CgfvC+YB0OzfNYRWZP8ggYIl/wGu76lgL/QvD9UwXdtaLlF2
         2Ajg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v20si30257022qvf.203.2019.07.24.11.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 11:41:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9C27B30C0DCF;
	Wed, 24 Jul 2019 18:41:51 +0000 (UTC)
Received: from [10.36.116.35] (ovpn-116-35.ams2.redhat.com [10.36.116.35])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C234260BF7;
	Wed, 24 Jul 2019 18:41:34 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <f7578309-dd36-bda0-6a30-34a6df21faca@redhat.com>
Date: Wed, 24 Jul 2019 20:41:33 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 24 Jul 2019 18:41:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.07.19 20:40, Nitesh Narayan Lal wrote:
> 
> On 7/24/19 12:54 PM, Alexander Duyck wrote:
>> This series provides an asynchronous means of hinting to a hypervisor
>> that a guest page is no longer in use and can have the data associated
>> with it dropped. To do this I have implemented functionality that allows
>> for what I am referring to as page hinting
>>
>> The functionality for this is fairly simple. When enabled it will allocate
>> statistics to track the number of hinted pages in a given free area. When
>> the number of free pages exceeds this value plus a high water value,
>> currently 32,
> Shouldn't we configure this to a lower number such as 16?
>>  it will begin performing page hinting which consists of
>> pulling pages off of free list and placing them into a scatter list. The
>> scatterlist is then given to the page hinting device and it will perform
>> the required action to make the pages "hinted", in the case of
>> virtio-balloon this results in the pages being madvised as MADV_DONTNEED
>> and as such they are forced out of the guest. After this they are placed
>> back on the free list, and an additional bit is added if they are not
>> merged indicating that they are a hinted buddy page instead of a standard
>> buddy page. The cycle then repeats with additional non-hinted pages being
>> pulled until the free areas all consist of hinted pages.
>>
>> I am leaving a number of things hard-coded such as limiting the lowest
>> order processed to PAGEBLOCK_ORDER,
> Have you considered making this option configurable at the compile time?
>>  and have left it up to the guest to
>> determine what the limit is on how many pages it wants to allocate to
>> process the hints.
> It might make sense to set the number of pages to be hinted at a time from the
> hypervisor.
>>
>> My primary testing has just been to verify the memory is being freed after
>> allocation by running memhog 79g on a 80g guest and watching the total
>> free memory via /proc/meminfo on the host. With this I have verified most
>> of the memory is freed after each iteration. As far as performance I have
>> been mainly focusing on the will-it-scale/page_fault1 test running with
>> 16 vcpus. With that I have seen at most a 2% difference between the base
>> kernel without these patches and the patches with virtio-balloon disabled.
>> With the patches and virtio-balloon enabled with hinting the results
>> largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a 2%
>> drop in performance as I approached 16 threads,
> I think this is acceptable.
>>  however on the the lastest
>> linux-next kernel I saw roughly a 4% to 5% improvement in performance for
>> all tests with 8 or more threads. 
> Do you mean that with your patches the will-it-scale/page_fault1 numbers were
> better by 4-5% over an unmodified kernel?
>> I believe the difference seen is due to
>> the overhead for faulting pages back into the guest and zeroing of memory.
> It may also make sense to test these patches with netperf to observe how much
> performance drop it is introducing.
>> Patch 4 is a bit on the large side at about 600 lines of change, however
>> I really didn't see a good way to break it up since each piece feeds into
>> the next. So I couldn't add the statistics by themselves as it didn't
>> really make sense to add them without something that will either read or
>> increment/decrement them, or add the Hinted state without something that
>> would set/unset it. As such I just ended up adding the entire thing as
>> one patch. It makes it a bit bigger but avoids the issues in the previous
>> set where I was referencing things before they had been added.
>>
>> Changes from the RFC:
>> https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
>> Moved aeration requested flag out of aerator and into zone->flags.
>> Moved bounary out of free_area and into local variables for aeration.
>> Moved aeration cycle out of interrupt and into workqueue.
>> Left nr_free as total pages instead of splitting it between raw and aerated.
>> Combined size and physical address values in virtio ring into one 64b value.
>>
>> Changes from v1:
>> https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
>> Dropped "waste page treatment" in favor of "page hinting"
> We may still have to try and find a better name for virtio-balloon side changes.
> As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.

We should have named that free page reporting, but that train already
has left.

-- 

Thanks,

David / dhildenb

