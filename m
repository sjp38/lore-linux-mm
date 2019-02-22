Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46F36C00319
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 02:01:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B5FA20818
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 02:01:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B5FA20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EA328E00E5; Thu, 21 Feb 2019 21:01:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BEB18E00E2; Thu, 21 Feb 2019 21:01:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8865B8E00E5; Thu, 21 Feb 2019 21:01:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 584E98E00E2
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 21:01:40 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id y31so820309qty.9
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:01:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rn5+FTxZ/nkyRt8W9CCUYoMZdjHRohc6I4eCG814S40=;
        b=JjOK9oj7UJC67zk7w/pa9XdWype7pstBXAjn2sGsfS0IyaCdDOiWYJQSrH/FAXIvOu
         cM6LmvPKS920DlKHKexbCJxdEiQja9SjDZfGYwrV8CHyYuYSDZPBsjCDfpCSu6vRO0VK
         8RUSxnZ3893regwrAF8c95pr2N3EDjw+N5U81OuvC/HloLSkAD1+UOWCQXNrXmFq9b1S
         YpVfVyVhox5XC5LQzuHF2yxoUIJtTAxVlbx9+YOiv37brBaGwuObSJvp/SmTBxI2nyGL
         sTO85ZNTvHw/to9matsg3FpW7O3wAGlNIbQwYTLeZo51eTV2+1eX83k4QsFdXdpBm7dR
         WJFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub1CeKmVTk1HHrNm0GZkhaiOWFNuZHiHjzcPXRif3fyNDlvCYvw
	z7tcCnDc7kwde8Nr9dX5nmot26U9+YR+AOrJ0BXTk6NN51KKtHfgDQOBSEx8Unpmk4knI+QQUfV
	sXmSFGu45e4RkIyQjKddEnQG7gDm6IngP8VC4wY+2BzDOrEWONMXsp0p7Exivp8MTeA==
X-Received: by 2002:a0c:879c:: with SMTP id 28mr1266271qvj.63.1550800900153;
        Thu, 21 Feb 2019 18:01:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZMdn1rXS6zvHXFJzr25aDyGbW7DWPcp5E1q5Zjlsf9km79OGEBDtz/bMxXVMIbeyJnLzUd
X-Received: by 2002:a0c:879c:: with SMTP id 28mr1266239qvj.63.1550800899503;
        Thu, 21 Feb 2019 18:01:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550800899; cv=none;
        d=google.com; s=arc-20160816;
        b=F8XkgfptWCvemu2eYD1GrGOW52cm47uqK9SvkztDvReU9XJidoD1fEfb/WxYRabzqm
         LhfxN0vL8SenOgS0qobIjk4aG4TAlGPRp2hI5VfmUm87zhQDHuwStvOWe63mXi4FXFpr
         FKrgTxHtV10drP6s43ErLFVWjTlbwzZ6FYFtO54BpMW1Tb+QI8YrUPxHZOK3mge6m77+
         BmP7W2ieCvVKOtqfDYeJAmhXphucP7vKrvyVIxhpmtVPNQ+XjVh86iQErkUIIjWQIO82
         PwTY6q9vKNvUXL3uaiho6p4AwqCh2PkwullrCZ+QAwP+13wOunOwCjbXsihs9mFvacxB
         Pwug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=rn5+FTxZ/nkyRt8W9CCUYoMZdjHRohc6I4eCG814S40=;
        b=qe6C9LfjLrqv5tcuzwCtJU97JvzntIjcKJjQPUN+YAILFqws5TADJE3yd2DKBOLTrl
         qrIucW70/zTfARpzcjxJNY31sUgvl4iQJPJESLjPf73kzvSmcOvHlB2jTarhUt4T2eo+
         m+ggFKs8hYM/dvD3PJM7CmE5sF/oT0dMYImjG7wybOjn3+7FJePv0X7rLAu7a6NYZTL6
         +jzM6iLWeMNLQ8UujvVWDxBA3JY/elsqm5BhLauiZgVQd/UmWj5dfeC57IYo8PeIjdTf
         6xfnfsxwoRt+U8+IJAVtrfmQSt2iXa9lYAkQL6x2hbXxoIhks4NAn7y3hHoQ15rhTpyi
         ArWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k96si91062qte.13.2019.02.21.18.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 18:01:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 70C098762D;
	Fri, 22 Feb 2019 02:01:38 +0000 (UTC)
Received: from redhat.com (ovpn-120-13.rdu2.redhat.com [10.10.120.13])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0FFBD19C58;
	Fri, 22 Feb 2019 02:01:36 +0000 (UTC)
Date: Thu, 21 Feb 2019 21:01:35 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Haggai Eran <haggaie@mellanox.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Aviad Yehezkel <aviadye@mellanox.com>
Subject: Re: [PATCH 1/1] RDMA/odp: convert to use HMM for ODP
Message-ID: <20190222020134.GC10607@redhat.com>
References: <20190129165839.4127-1-jglisse@redhat.com>
 <20190129165839.4127-2-jglisse@redhat.com>
 <f48ed64f-22fe-c366-6a0e-1433e72b9359@mellanox.com>
 <20190212161123.GA4629@redhat.com>
 <20190220222020.GE8415@mellanox.com>
 <20190220222924.GE29398@redhat.com>
 <20190221225937.GS17500@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221225937.GS17500@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 22 Feb 2019 02:01:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 03:59:37PM -0700, Jason Gunthorpe wrote:
> On Wed, Feb 20, 2019 at 05:29:24PM -0500, Jerome Glisse wrote:
> > > > 
> > > > Yes it is safe, the hmm struct has its own refcount and mirror holds a
> > > > reference on it, the mm struct itself has a reference on the mm
> > > > struct.
> > > 
> > > The issue here is that that hmm_mirror_unregister() must be a strong
> > > fence that guarentees no callback is running or will run after
> > > return. mmu_notifier_unregister did not provide that.
> > > 
> > > I think I saw locking in hmm that was doing this..
> > 
> > So pattern is:
> >     hmm_mirror_register(mirror);
> > 
> >     // Safe for driver to call within HMM with mirror no matter what
> > 
> >     hmm_mirror_unregister(mirror)
> > 
> >     // Driver must no stop calling within HMM, it would be a use after
> >     // free scenario
> 
> This statement is the opposite direction
> 
> I want to know that HMM doesn't allow any driver callbacks to be
> running after unregister - because I am going to kfree mirror and
> other memory touched by the driver callbacks.

Sorry i miss-understood your question. Yes after hmm_mirror_unregister()
you will no longer get a callback from HMM ie it is safe for you to free
any data structure associated with HMM.

Cheers,
Jérôme

