Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A09C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:04:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A09920881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:04:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="K83trPq/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A09920881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E84D8E0002; Thu, 31 Jan 2019 01:04:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 897A98E0001; Thu, 31 Jan 2019 01:04:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 786D18E0002; Thu, 31 Jan 2019 01:04:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 521938E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:04:04 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w1so2414590qta.12
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:04:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=pm74jFL5WdkgPbflaRWND5Onh5JGUH4RIyse6+DyrEA=;
        b=uMR5LNh+9FiMRIt9p34yezyv63qLV/c4rYKf0HlFzN3xZf+6MV6saLQrtMYG/sKt5O
         5SwQB0dtpbU42ec+XTI1bynfayp5zlubZpzko1IYUvel5TDthaJZjrP26NY7AgVCH+pt
         Ej985zaI/01ch6W8JAyj+HnRgjpcxLKSRojWLd26BwlRQjz2suytmTIWlSIVDZfdRn8c
         NEsyOxc5cjqCgyjpViSi6+Hiv8lbxlroBhxJrXIlIigJjwsKEDkgoY7cw0LY8oFRJnFD
         dy7eHxG0/7PqkOel4ZJQO0p1FDbJ7cMr55tuXwV/z2kgoI7ndI+SmHsVU2a7u3nWoTYt
         yniw==
X-Gm-Message-State: AJcUukcRJRgmT++bV6qQR5YtAlwwLncNRnIXS9z6z81ENPdpmsgA3RQW
	zu69NgpbIRuutuSaVmyhZCsJZPza6T4Sd0dPfBkSWEYEKYSLw9XwTuR8+ZChWBZTz0xiiWdG22W
	cnhcN4kvl719dm6P8uz6s1q+TlR13nzNgWNhs0RSukahUx8hk6lgx9XK+r0o+qPw=
X-Received: by 2002:ac8:2585:: with SMTP id e5mr33109054qte.233.1548914644026;
        Wed, 30 Jan 2019 22:04:04 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6xLIAUUIRicUCtmPDvKrfyGH1pWwD4U6xMfjHgsvJ+KsNPAlYGiQDVitzm35j8ItK+Wv6t
X-Received: by 2002:ac8:2585:: with SMTP id e5mr33109031qte.233.1548914643463;
        Wed, 30 Jan 2019 22:04:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548914643; cv=none;
        d=google.com; s=arc-20160816;
        b=BDkH7avl1tSAn3wva/3owXMKOJgrB+bsfeRsGnNU0tN4IueWPMkJBprM0lGE4ISaaG
         scsd5ZNQVUJkljckbzy2eqtQGnMzPwYVkrIgDQJ57SZfbbl4425dB84E8FRi6BRrU2Bt
         bt6AnNjrRVBxATKfuUDRM1Dqjr1pdYJNTFTy14H5u/0OBdYOVe26tadYC/YPCtWVs39v
         6ote9TY4/UthI9vvoJVk2zvcATEJmitfsNYg6ChftVNYQp8fHJ4miS/rB/+00ohgvabz
         RFaXTMfcOLG69oeS8/7obDpfY3NSbRvgWjrCnX2pNjbkSLb9W492LIq/jgWnQodG+YpN
         Zkiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=pm74jFL5WdkgPbflaRWND5Onh5JGUH4RIyse6+DyrEA=;
        b=gbSwhCQv6HD8kd+ByeNaK+ooqhZUlPByoTBnWvR7MPf+IzcPnUBl+wDqNMgrYFbhLk
         WUYyS/Bxwfc7dHx9BsQ4QslAYZ9LZBqMBEw+47YraAZluSlClBjGUcEBaT1mZtjki/in
         zBKt+1vJKpqGGZekHob0ti/g29AdWvF9hbbYHV6sA/PJfR8pMfPQy5k6JSTqv0xuK/RG
         QSRbRbkTZJP1DFav8qmyvvUjsR9PwqBGNxnSu2JF/K6V/EBOc0yZA5mMMG9XIIF6o9PQ
         5DKh65/uxM34gIch+bBcgl4Kt9x/rwPGreGkDmTFYLSF4HF74k9dU91AYduFy9/cJZQz
         1HAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="K83trPq/";
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id o44si2590208qtc.134.2019.01.30.22.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 22:04:03 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="K83trPq/";
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id EE552216C5;
	Thu, 31 Jan 2019 01:04:02 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute4.internal (MEProxy); Thu, 31 Jan 2019 01:04:02 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm1; bh=pm74jFL5WdkgPbflaRWND5Onh5JGUH4RIyse6+Dyr
	EA=; b=K83trPq/lRQ5ZAEYokXtzAHdeVPm3lHZ2XLhKPZ1Zsbfke2/k8QO7KTo7
	THpV7spAKIn45V3f0rQuImWFcFOUTIQ4jNkjgo4VJIPdyJxtp3HF8fxNEKbJjUPD
	nXpxfqnLiHQB3k3oSQ9aPSEzwmNhi/NJy07HqBqyFZRShvRauN/0hCJ3au1UIwTG
	+u9oDb+RzauvtUYLsFzC1Pu9PX18t7HbFyZsL8K2/3fj8ELnW00sTecQLydtKNms
	ZgfIPB4DtqI0PBbWWkQU3GiVR0QGHxtXUpXNQ4Ryeb+N4iyTbC1YsZphigAEFEIk
	WZpcKW281KMOD6ZxSR/xd7w0iEpBw==
X-ME-Sender: <xms:z49SXPnAFRHox4N84sy9Ju_0Lj0jhLethXXOpyVz-6IXibBu7xD2vA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeehgdeklecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhepuffvfhfhkffffg
    ggjggtgfesthejredttdefjeenucfhrhhomheprfgvkhhkrgcugfhnsggvrhhguceophgv
    nhgsvghrghesihhkihdrfhhiqeenucfkphepkeelrddvjedrfeefrddujeefnecurfgrrh
    grmhepmhgrihhlfhhrohhmpehpvghnsggvrhhgsehikhhirdhfihenucevlhhushhtvghr
    ufhiiigvpedt
X-ME-Proxy: <xmx:z49SXFbA4teLOv1uCMRc_Xqar5Wsjw1P5yApBhpu1OdIsMtYqudJAg>
    <xmx:z49SXJT9vg4SSoatl62M3_ELW6vevYPm54aCx1yfgFyCRdwPq8c5ug>
    <xmx:z49SXHulIQlQ2D9nJdlhFTevbUaISQr3RPyNbDpmXEydkCwsPNdyqg>
    <xmx:0o9SXFRMUqNgS-UrW9XDztpykGZ86DDkTHRiFmH2wScin1ds_k6Xug>
Received: from Pekka-MacBook.local (89-27-33-173.bb.dnainternet.fi [89.27.33.173])
	by mail.messagingengine.com (Postfix) with ESMTPA id DDBC0E40FF;
	Thu, 31 Jan 2019 01:03:56 -0500 (EST)
Subject: Re: [PATCH] mm: Prevent mapping slab pages to userspace
To: Matthew Wilcox <willy@infradead.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Rik van Riel <riel@surriel.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, kernel-hardening@lists.openwall.com,
 Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>
References: <20190125173827.2658-1-willy@infradead.org>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <f1cd3105-2d36-a699-ed4c-e293d26b828d@iki.fi>
Date: Thu, 31 Jan 2019 08:03:54 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190125173827.2658-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25/01/2019 19.38, Matthew Wilcox wrote:
> It's never appropriate to map a page allocated by SLAB into userspace.
> A buggy device driver might try this, or an attacker might be able to
> find a way to make it happen.
> 
> Signed-off-by: Matthew Wilcox <willy@infradead.org>

Acked-by: Pekka Enberg <penberg@kernel.org>

A WARN_ON_ONCE() would be nice here to let those buggy drivers know that 
they will no longer work.

> ---
>   mm/memory.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..ce8c90b752be 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1451,7 +1451,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>   	spinlock_t *ptl;
>   
>   	retval = -EINVAL;
> -	if (PageAnon(page))
> +	if (PageAnon(page) || PageSlab(page))
>   		goto out;
>   	retval = -ENOMEM;
>   	flush_dcache_page(page);
> 

