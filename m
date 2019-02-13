Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 976D8C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:25:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59246218D3
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:25:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="N7fF38VA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59246218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06CB98E0003; Wed, 13 Feb 2019 14:25:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0D358E0001; Wed, 13 Feb 2019 14:25:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D857C8E0003; Wed, 13 Feb 2019 14:25:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 920D18E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:25:15 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id w20so2378899ply.16
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:25:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wp88X0n7T+oW/4jJeVP1LwxYcQsnaad4aiDkPEIVESg=;
        b=Q6ZKcA666fMI0eqQstnv2kdgEPYsvc966UonsYsKfScun0DtALFQpki47DBD/mm9bZ
         nmJzi2nmCZy/BsX7kvxq6W2ITSqGYaraRDEvW5Cdee3KQ+3/O7mWBwh+JTb2OleCCbgg
         d8rUax66dR894+HEpQHyenCq0q/dCCvBSCw+8CzKKvBnM7eoIsP7QaZ0WBJ6WKdN4WEd
         Mh9tib+3nkcMJRmX7+3v3Sdvies6nD313bGOKFrsct/iJaQqCNim0Mj6rRA7IiokyNNZ
         7DDzVNxRu93cna8k+8EvlSqE15/eM29Me1CzFT3gOj10YqUviB9wVmLHu8cJfjh3iNjn
         5+Bw==
X-Gm-Message-State: AHQUAuYfKkYfg/Z+7xpPcYGPxG9HtyE49jO4bHByHFtd8cdI3FzAdbf9
	NTeGJi+Lz/uV8s9+BEvMFQp6Ak/qOocS2JznZHDFh/c45F1129EtdQLN51fieDbdn4utRo/45DF
	thnFY/7agcAsR9Pcbpii6jyRAMLEiHjYFjJsOGjhauMQQLnrR+5kvgp4CB7E12ruZCQ==
X-Received: by 2002:a17:902:2966:: with SMTP id g93mr1979259plb.11.1550085915196;
        Wed, 13 Feb 2019 11:25:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY60IsFNyfKBPAR80YjnsnGhuP4AutGZ1BtS5IwAQYlq1DuyKo9PmmTvlsJxg8LBKhNZBC9
X-Received: by 2002:a17:902:2966:: with SMTP id g93mr1979204plb.11.1550085914439;
        Wed, 13 Feb 2019 11:25:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550085914; cv=none;
        d=google.com; s=arc-20160816;
        b=T1/d0PawrOuPDWWPRnZwXgr0C38cjRjC9YDnz/Jib/tIiAcT+Z2fi2Wc/kNnmDGsSR
         56C08RIs4kgdZ7h2Mv1S/YoKUuDw0oYIX5GUAEvnoIlqbw9Xs4olkHrG7Zcg2r2qYfzw
         tq+R8iYTy8yvr+EBYVwcUzb9pgG2wCOM1N+IAE+aRvdBWHUC209VpDnpJ1l4nIsX7q7v
         855a28ln4lqbZ8WDXS4k7YpX07PXeLqNq3GTFpbDiIkvQcSJVVUau3AUhNnQNe3IwTML
         ogF8Mc796/O+o7tkoR1b/v1Yzsrc6560TlH3L/zCzfuIJOpceV4ZFBzFTy2FXHNY0jcC
         WoBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wp88X0n7T+oW/4jJeVP1LwxYcQsnaad4aiDkPEIVESg=;
        b=EUpIjfFmgJ8N5BZVaQSf+gH6TiYuKXQWkrvDgbEiP8YtoipOZ0PUuHsK4cKtfcvkhj
         /RHcIgjzddsna5F426NkspPJUm1mWbK0X8iT/OlpF61YYg8r3F8OUBRP3Ur2EAGUJwIn
         zEQST3CvPrRvxf1E0X1uIdNFzqjn0+KbkMoKkEUkIw4H53ragr4rE634+4iF3RhNu5e0
         gEpmrYcqMAZHiL4GGd4zpwW0DRPiWoeki9g84jvywXxBnh1S+Nw2y89MYoV1IsieH5VR
         07frD6xNgdyeRbDemyvUOe3OhB3N4hrYAzaB0QDHiokRDvEHazw6e1wcSem5AoKZCqQL
         Nrnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=N7fF38VA;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z12si109076pgv.1.2019.02.13.11.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 11:25:14 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=N7fF38VA;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C36A0218D3;
	Wed, 13 Feb 2019 19:25:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550085914;
	bh=wp88X0n7T+oW/4jJeVP1LwxYcQsnaad4aiDkPEIVESg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=N7fF38VAjYGoMh9ztuD8OYJI6pSNlaXDcvqGOtmZqcF3KmSGICCypWjmmZdbbJ6ds
	 XMdtNXg2N7BuRK1HanA9BA+TyPVn5PJG619hBDoDDL6Bs+qhygWzSM2qwbIONM4LiD
	 Q2CYn/XxDXun2Fv3qnsJm1ly4G+iCSh1eZzGhw5Q=
Date: Wed, 13 Feb 2019 14:25:12 -0500
From: Sasha Levin <sashal@kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Amir Goldstein <amir73il@gmail.com>, Steve French <smfrench@gmail.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190213192512.GH69686@sasha-vm>
References: <20190212170012.GF69686@sasha-vm>
 <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190213091803.GA2308@kroah.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 10:18:03AM +0100, Greg KH wrote:
>On Wed, Feb 13, 2019 at 11:01:25AM +0200, Amir Goldstein wrote:
>> Best effort testing in timely manner is good, but a good way to
>> improve confidence in stable kernel releases is a publicly
>> available list of tests that the release went through.
>
>We have that, you aren't noticing them...

This is one of the biggest things I want to address: there is a
disconnect between the stable kernel testing story and the tests the fs/
and mm/ folks expect to see here.

On one had, the stable kernel folks see these kernels go through entire
suites of testing by multiple individuals and organizations, receiving
way more coverage than any of Linus's releases.

On the other hand, things like LTP and selftests tend to barely scratch
the surface of our mm/ and fs/ code, and the maintainers of these
subsystems do not see LTP-like suites as something that adds significant
value and ignore them. Instead, they have a (convoluted) set of testing
they do with different tools and configurations that qualifies their
code as being "tested".

So really, it sounds like a low hanging fruit: we don't really need to
write much more testing code code nor do we have to refactor existing
test suites. We just need to make sure the right tests are running on
stable kernels. I really want to clarify what each subsystem sees as
"sufficient" (and have that documented somewhere).

--
Thanks,
Sasha

