Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC2D3C282DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 13:55:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A096E217D6
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 13:55:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A096E217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5166B000A; Mon, 15 Apr 2019 09:55:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3640C6B000C; Mon, 15 Apr 2019 09:55:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 254DE6B000D; Mon, 15 Apr 2019 09:55:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03B086B000A
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 09:55:48 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q12so16195349qtr.3
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 06:55:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=CDprCqnOA6v0hs/kvmbxfKM1w/vtjmPVEBNC0lsLGtA=;
        b=dS+W12RsAdel4lwatIqiEgALVshFHEhE6rE4VdOAmdc01Ne3J5TWVfKahkBmbVnKYN
         IkV2TvyJ5buxRwcac4lRjveY8bE6N0jfE7GOH9MWTT8yLEI+029gByR5B31oMvhWmr6Y
         9G/AsgV+V4HU8cGijWOunvFoJYcSMsDUjxs/TRUFnovj5JOdGoRQh/HJ6mANGLzlpxdf
         CWdq8hrXZYGWK103Dmw98QTHY/GG746VYzY6hTnSp+XoWTErWo55ZGVufzc0KFz6f/in
         JF/RGzHlqR0otcPcoWsyDiPp4LKjdC9i7U/O/sRSKAxa4K1KcIzIl12ul3kbXhLJI6Dq
         AVhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW6GRPYaeLXMoUGQdjS96SuzBV3E31kquuKe17FCEDQCaF8U9I6
	GC1gv+UcY+S+L/Ax3gBcBxEk9pSfmvBk25NE4ne+PQdTzAcJFvXiRLE9zFtZkt4pnEHkuPEerKO
	FhV8ZgH146D6UGzEhlYL4MsIhwb42uJTJbWDL2xinBUV6sRGLDmCMRKaVxeT81IeOSA==
X-Received: by 2002:aed:32e3:: with SMTP id z90mr57671186qtd.266.1555336547652;
        Mon, 15 Apr 2019 06:55:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyW1w8VoA+1EixzrhhpuKA6qiN7PD5W4uJlamcay6d+sfLLhBVPqU58lTZruGWL+7XSqn4/
X-Received: by 2002:aed:32e3:: with SMTP id z90mr57671134qtd.266.1555336546899;
        Mon, 15 Apr 2019 06:55:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555336546; cv=none;
        d=google.com; s=arc-20160816;
        b=KrCaEex3LJFa3bjZRt6GaJ9vcePeYWEowAX86oeAheB99HoYlTqJaKeynZ1IIkrEC9
         CkvqhS2Xp9zsU/HjLCJXbG48w4zR7zZL5HWDDUny+7jdP/Z/xNpJhcFkaRA1GCch3bYj
         AVtReaH8FIn/2lYoYpiSxBTmVzPdW4mQ7RqhKGbpfWPDdszWA9aLRQ8kiy8Dlq36K4z9
         OFk+PYA+p7qYwov6F87/3zkbxaDwXvncgTwBUZg5R6oNS3Tg+Kju3xcuEDMTlgAqAG+U
         OOOQqUqPMXISfDrxgv7J3IBaOweLwkacq1s8y5V8pdskqqwzBCPyjkqV+wVGTStiaAtm
         /WIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=CDprCqnOA6v0hs/kvmbxfKM1w/vtjmPVEBNC0lsLGtA=;
        b=oTyqz4ycKaMggaIu728knrA6GZo85X2WF0lBNCrUtq6z9dIXOmnBiZSEW5w06qdZos
         s07LdeRoMTyqiP9J9uyoKe+nnJLjc6lhQ+zU6gdxQvYUZ56V1auYr8K5H3yYFIVyc8WZ
         PZ7RPMRSgyY+mSLzgq7BJHe2sCINf9lxm9Qa8A6SSeqwSxJLEZ5sEW+PfaoleSHEhGW2
         I1EMDmT+1rCRfnU9r4fcKtY0FrIcy/hipYBdI5XQ7wqKOlQniPWzCfhKiIxkRjA7H5KF
         p4Ejwm3pG6mJkYkXZsrn/+/1kObDlRWudecuilCIZvTbqMywm9Jx5ReI5GVcLH+UQEV1
         OoTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m30si6690825qtk.269.2019.04.15.06.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 06:55:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D251230789BE;
	Mon, 15 Apr 2019 13:55:45 +0000 (UTC)
Received: from [10.36.117.28] (ovpn-117-28.ams2.redhat.com [10.36.117.28])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 27ECC6090E;
	Mon, 15 Apr 2019 13:55:41 +0000 (UTC)
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <614fe7d2-cc5d-61a2-6894-026e30498269@redhat.com>
Date: Mon, 15 Apr 2019 15:55:41 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 15 Apr 2019 13:55:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
> +{
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	struct zone *zone = page_zone(pfn_to_page(start_pfn));
> +	int ret;
> +
> +	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
> +	if (!ret)

Please note that I posted patches that remove all error handling
from arch_remove_memory and __remove_pages(). They are already in next/master

So this gets a lot simpler and more predictable.


Author: David Hildenbrand <david@redhat.com>
Date:   Wed Apr 10 11:02:27 2019 +1000

    mm/memory_hotplug: make __remove_pages() and arch_remove_memory() never fail
    
    All callers of arch_remove_memory() ignore errors.  And we should really
    try to remove any errors from the memory removal path.  No more errors are
    reported from __remove_pages().  BUG() in s390x code in case
    arch_remove_memory() is triggered.  We may implement that properly later.
    WARN in case powerpc code failed to remove the section mapping, which is
    better than ignoring the error completely right now.



> +		__remove_pgd_mapping(swapper_pg_dir,
> +					__phys_to_virt(start), size);
> +	return ret;
> +}
> +#endif
>  #endif
> 


-- 

Thanks,

David / dhildenb

