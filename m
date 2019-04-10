Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC3A4C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 08:07:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A286A20818
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 08:07:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A286A20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B9AB6B0271; Wed, 10 Apr 2019 04:07:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18FC56B0272; Wed, 10 Apr 2019 04:07:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07E896B0273; Wed, 10 Apr 2019 04:07:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6AB86B0271
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:07:29 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 54so1460449qtn.15
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 01:07:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=5p0rXfrK49lAJ5msdIhH9Thf5gXTDO5k0PwBh05IM48=;
        b=Tyr1JdMSRs4c/ioV/PzxhHrqIMv0m3dhRMg17XxRLe6ZwDAUsCG/dwhxHXeG+v/22d
         Iwjyk/0ahR2aZHi2elABof2jAYJoAkQgNjno0sjPDiNaXhnYyNVk22c3Y7oryagu6LQe
         Ryu1Nq/yMEc9MH8Tb8ym/tz6SvdF3NIJ8rUuG0qelwK7EDq1XoClT9Qfm5dnDl84vEA9
         xys8/3WDesJrF2HtPnftUMOb4Xy0lMV2Mhr+DLfcN8sKHQqD5GupbD1+CZb0AFI6cNph
         k0oRQvE/K4T9wr2fNZvIFE4bCkEW4q0R0Ya3ZEZsYv0Wb04UURQqQQJGatFRmSPiLwit
         vPQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWFb81pknrM2x2i6g/8QER+m3+Z9EKV8zxVz3iFL/OV7Z6WmX/0
	okW2Y5RFcUu3dR+oPp9gBWb3RdUZGRi4JFg9Ji4wdHvdVO9c3XtTB0mhAXy4nQtmDxmAcLTSjDG
	h5E3lJ5ouzsJa59BXsbluvc680CjYf7rYKVXedr5WvrTmB3E5I0IKs2TTiOeGj7tGhQ==
X-Received: by 2002:a0c:91f0:: with SMTP id r45mr33392913qvr.7.1554883649666;
        Wed, 10 Apr 2019 01:07:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQ1GJpusqCzD9/wRt5aGCUU6j9OCUgP1jcQv6ECjNVXIV1H91+lkPJcG17Uh3hsNTAHzb2
X-Received: by 2002:a0c:91f0:: with SMTP id r45mr33392862qvr.7.1554883648958;
        Wed, 10 Apr 2019 01:07:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554883648; cv=none;
        d=google.com; s=arc-20160816;
        b=w39fSgPxvFP6mOP0o/0XLOON4wK4h7R7ZCmaSNY304rMuuSyWi5iu8XIitbZZ0duhU
         jeVepFgJOUPy1RtjX0ztywqhXvChVQvpQ5lOXi8M8QP2P4vPAe5iExcfgSztUFNFUyhb
         d4UW1WxKGmM0GrVbwwFq9famGKqZgrHK20l7K1GDgai4xhb3+Vy7IDn0e1MZ0XHA0p2R
         gREVosfSDIeSzZUxmpqpYLu1OjitQyXRk23xSGIX1u0DR/UV9Uyd+LxK3Prs5IRCPa2Y
         QuxbnA/Ft2SQnYXS7jFr6u4ck0byLwFIvBe2kVkaD8rxDqIgHzBxhCrn5UiBDyGGkrgx
         tJmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=5p0rXfrK49lAJ5msdIhH9Thf5gXTDO5k0PwBh05IM48=;
        b=WFm2mx6JyaS4JkOxpT4FZ51aO8DG/ucv64RVhe0d8TrXXv+8dVeuPXXZmUTKAE/c9n
         B74o9LkiEHqGyxBevpwJKKYZ1GcXbCQBZrimGkWpFrwn3jT9jbiTuiMfgAdTIzNeFPuS
         XKBy3XCBcYZMw93F3bK/XKFXGZlBME6dycI4EibokcVO+kL1lrzUv2nbDXS5NJKCTMRN
         2vHbzndlO24K6VurCSA2fnJiGyPz4yZeb+hOoG4mdFKm7PYJTheoQes9R0s6EelbBdm3
         EvbqQHRiKujpKKKIfqjcme5qmLxVzpLV+2t8tmw7P/I+jsDEBptkU1x5rO6dA3Qbnlq3
         JfMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i33si8348596qvd.144.2019.04.10.01.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 01:07:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1CE1F307EAB0;
	Wed, 10 Apr 2019 08:07:28 +0000 (UTC)
Received: from [10.36.117.213] (ovpn-117-213.ams2.redhat.com [10.36.117.213])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 193045C223;
	Wed, 10 Apr 2019 08:07:24 +0000 (UTC)
Subject: Re: [PATCH v1 1/4] mm/memory_hotplug: Release memory resource after
 arch_remove_memory()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
References: <20190409100148.24703-1-david@redhat.com>
 <20190409100148.24703-2-david@redhat.com>
 <20190409154115.0e94499072e93947a9c1e54e@linux-foundation.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <7cbea607-284c-4e20-fee8-128dae33b143@redhat.com>
Date: Wed, 10 Apr 2019 10:07:24 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190409154115.0e94499072e93947a9c1e54e@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 10 Apr 2019 08:07:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.04.19 00:41, Andrew Morton wrote:
> On Tue,  9 Apr 2019 12:01:45 +0200 David Hildenbrand <david@redhat.com> wrote:
> 
>> __add_pages() doesn't add the memory resource, so __remove_pages()
>> shouldn't remove it. Let's factor it out. Especially as it is a special
>> case for memory used as system memory, added via add_memory() and
>> friends.
>>
>> We now remove the resource after removing the sections instead of doing
>> it the other way around. I don't think this change is problematic.
>>
>> add_memory()
>> 	register memory resource
>> 	arch_add_memory()
>>
>> remove_memory
>> 	arch_remove_memory()
>> 	release memory resource
>>
>> While at it, explain why we ignore errors and that it only happeny if
>> we remove memory in a different granularity as we added it.
> 
> Seems sane.
> 
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1820,6 +1806,25 @@ void try_offline_node(int nid)
>>  }
>>  EXPORT_SYMBOL(try_offline_node);
>>  
>> +static void __release_memory_resource(u64 start, u64 size)
>> +{
>> +	int ret;
>> +
>> +	/*
>> +	 * When removing memory in the same granularity as it was added,
>> +	 * this function never fails. It might only fail if resources
>> +	 * have to be adjusted or split. We'll ignore the error, as
>> +	 * removing of memory cannot fail.
>> +	 */
>> +	ret = release_mem_region_adjustable(&iomem_resource, start, size);
>> +	if (ret) {
>> +		resource_size_t endres = start + size - 1;
>> +
>> +		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
>> +			&start, &endres, ret);
>> +	}
>> +}
> 
> The types seem confused here.  Should `start' and `size' be
> resource_size_t?  Or maybe phys_addr_t.

Hmm, right now it has the same prototype as register_memory_resource. I
guess using resource_size_t is the right thing to do.

> 
> release_mem_region_adjustable() takes resource_size_t's.
> 
> Is %pa the way to print a resource_size_t?  I guess it happens to work
> because resource_size_t happens to map onto phys_addr_t, which isn't
> ideal.

Documentation/core-api/printk-formats.rst

"
	%pa[p]	0x01234567 or 0x0123456789abcdef

For printing a phys_addr_t type (and its derivatives, such as
resource_size_t) ...
"


Care to fixup both u64 to resource_size_t? Or should I send a patch?
Whatever you prefer.

Thanks!

-- 

Thanks,

David / dhildenb

