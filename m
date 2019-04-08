Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAC1CC282DE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 07:05:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 990C3218DA
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 07:05:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 990C3218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12F5F6B028F; Mon,  8 Apr 2019 03:05:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E0E16B0290; Mon,  8 Apr 2019 03:05:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE99E6B0291; Mon,  8 Apr 2019 03:05:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA9766B028F
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 03:05:58 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e31so11969417qtb.0
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 00:05:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=P+9nGPLUpGp9qF3FpUQLKLCiQ0DxQkFJX5Awlv364ng=;
        b=NJNpXQqSoDM1Xi9Ox9S1FRnNvxl1L7GXogNIe8bK9iH0utdm+XTw3mD5lvlLcQHhkQ
         +dkUe3Qn40+yyWMt+eTco8yVIQcB2EYpefQVJGCIq4qvhF7VIyRMU++iwcHfjPqAT/Sb
         aGgfgON4Z3nNm8udVoVtZn9xZ5XYPrvbzzkHTRLxrOrR1phc+AOW8y5/9KR+8ZMJkLWj
         vjVMeXHZLvAHoR56y/K4IuCgLjLAOex1yddVoE0T3ISfayUJPyIchuCpQDlM/pQBZ3mx
         HLYxYHPVbPqrN4pKelRqcO3F17DpTCYDYdJ/tpOxPSblutn2tVAb/spFQq4tM23Q2/S6
         gqLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWZ5BaUuneOBXnNjRNvsekGQiNDMeoVTlo3Z/ANv+CKGZLL8fmP
	2md6rSVYseMoDMcnUNL/2sMtF7xI9stiXsb/aQJ/tIWMmJwIZw5rSn762nJwQqXISfSsPzh1+wN
	ok/dczzyTZDtCQFwiygSkxfiX8lYwiPI0k/uspyDeSXWmixde6PQuYVjDKSdZJtYgpg==
X-Received: by 2002:a37:4b41:: with SMTP id y62mr21715927qka.104.1554707158525;
        Mon, 08 Apr 2019 00:05:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAN5iWqPD1hYSvzKk2h2vwzHLl06mS22GUVTmyIASz32lEW4n5mgqYk/5RBqhzs5SHl7du
X-Received: by 2002:a37:4b41:: with SMTP id y62mr21715908qka.104.1554707157993;
        Mon, 08 Apr 2019 00:05:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554707157; cv=none;
        d=google.com; s=arc-20160816;
        b=i3fMKW4R7/GV1K/3Ro689Tdf0m6TIJj7Rp2hQBQ6HcTLQZfjTva+GqEFIsVZUKwLLy
         GNbuJv5SGBeuMN3t3TfWErJTIWQPjZYWPnyU/4Hs4Olk89bk2b+oZ90WXgp7ddXXnGYV
         xJKNbR1OGeMUCOJxzp45NXkdFmbiyGcduQD0Zf8Y7C/2CBys1VkxH9dNmpiD9U41m43H
         9hroCHFdb5MpYp8L2ToKYTpQnCEQPu9pXKsL5r8HruQT8PGy6U+2ddkaEPjLFK7APzhQ
         NdyOhc6cqo1b7SvotMCro2p40EVB8Rg5RBt/eUOaoaSsxd4nM/P1KTBjA+02nIP1gm3X
         bfcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=P+9nGPLUpGp9qF3FpUQLKLCiQ0DxQkFJX5Awlv364ng=;
        b=fTWK5P6kZ91Lu3m113zzy7zDrggpWoFpo/RXNWdh6YpAaZaiaA+Emc8WT6HQTHvdpD
         K14y1PYy9TXf4JxCG2ktpqeFKGT4V1c80HLxveS+Wwrsbyrhpsf4AjxLDlDAGQB47Zua
         /U4wjjZIfYk/MKaURbNP6SDTEux4/dg21YbdxhwwsKirEFPGLzhLfERwZSDdguvGT4lN
         cWiiZHOLV6EGH8WEsu6qxXDGmXQGhowFZ/vnRP775rvqw4oQz0ACOUA+n8MpeguRRdKA
         90WF9pREQH0Nb9bvKXDWDf7RZHAgBT+BSE+/1gSp0UBjBwdEH2bziOqHjVAytViGzyv/
         lHag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o23si4705390qkk.147.2019.04.08.00.05.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 00:05:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 08514461CD;
	Mon,  8 Apr 2019 07:05:57 +0000 (UTC)
Received: from [10.36.117.53] (ovpn-117-53.ams2.redhat.com [10.36.117.53])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4A4556085B;
	Mon,  8 Apr 2019 07:05:54 +0000 (UTC)
Subject: Re: [RESENT PATCH] mm/memory_hotplug: Do not unlock when fails to
 take the device_hotplug_lock
To: zhong jiang <zhongjiang@huawei.com>, akpm@linux-foundation.org,
 rafael@kernel.org, rafael.j.wysocki@intel.com, mhocko@suse.com,
 osalvador@suse.de
Cc: vbabka@suse.cz, iamjoonsoo.kim@lge.com, bsingharora@gmail.com,
 gregkh@linuxfoundation.org, yangyingliang@huawei.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <1554696437-9593-1-git-send-email-zhongjiang@huawei.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <209a8820-7f4f-c36c-2f48-ebfc31e64428@redhat.com>
Date: Mon, 8 Apr 2019 09:05:53 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1554696437-9593-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 08 Apr 2019 07:05:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.04.19 06:07, zhong jiang wrote:
> When adding the memory by probing memory block in sysfs interface, there is an
> obvious issue that we will unlock the device_hotplug_lock when fails to takes it.
> 
> That issue was introduced in Commit 8df1d0e4a265
> ("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")
> 
> We should drop out in time when fails to take the device_hotplug_lock.
> 
> Fixes: 8df1d0e4a265 ("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")
> Reported-by: Yang yingliang <yangyingliang@huawei.com>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  drivers/base/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index d9ebb89..0c9e22f 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -507,7 +507,7 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
>  
>  	ret = lock_device_hotplug_sysfs();
>  	if (ret)
> -		goto out;
> +		return ret;
>  
>  	nid = memory_add_physaddr_to_nid(phys_addr);
>  	ret = __add_memory(nid, phys_addr,
> 

Indeed

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

