Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43BC8C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:08:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F311B20989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:08:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F311B20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 867748E0003; Tue, 29 Jan 2019 05:08:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 817A88E0001; Tue, 29 Jan 2019 05:08:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DF638E0003; Tue, 29 Jan 2019 05:08:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 405E58E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:08:37 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id b16so23763621qtc.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:08:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=tQ4FgS49orbyn/xMzcpKA/ZVOiU6LEzkZ29/tc8EBNE=;
        b=oa73aJQZMHxUrrkbF3c6cNC05uBfnzR7ik2NcFbBV/H7dttVWkg2WSF7G89fGX2pyw
         ZQnbOhcmtPD0i+SUOnSkq2HPPjc8+0jEEV/l72q2EFSgvj0rU6tKl3sxSwN/X7Cbv0CI
         Uh5mJg2vMbKCt72ddFEouAVzX89MmL0vL3GA8KCb3+E898KGINzTdvKsUVB3oQbYBNmY
         3cBI8K5RdE0URo80Z7kdVFH4+kB+rzjt1LaJD9EtaS28iyPQ8JCLMiyI5qcXmFutcNJH
         OO5E/4GKSIlFjqSkst3qs9l7FcPxY/2d09vDjPao97BdIdH9WlHG7nKG5Z0UE5hkL2lV
         CS7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukebG1XbznDQCYUeWi9f5hCar/f/cAB/2QQ8AhLXeo0FheQI2xbN
	0m+sNJY0rW8L+EfQzIXFH+2+H0AG9DZ6V9ZJpoyBOKIvXjzXrPfsKXMZpvjsObEUXjlfNuAyGKz
	N0hLadRVuCh+HaSGKO8UTWIapCgWq/JYXb1w2/ddbbx8128glh1Yx7VgWC58zMdBxlw==
X-Received: by 2002:a37:9bc3:: with SMTP id d186mr22520039qke.22.1548756516989;
        Tue, 29 Jan 2019 02:08:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7Sq0ln3gTvcQ9h2naok5OtaFDGepi2exQ77jtVfcNL/4ELFZ8w4ngjKM3wJOamCX1rAFMr
X-Received: by 2002:a37:9bc3:: with SMTP id d186mr22520001qke.22.1548756516379;
        Tue, 29 Jan 2019 02:08:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548756516; cv=none;
        d=google.com; s=arc-20160816;
        b=iNbri5viwVN6JR3SMCljnAZIQ697ipi9pXzzjOliBREpw8BLSbX7UWbh3tGzCx3jyV
         bQETmeeozuNhk+OGdF/rs3fzGjzqbdf3PL46omfcUCC6OreQBRcnPsSHAUXnn4e6s1c1
         F06RwIVVCWCXmef+c6d1DfiXueNSRjJpWb2aJ54snbsnhLjXxoDMTnFXPtzSsbkxMB58
         TiKIqmD8KDJKsB80R68ae9yq8SooIWN7xfVpAe34QCf4PjCPpmLfe2P/JPwVD4IdZjx5
         HgqUQbIFDeYZbw3sv6xWYDiVUry5qrIPDEl3iiiNqXbZ1V/ay2JMM5m/ixXSI7pnD4XK
         +ibA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=tQ4FgS49orbyn/xMzcpKA/ZVOiU6LEzkZ29/tc8EBNE=;
        b=E+T+OvBoTCocuX7PyDE8ByRFrHmmYXuxKnVmfmfnVU/omSACjxUYxJUQSLwkwU9fOx
         lRmLHOCDC3N4RX6teaj4RpuPCvDEdjbcRo+YqnRvg5cC71Yooi05TIbAqicQk1rNgcsM
         N5H8+D4BUsoFyRi75lnjyAdHxoU/cw2yLhgyXCPpJSJtwfOcqcDLgibXP5d7KJ+bOE/q
         pP8xrBVLDOjiK474gMbaZrHaxMm45Z3ZCT+RF9Iqp1AK/7YBXF2YnxsooeCCQ1o1PB/j
         NmngArSri064o3DqwixQcp6qb/fVS+pIi/5iBrBN6VovS1BOm2eajGcnYBECntHA6Vxw
         ej1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j13si931973qtj.296.2019.01.29.02.08.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 02:08:36 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 74F76C05B039;
	Tue, 29 Jan 2019 10:08:35 +0000 (UTC)
Received: from [10.36.118.12] (unknown [10.36.118.12])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BB6FD5D73F;
	Tue, 29 Jan 2019 10:08:33 +0000 (UTC)
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, mhocko@suse.com, dan.j.williams@intel.com,
 Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org,
 dave.hansen@intel.com, Vitaly Kuznetsov <vkuznets@redhat.com>
References: <20190122103708.11043-1-osalvador@suse.de>
 <d9dbefb8-052e-7cb5-3de4-245d05270ff9@redhat.com>
 <20190129084359.65fzc4hqan265gii@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <23d64fa1-386d-bdbf-1546-77eb56fcebc6@redhat.com>
Date: Tue, 29 Jan 2019 11:08:32 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190129084359.65fzc4hqan265gii@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 29 Jan 2019 10:08:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.01.19 09:43, Oscar Salvador wrote:
> On Fri, Jan 25, 2019 at 09:53:35AM +0100, David Hildenbrand wrote:
> Hi David,
> 
>> I only had a quick glimpse. I would prefer if the caller of add_memory()
>> can specify whether it would be ok to allocate vmmap from the range.
>> This e.g. allows ACPI dimm code to allocate from the range, however
>> other machanisms (XEN, hyper-v, virtio-mem) can allow it once they
>> actually support it.
> 
> Well, I think this can be done, and it might make more sense, as we
> would get rid of some other flags to prevent allocating vmemmap
> besides mhp_restrictions.

Maybe we can also start passing a struct to add_memory() to describe
such properties. This would avoid having to change all the layers over
and over again. We would just have to establish some rules to avoid
breaking stuff. E.g. the struct always has to be initialized to 0 so new
features won't break any caller not wanting to make use of that.

E.g. memory block types (or if we come up with something better) would
also have to add new parameters to add_memory() and friends.

> 
>>
>> Also, while s390x standby memory cannot support allocating from the
>> range, virtio-mem could easily support it on s390x.
>>
>> Not sure how such an interface could look like, but I would really like
>> to have control over that on the add_memory() interface, not per arch.
> 
> Let me try it out and will report back.
> 
> Btw, since you are a virt-guy, would it be do feasible for you to test the patchset
> on hyper-v, xen or your virtio-mem driver?

I don't have a XEN or Hyper-V installation myself. cc-ing Vitaly, maybe
he has time end resources to test on Hyper-V.

I'll be reworking my virtio-mem prototype soon and try with this
patchset than! But this could take a little bit longer as I have tons of
other stuff on my plate :) So don't worry about virtio-mem too much for now.

> 
> Thanks David!
> 


-- 

Thanks,

David / dhildenb

