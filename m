Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F722C10F05
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 06:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA19A20896
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 06:05:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA19A20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5906E6B0006; Mon,  1 Apr 2019 02:05:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 566206B0008; Mon,  1 Apr 2019 02:05:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 454A96B000A; Mon,  1 Apr 2019 02:05:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25F086B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 02:05:05 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w124so7617221qkb.12
        for <linux-mm@kvack.org>; Sun, 31 Mar 2019 23:05:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=+cF/m1O7fYEr5IOW8mmr5o33R/o+kbPBFSWYa1cd8hk=;
        b=bc4iVLQp3Jdcdxgi/IiSVEKzuJIiMSel4CtzrtlVWaMTIHCJYrxOoHKlOZFb1cNJ1h
         4bi+7GS8d14zEQSrOODPS8r0sciRJeYC9dEfA3xxcosEg/Q74HEfIMRi9PK2lA6aZXW/
         wng6E94DQjhObS46icbGeQ9ZBTesCwaNnd5is2Ha4xywvvuJa7gUjJ8yqsif4LFuu85s
         Oa8K6ws/WsMRHYK5v5vp8MUPNsXo8bA1oQjsTBmM4UDUgC4rYs1p6KKKWW/SDhCQ5EmW
         3epfr5nk/UwfXMK2PTqHWKmR+3iMFEwNAd6CIY/mBalwfB46P9DJmuEzVytOs0Gg023c
         CVEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWIaIfbUhQ6fVatIgGEsa8RT/Al0QtOY1ulUTJOHzcqMnTeLZJ7
	wTTaLNE1c16EEjgqYMSVKNduqTCeRUEYeO5YRW6m7TwQDphQNARM6Y+yj9n6nSDGrflcmtMfUen
	99DkkbLrXyllT7NgBF504/pjPWH/R7KWhnn73TFfLdMttPDX5BiKqTCuEjs+AnuRniA==
X-Received: by 2002:ac8:30e8:: with SMTP id w37mr52762025qta.136.1554098704929;
        Sun, 31 Mar 2019 23:05:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznivkVBa+782n4LoErVRMamGaVLsbDY8JVNKSYQc+UzybaS8rFhoURWN3X+Ca99tG/spxB
X-Received: by 2002:ac8:30e8:: with SMTP id w37mr52762001qta.136.1554098704343;
        Sun, 31 Mar 2019 23:05:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554098704; cv=none;
        d=google.com; s=arc-20160816;
        b=kWHmxkMmI81RCCPiqbTSBnZJT3jA1jRwng7AAoUQ2wfLrnBbkbs7uGP4yRMWzFSpW4
         5X6WhEFhj7+w39LacYMLQ2jN5jxc9bxBDPhKwCMg7SsEGjkWIEMhAcb7sWvszcSs4UgX
         pSsuzmtzSAIK46Aqet0fB6R4tsZiBmOyGoM+sxuVOJINwctnpBPhm9Am6QbagsvV6gIo
         hPlG5yk6k4nGiVEgkd32uq06XSyleeZW9pE8HJHCR1mu2POsl0w7W0mNdGFAAB/UJb2F
         B81J5PFBO6LLme01AmOxZth7LZa5oa+xhj7uugxPSvwQdgPY4APZcLcEkiW/3fO1soay
         OdaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=+cF/m1O7fYEr5IOW8mmr5o33R/o+kbPBFSWYa1cd8hk=;
        b=GbgMbWBifyrJmZVCUNFiWSPZE9dbsfPjNR720+m8Zb/kdxJN0ap6wHSOlzv2m8/WdP
         ZGVXOuMp/T/v/eUuAm9xLuRAzzEX68J5VY/Bwh1s3BGmd/If1RvRk08UWG008DxsGnqS
         qOP7hc/+itRcNIgrpRRLd5002ffKpmwRiEFcUHcptrL50w473hTrOef5apf06WpvpW+A
         ZXRrCzZbMdrNhX3+RESi2Vw45/NJU3IJNLaaBfaXko5XjyeJwCv0MERsdvs8sKmBAlno
         Du3XwANttd4MSXQaXdGtabD0t4VYBNweHm34urhMOrHvP+pdurDDq273SqdzkeFZhZSO
         NlkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z16si1159468qtb.329.2019.03.31.23.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Mar 2019 23:05:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 69C863084295;
	Mon,  1 Apr 2019 06:05:03 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5105C5D70D;
	Mon,  1 Apr 2019 06:05:03 +0000 (UTC)
Received: from zmail21.collab.prod.int.phx2.redhat.com (zmail21.collab.prod.int.phx2.redhat.com [10.5.83.24])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 13F611802120;
	Mon,  1 Apr 2019 06:05:03 +0000 (UTC)
Date: Mon, 1 Apr 2019 02:05:02 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	"Michael S . Tsirkin" <mst@redhat.com>, linux-mm@kvack.org
Message-ID: <1185594000.16522589.1554098702713.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190329122649.28404-1-david@redhat.com>
References: <20190329122649.28404-1-david@redhat.com>
Subject: Re: [PATCH v1] mm: balloon: drop unused function stubs
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.67.116.139, 10.4.195.22]
Thread-Topic: balloon: drop unused function stubs
Thread-Index: /cPl/4jQNeW9hdMwdinHmNF6zmc/7Q==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 01 Apr 2019 06:05:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> 
> These are leftovers from the pre-"general non-lru movable page" era.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  include/linux/balloon_compaction.h | 15 ---------------
>  1 file changed, 15 deletions(-)
> 
> diff --git a/include/linux/balloon_compaction.h
> b/include/linux/balloon_compaction.h
> index f111c780ef1d..f31521dcb09a 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -151,21 +151,6 @@ static inline void balloon_page_delete(struct page
> *page)
>  	list_del(&page->lru);
>  }
>  
> -static inline bool __is_movable_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool balloon_page_movable(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool isolated_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
>  static inline bool balloon_page_isolate(struct page *page)
>  {
>  	return false;
> --
> 2.17.2

Looks good to me.

Acked-by: Pankaj Gupta <pagupta@redhat.com>

> 
> 

