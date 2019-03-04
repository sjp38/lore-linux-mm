Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 742BDC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 09:18:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3462C2082F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 09:18:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3462C2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0FCD8E0003; Mon,  4 Mar 2019 04:18:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC0BE8E0001; Mon,  4 Mar 2019 04:18:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A86DE8E0003; Mon,  4 Mar 2019 04:18:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83FA68E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 04:18:48 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 35so4537897qty.12
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 01:18:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=qKwLFC46t4+YqLvXKYaZVzjn2UoBI135Hp+w/OyR6XU=;
        b=TNfJQTPibCTzMVfqXPJ+wlLE9V7Zl4RsGiO24DeE7jkCyineq/ciTTjTIo+VgdPq6p
         U7MsuxZ3GjOjcT+AocpQbHJXQ6PpR8FLFm/f2ItowfBmfu3KI5oBsiiMSZd2CaZyi0pH
         ov+sY/kbJutaJD2Xcw6NLf+c1ctEddoVG0dxMuxAylsS/il/pzs29wSV8KbAYsIPjqVG
         jDgMI/NzQbNAER7bulvUJaQAKzmkVO9uvm/1fdUeDTTzk3zTqtdWJCBPd2EWsNZK91V2
         P3rcTbW9dkuXoDMFXJPqutzGW/dn0TuoDSWYQBOaIgWQiMg1z6jajHKEti5N7A0dOgVx
         SU3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXfHV/a1W9a0vip1MM7WTce0HiX0ceWwdzoubdCEXvgsZq5Al1l
	bwSGOVz2AH0/8ogxuS5senCat46t9PtMJT2Yh7c+3Q+Gg0nKotaL/cPdXNCf30czYTUPozxUBzB
	31i6Sme4giZtM8I8k/0/m5kbkNbZhzAPr9InN0XwXefBUtzzA//HWr1R42uSmpSqqJQ==
X-Received: by 2002:aed:21c2:: with SMTP id m2mr14528119qtc.107.1551691128235;
        Mon, 04 Mar 2019 01:18:48 -0800 (PST)
X-Google-Smtp-Source: APXvYqzXVAYIcJjVuAHN3MsKUxFudBBRF4QOWaeMWmG/W3fKBRRSVFMoiMB0FPRb3SO87Owv8tFd
X-Received: by 2002:aed:21c2:: with SMTP id m2mr14528100qtc.107.1551691127560;
        Mon, 04 Mar 2019 01:18:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551691127; cv=none;
        d=google.com; s=arc-20160816;
        b=ZfxhNLodHDXx5b5wfuCZj+iJ88SSUulNXSEm31S3GYXXOUKTUnFf4xXk6+usjshloi
         ybnRFbQyOvHjOHVc1V8Y0b8aqCi1qMHwPPZr1XN2tLfPtMRxyJ9nhD1rQ0lH6MuWViJm
         CeqD2z/X1KhHkoW1P8gGC8XQnkDndAFDL9KlGkQiH8aNICO9DC+YrTxgs/zmkvGNvgio
         Eh+zYxq5NW7saQNv6qOff/YZ8J85XmhcAVramirp95T/ajYvWV0tcuTQQgsZKEM4K947
         cHvr5pR1D1k03wEgF+b0c/pi0M5v14gxRdZW5DaIVR5Kng1fWMyFvAgCeXsYhmhfvMt8
         mmuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=qKwLFC46t4+YqLvXKYaZVzjn2UoBI135Hp+w/OyR6XU=;
        b=0grPX6uxqIcKxi76Bdaip8CqZZfZ8GTHQPIjBJPYTDjr0qPIjzMjFZpl7E/5pqiaa8
         9/NrBnPscE6jcCjkLvMwGTMNnaeGf7/rukjVDhFmXRQHHvapRsvgUJJ8dkbzTpZMOcYA
         xelsBBe8PAAgOgsXWTOPuzWxM5XUOZqChJk6N3muwNPlG0V7OI5JPo6sMZ4o5GENTvDx
         TDThC03kesahKyjPJYwDWIWTPpIUaDP/SljenKqIeZxholaIm2O8TbxdpoBtypWScnvM
         GN+4XuMt6Epmf2I+CgICmWLSHyhh0o1l2PSXn8wUIyskNk+Th3yVbLoPJU2TaTbKCJMw
         QqrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b39si2920716qvd.203.2019.03.04.01.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 01:18:47 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 183982D805;
	Mon,  4 Mar 2019 09:17:29 +0000 (UTC)
Received: from [10.36.117.58] (ovpn-117-58.ams2.redhat.com [10.36.117.58])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B76C85C73E;
	Mon,  4 Mar 2019 09:17:27 +0000 (UTC)
Subject: Re: [PATCH 2/2] mm,memory_hotplug: Drop redundant
 hugepage_migration_supported check
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, mike.kravetz@oracle.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190304085147.556-1-osalvador@suse.de>
 <20190304085147.556-3-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <1b56e6d3-9309-69f3-0ece-228705094975@redhat.com>
Date: Mon, 4 Mar 2019 10:17:26 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190304085147.556-3-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 04 Mar 2019 09:17:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.03.19 09:51, Oscar Salvador wrote:
> has_unmovable_pages() does alreay check whether the hugetlb page supports
> migration, so all non-migrateable hugetlb pages should have been caught there.
> Let us drop the check from scan_movable_pages() as is redundant.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 0f479c710615..2dfd9a0b0832 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1346,8 +1346,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  		if (!PageHuge(page))
>  			continue;
>  		head = compound_head(page);
> -		if (hugepage_migration_supported(page_hstate(head)) &&
> -		    page_huge_active(head))
> +		if (page_huge_active(head))
>  			return pfn;
>  		skip = (1 << compound_order(head)) - (page - head);
>  		pfn += skip - 1;
> 

Yes, it would actually be a BUG once we reach that point and we suddenly
have !hugepage_migration_supported() in my opinion.

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

