Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27870C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:28:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E257E20663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:28:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E257E20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D79D8E0005; Wed, 26 Jun 2019 04:28:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AE418E0002; Wed, 26 Jun 2019 04:28:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79D8C8E0005; Wed, 26 Jun 2019 04:28:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57D338E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:28:41 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id q62so1673395qkb.12
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:28:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=JDFELcs1j0C/xk5djUuDRgHKvOhbgguUGPIUCAB7lYw=;
        b=UHjiaFBfKBAdlcPwmNz7cgcq2cR90Em0GUf6pdhXWyddD5idpe2Le87DPdxJS4gwgH
         YIzKJXKpVCVyUDKYRXmLpaKrUwv9yOiicimYq9ZMkF2FTu8wjA5PDHbwe3NIBXOPN6Qn
         ajgyT/YuRR2goxNC8zCb4GUHd64u+MxQ4A2lXNxXkRwR86boVw8X7UV7qqMhmiA4cRGJ
         OsaEh7rR6VXI0nQKHxA22xm9i5/jWWd6+bUt6o4s8eAaJuIcfEK0RGPdUMW2+QvrZGnG
         nSirEMWv9JBk9ivJd4kP+Q9nI1BqLlECJzkRUqj3lNrYfAXIIsnallxbF7yTfoVRduMk
         7+sA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU6t9H7vE8WLGjJw9Hv4wrEN4X/py+pGywxZqc+WJ/oRzo0jrJ1
	Yisnt3yDhskg0X38/ziDm5XiCiEm0QNXZDz7lcYq3AVl6d/hzC5mfDMQF1tFzUnEuKu1qX8T9yg
	JVtQvxfXnvldPglkppM+uxY+PiP7di7rnXsLA41dD94C5ZXsJbNky4P0juO/Y1NCKuw==
X-Received: by 2002:a05:620a:1497:: with SMTP id w23mr2663558qkj.49.1561537721166;
        Wed, 26 Jun 2019 01:28:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4d+8s1ivNUo6bJAfU5NjfqvoeUofrXSQF5ibHB9DXhIY0WrO7wZaL4YrBK+UPG+soGoaD
X-Received: by 2002:a05:620a:1497:: with SMTP id w23mr2663541qkj.49.1561537720681;
        Wed, 26 Jun 2019 01:28:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561537720; cv=none;
        d=google.com; s=arc-20160816;
        b=aPWbJX0053fM2Cpwybqg1AweXC0YKjQIGAqU0B64ZMlGJRv0+VMjEF3LvcHXunLaiV
         DbftpGq71s4nbSYbRB9oRyRqzuKQ8zSYyBHCh3Ll0Blir+TGz+Zhuh15ETDBGPkJqCOd
         G2Sbs51omZ2hOzxZIRo15r6d356vToekDliAJ5zl9yha7rRy7/Gi1s+Ba4H0CxLWq27W
         MEVncPWZyHlsZI43M6qoGNIAqcvMgbwNgeBW0hwun59dJcmv5FBXEcfRuVQAQt+TFd0z
         9LIwO6PSg+m9+hwHXrvb/uy04eWK5URf0jIhMEjnQ3xWG62ladGWEFPVizbbGxy8ItB2
         7Mow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=JDFELcs1j0C/xk5djUuDRgHKvOhbgguUGPIUCAB7lYw=;
        b=UstdeT6R49uEBLJ8ErozGAa2par6AyijVH/uAq8j9l6fSaeTyL2+ijsvJQq0qolBxe
         IKGqw50QIT6/1mJefQcx26T/Ybu6zqqk/7NuYjcHynpTdvMQGIeZq1TKrO/+mt4tLnF6
         8TBeRhiU/0B6BnygEm9EURdbykvWgmE5WLLTBIaBHkHT66XixwViR7xZ4vCPGQdYmCiq
         ZXfwjtldEB1LHMFOStAhLFJChjZhFxwnzd0RaUI0cnpQvtmHCVblEOu1XpvNQsaCZO+K
         bILc9hLigTPQr0f4gSanp6sDQ6es1+CPzejOS8/Zyc/Mhc+opDfOIXTXrX/tLPIPMif3
         NUEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a43si11915698qta.351.2019.06.26.01.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 01:28:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C2B6B8553B;
	Wed, 26 Jun 2019 08:28:39 +0000 (UTC)
Received: from [10.36.116.174] (ovpn-116-174.ams2.redhat.com [10.36.116.174])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 180BB1001B04;
	Wed, 26 Jun 2019 08:28:35 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>,
 Rashmica Gupta <rashmica.g@gmail.com>
References: <20190625075227.15193-1-osalvador@suse.de>
 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
Date: Wed, 26 Jun 2019 10:28:30 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190626081516.GC30863@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 26 Jun 2019 08:28:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.06.19 10:15, Oscar Salvador wrote:
> On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand wrote:
>> Back then, I already mentioned that we might have some users that
>> remove_memory() they never added in a granularity it wasn't added. My
>> concerns back then were never fully sorted out.
>>
>> arch/powerpc/platforms/powernv/memtrace.c
>>
>> - Will remove memory in memory block size chunks it never added
>> - What if that memory resides on a DIMM added via MHP_MEMMAP_DEVICE?
>>
>> Will it at least bail out? Or simply break?
>>
>> IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save to be
>> introduced.
> 
> Uhm, I will take a closer look and see if I can clear your concerns.
> TBH, I did not try to use arch/powerpc/platforms/powernv/memtrace.c
> yet.
> 
> I will get back to you once I tried it out.
> 

BTW, I consider the code in arch/powerpc/platforms/powernv/memtrace.c
very ugly and dangerous. We should never allow to manually
offline/online pages / hack into memory block states.

What I would want to see here is rather:

1. User space offlines the blocks to be used
2. memtrace installs a hotplug notifier and hinders the blocks it wants
to use from getting onlined.
3. memory is not added/removed/onlined/offlined in memtrace code.

CCing the DEVs.

-- 

Thanks,

David / dhildenb

