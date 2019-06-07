Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C44FDC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:49:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 758D9208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:49:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="XXE969tP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 758D9208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35B506B026F; Fri,  7 Jun 2019 16:49:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E4576B0270; Fri,  7 Jun 2019 16:49:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ABEE6B0271; Fri,  7 Jun 2019 16:49:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF6FA6B026F
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:49:31 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q13so2901004qtj.15
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:49:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xpue/yTKTfw/egd/V5x6eR0dUTrWX63mNojFgXXVaNY=;
        b=NEzJyta6IbUd7w6KoOXPpKRrpmKPKbYC9EK1sWb5o24pRuKzHgxTO2o/RVGV8mKuJF
         wEs6qs1TKxV9Y8mb0HR5AwJrBqsEWwVxCQCidI4rNjr5eGUx+4JkOdmdu2rSu7oYapj6
         eXBl5xWvq5qi56gu8oH0EDP+DXG7T1ORVQGAI4yZxBjrjrIEUSTfvB9hCe/cpPgfy537
         eHBVtdqBgUDcxEDg0D2r8rzLv5aQwErOd+7oYFRndi30VNXSB4L5jdGLbwPfTLjJdO3n
         q//5wFnJFlF2owtsfl2BMCE4QOmjvlFYBzyplOPhw7ThXS2YBuKgv5DtibB5eVeAu5qj
         prkA==
X-Gm-Message-State: APjAAAWjOeA51smr0vitu5XmZKAxOM42HpbnobYlgg2VNqlKYbol3dBL
	aLOpqsabmzCA2PSGu39G8/uWDprpUCRrX60YeFcwBnSHmYEwEYLgqESt1l1ROix25swKNVNXmL8
	oB9ToKSNnAjwsu2rioBAm2s4fXLk2d31woaNo4XKsdAu/Hk/rWFAyilYzhq1ZpjQkcg==
X-Received: by 2002:aed:20c7:: with SMTP id 65mr13233451qtb.392.1559940571760;
        Fri, 07 Jun 2019 13:49:31 -0700 (PDT)
X-Received: by 2002:aed:20c7:: with SMTP id 65mr13233427qtb.392.1559940571260;
        Fri, 07 Jun 2019 13:49:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559940571; cv=none;
        d=google.com; s=arc-20160816;
        b=olD2MKyPYS4IfL3G3MqPhsOpiJQMf4qObvadhtJ0iyLI4fqM+WDx1toph9cV6eUX45
         adq1RdFkUnKMWHu1e12CqUn4XpggBB7GzPdwQ4+EHVsujtVoCWA5ksaKUkFo9DYYllxt
         xVb3WnBXo2D0xqFrjSyFRHcQxuRbIO+NTl6xSRgiZ7PiQ3PdKxKvY/qxVlpbRHFo/ZrY
         uOwMpnPq75hXMiHULKgDqQ9YCq8+TJKyh2DL50C8z0EjTu2pEE+4r4bHUDTXsXmvucX2
         bQpTze5/WgxUwkpEVH7TELYy4Hhn0t/PDCha6K0lbWvdyc9tHTjqi1uJBhoLiYuT29/y
         Y3Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=xpue/yTKTfw/egd/V5x6eR0dUTrWX63mNojFgXXVaNY=;
        b=LgNEkoYSOFubzeE62EwmuwahTp8SKxzX0grwivzQJd52IhUrpI3JovOeYDmomBcbft
         b/czYNWD/dYiDbrih0ZYTwLZqeTOKlfsxaQY5X1JchWqf3AV2RMy7lPJDWxgodmXLeGz
         JrbRM43iVwarGhCo/sy/qSNuclKUw2ML7kPdJR7iD4PvxrwkR9xCMgutPRMovhl518gu
         5rUl6P4ZRmR7Cv0W01AgaYDoCpoKTOyK/ZFgRP1yrRCgyTsbw9RlYVFxogpj5doFdtz8
         9XCuqR/UMHd6jCBlQN4sk3Er2AbS5svrGP8SZD2PC4Zzg/KIup9MRZfiaUFm7/lhrjef
         LPzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=XXE969tP;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w23sor3818968qtn.48.2019.06.07.13.49.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 13:49:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=XXE969tP;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=xpue/yTKTfw/egd/V5x6eR0dUTrWX63mNojFgXXVaNY=;
        b=XXE969tPj//9W51VkE9buoc1JR7bmeVIhDAenkig2qDcQeGQ9MQNdB4210YOgBQ6Ee
         urj3N09P7L5Mjvi4xbXHFj8HKfPprYKq7M7k/EcjofeMB2GoxEsuqBmDRxsipmPauBqe
         JJ48ov9QD+JiHQdqD9ykoXBcB6idhYNIBBpzZJ3zljvLxzfdUEHW6WPXsiiOISOg1mj6
         7DBax0TlpUXdzKzMpIHUKAbPg2PH7L5VNttRwq2gKh2xi8KiWg94GJWmCGzV9d7EA4dS
         T2I4WYqCFPx5kBGsqWXqkhkJCYicSNB5CNfx8sekAbHUUM1GtLdieXZWKGLrM/mxrLUx
         C/1Q==
X-Google-Smtp-Source: APXvYqzPKIbGhJdstJ73Gy3kLdTzS56fHmRoDPMXyiprmrDID4cHA2htBZhMjn4/4PIp+2lgQ2jdNg==
X-Received: by 2002:ac8:3325:: with SMTP id t34mr44082999qta.172.1559940571006;
        Fri, 07 Jun 2019 13:49:31 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id b66sm1666176qkd.37.2019.06.07.13.49.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 13:49:30 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZLnm-0001TA-75; Fri, 07 Jun 2019 17:49:30 -0300
Date: Fri, 7 Jun 2019 17:49:30 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 09/11] mm/hmm: Poison hmm_range during unregister
Message-ID: <20190607204930.GV14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-10-jgg@ziepe.ca>
 <96a2739f-6902-05be-7143-289b41c4304d@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <96a2739f-6902-05be-7143-289b41c4304d@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 01:46:30PM -0700, Ralph Campbell wrote:
> 
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > Trying to misuse a range outside its lifetime is a kernel bug. Use WARN_ON
> > and poison bytes to detect this condition.
> > 
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> 
> > v2
> > - Keep range start/end valid after unregistration (Jerome)
> >   mm/hmm.c | 7 +++++--
> >   1 file changed, 5 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 6802de7080d172..c2fecb3ecb11e1 100644
> > +++ b/mm/hmm.c
> > @@ -937,7 +937,7 @@ void hmm_range_unregister(struct hmm_range *range)
> >   	struct hmm *hmm = range->hmm;
> >   	/* Sanity check this really should not happen. */
> > -	if (hmm == NULL || range->end <= range->start)
> > +	if (WARN_ON(range->end <= range->start))
> >   		return;
> 
> WARN_ON() is definitely better than silent return but I wonder how
> useful it is since the caller shouldn't be modifying the hmm_range
> once it is registered. Other fields could be changed too...

I deleted the warn on (see the other thread), but I'm confused by your 
"shouldn't be modified" statement.

The only thing that needs to be set and remain unchanged for register
is the virtual start/end address. Everything else should be done once
it is clear to proceed based on the collision-retry locking scheme
this uses.

Basically the range register only setups a 'detector' for colliding
invalidations. The other stuff in the struct is just random temporary
storage for the API.

AFAICS at least..

Jason

