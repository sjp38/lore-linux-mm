Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B82CDC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:56:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64B162184D
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:56:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64B162184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFF776B026A; Fri, 29 Mar 2019 04:56:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED6276B026B; Fri, 29 Mar 2019 04:56:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEE036B026C; Fri, 29 Mar 2019 04:56:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA6FC6B026A
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:56:41 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q12so1594184qtr.3
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:56:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=PBMt1wTkD0xpnWo/dRY7GKZR4V8f+lC6/Y5I5kDL8Hw=;
        b=iaFmOOGAOL+INQIZcCqdNIwHPaqWk2L2AfFbrWdWQrUY2jV8bacYgsOrOvyfY8IY+a
         TxsuPcZK/i1gzNmEfUdvfom3EILeqAnde5ILDnY6IvapyKIrF040BgM92tQtEg4HEvUe
         zzwtYcqKAHDajzVnwSo1L5LsolJ7/iMPVPyY9aE2q3f8x1wUa1hlPzsk6S0OY+FMcs5E
         cKKUUzevRA3jJOreqzBdLKB6gxL2WOo1+9/cjNKapXoWSAOVUb8bvJDPTjRxhziZ7LPm
         +rshzcZoTflFb70INK0QA5qTw1MSONBOYf+kWj4UEwQr/44M+pQh3qUUolSLErUElXhc
         0xfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVsh6UPBPGPmEg/T7lbb2GTfIKr9SKW40CTkDGTxWb8sz6grJ5S
	QE3UFQZQ5IjGcI0yCBZOvrTBdv4t3iue9orGUzXeWR17gd0/CaGzr8JmUDpVVZjXU7WCd5do+wh
	1AIU7p6x5ZQTHvRUaDKo9Exo2NMsDblL5xPG7eQLh3aY5ex5QuT1O4H8I/udAd83URg==
X-Received: by 2002:aed:2208:: with SMTP id n8mr25162871qtc.168.1553849801537;
        Fri, 29 Mar 2019 01:56:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxL0oGzZqPiG4PStYZhTUck/Q2B7s9ZKTt/dfyupbk6WMGBX7AARbCxJKI+G9+9gjokynbz
X-Received: by 2002:aed:2208:: with SMTP id n8mr25162847qtc.168.1553849800969;
        Fri, 29 Mar 2019 01:56:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553849800; cv=none;
        d=google.com; s=arc-20160816;
        b=OaudRrx/PWZSENByVDabLhjku9s8XverFqkv/ztEzHVYGS4+PCE+m6HwYF4O+ND/JS
         0KLQ8UbzE7bkGatocLnt0btwopgtSapuaL0bmEVu6lmaeSMQ/HjHyK+jDb2lTjlVyiUQ
         8GlanEEiNrY+9NIBtILAzvPYXXOmFl6xzO71pfiEpd9xDMv2RGspmph+vlnDgcDB6f2u
         62v5uAaUSDSQ13sBBsxOjJCLwy6G9I6UmBbdxRAUVSEFbL7zj09dEcB6jxxa04HcGL68
         JenytWH7Bix7shQgBZN+ASe9xgvyjn4qBxWh61mAuowdfdV/Kpf/r3VQ7oR7jqD1mbqj
         X1Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=PBMt1wTkD0xpnWo/dRY7GKZR4V8f+lC6/Y5I5kDL8Hw=;
        b=GuLuax+t4GFmlsJrytJVbwQxmG4swv43w/a5viN8BBt8JfAS3cEJAw/mXLtTNi5GNk
         qqBQBLLipkje/6qgzpr/JlzN8+uuA88UxIyPiJDwOilDLjOyBuzrDdhJ4e94+9yH1HMN
         26VTFWBpgYwfp7AcAlWXPMUWsn7VDejz8mItEzbXAwCTueyDpHuPpEpIvLOuIRYNvRs5
         Q6mgu7ASI/0SYJRc1+c9ZNWTL2LRgyBt/qNgeIOIgoPsjZ4dS7O7wfSmmSELIDd0z6Bp
         t6IooIoaUXaPJSrej1VAv0/rbQ0tKNsR+83ktLiyFJmcbe0Z7E5A0BZPKgiGAQmjg4rg
         6fVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m13si920583qtp.68.2019.03.29.01.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 01:56:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F330E30BC65D;
	Fri, 29 Mar 2019 08:56:39 +0000 (UTC)
Received: from [10.36.117.0] (unknown [10.36.117.0])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2D0A760852;
	Fri, 29 Mar 2019 08:56:38 +0000 (UTC)
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <23dcfb4a-339b-dcaf-c037-331f82fdef5a@redhat.com>
Date: Fri, 29 Mar 2019 09:56:37 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 29 Mar 2019 08:56:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.03.19 09:45, Oscar Salvador wrote:
> On Thu, Mar 28, 2019 at 04:31:44PM +0100, David Hildenbrand wrote:
>> Correct me if I am wrong. I think I was confused - vmemmap data is still
>> allocated *per memory block*, not for the whole added memory, correct?
> 
> No, vmemap data is allocated per memory-resource added.
> In case a DIMM, would be a DIMM, in case a qemu memory-device, would be that
> memory-device.
> That is counting that ACPI does not split the DIMM/memory-device in several memory
> resources.
> If that happens, then acpi_memory_enable_device() calls __add_memory for every
> memory-resource, which means that the vmemmap data will be allocated per
> memory-resource.
> I did not see this happening though, and I am not sure under which circumstances
> can happen (I have to study the ACPI code a bit more).
> 
> The problem with allocating vmemmap data per memblock, is the fragmentation.
> Let us say you do the following:
> 
> * memblock granularity 128M
> 
> (qemu) object_add memory-backend-ram,id=ram0,size=256M
> (qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1
> 
> This will create two memblocks (2 sections), and if we allocate the vmemmap
> data for each corresponding section within it section(memblock), you only get
> 126M contiguous memory.

Oh okay, so actually the way I guessed it would be now.

While this makes totally sense, I'll have to look how it is currently
handled, meaning if there is a change. I somewhat remembering that
delayed struct pages initialization would initialize vmmap per section,
not per memory resource.

But as I work on 10 things differently, my mind sometimes seems to
forget stuff in order to replace it with random nonsense. Will look into
the details to not have to ask too many dumb questions.

> 
> So, the taken approach is to allocate the vmemmap data corresponging to the
> whole DIMM/memory-device/memory-resource from the beginning of its memory.
> 
> In the example from above, the vmemmap data for both sections is allocated from
> the beginning of the first section:
> 
> memmap array takes 2MB per section, so 512 pfns.
> If we add 2 sections:
> 
> [  pfn#0  ]  \
> [  ...    ]  |  vmemmap used for memmap array
> [pfn#1023 ]  /  
> 
> [pfn#1024 ]  \
> [  ...    ]  |  used as normal memory
> [pfn#65536]  /
> 
> So, out of 256M, we get 252M to use as a real memory, as 4M will be used for
> building the memmap array.
> 
> Actually, it can happen that depending on how big a DIMM/memory-device is,
> the first/s memblock is fully used for the memmap array (of course, this
> can only be seen when adding a huge DIMM/memory-device).
> 

Just stating here, that with your code, add_memory() and remove_memory()
always have to be called in the same granularity. Will have to see if
that implies a change.

-- 

Thanks,

David / dhildenb

