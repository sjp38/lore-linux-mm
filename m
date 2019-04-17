Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B1AC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:26:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33D7720675
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:26:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33D7720675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF2156B0005; Wed, 17 Apr 2019 14:26:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA0806B0006; Wed, 17 Apr 2019 14:26:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB59F6B0007; Wed, 17 Apr 2019 14:26:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B94D86B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:26:23 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x58so23478912qtc.1
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:26:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=EcVQqbPsBLazfmwcePHB1XP40c+WrTsPFIhUq7aOyRc=;
        b=anaqRcLYBuxyfisDyF2tPekwzjaWL/KRgzkFK+wMr/+JNpVBjchw4Pz8cbvdo182Lk
         ZTImNFzWBF8gNeAHD8zdaExhhTXsbMoUrOr7nQpZHKOdp8DueE3ttRidKMY/0Q43BUNx
         WjyAMrvnWnHiWao4T0jqP3GurrADwBEBFvM9lJTfRCUZ8DG7YcQav4JTay8PDysmdW+y
         uE3rZ6D2ffrTGKuUX4pAarMpUCOZpLiDHLUe6gFx14CnV0IsAWXVrC+Re2sAGkoVdjIh
         l7AgtiKENvdVeNGtp0ZFzv0zNrYJu3mjApq9XPwukrxGQQsRTANhXfhCPEs8usvh+a5i
         ZrGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUUilME2nS5+5XlCVHAuGeAJCGVXEq9n8ecwTW7pyCwW3P1m0FO
	Iry8lLPzk93xKcfNa01UC1+q44cYsCnshanONgygvL20AvIKHNFByIg9acLQQHGLUW3XHlDhEP/
	820+Uwqj/1BbC26lwgQ6urJd04yNd8+SRyyqggNqIzb5ryD5qw3c5LWhhzUvKlUZcAA==
X-Received: by 2002:ac8:2aa4:: with SMTP id b33mr71970646qta.127.1555525583489;
        Wed, 17 Apr 2019 11:26:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDXrJ7WtjW1MMhZ4lQIS46+TN+/+CytgzvhiDSqSuDdHKAMeZhaz0iwP0OHVKaJ0LnCzdE
X-Received: by 2002:ac8:2aa4:: with SMTP id b33mr71970591qta.127.1555525582544;
        Wed, 17 Apr 2019 11:26:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555525582; cv=none;
        d=google.com; s=arc-20160816;
        b=NdpfA5jPEwjwJcCsd7fj4g7beBCuBT1C5XNLeLyFVPqRl7eiZfWB5pJopL8AeEobX0
         odXengK0dyk3ynW+p5Gl7293PTWDNFhsu9onXUbkafuLP6qDy7L/qspWu2gONM+nedb3
         hZAY539GhC63RoF60yaRrwREH4Hn7D+91s9g5mUrO/6IAOH6wj5BnJEyCaMQ57N20VrK
         3NB/LTFuKwNsHMD1XCIsLJ0dVieDfgPpKo9YMBjgA84ZlrdvWUWhUdYVvmu7KDkVJQN4
         g3omW5nnAgyq4N3GcX2WmwyD+OARKk0NsOpNHrLrre3Eg8eFR11Wc6MjsXtwKbn+xgXW
         /kdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=EcVQqbPsBLazfmwcePHB1XP40c+WrTsPFIhUq7aOyRc=;
        b=kio0bEZ16rvtBrPrebQJulAMfm2EQIv2x17YeogAQprIjevP6KMK+RDnx0fnaIEPFC
         fe9HSMNPoUY7m7OMiUgOyth2zSuGeFypL28ONEQNMYypEXtxpYrb0Mw82dnXhB86Kwwa
         aADW8cQsrgtvftU/wPojUcEkwdWhiiOqJZI9yWtH2cOPyKd+KioLAmNxJ+qfnwXuTVc0
         3IC0ZNgz2wzVcbf/fX045V2fTqpMHx026bZNTrIGZ+M7GTcHV1FFvSu4KfXr7ekp4toD
         9a435TBGF8Ys1z9ci4Mad4Z+FsJPlirhrgB2CrboHNTUP7/fECy6DnHeUC9l+y7eAbFA
         XByQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l8si1947105qtn.217.2019.04.17.11.26.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:26:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BCA6C3078AAE;
	Wed, 17 Apr 2019 18:26:21 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C068A1001E8A;
	Wed, 17 Apr 2019 18:26:20 +0000 (UTC)
Date: Wed, 17 Apr 2019 14:26:18 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH] mm/hmm: kconfig split HMM address space mirroring from
 device memory
Message-ID: <20190417182618.GA11499@redhat.com>
References: <20190411180326.18958-1-jglisse@redhat.com>
 <20190417182118.GA1477@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190417182118.GA1477@roeck-us.net>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 17 Apr 2019 18:26:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 11:21:18AM -0700, Guenter Roeck wrote:
> On Thu, Apr 11, 2019 at 02:03:26PM -0400, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > To allow building device driver that only care about address space
> > mirroring (like RDMA ODP) on platform that do not have all the pre-
> > requisite for HMM device memory (like ZONE_DEVICE on ARM) split the
> > HMM_MIRROR option dependency from the HMM_DEVICE dependency.
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Leon Romanovsky <leonro@mellanox.com>
> > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Tested-by: Leon Romanovsky <leonro@mellanox.com>
> 
> In case it hasn't been reported already:
> 
> mm/hmm.c: In function 'hmm_vma_handle_pmd':
> mm/hmm.c:537:8: error: implicit declaration of function 'pmd_pfn'; did you mean 'pte_pfn'?

No it is pmd_pfn

> 
> and similar errors when building alpha:allmodconfig (and maybe others).

Does HMM_MIRROR get enabled in your config ? It should not
does adding depends on (X86_64 || PPC64) to ARCH_HAS_HMM
fix it ? I should just add that there for arch i do build.

Cheers,
Jérôme

