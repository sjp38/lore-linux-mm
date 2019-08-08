Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13D40C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:34:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9133B2189F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:34:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="Lf5+Mxhb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9133B2189F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 053276B0003; Thu,  8 Aug 2019 16:34:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 003BE6B0006; Thu,  8 Aug 2019 16:34:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E35176B0007; Thu,  8 Aug 2019 16:34:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2156B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 16:34:10 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id x19so18929080ljh.21
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 13:34:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=+bZQck0RMkLGxqQNS5jCLDjNYAJR+40kPw6DqiBJ6eY=;
        b=lVyd7jvNVsFzc4dJJcubUHp6NguzmhhrqJ/Fn2omAh1FANbaK61j6souLyxHSV4qer
         MqNNjABJjU/DPvY3OLccAtEpWZf7tJvf10+bpCG6RQ2MhdV+ucWXvAXZqvLnbJD8rP7B
         bFtHbCdSiI/p3hAf119DwWnv1f8YpGHL7VLuNKll4stvHuGdeQvaFsxQXJlRsmuJvFkg
         em3UEpOXuG/Vxle6zLtCrnaeIpMRhnlXQig32sQm/957lZ8+9mQCgCyel62XHEAnZvha
         G1AUJiack0f8VvgxobJ3/tDOeKJy/FZdijqm3pNoD06bRc0ofvUHRV0f016aLMKewmMg
         5Efg==
X-Gm-Message-State: APjAAAXveCTg5H2uEfsc3aIBO+c/UY5xEEdzLsPNo/X/WG4DLpwDsH0H
	kzGnu5JEDD6OMqdd/R8gPmjXTggXEZFXs8+NxVUpFDA7RLaDRr6R2dB1JFmMnZCi762vAlVIbOH
	S3kVNb2okVrF0Ujxl3B1/zZi7StUHkKg+o1rGy/alU/ivup8qRAwx8f8yaLpn+gcizQ==
X-Received: by 2002:a2e:1290:: with SMTP id 16mr8995129ljs.88.1565296449626;
        Thu, 08 Aug 2019 13:34:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFvMDVgSvLfissXWDJ+TyUsx3Sh2DTi4s7G22pTDCvJnHrIDvxUe68f7ayN1AfiD9i2PkA
X-Received: by 2002:a2e:1290:: with SMTP id 16mr8995099ljs.88.1565296448747;
        Thu, 08 Aug 2019 13:34:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565296448; cv=none;
        d=google.com; s=arc-20160816;
        b=xPUM82TeH8LsxdHTYzoWI2N17uuTIj7IvjWpStqRyU9Y5y/CpXhr8yfOKPQA+n4L82
         PLhzV+J4hKvyw1ZbjjD/GotPqbFMjvL238PSHqIInClWaQfZZ1qy+Q6lIHG8M9XgpUyE
         x4HkLDoLCHHW9rBWdjUh89VMKJyJsv9+qcFDr8rklAznxQo+VaXOFubRAgwvBb64igBL
         KtwZNEkbzxzQCW72ncJmTiwLgB7Jb/lHFu2mJTCcReSBDCM1lvSnknTaJfLvaGrRHs3v
         pVOxUn/VDK535ZWuD0Loj6cB0UJdxViEad1aA5Ov4V2L3+MOzy4jCzlRNahp45+ki0XA
         rR/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=+bZQck0RMkLGxqQNS5jCLDjNYAJR+40kPw6DqiBJ6eY=;
        b=SpwI+wWgnERh/9729hTQFEFskQFKzVZS9kkk+Txxpnayvd/b4gtOV/SphMlqGp6E53
         9vMBKqhjqcJ8wUITekrgi5RJaOwy9XaS1Q4L3vvGLPtGyZRtudXozZxsNu3Ti3AC6Db1
         tsr2p9cN7Y861NxiJDol4D0G5cWtAycjgLV8/HHx1rOBZHmZ7RyLPThJg8v2WMfHB+cX
         3IE1s/Mdv5i5rsULS8TBJVROAqHiKFVyjvMDVQtKeZVq75gmSVM4sWPpSSkwCBx43uLe
         2J2pZW1teDGH/8ZuNYoFGzwFWKNQHJTH6XFAOdsulGVYLhlapIsG0Fla6Kq5EywTN1EW
         jeRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@shipmail.org header.s=mail header.b=Lf5+Mxhb;
       spf=pass (google.com: domain of thomas@shipmail.org designates 79.136.2.40 as permitted sender) smtp.mailfrom=thomas@shipmail.org
Received: from pio-pvt-msa1.bahnhof.se (pio-pvt-msa1.bahnhof.se. [79.136.2.40])
        by mx.google.com with ESMTPS id d15si85335367ljj.171.2019.08.08.13.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 13:34:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of thomas@shipmail.org designates 79.136.2.40 as permitted sender) client-ip=79.136.2.40;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@shipmail.org header.s=mail header.b=Lf5+Mxhb;
       spf=pass (google.com: domain of thomas@shipmail.org designates 79.136.2.40 as permitted sender) smtp.mailfrom=thomas@shipmail.org
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa1.bahnhof.se (Postfix) with ESMTP id B14B03F5D5;
	Thu,  8 Aug 2019 22:34:07 +0200 (CEST)
Authentication-Results: pio-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b="Lf5+Mxhb";
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id N-GpX9dXhaTB; Thu,  8 Aug 2019 22:34:06 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id B78203F5A8;
	Thu,  8 Aug 2019 22:34:05 +0200 (CEST)
Received: from localhost.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id E0D65360301;
	Thu,  8 Aug 2019 22:34:04 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1565296444; bh=EIk0/MUpwLpbdNkCz481ROZL1qwhrG0hJX4BjHbekd8=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=Lf5+MxhbJc+lwsstwp0LgCIZkWOVlVZhKQueAOEsO3kwvFF8OliImWzJw26HVXTf/
	 PUGGY9SB6hV4Qh3dGW73STTF+vVQ5BqMuvG9UanaRrb8uTJbuZ+CSLxEvu9rTo6c1n
	 mm8RZL/XZ8xyPu1syz5148DT/U61+whiMp3kL398=
Subject: Re: [PATCH 2/3] pagewalk: seperate function pointers from iterator
 data
To: Christoph Hellwig <hch@lst.de>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
 Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190808154240.9384-1-hch@lst.de>
 <20190808154240.9384-3-hch@lst.de>
From: Thomas Hellstrom <thomas@shipmail.org>
Message-ID: <087f19ee-0278-b828-feb0-ff4a2c830a0f@shipmail.org>
Date: Thu, 8 Aug 2019 22:34:04 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190808154240.9384-3-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 5:42 PM, Christoph Hellwig wrote:
> The mm_walk structure currently mixed data and code.  Split out the
> operations vectors into a new mm_walk_ops structure, and while we
> are changing the API also declare the mm_walk structure inside the
> walk_page_range and walk_page_vma functions.
>
> Based on patch from Linus Torvalds.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

Typo: For the patch title s/seperate/separate/

Otherwise for the series

Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>

/Thomas


