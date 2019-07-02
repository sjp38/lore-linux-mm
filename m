Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68B1EC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 09:48:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1975E206A2
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 09:48:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=broadcom.com header.i=@broadcom.com header.b="PZuM9EJb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1975E206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=broadcom.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DE558E0001; Tue,  2 Jul 2019 05:48:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 765B76B0005; Tue,  2 Jul 2019 05:48:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62E0C8E0001; Tue,  2 Jul 2019 05:48:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 185B76B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 05:48:50 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id s19so44359wmc.7
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 02:48:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UdYCIZGQ7tAt7A88vWqWA422Qpx5IuQReKn9P3m3xX8=;
        b=B2q9jJt7C7sRnr0xMCHlXmnOr4/aWmqyiNIS3oApw5YRYoGj81TNV2SDTsk9A9UrF8
         8Ut/XCitXswrjQPwMpdTopB5KKLXty+ewS/owZxTWJvkHiwWgokN+A4pGKyXN5lKx1Pk
         cthOSUg/WR7gAAZbTqnTCTUqBxHd6AZn/vw7umzFlBGG+WeVyPMNY2n0PX2OogxGTW/x
         ltKu1splY1JEPEKu1SL9dv1f1DDc9Ohm1KIxFDP2BafnJn1C1N+E784+ia4tZ5cSf6E1
         xfo12jZ5t3EiKD50SRR1h2uLqt8KDaLoNSuoxnSYjY3WahjbTvm7q8Vod1kmmOsXi3GS
         aBJg==
X-Gm-Message-State: APjAAAXomapgQP4YiyduqLCwqrnil4CK0Z3Ra9RoZhyhSjEZeY0r2vj/
	4IXuCZ+KlreaxCAanrD8Dqw35A12TYfChbTHxVenRZJV1H/dyF29XUBCleJI+XxAUj7SWzMTzDs
	ngtjpoNkZ/+HNQzQEQ3dcF+CP8SBarc00Jpn2df7BxLE3aJCWp6O6KtG/xyIsls9htQ==
X-Received: by 2002:a5d:5702:: with SMTP id a2mr24419149wrv.89.1562060929472;
        Tue, 02 Jul 2019 02:48:49 -0700 (PDT)
X-Received: by 2002:a5d:5702:: with SMTP id a2mr24419083wrv.89.1562060928655;
        Tue, 02 Jul 2019 02:48:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562060928; cv=none;
        d=google.com; s=arc-20160816;
        b=oYPSmcPRfeUtap8gC8Dbj/B1/05IqCUeCENflbtRs2wCFaLDc7BUjq/bU4j2Hw9UfN
         X9vKv2XaPE2F0odG9EiYQrWP/rVqh/rPLcFTF9D143pzsNIwP8mvIYU5zgVcHL19TXkP
         d06nZd1aTnk4fwGH2holncHNB93yHwU/SaFFeWF7EFVVlUVB1t8NnH+c3y9GpMraah79
         SjFjgHURm2Rp/Qu3oiHFPfefxRcRDz1Iq4Kx57qQd+PIVVIAtp5cccalYgF6wPmo4ugb
         axNroWKW5ApajxQOjmnaAZUgnzHJOKphjBEmDR8Yj9+LSzheMQpL6RBzc5g3kj60yF+5
         1lnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=UdYCIZGQ7tAt7A88vWqWA422Qpx5IuQReKn9P3m3xX8=;
        b=DtjGOwdyuLT05HVcdes5YCaOeKowQfWqaOzoepcTL6hdVH5Ce3Occphzr91/f9tMeu
         dj3pYtrC/ncJC18QKpTKB7mb3vAP/6PUDlogSHn/QgqItf2/PTZhHh8SFYiP5CcWuH+u
         6OMIUyYhxpIxntQzhE2t8/i2CdkhDZ7SBCzvTc5W3DbnAEwvr20kNL7/1iOfP/n5O7AO
         Dzc/mApskRS93RAQqDBoauzyrlcBBTvSjXDxy2ZIkFQK58XHFPaQmyPMKVi+HPkw/37T
         xcjaSEOKJOsToZsdOAM806T3YNmpWAbUBcngPFx7zbwwkzhL7QgZLWanpv1+GChz3MMR
         Y/kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@broadcom.com header.s=google header.b=PZuM9EJb;
       spf=pass (google.com: domain of arend.vanspriel@broadcom.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arend.vanspriel@broadcom.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=broadcom.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor10024184wrt.35.2019.07.02.02.48.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 02:48:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of arend.vanspriel@broadcom.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@broadcom.com header.s=google header.b=PZuM9EJb;
       spf=pass (google.com: domain of arend.vanspriel@broadcom.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arend.vanspriel@broadcom.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=broadcom.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=broadcom.com; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=UdYCIZGQ7tAt7A88vWqWA422Qpx5IuQReKn9P3m3xX8=;
        b=PZuM9EJbQb3YhMp+qaw+VF6BwkhSSyYMquhljCcVZSO+tjIcy06ofVIGPbwYNmREXi
         pRcuGFWqgU+nSlEobDVIi97m26fD20LGHZVCL/m/+eGewb0yAO7NlvlF/9gBYN5Rgy0B
         UVcUnIeulg2Ui8pzjNF76wVB55J/p/3pN/YrI=
X-Google-Smtp-Source: APXvYqw+cs3wphtlInYiqa/iYYLL5YBkbuaWsrCFwdpkqDK8kfUrPvl8YI8TNOvUo+26MvPNs1E1Ng==
X-Received: by 2002:adf:9487:: with SMTP id 7mr9588274wrr.114.1562060928176;
        Tue, 02 Jul 2019 02:48:48 -0700 (PDT)
Received: from [10.176.68.244] ([192.19.248.250])
        by smtp.gmail.com with ESMTPSA id l124sm2421987wmf.36.2019.07.02.02.48.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 02:48:47 -0700 (PDT)
Subject: Re: use exact allocation for dma coherent memory
To: Christoph Hellwig <hch@lst.de>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 Maxime Ripard <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>,
 David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, Ian Abbott <abbotti@mev.co.uk>,
 H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
 Intel Linux Wireless <linuxwifi@intel.com>, linux-rdma@vger.kernel.org,
 netdev@vger.kernel.org, intel-gfx@lists.freedesktop.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
 iommu@lists.linux-foundation.org,
 "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
 linux-media@vger.kernel.org
References: <20190614134726.3827-1-hch@lst.de> <20190701084833.GA22927@lst.de>
From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Message-ID: <74eb9d99-6aa6-d1ad-e66d-6cc9c496b2f3@broadcom.com>
Date: Tue, 2 Jul 2019 11:48:44 +0200
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701084833.GA22927@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/1/2019 10:48 AM, Christoph Hellwig wrote:
> On Fri, Jun 14, 2019 at 03:47:10PM +0200, Christoph Hellwig wrote:
>> Switching to a slightly cleaned up alloc_pages_exact is pretty easy,
>> but it turns out that because we didn't filter valid gfp_t flags
>> on the DMA allocator, a bunch of drivers were passing __GFP_COMP
>> to it, which is rather bogus in too many ways to explain.  Arm has
>> been filtering it for a while, but this series instead tries to fix
>> the drivers and warn when __GFP_COMP is passed, which makes it much
>> larger than just adding the functionality.
> 
> Dear driver maintainers,
> 
> can you look over the patches touching your drivers, please?  I'd
> like to get as much as possible of the driver patches into this
> merge window, so that it can you through your maintainer trees.

You made me look ;-) Actually not touching my drivers so I'm off the 
hook. However, I was wondering if drivers could know so I decided to 
look into the DMA-API.txt documentation which currently states:

"""
The flag parameter (dma_alloc_coherent() only) allows the caller to
specify the ``GFP_`` flags (see kmalloc()) for the allocation (the
implementation may choose to ignore flags that affect the location of
the returned memory, like GFP_DMA).
"""

I do expect you are going to change that description as well now that 
you are going to issue a warning on __GFP_COMP. Maybe include that in 
patch 15/16 where you introduce that warning.

Regards,
Arend

