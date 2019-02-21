Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A219C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:34:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 638B82075A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:34:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 638B82075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 182E58E008F; Thu, 21 Feb 2019 10:34:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 133418E0089; Thu, 21 Feb 2019 10:34:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 020438E008F; Thu, 21 Feb 2019 10:34:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B70048E0089
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:34:19 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j13so989510pll.15
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 07:34:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XPqRx3G1zDibY5f11Kqd711bReAyQUyuceYskmJlDgk=;
        b=Iqrj4pIvk5S36pgGyogBBZXK7B87/WL53d7TV8GyMWG05ttHhYpgixaOZgyOz1iBVe
         RxnjJQYcUHFid48/ckkNf1EHzFE6/NuArfy+ETaQS90YBapwNq5LOA5C6SR4LIfJhCD8
         gDnwDerDlRB4UxOgh2tHZ3A8dQmkv0NGo2BcA5oyK5qmFf8vlP52swAgqFTgUwqwcMcF
         Psh5P0D5CXHh4wz1vdNHe5ej/uRfOEvr4PiMmq2NAxUVOGid0KZkZU728sEfxEQjmISp
         oGwwdN+yjPcaYOQKplTl95uagnVUCvkKmA9nyNcF6j4EryD9oI03iIa2oHlxdCDDacpd
         b5/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZqZRu3X0RRV0R9W+GI6kN1Frt6Ae5oXBxvQLGwOmqiyKl2ewqV
	qYK1OS0Wk5vSeXTLmgvuOaYbscnbNdDS5YpuRrSwzYH5Ett95ubsbWNjBqr4CKZpsSGm3+JKuEo
	U9lNz9KQEBIl/E1PwfUVuDaVKK5PO4g4ljDM+0QYVU0j6L+YfUKEjcqr2wrWht9QjEBwcvWKhq3
	D5BKfnx33afclYPH+kvXjk9zfoDxtThNLwnflmHQRLzCrlZH9xAqk6J/htI7afgEiao3iK8r6gU
	WmdUPpyCFNQP/jtiSaTNw4QDqw+hf0fUQni0/dBxB6Teln9kBRYSUOLoJC87Zi9Ujfc5HgMp4J+
	NiRKPNhc+whnt7ajxduNe+AoYV1TYW6FFTWLdWSQoK4y0Pxuhg2BfLCMnRxrojQHc1ErbMXSDg=
	=
X-Received: by 2002:a65:46cf:: with SMTP id n15mr35538612pgr.187.1550763259453;
        Thu, 21 Feb 2019 07:34:19 -0800 (PST)
X-Received: by 2002:a65:46cf:: with SMTP id n15mr35538549pgr.187.1550763258669;
        Thu, 21 Feb 2019 07:34:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550763258; cv=none;
        d=google.com; s=arc-20160816;
        b=09zuZCOJILMNbU3RUQBmXn1croWUWWOSTeY9DxvqCGh2xPI4lxBkQuUTERhMECyWFR
         GAWdXTo9YMnZeZVjlZCRUjDRcFVFgYCdNiY3bLz7tEl5h2GFmcTOR4YvzdxACbx0JMYE
         oAadBjJqci9F0dDGVqEisvijB/24FTwnGcslNLbTxSUa3jm1W6Tr8CkbsEyivkGBfjz6
         TOBHZntr455grK4TqwQCGV0BqEkRDQr0QP5ihl4UUpF6CfurfaYwIOOf9yrcHlWB0Wve
         lQ5XgiYQyhUdaw3PWaHVEvRi8MydD9fcDAMLWCUMdlmHLD59dJAuiCGYG9d3lcGLJDuI
         /reg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date;
        bh=XPqRx3G1zDibY5f11Kqd711bReAyQUyuceYskmJlDgk=;
        b=n0CC3DOkBMPBVg92dOKARfxKIxDlfTjx9lm0Qs3Ald/agVdIhxiRAJMLgAWzow2T8X
         Fb5ElK5+0jCdDFg3CvmXnLfYPrL3cMRj2rjB6vUtj3a7+mbspw7NjyJ9Vm23OBkmwszm
         wanTD2EIa5i+Of13tloOUxsctnCJsD3lFZnVHnGR5yB0xzJlHTplLvlb9ppJgaL5HzxR
         HxeuAKljycj8i+KHSq92pck8SuxkiT/P8rAr3eIfxyUAHp5dWf5O35BLbOg6OH1r6lfO
         6JNSoZqkJnG3pPtZwrlnjM5v3AK6pOmr2Nm+hABbtIy5v/UDoFr32NlxdRreGG0gf4Hd
         KscQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j8sor34992213plk.53.2019.02.21.07.34.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 07:34:18 -0800 (PST)
Received-SPF: pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbQhHLkj+rQEswB+BoVSLMBa9mIIZ3HP92lYutjhoqXwJf0K2FXjHuJFvPPK+SFR0rkJuuRpA==
X-Received: by 2002:a17:902:9003:: with SMTP id a3mr15817741plp.2.1550763258257;
        Thu, 21 Feb 2019 07:34:18 -0800 (PST)
Received: from garbanzo.do-not-panic.com (c-73-71-40-85.hsd1.ca.comcast.net. [73.71.40.85])
        by smtp.gmail.com with ESMTPSA id a20sm34713724pfj.5.2019.02.21.07.34.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Feb 2019 07:34:17 -0800 (PST)
Received: by garbanzo.do-not-panic.com (sSMTP sendmail emulation); Thu, 21 Feb 2019 07:34:15 -0800
Date: Thu, 21 Feb 2019 07:34:15 -0800
From: Luis Chamberlain <mcgrof@kernel.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Sasha Levin <sashal@kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Steve French <smfrench@gmail.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190221153415.GL11489@garbanzo.do-not-panic.com>
References: <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com>
 <20190213192512.GH69686@sasha-vm>
 <20190213195232.GA10047@kroah.com>
 <1550088875.2871.21.camel@HansenPartnership.com>
 <20190215015020.GJ69686@sasha-vm>
 <1550198902.2802.12.camel@HansenPartnership.com>
 <20190216182835.GF23000@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190216182835.GF23000@mit.edu>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 16, 2019 at 01:28:35PM -0500, Theodore Y. Ts'o wrote:
> The block/*, loop/* and scsi/* tests in blktests do seem to be in
> pretty good shape.  The nvme, nvmeof, and srp tests are *definitely*
> not as mature.

Can you say more about this later part. What would you like to see more
of for nvme tests for instance?

It sounds like a productive session would include tracking our:

  a) sour spots
  b) who's already working on these
  c) gather volutneers for these sour spots

 Luis

