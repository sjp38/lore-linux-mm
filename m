Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CF94C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:01:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0213520863
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:01:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0213520863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3E068E0003; Tue, 25 Jun 2019 04:01:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EE4F8E0002; Tue, 25 Jun 2019 04:01:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B5328E0003; Tue, 25 Jun 2019 04:01:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69F6E8E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:01:16 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z6so19924816qtj.7
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 01:01:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=XUI5SRvROd+lVvLS7dPi1pfGcX3hZet76sfgjCf+lGE=;
        b=YqW2uWPA12lSfT3kA15tJt0Rlpx7qSYB3/FbUGk5paO/diWsYPgMdvQQKQ0gUgOd8m
         JgYneVxANmufASNqF6ShVAEsiI68W4q5U5wu7He+ao6is+MDN43Y0fwrIpzc+Ae8Qhxu
         LaWfASyzuzMHi110jQAoQ13s7Wn/kgEKU2yZCHirgfs8TMFD8AhhuRKvJUfWzczH90Gw
         3NWjhzDeNzgGTA1pL0t4I9tZ3tHQTaOA/VNwdofbrmL1IffNOdm8gQpU5AXYgcvfhh0T
         Rh7jMGsviMEBM/hWmPFdbAzoOjygtrzcuEdhK5ex60IQ5yYITDnlDsW2dZTeTJxWix1o
         kEmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVzuCySy5DYS7J8nDqSeqOpNtACHnrbUA6uvbtx4wAahazRQUGr
	9+Jti8QNgVZHiAZFFlrpDb4FsrJeGmNq7m8q5M3T9ztxRVIhd2erfvjTnOzUfn6b40XzgdpUszo
	DzD9s5ZydMa00wLADoypnWaepRdPU063+m1mntFVDWdECzf53yBQtS2NEVrC3XbJ5uw==
X-Received: by 2002:a0c:d0fa:: with SMTP id b55mr62289194qvh.209.1561449676217;
        Tue, 25 Jun 2019 01:01:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIAidAOA8jbc0CeycZKbzFwdQM7NAALChE1liNfIusAl5ZhB+7O2mUfzQR/xdOxvuiQ50J
X-Received: by 2002:a0c:d0fa:: with SMTP id b55mr62289169qvh.209.1561449675755;
        Tue, 25 Jun 2019 01:01:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561449675; cv=none;
        d=google.com; s=arc-20160816;
        b=LEg7Z9grtDVqmOhJmHaoWX+AsR/mt0RC3Pxz2PD+odiOmhzypjrmTfr5iWwdn6PnKA
         ZH3kJvBScTToWVWCBM/jBB2/t6zhXFwzhCrw/6VEsXAW/N87PG4t4V9eZzFRoeEib6jM
         fT/LePZr/tRBJcVP9+8SXhUWUmiYSGHSTV4sWVBVJpYPti0/xk34EPB9jXpPmeF9HZIn
         TByd0ZDTy6DumIZwk96a+PjyJh1LDXJtcHkMem2QGyj1CdKcxhid01OOhNb49WRIvFFG
         OxSd8vUhLRhtlMgnZ1YnkVhSJQiimRFpM2WIRaB1agvYN9oycpX+EymkXWqZWa9K8kjV
         j21A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=XUI5SRvROd+lVvLS7dPi1pfGcX3hZet76sfgjCf+lGE=;
        b=a2wTGAK1+7ye6uj0U5oGb0+GNno5JxTDszsV4Nav4pw7w0x6pJHbNyFc7+6dOAPmve
         KK9Pe+4VmMgNqKjV7CDpcsmP0zk2mMBjPY2Rk7t/2HwfyXGkj97EgS9i7cbuf0BBoQ0v
         HUVWHDLswgyYwb9lR7Z788aoEAlhcMbOHhsugIh/msx4FccIewD2t+Io/gfht7BFk8Qy
         19m+a75t+7NQpfdwZuWTQrYieS/7MHMLf5fdsJqQymmn90huvktG8YdNiSGitfS5U6cj
         9+1w3CeS/GF1saUaGEgK5ehTJ5rylUslANBrpCgNgYw6U3mjvmrhu0MqPRE5dceW2iwo
         C/yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s21si9464832qtc.6.2019.06.25.01.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 01:01:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 42C1BC18B2D8;
	Tue, 25 Jun 2019 08:01:14 +0000 (UTC)
Received: from [10.36.117.83] (ovpn-117-83.ams2.redhat.com [10.36.117.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 235415D70D;
	Tue, 25 Jun 2019 08:01:11 +0000 (UTC)
Subject: Re: [PATCH v2 1/5] drivers/base/memory: Remove unneeded check in
 remove_memory_block_devices
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@soleen.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-2-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <3e820fee-f82f-3336-ff34-31c66dbbbbfe@redhat.com>
Date: Tue, 25 Jun 2019 10:01:11 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190625075227.15193-2-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 25 Jun 2019 08:01:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.06.19 09:52, Oscar Salvador wrote:
> remove_memory_block_devices() checks for the range to be aligned
> to memory_block_size_bytes, which is our current memory block size,
> and WARNs_ON and bails out if it is not.
> 
> This is the right to do, but we do already do that in try_remove_memory(),
> where remove_memory_block_devices() gets called from, and we even are
> more strict in try_remove_memory, since we directly BUG_ON in case the range
> is not properly aligned.
> 
> Since remove_memory_block_devices() is only called from try_remove_memory(),
> we can safely drop the check here.
> 
> To be honest, I am not sure if we should kill the system in case we cannot
> remove memory.
> I tend to think that WARN_ON and return and error is better.

I failed to parse this sentence.

> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/base/memory.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 826dd76f662e..07ba731beb42 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -771,10 +771,6 @@ void remove_memory_block_devices(unsigned long start, unsigned long size)
>  	struct memory_block *mem;
>  	int block_id;
>  
> -	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
> -			 !IS_ALIGNED(size, memory_block_size_bytes())))
> -		return;
> -
>  	mutex_lock(&mem_sysfs_mutex);
>  	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
>  		mem = find_memory_block_by_id(block_id, NULL);
> 

As I said when I introduced this, I prefer to have such duplicate checks
in place in case we have dependent code splattered over different files.
(especially mm/ vs. drivers/base). Such simple checks avoid to document
"start and size have to be aligned to memory blocks".

If you still insist, then also remove the same sequence from
create_memory_block_devices().

-- 

Thanks,

David / dhildenb

