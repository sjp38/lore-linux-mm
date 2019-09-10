Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF7F8C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 23:28:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87F9D21A4C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 23:28:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="wjegl/rm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87F9D21A4C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2626D6B0005; Tue, 10 Sep 2019 19:28:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E3BB6B0006; Tue, 10 Sep 2019 19:28:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D2866B0007; Tue, 10 Sep 2019 19:28:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0188.hostedemail.com [216.40.44.188])
	by kanga.kvack.org (Postfix) with ESMTP id D9B376B0005
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 19:28:10 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7DC0C282D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 23:28:10 +0000 (UTC)
X-FDA: 75920601540.17.head28_d1b50504203a
X-HE-Tag: head28_d1b50504203a
X-Filterd-Recvd-Size: 4302
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 23:28:09 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id f2so12526756edw.3
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:28:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=oUUiNhAYgPVa+n7rcOh1w/3vTVOmNb/c0QUr1wlOjPY=;
        b=wjegl/rmzf8chnaU019SF3I2nksqjHCqVQUT0QuBjb3JPJPcYocdDAbW8IPyAecfon
         bF4eA333m0GTTmtXYNoHHCvQDXs3E+UwlM+Ft86PX+D4IN/L7v6UK7/My3vmxic45fNE
         NF4gkJ8Y+jJ9gnx0kCR6gAchhD9Hr43jtUbWrtDAAUbOl16x1BJ4hcTMvKikrTLsMmR7
         UuqPQcJ1AqVnlPAyq2lVthpgEFeOzOULF8XEzk9zCKQHTgIIttFlSPIUwnxxS0K1lLIb
         aO0yBWSy45Zdhmtg9V+OSduCMutLdBIyEUs2Zjfw9//kJOaIBCClFwonz35vyuyuVpcq
         6yEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=oUUiNhAYgPVa+n7rcOh1w/3vTVOmNb/c0QUr1wlOjPY=;
        b=KbNTUpS7uarjL3ZFlJOukzacuqqvuTN1xsyKvUqALgsyx1fjuwAcXYs10YG2FYjNxx
         JehPC/R3ZEDv/SNocYNlw0GLvprrA/vQYrwrzNxNTRnkTDZvfv7cYPsIhRmwflsOYLau
         c+c51SP1Uv1yD7DHpZNVV5Jj3JJEAm5EQE/ExQDNl3hurTqcKEYLgygjHNvM5g84w0kC
         7KAgzUJxROrz6lXpR6sLi8pSp/54R/v9YbDFEpCZHMYjKiEzLQ96MAOogpBojYlfBTjP
         938Je+xRCql9OjhyiAiVVpyh4yPC1677DBWgD0l3OUZVwL88e0DNouvIQpdzyncUjA5z
         lWJA==
X-Gm-Message-State: APjAAAVCwEqvhwHpee67oIoWaTHM/2GVPFT17FCMm1PV2UeQex/iIbd4
	RDyMjsixEht4f9RhZcm2E2pZyg==
X-Google-Smtp-Source: APXvYqxIYXwCm1ysIUJX5goc665k32cmNg/KGwTO7CHaXMMTfsiMvJkopxE/Qr0Exzy1/emo2Kf5/Q==
X-Received: by 2002:a17:906:3446:: with SMTP id d6mr8523490ejb.244.1568158088641;
        Tue, 10 Sep 2019 16:28:08 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id ns21sm2252371ejb.49.2019.09.10.16.28.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Sep 2019 16:28:07 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 5C20E10416F; Wed, 11 Sep 2019 02:28:08 +0300 (+03)
Date: Wed, 11 Sep 2019 02:28:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Mike Christie <mchristi@redhat.com>, axboe@kernel.dk,
	James.Bottomley@HansenPartnership.com, martin.petersen@oracle.com,
	linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-block@vger.kernel.org, Linux-MM <linux-mm@kvack.org>
Subject: Re: [RFC PATCH] Add proc interface to set PF_MEMALLOC flags
Message-ID: <20190910232808.zqlvgnuym6emvdyf@box.shutemov.name>
References: <20190909162804.5694-1-mchristi@redhat.com>
 <5D76995B.1010507@redhat.com>
 <ee39d997-ee07-22c7-3e59-a436cef4d587@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ee39d997-ee07-22c7-3e59-a436cef4d587@I-love.SAKURA.ne.jp>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 07:12:06AM +0900, Tetsuo Handa wrote:
> >> +static ssize_t memalloc_write(struct file *file, const char __user *buf,
> >> +			      size_t count, loff_t *ppos)
> >> +{
> >> +	struct task_struct *task;
> >> +	char buffer[5];
> >> +	int rc = count;
> >> +
> >> +	memset(buffer, 0, sizeof(buffer));
> >> +	if (count != sizeof(buffer) - 1)
> >> +		return -EINVAL;
> >> +
> >> +	if (copy_from_user(buffer, buf, count))
> 
> copy_from_user() / copy_to_user() might involve memory allocation
> via page fault which has to be done under the mask? Moreover, since
> just open()ing this file can involve memory allocation, do we forbid
> open("/proc/thread-self/memalloc") ?

Not saying that I'm okay with the approach in general, but I don't think
this a problem. The application has to set allocation policy before
inserting itself into IO or FS path.

-- 
 Kirill A. Shutemov

