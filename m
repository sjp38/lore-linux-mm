Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DDEDC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 06:54:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 673CE20656
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 06:54:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 673CE20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAC606B0005; Wed, 24 Apr 2019 02:54:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5CA46B0006; Wed, 24 Apr 2019 02:54:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4B8A6B0007; Wed, 24 Apr 2019 02:54:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4BE86B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 02:54:31 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 18so16900530qtw.20
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 23:54:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=REIRljEnuZQ2EkF+IT6UHuLFU6vu2fSKptw3ZvZUD+I=;
        b=hFbv8KuoMM40LbPpjbquwrI2krnnCYhgciXZFu+5j/VLjuApPEepxN8uvC6WjdgmCy
         re7z/OVZjzc0FpF2KGFTMG1MwC5Yq6kGRYBmt8r4Gek8ExYAIdXQihNXGOmh16UXAAO4
         7+HQNHcs9eWZheIFzZrFS1dm+1ovequsEof2ySW8HSlNuQ8c6DhftpU/jPPV6KXKpMGV
         yeHK4nAXrolep9ZJMOmvkZXKxEDkgxoWRHnagDo3snIApdTeFMXwbJG3FgmM3YGf0uVa
         mD+gP8bJyxR33QPHlRsGD1gdHciCtmFG9kHJumbTwz7ZjGBXCcJLCa1EOXOljtxmailI
         J6Sw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXTGyW+JyFsBkfB9JPQSWAdORp0RxijuwXfNX0eKkOuU9dI7RkK
	dUixeCq0MBWf4lFdSFLNzbVgIpkWTeyQuLC3MF5yy7NiOahVHkxB4cf3PHyXn9TmgU0OD0K8P9s
	y7QBgvVTh2DPZNbkemNg3Msc2mR51p7eWfJngTtC8EeTVHjIxMlvHEO6FXAoT4Ckbgw==
X-Received: by 2002:a37:74c5:: with SMTP id p188mr611705qkc.26.1556088871400;
        Tue, 23 Apr 2019 23:54:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy204/mNpNOzDNqwUdALG0ZBvDVPSPJbfZ79Fwx35VDEskNSsDBKLxOzSpd+LYFnOk9KNcb
X-Received: by 2002:a37:74c5:: with SMTP id p188mr611683qkc.26.1556088870788;
        Tue, 23 Apr 2019 23:54:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556088870; cv=none;
        d=google.com; s=arc-20160816;
        b=1EDcqj+1Ojdy4jF/Lf3QwPQpZG3ISJMPo6i0g+XSQEQmCs6xqoABI4dE66pVgIPp6y
         DDwRkj4yOiEIJwFIOwU5U8DglUbA4oIZ1WmgNCERDRx8z0u6rhH+3zniMXW073WcOLIu
         wfE6QTwKP9EE+FTWKXgOX1OMZZPg0xhEXaGNI3fMpNaDPPPnEVzCvcboLBU6jxu+PcG2
         1/dVLLc9SwzeMQVgAJzAYkKG2J9KfViOUlx6I4vZ924I41FEhIEArxv8gpCMA0vTVEUN
         dJi5qS+AgN2oTiU27I9Ftl18eJHQXal6sGfbu1SQ6R0Hd4jfHmcSxgzALwucjl4dETVL
         Awig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=REIRljEnuZQ2EkF+IT6UHuLFU6vu2fSKptw3ZvZUD+I=;
        b=jTLalMjxYhYX6827YaG3VZhPtArSqho0i7A0cvpyrOthKTcVmR+sls2Havk/XB8DW0
         vKMibwF4tTKaNPbuuNz0ThpxMmq/gHa8ZgSBIq/cuGKxBcmujSgm02gkNRoCJPT+o7fo
         2ViIYmSbx11A5uPGbHEg2xr1B1z7L9dmgntSm3j/3zcdUHLiR2gfUhAzc4UL/Y4SeVGr
         t4kycJ4L56txDr92oLiciSfNNIlxfDoLAE6KxfvsL/nmALZf1G3kYZ+6o6HNGLxXJtem
         JD7lxNtvBC6rXEjGx8umEyGSnQ7MO97uhyAjrImq1mv50XMQXUJkmGIjxPrAbO0isyNo
         VWBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n6si818580qkg.1.2019.04.23.23.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 23:54:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C64D230A8199;
	Wed, 24 Apr 2019 06:54:29 +0000 (UTC)
Received: from [10.36.116.45] (ovpn-116-45.ams2.redhat.com [10.36.116.45])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9A217648D9;
	Wed, 24 Apr 2019 06:54:27 +0000 (UTC)
Subject: Re: [PATCH v1 3/4] mm/memory_hotplug: Make __remove_section() never
 fail
To: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Qian Cai <cai@lca.pw>, Wei Yang <richard.weiyang@gmail.com>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
References: <20190409100148.24703-1-david@redhat.com>
 <20190409100148.24703-4-david@redhat.com> <1555509378.3139.35.camel@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <bfa88494-6e4b-9139-21a1-e80546d2dac9@redhat.com>
Date: Wed, 24 Apr 2019 08:54:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1555509378.3139.35.camel@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 24 Apr 2019 06:54:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.04.19 15:56, Oscar Salvador wrote:
> On Tue, 2019-04-09 at 12:01 +0200, David Hildenbrand wrote:
>> Let's just warn in case a section is not valid instead of failing to
>> remove somewhere in the middle of the process, returning an error
>> that
>> will be mostly ignored by callers.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> Cc: Qian Cai <cai@lca.pw>
>> Cc: Wei Yang <richard.weiyang@gmail.com>
>> Cc: Arun KS <arunks@codeaurora.org>
>> Cc: Mathieu Malaterre <malat@debian.org>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
> 
> Just a nit:
> 
> I think this could be combined with patch#2.
> The only reason to fail in here is 1) !valid_section 2)
> !present_section.
> As I stated in patch#2, one cannot be without the other, so makes sense
> to rip present_section check from unregister_mem_section() as well.
> Then, you could combine both changelogs explaining the whole thing, and
> why we do not need the present_section check either.
> 

If I have to resend the whole thing, I might do that. Otherwise we can
drop the present_section() based on your explanation later.

Thanks!

> But the change looks good to me:
> 
> Reviewed-by: Oscar Salvador <osalvador@suse.de>


-- 

Thanks,

David / dhildenb

