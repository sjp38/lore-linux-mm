Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F106C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:11:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E42E321B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:11:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E42E321B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E4738E013E; Mon, 11 Feb 2019 14:11:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 893B78E0134; Mon, 11 Feb 2019 14:11:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AC2C8E013E; Mon, 11 Feb 2019 14:11:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC868E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:11:38 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a11so2062135qkk.10
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:11:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=3Ylyj4f77u1Z0/+nTrchC8+X0qbmTKEClAJ2rsDHakk=;
        b=DCQ26G4OPNPHe2/OgohGmtzhrNlOzi2PW5J7gAv5eEsvlVC2QbUWBB+s+W0iZYRb1G
         E49/Q9Qoq4uSMU1syynbREpvX62UzEFNTOPIwX9tbq/uaqEM0/wdCMe9Rdl4Y+ItLgmf
         YXBB35ZPNIVQVNN9SLhxc7VmV2h8Uj1oXqIMiNRy6I2QeXytzVZ6ikSuQSlssbAocnD1
         hGm/oVfgAF6uxuLUIHEh3oBWQbZt8x8g43FcDmkI5w1MIvPd0IZL+KcxDIaD53LdIN2e
         Sf6OL738sVHJ9juCtf4THz5+aqgkMLEg4KODCsDST0kasRry1yj3YY8cGb4wxTgjeimu
         osTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuY4+/G9zDklDVTcNkG4ggJnNAwYIvZ08XcADMK8LF2b+DDsr1o8
	L/26qI0MAMdhnGcynygI3KrMvr0lCMnsmeajYYlIILjNOt4s+GBMbCBaq7U2C5twyRly0iiA1jh
	yH2DcJd4Yqiq6dSAh5D6wht6x/clmns89140MkrW6MmSzS93QB9BM07OK3RfThgBa8g==
X-Received: by 2002:ac8:28f1:: with SMTP id j46mr3854785qtj.133.1549912298077;
        Mon, 11 Feb 2019 11:11:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYiFb5S9Ubx3s8PUF303noHoImP8nlrY8HbD9ywHmAisMP3RLYtrArEg+UJ7OulAAhSyto0
X-Received: by 2002:ac8:28f1:: with SMTP id j46mr3854745qtj.133.1549912297508;
        Mon, 11 Feb 2019 11:11:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912297; cv=none;
        d=google.com; s=arc-20160816;
        b=C9qMY2g8eTHPtYniMMrILEY5aBueol+AZUEqpQ5nYStodIW1x/U20a9Olcgbgnr/eu
         ugEiN96TEkIQVRLn+2SJJ5csxbPN5XfAw23/jE9feolJ1ZmgDs2X0Ho1U0bP+iJSWENh
         yyfPyDxFgVq2ftyo/OONqjEwHgMtZk6FgahvwJG4dx90j5pN3ab7nWUpBKV9KaPUs//2
         m17gcTSaIWliy8D2PsabdnQPq6l0uanpYHU9Mv20OwxSGrp/po3xTSmlfu0I5oyDFv/s
         6F4hgvTZ53A/MqeWg2UwNss+8sui2fXvlBdBcC4kXEHPhNbvB9r7Wo5glbcQZwvivonS
         3/Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=3Ylyj4f77u1Z0/+nTrchC8+X0qbmTKEClAJ2rsDHakk=;
        b=lauj8cGbbj5JMxdxp8Gsc2bLpuGABcMaJ0qUWB42oqfGBKhpokdO+97E3eqKyIWWhb
         BM93ITZkGn0u9kb7jmW6zvHOwrIp4K94mbg7R1csfVQH0z8YY3X48uE0rwFpacwkJLRj
         Ep4jKcMbpsiGUH+pgTyNcEQPgN19lPctJF0z9AtWnMUQn8mghYIxSnrGkzw0NL/sK6Rp
         d4jkBDPjnzjLwJCS0QqsNI/jZ5xPwGFTnc7dx9+lKUF55mG12j8j4IJxqikL7dxciuR+
         wzk5ETPZZ4pnZTypLvba2gv8c/x0BQCy/OM6YqIgdrTSSEP+owhAAISSmCh/naXeKeFJ
         UEHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e53si2511823qta.58.2019.02.11.11.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:11:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A398AC0669C2;
	Mon, 11 Feb 2019 19:11:36 +0000 (UTC)
Received: from redhat.com (ovpn-123-21.rdu2.redhat.com [10.10.123.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D43C5100190B;
	Mon, 11 Feb 2019 19:11:35 +0000 (UTC)
Date: Mon, 11 Feb 2019 14:11:34 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v2] mm/hmm: potential deadlock in nonblocking code
Message-ID: <20190211191133.GB3908@redhat.com>
References: <20190204132043.GA16485@kadam>
 <20190204182304.GA8756@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190204182304.GA8756@kadam>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 11 Feb 2019 19:11:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 09:24:21PM +0300, Dan Carpenter wrote:
> There is a deadlock bug when these functions are used in nonblocking
> mode.
> 
> The else side of the if/else statement is only meant to be taken in when
> the code is used in blocking mode.  But, unfortunately, the way the
> code is now, if we're in non-blocking mode and we succeed in taking the
> lock then we do the else statement.  The else side tries to take lock a
> second time which results in a deadlock.
> 
> Fixes: a3402cb621c1 ("mm/hmm: improve driver API to work and wait over a range")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
> V2: improve the style and tweak the commit description
> 
>  hmm.c |   15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index e14e0aa4d2cb..3c9781037918 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -207,11 +207,12 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  	update.event = HMM_UPDATE_INVALIDATE;
>  	update.blockable = nrange->blockable;
>  
> -	if (!nrange->blockable && !mutex_trylock(&hmm->lock)) {
> +	if (nrange->blockable)
> +		mutex_lock(&hmm->lock);
> +	else if (!mutex_trylock(&hmm->lock)) {
>  		ret = -EAGAIN;
>  		goto out;
> -	} else
> -		mutex_lock(&hmm->lock);
> +	}
>  	hmm->notifiers++;
>  	list_for_each_entry(range, &hmm->ranges, list) {
>  		if (update.end < range->start || update.start >= range->end)
> @@ -221,12 +222,12 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  	}
>  	mutex_unlock(&hmm->lock);
>  
> -
> -	if (!nrange->blockable && !down_read_trylock(&hmm->mirrors_sem)) {
> +	if (nrange->blockable)
> +		down_read(&hmm->mirrors_sem);
> +	else if (!down_read_trylock(&hmm->mirrors_sem)) {
>  		ret = -EAGAIN;
>  		goto out;
> -	} else
> -		down_read(&hmm->mirrors_sem);
> +	}
>  	list_for_each_entry(mirror, &hmm->mirrors, list) {
>  		int ret;
>  

