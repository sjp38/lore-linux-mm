Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73C3BC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:41:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 282A7217D9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:41:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 282A7217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8F5C6B0003; Tue, 21 May 2019 06:41:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B17986B0005; Tue, 21 May 2019 06:41:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 991646B0006; Tue, 21 May 2019 06:41:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 734CE6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:41:54 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p4so15180605qkj.17
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:41:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=rtX0g6MtI1kxk+ZF5SLj/4dIIl2N6Lgh1lmt5VQCWHE=;
        b=l5UALQyILrmhRMCI/968WH9Db9DJhN2Y7cGbegb3WgUww3ynbZ+R4NVPURD0KTd5+U
         aejO4Um2HLpBWgxFyVxazoNjo7S1CahsgMBd035X0LcGzvtgX1RCrMrL6dhc+uDmgh9C
         2kpe9Fb2R7LGlvrTPeBV93CNrpR34xiW+IJqUjx+TA3xynqb3XkgF60/3th4Fjll91v2
         yFtfkO131Sy6tkUaNdCjj0sY6UTszlI//fouHljYnvOMJzQ4iv9C1JqzKo+neJgSMayS
         G9crzrNOjPWXrzib2cKaEoa6qToMrTyVdGXkat0z+XqVcOeSmcAsvS0NiInafiTGqqlO
         T0sQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXvMKCufRtXAvcd/nmKgJm2waP/I5RDm8OMEosBXGrzeKqPOi9n
	QdCVk9vS32GjXSKUd1PobVr5izASHQNpwYeRlmoPA8WEBdvIMlpTAvPoOmm8w4oy8O7xUJSML4O
	slj/cToGmwP29eAXd1EImk+cHtgyRBVB7eicd99q/iVnHOpYpLk674AUCtqVTBZewLg==
X-Received: by 2002:a05:620a:144c:: with SMTP id i12mr34893337qkl.243.1558435314233;
        Tue, 21 May 2019 03:41:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVVrCwGcHO5q7GgZUOCJOj2ILTwDEUsLWb0V6EKwmBuk8eMkcl1uoD/vgyqLSz3b87fcvj
X-Received: by 2002:a05:620a:144c:: with SMTP id i12mr34893305qkl.243.1558435313579;
        Tue, 21 May 2019 03:41:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558435313; cv=none;
        d=google.com; s=arc-20160816;
        b=wmfDg4eqk7fy8XsWIOPfLZwQK6Q9/l21gf31oXFLMl692dT5srCCGguy5Y8wvAjETq
         t/kTAgFt32eXDJ7ZCf+8EKZTQdXbuHBIxMdtecwVDylM3XyyIpuJDmumfZtkBh5mLkse
         wwIhjbiizelI9+orRb//pbKPeOr0a+PBnl7QOLMxJtptisMGff/uwsSsQfX4DKCDSOv8
         Q6JjZX4hp3LRnA9u6f29u4SFFdXvtssA9Ufi9a+XsBjr5PcoqoEzlHkjNULWtzKMWa0u
         8kkURv13Kg83xOw3PKLWx8WbRSDv/VzFTEZWKK7a5WKP43/KPYiTLeJ46//e+717oWyv
         xC9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=rtX0g6MtI1kxk+ZF5SLj/4dIIl2N6Lgh1lmt5VQCWHE=;
        b=LC8Yzlc5cIHsQ06OjAHMT6ms10WoWHCdr+ox+nIT5picJohClYr1JvAID1oLScFD+W
         aPJXi//QRRxz1rHXohL/GKkiPtvFyv/5tAI+9TNSFWYUiqEjuWxoJu+hM325PV9WkRoQ
         JdA+o0Z8mSunStbRREGDMJFiQwwpMB7726NqWAwv+CF/LI8JmKJMsuOZ/6kkBgLPI0pU
         pZqoOuxUW0Fysf2tf/DD6TNipRyL/zNF4NWpdsWlV4piaVND8VlvMxqj8zjNiRrHaDwc
         yKvX3dBHWCq4GJ+QcUNj08dkGovbXABH6KP2RWmxWjaKyAsx3StyF4JZz3weiwVr67PL
         Gcqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z58si8165590qtj.225.2019.05.21.03.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 03:41:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C8A3F308620F;
	Tue, 21 May 2019 10:41:52 +0000 (UTC)
Received: from [10.36.118.15] (unknown [10.36.118.15])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8F0577841C;
	Tue, 21 May 2019 10:41:51 +0000 (UTC)
Subject: Re: [PATCH] docs: reorder memory-hotplug documentation
To: Mike Rapoport <rppt@linux.ibm.com>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1557822213-19058-1-git-send-email-rppt@linux.ibm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <43092504-a95f-374d-f3db-b961dd8ac428@redhat.com>
Date: Tue, 21 May 2019 12:41:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1557822213-19058-1-git-send-email-rppt@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 21 May 2019 10:41:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.05.19 10:23, Mike Rapoport wrote:
> The "Locking Internals" section of the memory-hotplug documentation is
> duplicated in admin-guide and core-api. Drop the admin-guide copy as
> locking internals does not belong there.
> 
> While on it, move the "Future Work" section to the core-api part.

Looks sane, but the future work part is really outdated, can we remove
this completely?

> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  Documentation/admin-guide/mm/memory-hotplug.rst | 51 -------------------------
>  Documentation/core-api/memory-hotplug.rst       | 11 ++++++
>  2 files changed, 11 insertions(+), 51 deletions(-)
> 
> diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
> index 5c4432c..72090ba 100644
> --- a/Documentation/admin-guide/mm/memory-hotplug.rst
> +++ b/Documentation/admin-guide/mm/memory-hotplug.rst
> @@ -391,54 +391,3 @@ Physical memory remove
>  Need more implementation yet....
>   - Notification completion of remove works by OS to firmware.
>   - Guard from remove if not yet.
> -
> -
> -Locking Internals
> -=================
> -
> -When adding/removing memory that uses memory block devices (i.e. ordinary RAM),
> -the device_hotplug_lock should be held to:
> -
> -- synchronize against online/offline requests (e.g. via sysfs). This way, memory
> -  block devices can only be accessed (.online/.state attributes) by user
> -  space once memory has been fully added. And when removing memory, we
> -  know nobody is in critical sections.
> -- synchronize against CPU hotplug and similar (e.g. relevant for ACPI and PPC)
> -
> -Especially, there is a possible lock inversion that is avoided using
> -device_hotplug_lock when adding memory and user space tries to online that
> -memory faster than expected:
> -
> -- device_online() will first take the device_lock(), followed by
> -  mem_hotplug_lock
> -- add_memory_resource() will first take the mem_hotplug_lock, followed by
> -  the device_lock() (while creating the devices, during bus_add_device()).
> -
> -As the device is visible to user space before taking the device_lock(), this
> -can result in a lock inversion.
> -
> -onlining/offlining of memory should be done via device_online()/
> -device_offline() - to make sure it is properly synchronized to actions
> -via sysfs. Holding device_hotplug_lock is advised (to e.g. protect online_type)
> -
> -When adding/removing/onlining/offlining memory or adding/removing
> -heterogeneous/device memory, we should always hold the mem_hotplug_lock in
> -write mode to serialise memory hotplug (e.g. access to global/zone
> -variables).
> -
> -In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
> -mode allows for a quite efficient get_online_mems/put_online_mems
> -implementation, so code accessing memory can protect from that memory
> -vanishing.
> -
> -
> -Future Work
> -===========
> -
> -  - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
> -    sysctl or new control file.
> -  - showing memory block and physical device relationship.
> -  - test and make it better memory offlining.
> -  - support HugeTLB page migration and offlining.
> -  - memmap removing at memory offline.
> -  - physical remove memory.
> diff --git a/Documentation/core-api/memory-hotplug.rst b/Documentation/core-api/memory-hotplug.rst
> index de7467e..e08be1c 100644
> --- a/Documentation/core-api/memory-hotplug.rst
> +++ b/Documentation/core-api/memory-hotplug.rst
> @@ -123,3 +123,14 @@ In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
>  mode allows for a quite efficient get_online_mems/put_online_mems
>  implementation, so code accessing memory can protect from that memory
>  vanishing.
> +
> +Future Work
> +===========
> +
> +  - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
> +    sysctl or new control file.

... that already works if I am not completely missing the point here

> +  - showing memory block and physical device relationship.

... that is available for s390x only AFAIK

> +  - test and make it better memory offlining.

... no big news ;)

> +  - support HugeTLB page migration and offlining.

... I remember that Oscar was doing something in that area, Oscar?

> +  - memmap removing at memory offline.

... no, we don't want this. However, we should properly clean up zone
information when offlining

> +  - physical remove memory.

... I don't even understand what that means.


I'd vote for removing the future work part, this is pretty outdated.


-- 

Thanks,

David / dhildenb

