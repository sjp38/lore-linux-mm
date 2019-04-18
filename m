Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23C33C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE0A820821
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:58:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="nkxN45Ws";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="1eAto5RH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE0A820821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kroah.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61C2D6B0007; Thu, 18 Apr 2019 11:58:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CC3A6B0008; Thu, 18 Apr 2019 11:58:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E2246B000A; Thu, 18 Apr 2019 11:58:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC096B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:58:51 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id l26so2367703qtk.18
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:58:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=92OcmDHhMwZpz8e1eAiat+FLtmZj7Z9pUCxSqNJWTlI=;
        b=nalnsnOrxjNSqvdX3nGyvElZArq8v6e72/NczxiyQDljFf87CnnfYuf/MYxIOcuEIB
         L2DORZFBz2rAmxt8Ignsyc1zi5m3ESG+1S2DsQLz2cG2LANTW8gJmK1NzZtX9exkxZvQ
         d/Sz9MoaVhtfLSzjfQ+HcHXKOraqAEwXRti+KCNWrm+D3OY2gKv+HnSphyBM7ueVFboC
         lu3VXzfvH8Lfr3TtfgX5Ah6uz0rNI/ZXFtEf2FYMdwD7oS0z+FINyhKcLYOj89DgHy21
         FILERcxrofqsLU8t8/hR5gkfqPhh12WpEpwlgtYgJiAkxzWMtUX5ICqCrHy+/ICG+/l1
         jeJw==
X-Gm-Message-State: APjAAAVuHqWWBFrwenLsc+svYRRAfZk4dVeurw+yMYOl+/DuJERKt+cb
	9aCKjHZtNcGg/uUklanGoIKHbrCjdatxiHYCuwyai38jGm+PpdSksMgu/ph9G3HbVjuju1JhLSR
	Pb8IFRmt9ExDRY8DRAWQP81bSnHVPfDeTXrjVW6RqhPR1xy3XVsfSHDD8hji02a6xag==
X-Received: by 2002:a37:b444:: with SMTP id d65mr72252386qkf.125.1555603130977;
        Thu, 18 Apr 2019 08:58:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzS2Ziv6LipbNEDyZueVAE39BstaM6UJU7DUOlPU6lC/2cdY543YAFgdvoGD979a2ZzdoUj
X-Received: by 2002:a37:b444:: with SMTP id d65mr72252350qkf.125.1555603130490;
        Thu, 18 Apr 2019 08:58:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555603130; cv=none;
        d=google.com; s=arc-20160816;
        b=ldy0dI7sIQ9xErghGkT2uUWf0+VSMTH897Y9zfiOyeVbBScrtssOGafq0cPLfWUy0j
         24UZuqrbX6cOuVJ/kHRAFL3zV2aukz64dZ0sAGT0MKMrVbkZTXsw5JYQGXZ818DOxqEd
         DdnH2Lzhxz3n/LYi/cim8STEFn4yBB5c46gzHREy6GqwHB3u6GjxqKyf1RxCpdnyQJdx
         SpbdpWciTfGhXbUAWcYmF0WJ4qajDLwCpKtOVGfJMNQ+mILQPudeDliOba5QdQPG+y5K
         g0XrqdrsXBIJ8tuxEJZilkU/lfFWgSQvIVp0BOULULkGFbU6eOcrXieQ337RXWVlj+BI
         ZnbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=92OcmDHhMwZpz8e1eAiat+FLtmZj7Z9pUCxSqNJWTlI=;
        b=WwmDQY2nujGMixunGmBMNJTl60rVj/oZMKTmbwopfqyjhxnsHJT2kVozg6ThJsHNPi
         judfCzMPnWTlCDW7GvH+aTBcgZ8Oy39hO9mMnkTIdSSkD+4ndvc+F5Ov+F1C7maPlrIV
         i1fseUf6q5A2Z5ibeGsUMqg8SMaRYPNrxkHCfk7dO1xAhL4ssLzei0wK2S0amAltFftw
         lLV3gFI9+6hPIU55SJEIif53IVoHsdkcgejDXNbyRpep2vUi3GlmurAAUp+OqnVXVT1/
         wOGNjSR+yvbpmhMs7aX6HhJ4IEVEP4B5qmNhTOpcAEgoRAJrk6v2RzQwICbvygZrdEk8
         Yi3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kroah.com header.s=fm3 header.b=nkxN45Ws;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=1eAto5RH;
       spf=pass (google.com: domain of greg@kroah.com designates 64.147.123.21 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from wout5-smtp.messagingengine.com (wout5-smtp.messagingengine.com. [64.147.123.21])
        by mx.google.com with ESMTPS id h19si831478qto.168.2019.04.18.08.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 08:58:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of greg@kroah.com designates 64.147.123.21 as permitted sender) client-ip=64.147.123.21;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kroah.com header.s=fm3 header.b=nkxN45Ws;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=1eAto5RH;
       spf=pass (google.com: domain of greg@kroah.com designates 64.147.123.21 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.west.internal (Postfix) with ESMTP id 092ED4CD;
	Thu, 18 Apr 2019 11:58:48 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute6.internal (MEProxy); Thu, 18 Apr 2019 11:58:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
	date:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=92OcmDHhMwZpz8e1eAiat+FLtmZ
	j7Z9pUCxSqNJWTlI=; b=nkxN45WsGBGuHy+tJmAFOjyYO3aqt5w4t2eFj5NG4+F
	V5P1GrToFC4SiH21nlpPoz2vVn1H3DDFLOv9+9iIGu04WEjq9SnI/QW+OpdVeSx+
	obaZHoyFlJLE51lPLH3cS46PZ1Q2kp7OSZWIoIu0IUKmJZCHni7uc8KQ7i9pt3/G
	INXP8Whs4Bj9FgbZLE8DXaOlRmwUt+TGH8s2OKuu/t+E9FiV2Jc1wTAyc6MpywHy
	0APpencwbXHvIUf19PrffYaWvTFjtqkPngKPkMXIQdjc4NDbzI2xG4ZDy1iPAieG
	rSmy8UBSWNbYwXfePtQUt4LKWEPl12QqAXI2oSz8P7g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=92OcmD
	HhMwZpz8e1eAiat+FLtmZj7Z9pUCxSqNJWTlI=; b=1eAto5RHykNM0PbzL6lkJr
	Jz3WrVjbmqWdEXUOCEnNNllwYsDQ+laFTfNllXZPrM+nO3n/eUNu6lDeH7BhagOB
	Q5PfKI+QW5Aj4f4rhsCfoucVIH5jLatQQkG7iHwMJxaWqzpwCNBZb9ITduJYRHP9
	yag8ytvCfrwH5Tlo25nq6VwWleFNeoLace+2uXPBUcoC01aV0sWlOi46Qs3uahoB
	ZTqYD4ew2v9pwJJ1nAH66H09wInohIDLiK1eL5AymXAWzEB9utdDsDHUUZOwESgi
	PKr4bccm8tOFCF9ZG4Vn8UBQbJVh1sdGV2VMiJE06jGfAqsyf4rkAqCxpJlsoCAA
	==
X-ME-Sender: <xms:t564XL6WOf9h_yV8RzO09ZAxp97h-atUQmyQauD9ELQyZbG5cjpLDw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrfeehgdefjecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpeffhffvuffkfhggtggujggfsehttdertddtredvnecuhfhrohhmpefirhgvghcu
    mffjuceoghhrvghgsehkrhhorghhrdgtohhmqeenucfkphepkeefrdekiedrkeelrddutd
    ejnecurfgrrhgrmhepmhgrihhlfhhrohhmpehgrhgvgheskhhrohgrhhdrtghomhenucev
    lhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:t564XPpH_3fvigoC4gNq2q3r8sEZ3C6WPmT9qjtzxH1jwbPzUSkszQ>
    <xmx:t564XHA4VO_AwSTwpIMFGaK6L_MzFXxnLihVe67Ger9LE_7aIHbvsg>
    <xmx:t564XIOcso3zl-gXSHxQb9F03Y01AjnHr7jCn9hacWc8SnyagbxhuA>
    <xmx:uJ64XEqsPtgXreWfZNoRTFXN3juZws1zGNNf7m9j4GFhsQFYJkj4wg>
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	by mail.messagingengine.com (Postfix) with ESMTPA id 0EDD8E4383;
	Thu, 18 Apr 2019 11:58:46 -0400 (EDT)
Date: Thu, 18 Apr 2019 17:58:44 +0200
From: Greg KH <greg@kroah.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: stable@vger.kernel.org, linux-mm@kvack.org,
	Roman Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH 4.19.y 2/2] mm: hide incomplete nr_indirectly_reclaimable
 in sysfs
Message-ID: <20190418155843.GB15778@kroah.com>
References: <155482954165.2823.13770062042177591566.stgit@buzz>
 <155482954368.2823.12386748649541618609.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155482954368.2823.12386748649541618609.stgit@buzz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 08:05:43PM +0300, Konstantin Khlebnikov wrote:
> This fixes /sys/devices/system/node/node*/vmstat format:
> 
> ...
> nr_dirtied 6613155
> nr_written 5796802
>  11089216
> ...
> 
> In upstream branch this fixed by commit b29940c1abd7 ("mm: rename and
> change semantics of nr_indirectly_reclaimable_bytes").

We are running at almost 100% for the times we add a patch to the tree
that is not in Linus's tree, for a fixup being needed for it
after-the-fact.

{sigh}

Now queued up, thanks.

greg k-h

