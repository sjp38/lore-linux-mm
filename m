Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA322C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:44:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B0B2216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:44:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B0B2216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 207628E0003; Thu,  1 Aug 2019 04:44:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B97E8E0001; Thu,  1 Aug 2019 04:44:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 081AB8E0003; Thu,  1 Aug 2019 04:44:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D94CF8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:44:41 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z13so60547218qka.15
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:44:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ySZnW3P5HdWDOuRz49nSCLDCln/WQG1asJkvWWv4ffQ=;
        b=q8spCBMtshV3aAz/sTo6yAJiJTjl9N3Y/AUMot4Zn3iEjgXhTQfPGqh4jebl+/Z1tx
         HQVmX+sEQMFYAEE36ccdQ6Jhj6fKQMAy2FCrYW7BdEwsdFnWz0Do9ZdFxMGuZyzNJ4Yn
         B+aq8579RTTMI8SWMaGt93hwhXjuiZwanMNyfxG5VWSZr2o2mHrKdSZCznhYEWFbHX5I
         HokDot2wv1mV+uynZKFAylOT1V4E13AUnd+8D0xVs6rQHIeVVLpxJqRrrg2JpNrZlx8u
         LY33qNpmZogdCeLy6iYuWvQpSnlMNdk6DWxLGYGunW5enpq8R/fMwXDqeOeUPTwlfqBB
         whMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVgAZaUo4qfan71hytsDfMpPLI/uq6HUmSMvIWfOJSoZsNwWzCH
	YhzWUzrMiKnMElgAcZ/tqlq0A3XWGubCzaNnqT02pCNu6Xws7/X5YFl6LgVTLSPXauJ3PGT890a
	QIG3RMwEAhMKf3FNH1KhE7yeRJ8cCcl9rq2I5+eUhnC2KbVwTlhxfVhZudfIpcfmKtQ==
X-Received: by 2002:a37:49c2:: with SMTP id w185mr75627963qka.407.1564649081641;
        Thu, 01 Aug 2019 01:44:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqNYp5V+EyDgseWy19UlbBPnFBMVtsDpdhkjfbCTmAaDBm9CL7OPAUpN0/n/rzcWB0mloc
X-Received: by 2002:a37:49c2:: with SMTP id w185mr75627937qka.407.1564649080778;
        Thu, 01 Aug 2019 01:44:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564649080; cv=none;
        d=google.com; s=arc-20160816;
        b=u6bDfwA/xCJhtnvu5GKi/df7K82OGaOfz6wT37Q+zGSBodUhAPsQ99ZuGx/Xb5z7sh
         adU1iBNF3dxHZMElCgt3a2vfsyi73xUxV2ePQr/+RtdygUgEHiWThOVa3eF27Ek/6hP/
         DyGtLQJN3mgzuemyZeF4pUxO+ZDkfTZQdnheCxljUltDvhI5z/TgUravyST59O3q+xiW
         OxguApsJE9er9PIH8hIZqgDODYqQCt/obm8xIUp1hB0FdJ2tOQbbw28SE+83rZqTahsU
         aMMd+OMg4sLgE7t8+Illj/cq0RxKsbqvi3yRe9BhrDTD8EtiQzPKJtgKkuiDu/SHdPDx
         EaIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=ySZnW3P5HdWDOuRz49nSCLDCln/WQG1asJkvWWv4ffQ=;
        b=NJuNiIKr8XhpZXAYIMNzVYwLW2hdhX73xjf7aZerc1fjRniK4yUh1Yae3KOxTxBq3z
         hizQ9PFYiEPrpOWpPDQOcXssMg5hq3cqmaJjFZvfPopYQBeOpjNF2wQGf2XaDWUD6DXA
         RNxaey5gQmZpLFT4ffksFGezUgVY+Ui4Q0bds6NT1JexZv5vbFFlp+dPRng32WyGXxq/
         GOQ7P9pUkeWVJn0UcVqQy1wC/rCwbRBnl4wjBMJK19mRSOoUbKJ4C9zPDg0dJWnFgM7Z
         t3HhxTZU7AC6g3KYSuwv6I+Tvh/dkqcVjcfFktBo4e/V1tTCmtRq7Zy2o9HtTmNGNmfI
         DAKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f7si38735951qkc.162.2019.08.01.01.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 01:44:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D52A7300CB07;
	Thu,  1 Aug 2019 08:44:39 +0000 (UTC)
Received: from [10.36.116.245] (ovpn-116-245.ams2.redhat.com [10.36.116.245])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8BA8E5D9CA;
	Thu,  1 Aug 2019 08:44:36 +0000 (UTC)
Subject: Re: [PATCH v3 0/5] Allocate memmap from hotadded memory
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, mhocko@suse.com, anshuman.khandual@arm.com,
 Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190801073931.GA16659@linux>
 <1e5776e4-d01e-fe86-57c3-1c3c27aae52f@redhat.com>
 <20190801083856.GA17316@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <9673cceb-afae-ae77-1bd8-56e07c814cc0@redhat.com>
Date: Thu, 1 Aug 2019 10:44:35 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190801083856.GA17316@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 01 Aug 2019 08:44:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.08.19 10:39, Oscar Salvador wrote:
> On Thu, Aug 01, 2019 at 10:17:23AM +0200, David Hildenbrand wrote:
>> I am not yet sure about two things:
>>
>>
>> 1. Checking uninitialized pages for PageVmemmap() when onlining. I
>> consider this very bad.
>>
>> I wonder if it would be better to remember for each memory block the pfn
>> offset, which will be used when onlining/offlining.
>>
>> I have some patches that convert online_pages() to
>> __online_memory_block(struct memory block *mem) - which fits perfect to
>> the current user. So taking the offset and processing only these pages
>> when onlining would be easy. To do the same for offline_pages(), we
>> first have to rework memtrace code. But when offlining, all memmaps have
>> already been initialized.
> 
> This is true, I did not really like that either, but was one of the things
> I came up.
> I already have some ideas how to avoid checking the page, I will work on it.

I think it would be best if we find some way that during
onlining/offlining we skip the vmemmap part completely. (e.g., as
discussed via an offset in the memblock or similar)

> 
>> 2. Setting the Vmemmap pages to the zone of the online type. This would
>> mean we would have unmovable data on pages marked to belong to the
>> movable zone. I would suggest to always set them to the NORMAL zone when
>> onlining - and inititalize the vmemmap of the vmemmap pages directly
>> during add_memory() instead.
> 
> IMHO, having vmemmap pages in ZONE_MOVABLE do not matter that match.
> They are not counted as managed_pages, and they are not show-stopper for
> moving all the other data around (migrate), they are just skipped.
> Conceptually, they are not pages we can deal with.

I am not sure yet about the implications of having these belong to a
zone they don't hmmmm. Will the pages be PG_reserved?

> 
> I thought they should lay wherever the range lays.
> Having said that, I do not oppose to place them in ZONE_NORMAL, as they might
> fit there better under the theory that ZONE_NORMAL have memory that might not be
> movable/migratable.
> 
> As for initializing them in add_memory(), we cannot do that.
> First problem is that we first need sparse_mem_map_populate to create
> the mapping, and to take the pages from our altmap.
> 
> Then, we can access and initialize those pages.
> So we cannot do that in add_memory() because that happens before.
> 
> And I really think that it fits much better in __add_pages than in add_memory.

Sorry, I rather meant when adding memory, not when onlining. But you
seem to do that already. :)

> 
> Given said that, I would appreciate some comments in patches#3 and patches#4,
> specially patch#4.

Will have a look!

> So I would like to collect some feedback in those before sending a new version.
> 
> Thanks David
> 


-- 

Thanks,

David / dhildenb

