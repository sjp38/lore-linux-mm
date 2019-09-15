Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E66CC4CECE
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 20:24:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C39B214C6
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 20:24:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Lromhxrg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C39B214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 943E96B0003; Sun, 15 Sep 2019 16:24:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F3186B0006; Sun, 15 Sep 2019 16:24:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 808466B0007; Sun, 15 Sep 2019 16:24:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5B79A6B0003
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:24:37 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id EEBC352A1
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 20:24:36 +0000 (UTC)
X-FDA: 75938282952.05.cub18_b2542bbb3e01
X-HE-Tag: cub18_b2542bbb3e01
X-Filterd-Recvd-Size: 2667
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 20:24:36 +0000 (UTC)
Received: from sol.localdomain (c-24-5-143-220.hsd1.ca.comcast.net [24.5.143.220])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 125AD214AF;
	Sun, 15 Sep 2019 20:24:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568579075;
	bh=LCVK2aMgwTZJzb8J63CkOjhrW0RaVm+XZQ9QcWk8u64=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=LromhxrgzgBiWiRCWifYke78su7FoAeFk4hbabgMD3j1OY6I9lhHsv4j7lLe+hR8F
	 IKDuRV1fnXI2+eGX1ZZ9vk4p1Uh1DSEbxGugPzhHZiCDEVAGazw+dCaOy9n9lxcf8I
	 uSQcy/lO1NXYFgdb7hVEa77AxizYUGFADjSSyKTM=
Date: Sun, 15 Sep 2019 13:24:33 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Janne Karhunen <janne.karhunen@gmail.com>
Cc: linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org,
	Mimi Zohar <zohar@linux.ibm.com>, linux-mm@kvack.org,
	viro@zeniv.linux.org.uk,
	Konsta Karsisto <konsta.karsisto@gmail.com>
Subject: Re: [PATCH 1/3] ima: keep the integrity state of open files up to
 date
Message-ID: <20190915202433.GC1704@sol.localdomain>
Mail-Followup-To: Janne Karhunen <janne.karhunen@gmail.com>,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Mimi Zohar <zohar@linux.ibm.com>, linux-mm@kvack.org,
	viro@zeniv.linux.org.uk,
	Konsta Karsisto <konsta.karsisto@gmail.com>
References: <20190902094540.12786-1-janne.karhunen@gmail.com>
 <20190909213938.GA105935@gmail.com>
 <CAE=NcraXOhGcPHh3cPxfaNjFXtPyDdSFa9hSrUSPfpFUmsxyMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE=NcraXOhGcPHh3cPxfaNjFXtPyDdSFa9hSrUSPfpFUmsxyMA@mail.gmail.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.007646, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 10:04:53AM +0300, Janne Karhunen wrote:
> On Tue, Sep 10, 2019 at 12:39 AM Eric Biggers <ebiggers@kernel.org> wrote:
> > > Core file operations (open, close, sync, msync, truncate) are
> > > now allowed to update the measurement immediately. In order
> > > to maintain sufficient write performance for writes, add a
> > > latency tunable delayed work workqueue for computing the
> > > measurements.
> >
> > This still doesn't make it crash-safe.  So why is it okay?
> 
> If Android is the load, this makes it crash safe 99% of the time and
> that is considerably better than 0% of the time.
> 

Who will use it if it isn't 100% safe?

- Eric

