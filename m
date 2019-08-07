Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA28EC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:05:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BA03219BE
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:05:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BA03219BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38F9B6B0003; Wed,  7 Aug 2019 03:05:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 317B56B0006; Wed,  7 Aug 2019 03:05:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DF656B0007; Wed,  7 Aug 2019 03:05:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F1D8A6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:05:56 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x17so78280601qkf.14
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:05:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=2iDfpUDnZqborPmDzrGU5SwUF8YEPZQChhbPpBggf6g=;
        b=l9PX0akvFxGsRrX1HCogyfkJ6Deu7D05UMb5yGDYcXvpEyaB6SJu07r/4gCwbxpg+K
         Im/5AJIlBWVA0j8x6+Y4sxKZA/WXuLwt+EqGQia6Av/7OrcjXzCLh8pmA+Z6JaCLfJB0
         jO3xE+C6KiTyXV3hQfle33dO3d0aHK619Cs7XsMSZ1S2eLv0rgne7ScrcYd+dhof3e3J
         WkmrvBmoJ3O768qZtFS5mZ3guUnuuQl9rPAys+zLLvNx+vuTD+flQNzTkq6AZIN2fk93
         wMZmoaMCGDndwCzo+8l6fzaiWpLTQwtfLft9vde3H8X9wFqmJos0/HOudjrSEIEuc08K
         BNxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV6brtqnkva3OwjaoIodeS7BoB/DRjs4c1ciwHiROkfncFRhZTR
	v6+pB4SJM4T4wKEd9cniMHDxHx++d4295aCVdNwTM08ePuwRHB7OulC8wdfLidQy90qNJmPyn3T
	tc1yqEyQozPtNkS7UTap+zkv7DiWk61lxkv+FnmRNcEoN9i4al20mciScyXhXfxwDZA==
X-Received: by 2002:a05:620a:1598:: with SMTP id d24mr7004819qkk.348.1565161556808;
        Wed, 07 Aug 2019 00:05:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGZVKytQPOnth4j/XHoJfUKJPXrhg89niSCFvVsZ6widEONfxOuCm/hzJZzPB+UqRrs6fW
X-Received: by 2002:a05:620a:1598:: with SMTP id d24mr7004790qkk.348.1565161556206;
        Wed, 07 Aug 2019 00:05:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161556; cv=none;
        d=google.com; s=arc-20160816;
        b=abDOAtBvrmc7LJIRLQuVjt7h4YWOSDU4AEWwaX4PTBBvQ8i/ryy6YQgAWOFHvRMLrh
         w4Ws/W/Ow3NCZM/uOd2xWnw3m+isnJL/yxONgIBOH+jX7LGD/ZJkml2XIjQDYFLTr0JK
         Uf4yhWf8IXwsiR4uxxyKfDjoNYfadpD4yihpkSR5URj75NHhG0SgiwytxD/wleC6lHas
         83FPoSrCuaGFuVOsjLxzhCmki8EubZ39i2uOFJXadXzWQZVBL9lPEK/Cv1TXR8jZXDQH
         hVyV1RsJywNRVF2qSZWtaa1P/DWLrF/Rh1vjU2XCZJ5gRPuEox5DocCXPcXK+7KYnj2G
         9WkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=2iDfpUDnZqborPmDzrGU5SwUF8YEPZQChhbPpBggf6g=;
        b=EiImDMpGYXueqRvVXrcSWF+3RHK4Zkr6QrMFrhS0zfZCKbXcnAvR7UiiaGzXDw7VLR
         QaJGNzeFzoWL2RWorq/dTEDvUd43pLwKdaYIHQFUBhdlvVq1DBI1ByS9+2W/3pK6dUU1
         wj9onFeElXaLzpPJE9kNv/xDi3fg5tEDe5O2QfuSi6WGMex8eUstfA3RGPcM5lAkd8E8
         NIb38CIPZVYEKlVzmhcom6fpUfonh5LyBIdJEjB2TcXttv+kGr2RPCkPoxbqAIIg2AWm
         N0j5AsHEvajXohwUYhzZknf7tULhS9hvfRmOHqIuMuCSATyk5UXklQNMm/8FvSdt92g7
         sV6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h7si46734qkl.267.2019.08.07.00.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:05:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7D78E81F25;
	Wed,  7 Aug 2019 07:05:55 +0000 (UTC)
Received: from [10.72.12.139] (ovpn-12-139.pek2.redhat.com [10.72.12.139])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E3D841000324;
	Wed,  7 Aug 2019 07:05:50 +0000 (UTC)
Subject: Re: [PATCH V3 01/10] vhost: disable metadata prefetch optimization
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jgg@ziepe.ca
References: <20190807065449.23373-1-jasowang@redhat.com>
 <20190807065449.23373-2-jasowang@redhat.com>
Message-ID: <a084127d-4acb-dceb-3bb6-617eb79734e4@redhat.com>
Date: Wed, 7 Aug 2019 15:05:49 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190807065449.23373-2-jasowang@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 07 Aug 2019 07:05:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/7 下午2:54, Jason Wang wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
>
> This seems to cause guest and host memory corruption.
> Disable for now until we get a better handle on that.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>   drivers/vhost/vhost.h | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 819296332913..42a8c2a13ab1 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -96,7 +96,7 @@ struct vhost_uaddr {
>   };
>   
>   #if defined(CONFIG_MMU_NOTIFIER) && ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 0
> -#define VHOST_ARCH_CAN_ACCEL_UACCESS 1
> +#define VHOST_ARCH_CAN_ACCEL_UACCESS 0
>   #else
>   #define VHOST_ARCH_CAN_ACCEL_UACCESS 0
>   #endif


Oops, this is unnecessary.

Will post V4.

Thanks

