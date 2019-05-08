Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42B46C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 07:21:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D171D21019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 07:21:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D171D21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CFFF6B0003; Wed,  8 May 2019 03:21:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 381856B0005; Wed,  8 May 2019 03:21:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26E846B0007; Wed,  8 May 2019 03:21:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 061316B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 03:21:56 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b46so8052886qte.6
        for <linux-mm@kvack.org>; Wed, 08 May 2019 00:21:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=27fPYDAuircJ86Pa8khvFfHOGJrbWdbSqVXmn7Nup/c=;
        b=ckO8FNM0RzNcjnh1xnS1ZUXyWdXgsABnzHKHdp873k1DOSVkMNm3OM7C0CAZ8gpBQf
         rrWrnCFbRAko0OB5Rx33YTrvLjqidRonelvHBgbXyx+eSpyJRRdTOSr3pDxwgvKmaV88
         hmu2wJDvsEeNQ3QCwQY1dj+faHApSfo4dW9LOv0nkGrwT5crLbhjPUkPaFonnOxKSRQR
         aoVhKX+rZH1cOsGo+XfRiHHxqwR8ltvu9dPL8oRoqa79AxGa+xtxONOSHSDqVWHSg2xi
         YxauTsDP5s0UhZsfR3HhdeD9s1/qybgx6DMit7GaU1N+cosidXUqt1rXoXl1r2ZhirG9
         zSxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWx9xuD8ZUPxAisWJV3ZnazgeQrbgjeRG/OkYjDOIjkU/k55ig1
	8U0Lm1lOlO2TayPpuXpzsMCup/OhpqaYXOucU6D22Ix8mDgy0BcXMFV4ggEkQH1V9POzw63B/01
	rGEqaoqw8qbPORNKdhIji9Qt+eUbJenvlgVJXGN1tda+Mlyd6x6TYnOjQfHXpX23MhQ==
X-Received: by 2002:ac8:37ee:: with SMTP id e43mr16181684qtc.43.1557300115712;
        Wed, 08 May 2019 00:21:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysntdstwCzfdoVSlp9Zq1XBugkdbsnr6dm12Lgr2zP/Tf37d+UAqK05jCSaN+gV2wXMQZY
X-Received: by 2002:ac8:37ee:: with SMTP id e43mr16181651qtc.43.1557300115125;
        Wed, 08 May 2019 00:21:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557300115; cv=none;
        d=google.com; s=arc-20160816;
        b=t7MrdOdenBOVLuX8Z3jXVjJf9KFGzYCZbVFH5bKWcP8SbwloEw79mHpM1u3TrI6fJb
         buecnac7lJ1erFnUgGY0lX7gC4RFoUyo8ldpz2eVGirESQZvzKHvx1N97Rlp8yehCuj2
         hJkYh5NvrCdIMzIw5ChSboaIV8GGgJ7JBeg/FgqXq/zgenWlCIJh7t2LVKGZxJGJqYYe
         gZAIzOLNoCoo8WD7bxTJlBblgw3AOaym17JiOK7muF/jXyikKklsBdypHS1ky1NEcaGN
         sBQvwYbGWuWmO/yCgoGOGtFUqTdJOUj79kTNu4GW/1Oa/fKe7HYh5eqjd0RbIrAqTw3l
         0jvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=27fPYDAuircJ86Pa8khvFfHOGJrbWdbSqVXmn7Nup/c=;
        b=VvJ9VdAAdn1oEL9sBl4ndZ/zCzBAADwFZWYdRaJofbP+NzKF95e9n3qy1JeM4hk48W
         oxpn4Qu2ffIUiA7CJjp6nwKAZZE4Jtpj8GfDUeIHExOSxver/PW/7Hoej1Kfxt8rqca4
         v2cZPJIIbueYYCruBBPyojWpLoyAJOoPfFogkAJGclLj9SjXmbaWxG/VAsccqzS2XRzh
         mXBCWl+oALZyL4LV5zIoIEkzUx+g2oC18rs2XfbItWyxg8QtWtK7ZszLL+3ttqjtUvZK
         NDVcZ/B9wulie2wP5zns6y9bmVkCIJCS4ANv5S6ff0T/DlCbIJULisOZFdW1fMYV+ogX
         hdOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w12si3864132qvr.21.2019.05.08.00.21.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 00:21:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 62B9337E79;
	Wed,  8 May 2019 07:21:53 +0000 (UTC)
Received: from [10.36.117.63] (ovpn-117-63.ams2.redhat.com [10.36.117.63])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A46755D9C8;
	Wed,  8 May 2019 07:21:49 +0000 (UTC)
Subject: Re: [PATCH v2 7/8] mm/memory_hotplug: Make
 unregister_memory_block_under_nodes() never fail
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 linux-s390 <linux-s390@vger.kernel.org>, Linux-sh
 <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Alex Deucher <alexander.deucher@amd.com>,
 "David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@kernel.org>,
 Chris Wilson <chris@chris-wilson.co.uk>, Oscar Salvador <osalvador@suse.de>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-8-david@redhat.com>
 <CAPcyv4h2PgzQZrD0UU=4Qz_yH2C_hiYQyqV9U7CCkjpmHZ5xjQ@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <1d369ae4-7183-b455-646a-65bbbe697281@redhat.com>
Date: Wed, 8 May 2019 09:21:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4h2PgzQZrD0UU=4Qz_yH2C_hiYQyqV9U7CCkjpmHZ5xjQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 08 May 2019 07:21:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


>>  drivers/base/node.c  | 18 +++++-------------
>>  include/linux/node.h |  5 ++---
>>  2 files changed, 7 insertions(+), 16 deletions(-)
>>
>> diff --git a/drivers/base/node.c b/drivers/base/node.c
>> index 04fdfa99b8bc..9be88fd05147 100644
>> --- a/drivers/base/node.c
>> +++ b/drivers/base/node.c
>> @@ -803,20 +803,14 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>>
>>  /*
>>   * Unregister memory block device under all nodes that it spans.
>> + * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
> 
> Given this comment can bitrot relative to the implementation lets
> instead add an explicit:
> 
>     lockdep_assert_held(&mem_sysfs_mutex);

That would require to make the mutex non-static. Is that what you
suggest, or any other alternative?

Thanks Dan!

> 
> With that you can add:
> 
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> 


-- 

Thanks,

David / dhildenb

