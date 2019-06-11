Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A910C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:02:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D8F220896
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:02:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D8F220896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4B636B0008; Tue, 11 Jun 2019 08:02:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C22456B000A; Tue, 11 Jun 2019 08:02:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B10AD6B000C; Tue, 11 Jun 2019 08:02:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC356B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:02:18 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o16so11617725qtj.6
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:02:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=+MXA3It3NWXsRYxbtFOawzkitDz1Jp5qXJtqUFixH/I=;
        b=HVa/xH11ENd1Gr6HfBaso2IikTZjAQnEXa9UDJz7fKIbNCMq4F7J83mAqYrkf9Uju7
         3l93Db78QAzEpE2PQL8U9gtnfxV/Jee7ZynC8KJqSIZr4sGwrOxerMpMe+hbYOV9oXkW
         en2/l3QT/vcTHQg5taRh3NZMixgNT0uK+amChWmOO7BlMg7KlBjas8bZA5b3vHvsW3V+
         ohF608nIukOMI744zKGaibdihSH4CCTMFsH5+kuDn3LtJr0+tfxrxvIluXhipVtwwMm0
         mSEOy/hQiPwZvzwnm5ohj6XXjZYZr03+ve6umBU2QWaFPh0IsJrTWRZxno0LYIdfS9iJ
         LTRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUQqHy365UIMhQLT0W3/X6HsNeRQnFdqEAQVUcoGn3EBlEZLNmv
	mPtmbFrf6rzR/XSlRM09+elnK+bL/5ixitZKybOX3AXWTm4rUlhzJq3TWTc+fmUqEzxa+Bu+QBv
	riDOC67JgJfBz/Ru4yo7/goG+58cDnygHhYHeuq2rruenEmGCzw92XTVUJGY2gDxrVA==
X-Received: by 2002:a05:620a:1270:: with SMTP id b16mr38483585qkl.333.1560254538331;
        Tue, 11 Jun 2019 05:02:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxr3r8oTQQu+2oCWAflbput4cxuxu46pbKd3z4wxfKYZzdg7KBV7FdF3GL+EiXZDOh24rf
X-Received: by 2002:a05:620a:1270:: with SMTP id b16mr38483523qkl.333.1560254537541;
        Tue, 11 Jun 2019 05:02:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560254537; cv=none;
        d=google.com; s=arc-20160816;
        b=GFy9CDCTwQRN5oDZt8ghp7qxG3xksTTvgQ0PXflJVp6eybnx6DzpRo6aFDPnAoXwE0
         D1ywUT/GxjkkII0EyIO5aIeNjZWIeyPczedJnUr7KVzNxGVBgHXrcklEAHdXdf6zt9g5
         M0E8mFYtI3XSI36mZF4vu9YP66igJHVOKQ20bFlW3p7M6GjOrb7QZ5Ur5T0SnDGx7nfV
         mP1Dsuy9aXKm9XMsKmNQ0CVh1nnlxv62RnY73PavmOghJNNzAn3ndvhtuijnWR4sINjz
         yJIxB51Je+pKk78Y+yhSjuwa+c/RAijvzHen/dL2Q99mO88oLvQCig0i3OQUeI/iLgj1
         GN8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=+MXA3It3NWXsRYxbtFOawzkitDz1Jp5qXJtqUFixH/I=;
        b=mKnZJkWSunTwjA3+DSSoY76LlkknLhnvJ8tuOrL7Ku0eowJeEL7pWtrHk5/PqX/daD
         Al+JyaV1UW8vgQTSgGUS9somPYEgnJ7/XlNICV0matvL3nRBU4bQoba9fAoygnTfcwVv
         DnoiyZl7jYc/wZZXTaZoKT4LY0sWuL0vZwhevzJTBlS4yFvlvunyZiR6H511+N+AlrB8
         eM1jYPC4bz86J/t+wivShwc4oxw3Mub1Q/4PAgJ/PVvJPhiABog9L6IMTTBbq7j685Vd
         scnxHovZFuFMTSI91Q+6hrFkE9VMkH/57O2S+6NKuEpAdQ8KHak0el9yR+dlUJJK+ww7
         QssQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l123si1978180qke.27.2019.06.11.05.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:02:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5694F356CA;
	Tue, 11 Jun 2019 12:02:11 +0000 (UTC)
Received: from [10.36.117.196] (ovpn-117-196.ams2.redhat.com [10.36.117.196])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6C7F2611B3;
	Tue, 11 Jun 2019 12:02:08 +0000 (UTC)
Subject: Re: [PATCH trivial] mm/balloon_compaction: Grammar s/the its/its/
To: Geert Uytterhoeven <geert+renesas@glider.be>,
 "Michael S . Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
 Jiri Kosina <trivial@kernel.org>
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190607113559.15115-1-geert+renesas@glider.be>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <7db7ee2f-3b21-282e-164f-60bf3a2cab92@redhat.com>
Date: Tue, 11 Jun 2019 14:02:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190607113559.15115-1-geert+renesas@glider.be>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 11 Jun 2019 12:02:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.06.19 13:35, Geert Uytterhoeven wrote:
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
>  mm/balloon_compaction.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index ba739b76e6c52e55..17ac81d8d26bcb50 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -60,7 +60,7 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
>  
>  /*
>   * balloon_page_dequeue - removes a page from balloon's page list and returns
> - *			  the its address to allow the driver release the page.
> + *			  its address to allow the driver to release the page.
>   * @b_dev_info: balloon device decriptor where we will grab a page from.
>   *
>   * Driver must call it to properly de-allocate a previous enlisted balloon page
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

