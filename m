Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77975C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:04:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 276362080D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:04:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 276362080D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C93138E0004; Fri,  1 Feb 2019 17:04:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C418A8E0001; Fri,  1 Feb 2019 17:04:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B329B8E0004; Fri,  1 Feb 2019 17:04:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFAC8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 17:04:11 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b185so8842703qkc.3
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 14:04:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=fv6+HW89O4XRO55ap5NsAJbxg1lz1SDZJB14NY7MH6E=;
        b=Od+PUMbBB/Mvp8C5+AeW7B/mHmXfzj9ZobWOyjbu8m9JQQqGCdjycYuHrUBZaW3Foo
         a43ArvgNdE4BVJmL9nPGbgoxtSbGyEK+PhgCqm8qcbDMbSYi/R8DYH3BtEEPKUYEzIp4
         NeAG6pcBJ+8Fa/Cb3ADnnueuQ5kgfKTcBb9iXvr149LtN97Ml/GXAt0jxWe/pdwwRC37
         G4HUZieMafcuYLzmj3YmALi7ZgLWJlYP7H33DgiD2mRRFqV2wlXUoruAbHafc+tQbwaV
         zeavxNLRj9xd0JKpTIiLpmphl/87bWEe9nObbFiMnmx7horSmWWMzIo7G0xMCohQ/1zs
         YSPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukc7BJ96wam7QdDN2hOt/Zeo5PXklyDMYUBIqjWcxSeDTUkw8nRY
	cD85d2sW4l6UvKq3ms1rCRb0xikuTr48VSw0ZYv9goTmETMbS8cVWsltmgqIUi0RNGBoB0TNZvY
	M/EuLXmaIFjzpW2CoftAQQe+1Uboz4GoYy63op0UThk/pRv8FQi6/0zEkAy2PMZ6FCA==
X-Received: by 2002:a37:b201:: with SMTP id b1mr36465528qkf.306.1549058651255;
        Fri, 01 Feb 2019 14:04:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7ZN0NttKqE4CKw8BOvMVmoFvu25qP0FvIJr7Y7f+GW8mC0GD0+WGZLvjgeHHHdlGMy6ihZ
X-Received: by 2002:a37:b201:: with SMTP id b1mr36465508qkf.306.1549058650694;
        Fri, 01 Feb 2019 14:04:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549058650; cv=none;
        d=google.com; s=arc-20160816;
        b=kMk2MjrP4xiSQkChd6bAfyxD9DZFgxTLCy+GsrnOHkl9KzlbTrCfaNtDwBongrU1zl
         CVELho8amTpxG/EyCBBMAYtp0aUvqkJPYHqTH5L8HQlnDFmYvqeBtADe8ncTie3eoB+3
         3qXP0/dQRUIa8ZiG4wA+mFF9TOHCdK6tmwFkehPCSkTS7Dx4rPPcpyEVd9s3iKKd32TX
         uOSQufotXyqeInBfUJ5FiYTtWG8Ac9YEOY5VBMFmlvnyHBLkdSwQDTHmyP0Fdj4D2SHA
         BiT1wydRm8u/JvJG4N+EiE6BeAfAjhFdMo2TeQNQEAGWhWo+hgDAdVokesb9NOfuZ6eB
         cJmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=fv6+HW89O4XRO55ap5NsAJbxg1lz1SDZJB14NY7MH6E=;
        b=xujZmxB7numD/MAMLNVxXTSuG4kKJIEgZDYmj+Loe2Qb3irR/Xbg+yYVUaetfs4pxg
         7MO4npVSgwppSBFNjTLwDa3Qi1AETV9cu7ylrCE3x9uDLHar9l78RD0/btWus6JNvTPp
         y+IoOqy/3OhofDFQMF2/CBxgSgs5SGyRaY1Mafzc4imJup8SvBnql+rgQEgSs7bsBvYR
         fyi8LCyAjs9W3dbPWK4nKR6LLnpdgyWkTCC2Q7cxMRJq/hOUDJnKUzyxUz9WgigxqC9C
         jErlaN9Z19WAz87cqLuE8ACIFLaJAYs8aRSV8V515jubzMl1ab8WNkJ74HCy7tE4yxEn
         NU/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h21si401902qtq.120.2019.02.01.14.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 14:04:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E0D52C7914;
	Fri,  1 Feb 2019 22:04:09 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D1CB75DD83;
	Fri,  1 Feb 2019 22:04:09 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id BC7D218033A2;
	Fri,  1 Feb 2019 22:04:09 +0000 (UTC)
Date: Fri, 1 Feb 2019 17:04:09 -0500 (EST)
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, 
	Linux Memory Management List <linux-mm@kvack.org>
Message-ID: <1540410520.100356979.1549058649241.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190201134737.9eaf0c69dc2584d2dc4ec4cc@linux-foundation.org>
References: <201902020011.aV3IBiMH%fengguang.wu@intel.com> <20190201134737.9eaf0c69dc2584d2dc4ec4cc@linux-foundation.org>
Subject: Re: [linux-next:master 5141/5361] include/linux/hmm.h:102:22:
 error: field 'mmu_notifier' has incomplete type
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.10.122.133, 10.4.195.29]
Thread-Topic: include/linux/hmm.h:102:22: error: field 'mmu_notifier' has incomplete type
Thread-Index: +loyCIqpBK5PuMpVD6qV77jieoY78Q==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 01 Feb 2019 22:04:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sat, 2 Feb 2019 00:14:13 +0800 kbuild test robot <lkp@intel.com> wrote=
:
>=20
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next=
.git
> > master
> > head:   9fe36dd579c794ae5f1c236293c55fb6847e9654
> > commit: a3402cb621c1b3908600d3f364e991a6c5a8c06e [5141/5361] mm/hmm:
> > improve driver API to work and wait over a range
> > config: x86_64-randconfig-b0-02012138 (attached as .config)
> > compiler: gcc-8 (Debian 8.2.0-14) 8.2.0
> > reproduce:
> >         git checkout a3402cb621c1b3908600d3f364e991a6c5a8c06e
> >         # save the attached .config to linux build tree
> >         make ARCH=3Dx86_64
> >=20
> > All errors (new ones prefixed by >>):
> >=20
> >    In file included from kernel/memremap.c:14:
> > >> include/linux/hmm.h:102:22: error: field 'mmu_notifier' has incomple=
te
> > >> type
> >      struct mmu_notifier mmu_notifier;
>=20
> I can't reproduce this with that .config.
>=20
> hmm.h includes mmu_notifier.h so I can't eyeball why this would happen.
>=20

I am on pto, i will try to look it over in idle time can you send me
the config, or can i download it from somewhere ?

If i had to guess it is because this random config enable HMM without
any of the other HMM bits so adding: select MMU_NOTIFIER to config HMM
will fix it.

Cheers,
J=C3=A9r=C3=B4me

