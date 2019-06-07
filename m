Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9895BC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:42:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4330920840
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:42:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="fOBioA9m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4330920840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2B0F6B000C; Fri,  7 Jun 2019 09:42:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADC9E6B000E; Fri,  7 Jun 2019 09:42:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97E526B0266; Fri,  7 Jun 2019 09:42:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 74D9B6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 09:42:30 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so1865264qte.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 06:42:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GnW/twM6MkT3sK1ZhrwgxUqvD0LPiRdOubIMmtxqWdI=;
        b=GPyghgpQm7nMCyM2y1DsS/mPb6vsuzZRMFb28hAb1889AGTgxF0dCUncpIvKZwRuIB
         63lNgf22wvGvr5Ok8Rl9lgAqVcQKfFbraSn4uneZ/IhWJHrAotJilhuUryFoRiQRYopH
         93pSaApdtSxY8MnYJRF3MLYFCvaRjIa91kUQgsgsIVvJEvVpKN/ExrJqnWxRTBI6Dpj4
         oskwUxL6cvs2QqqV/15oJSiX20i4iot/ZCqjCt+3tCk3SNcWxLR2iCQz/sCA6ijhRbeC
         30nQZAzjR8IzW2d/ldbHd+DS19UIhAP2F37IqW9vhhM4bDOjvqvHLO1KZprOW55ks/X0
         VE+w==
X-Gm-Message-State: APjAAAXflgTxaeTlplIb1cXS2T2e998e1hbf9L01bGPvbOg1IPB1XILF
	NeemfAdxCjclf7b4XuPapK/DmBC2QPPI7SPx2JjeX+Byd1k8goke7rXjb/R85JbDiZAFM024C70
	JXgysVK+SRJEIEhQG5drYBUPy5wZfAM4NpY3M6UH/s0v3nm6XTw4vZBhMJXDpBevdDQ==
X-Received: by 2002:a0c:88c3:: with SMTP id 3mr24974462qvo.21.1559914950272;
        Fri, 07 Jun 2019 06:42:30 -0700 (PDT)
X-Received: by 2002:a0c:88c3:: with SMTP id 3mr24974435qvo.21.1559914949790;
        Fri, 07 Jun 2019 06:42:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559914949; cv=none;
        d=google.com; s=arc-20160816;
        b=qD1ZAAqcNyFD+ZPPLAEF1wlC6M4LsrvzVxMiZQSnD4Pb3OqAXOgqDk/VStLKAw/Xrl
         kGae78z0xq/G9yMLx2udCiwDwOxYiI4Zf8dd5WREGrBNN7N91hIdevKOcRIcccG0q4yO
         YpY3PMCTnRfDm1YIbJdM8t1e2oqwPB+qXkgC5ARv746Irvw5rrQzvymVjKAJoD0+/4U0
         rjWfbnLHL7ySzptTSyWebyR+8IUm1CVkQy0oZvCHyNGZ9RFbyC0xG8315+6jAZaYXfjY
         sF+Vtt5y6s9JmtC9OMJb3ZOdgIbml6PB37ERXh+dA+lF4PVQm83GVtjVR221B/m1fwfa
         r6WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GnW/twM6MkT3sK1ZhrwgxUqvD0LPiRdOubIMmtxqWdI=;
        b=W/VQPz7PJUIIsBakvWAV4JfrWE5U9nNnYXgvkY0wIIHciKR/DT4YTcQ86kS+M/b8ku
         ZG3ibJtrCzknYzk1IdDvJs/IAY70uNAadG9jSFGjlEKBrsQQK8nkecusa7Zd/EotpWd4
         cWGM4byLQRKdTQ6EsHgc7o9rBM3objy/NtjYxgf5mcihj5RCC/bZQJiksJCNu4Ez285E
         SVJvx2qf1gV4JJyxzLEy8f2a+WNizhk8uEdl5/at3GApfxFibQQw1PvyIoH+8oFafQHB
         fWtmooX366P8TXJg7iDw8eK7WPKaFxGxV5/Yxp9R6dPBkg2qYBYtjMhBHuj/Rirb9cT0
         qB7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fOBioA9m;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r30sor2333778qtr.64.2019.06.07.06.42.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 06:42:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fOBioA9m;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=GnW/twM6MkT3sK1ZhrwgxUqvD0LPiRdOubIMmtxqWdI=;
        b=fOBioA9m9PbWefjn1DmJWxfFXCC2dztfbWTo9BaFpc1JJx99fsn9by4LkHonqKcFmM
         d/2SspLVs5CoByQJzhZGvsoKTPp5pbaAMXH/Y3xnQgNd85ur/14fqcJt/zQPtZRGnhan
         hRpZi3W37HzqC4a9zJzl2YUJbc3HDrINupGkFqNcTc57YBA+twb6v9h7pN4lWFUIZh/5
         fXWs4cmg6a6Z4mz+q5dP4OTA32NAxXoy6nmukwYHw4QH3BhKt9SZ5xtA10sXK/+ww6j6
         Rpga877RogkeluQhFKwv8FEazUzN2dRczANS+ORbtBYTcceCE2B/jT2rHsQls1Rwme7b
         Lo6w==
X-Google-Smtp-Source: APXvYqwsAceJbR30iBQCPsJ2106L5t6QxNp2dZRUeMJkrJIRo66xTGleQFJNlMPYL+7b91XqCDSsBw==
X-Received: by 2002:ac8:3811:: with SMTP id q17mr17943650qtb.315.1559914949560;
        Fri, 07 Jun 2019 06:42:29 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m66sm1104947qkb.12.2019.06.07.06.42.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 06:42:29 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZF8W-0008Kq-EF; Fri, 07 Jun 2019 10:42:28 -0300
Date: Fri, 7 Jun 2019 10:42:28 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 01/11] mm/hmm: fix use after free with struct hmm
 in the mmu notifiers
Message-ID: <20190607134228.GG14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-2-jgg@ziepe.ca>
 <9c72d18d-2924-cb90-ea44-7cd4b10b5bc2@nvidia.com>
 <20190607123432.GB14802@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607123432.GB14802@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 09:34:32AM -0300, Jason Gunthorpe wrote:

> CH also pointed out a more elegant solution, which is to get the write
> side of the mmap_sem during hmm_mirror_unregister - no notifier
> callback can be running in this case. Then we delete the kref, srcu
> and so forth.

Oops, it turns out this is only the case for invalidate_start/end, not
release, so this doesn't help with the SRCU unless we also change
exit_mmap to call release with the mmap sem held.

So I think we have to stick with this for now.

Jason

