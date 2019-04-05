Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0480FC282DC
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 17:11:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFAAA206C0
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 17:11:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFAAA206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 584816B0007; Fri,  5 Apr 2019 13:11:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 532916B0008; Fri,  5 Apr 2019 13:11:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44C5F6B000C; Fri,  5 Apr 2019 13:11:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EEC7A6B0007
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 13:11:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m32so3593460edd.9
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 10:11:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jWxk0GETdbMHBeJfcbGAniuJenh+xldWuNdVk5rPuLc=;
        b=HlpTD44A41Xiu+n9eOn/p1LFlGO6K8eHzmVxaIHpxUlsLAw78UEXm/8DtKuAlvthUN
         bAVTdi34iC1bZ+AiLBBj/s996jpWLacCxOQT1zCmRv0ujcx6lDHiSCl8Lgi2IwsfQcfs
         dTRwkZiocD0jbfQSo1DJdeRRbz6bjQTwREyzX3DYRdrvHZBarFPQNa9Pt9u6J6yoFOT4
         WCE7Zir2FcBwIUZ1TNbzR4niy1ZFyzLuFU38sAo1tFoF/ltTP9HXvSIQ9JcGjfft0uOe
         qyE8a/FgoY9XMdzNuFtnD6qoZ/57uu0jK5MdUexQWEcfZ/FyOgfWEfUA57yIUTwwsn5m
         YDpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAV+zrNp7gmYMLlrdclhINqatWexHsN0U+hNXIX1cICYiKCQXA+C
	0xaYMDjslB0Fnr7aDUi2YmmA4gYT8xgzbif2msjTDWfknTyUyUq1+r0buWSSNFKkPdeQTluBoLV
	orS0zWogdZaHs12FKcGnywIRxMCoHEjA3vmdvRt0HZSbRgVr2g//okZRfCklv8LN9rg==
X-Received: by 2002:a50:b1bc:: with SMTP id m57mr9010427edd.116.1554484281539;
        Fri, 05 Apr 2019 10:11:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxw6TLhO1Qb3JdtfkOrwgjJ1bXhX5GDQ4a90nOy+aSJ53j/LE0cHm7rgwWBX2GlnlTJReFW
X-Received: by 2002:a50:b1bc:: with SMTP id m57mr9010387edd.116.1554484280769;
        Fri, 05 Apr 2019 10:11:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554484280; cv=none;
        d=google.com; s=arc-20160816;
        b=RkxEfADfySZfdEHj/Tp4Ss5IwayNG9AGzYCDTdEGmqyoS2VMFvYytYijmtQ/OK4r9M
         8ncCupdk3le5yxOVbB5WXZtgkEh4HvLesNvjjXvHlAJ490KcqJu/KnPF3kZDsjNXbE0F
         +9yaBVKxmFXqGb0JgaKjAWswrg2gJhZO/BT3od4NEXXjpl9Hqq0ufquxJZlVmhG2oC/m
         0vqM7BkpsAdh7T9/0gHOCLTrXZS3gVUF6ScV1/UiL2N9+C1gf88X/17ycC4oCUlwv9wq
         kHkdA5WdAsqZRXOaRjDOUMow6m6j9yco7ckalUhkHcg+QxRYOcg1WiqS29L3e2sQJlzr
         l/lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jWxk0GETdbMHBeJfcbGAniuJenh+xldWuNdVk5rPuLc=;
        b=vsTDmAP2lifmdu3d/GsyRDjvyXhF7a4rHppl+q13NEvQns0ndyr+H1Km/O1tbd5wZy
         bfPzo9ij23TRTYe5Fr/rqV0N7Gb22WVeUvjF7ydyKMmXFHWMCRro9AVTdF2uoEW5P/4r
         KmUTQYbQMqxuyYiRz1G9U5TsfkRMRsM1Fxk8DQyPZzPTKotQZ+85/tPEWqf/LKdk+ChD
         pnwhwBgZibcap7YLU1LRmmMhUC05+vJz75nPro8lF1BQJxIVXVeBCMuEfKx4iiRCkaW0
         +UOqp7tWavc4bVjbqo29Kq2wgY3wpUlLZBKBkAVrHmLJAwfnYRaP1hfPJUdqB19g0ltn
         Diyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m5si2055693edc.344.2019.04.05.10.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 10:11:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4FCB0AD7C;
	Fri,  5 Apr 2019 17:11:19 +0000 (UTC)
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
 Matthew Wilcox <willy@infradead.org>,
 "Darrick J . Wong" <darrick.wong@oracle.com>, Christoph Hellwig
 <hch@lst.de>, Michal Hocko <mhocko@kernel.org>,
 linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
References: <20190319211108.15495-1-vbabka@suse.cz>
 <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
 <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
 <010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@email.amazonses.com>
 <4d2a55dc-b29f-1309-0a8e-83b057e186e6@suse.cz>
 <01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@email.amazonses.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2b129aec-f9a5-7ab8-ca4a-0a325621d111@suse.cz>
Date: Fri, 5 Apr 2019 19:11:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/22/19 6:52 PM, Christopher Lameter wrote:
> On Thu, 21 Mar 2019, Vlastimil Babka wrote:
> 
>> That however doesn't work well for the xfs/IO case where block sizes are
>> not known in advance:
>>
>> https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@redhat.com/T/#ec3a292c358d05a6b29cc4a9ce3ae6b2faf31a23f
> 
> I thought we agreed to use custom slab caches for that?

Hm maybe I missed something but my impression was that xfs/IO folks would have
to create lots of them for various sizes not known in advance, and that it
wasn't practical and would welcome if kmalloc just guaranteed the alignment.
But so far they haven't chimed in here in this thread, so I guess I'm wrong.

