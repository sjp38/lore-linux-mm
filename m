Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48306C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:45:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08D7820863
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:45:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08D7820863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEB176B0005; Tue, 19 Mar 2019 13:45:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C99426B0006; Tue, 19 Mar 2019 13:45:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6D786B0007; Tue, 19 Mar 2019 13:45:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 94EF36B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:45:57 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x12so20590723qtk.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:45:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dTUb5t0y7tbIYfYFogolS695IaTdR3eqmRax5LQRYS4=;
        b=B4VhmH45uwo7sypwM5qmKGjqSjVKdXwp32ZdnbF30BV/bxIPJYgXYWbx1YTiMNFQ7F
         bGDKGPZnRXd+xeGHIFE+QgRCWjOsxfBvQOC6HiBY5cOOTAGWneWcy4KAMRyiJy5mqWIx
         /LiuA8xlyWX9DjMDNEH7EShcCAS6j7TK3P7ZdZIrof1woAXE6t9b7ONI19H9HEJ/L42l
         D1cbX6FP5V2pxVhAKVTagr+Szcj8FLmwfv2V27K1FFu1clI2+3arw6U0XnaEP8oWu+en
         BufTqY8s0lauIG6acAJgBFrkE41io39Jdbx2S0UlR/3gYmKQVSNZwb/NaBgQtlpGIowz
         J9ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUse1EXOmxNhUF6XaTy+qWgEguTh+v3dGpc42VgVBeLiac8l9ge
	BxKTyU9w5mYXtOpAJeLsjzIFUU6KvFsRN6l2YeYGgqCRsL81llq2oWrmW+X0Oukw8RUvAQQj6BJ
	Aosj724WLLlUN/uYbNF+ChwhW84CGdl8IADhXlXjKqD59wL5kCAxT1E711HyIfMhysA==
X-Received: by 2002:ac8:25b5:: with SMTP id e50mr3238296qte.186.1553017557372;
        Tue, 19 Mar 2019 10:45:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5/rLz2b0pchhRXAuIwyhS5HDQs4rKtK2fSBpX1TDHAUTHv7zcQWCxHozEYTQU4TS/Fu4Y
X-Received: by 2002:ac8:25b5:: with SMTP id e50mr3238244qte.186.1553017556671;
        Tue, 19 Mar 2019 10:45:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553017556; cv=none;
        d=google.com; s=arc-20160816;
        b=Yid8C86AgjvsUl6ak2pGpatDhMEdHCW2zQNDE5cCfgYBfkcafCLPI2IwI9k/ZMI3fJ
         DcAkchvbBxzYTxbcgpglmAmQy9mdFIscPbZeBG8a8ALxjfVF0ix/VX6Mh0C052aOXRWX
         61bwxw/j+nZ+7mKSLjo/XTroZi3KH99XGMM0qnT1exBDnyW5nUiS8GTQ4vHsNqAURbz6
         1D8ivM47MfWugV3lF0Ej4ciIkG98/Ly6zVe2y0Dv06x5ub99qIf+nJaPjNPyu1pIR407
         IEm1XkM85VLRI1oQd+MVz/7nV96gGPR4Aqg03iI5kG9HyanZrmRKs1IHdN1gzUdcfiUm
         yjBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dTUb5t0y7tbIYfYFogolS695IaTdR3eqmRax5LQRYS4=;
        b=IPGmBfkePNVs9xCuM5Wvglzr1rIFku70B/bqaUjEHg5nzjbhaPcq9UnU/vB8+YEYWs
         ClCRqY1UTYp5a3bXCIF/K72TZvR3xqnbugR7Cvx2GpekU/faLxrNvXAk3ekS07ef5v07
         fwaWVVLzuRGIunMlR+RoFE2qjMUuenayVHImWvCnmqmzQpkDktHidDI6qbYwF2kQKcDh
         0/HiLOKFGVt7uUKH+21vtPCqxAOB6nzIYfrZmhYGKn/bRyL6k+AQrPeKFo+3wZq0cjuf
         kNNqIrAM3Q3wxmhHDN/6qgBIhB6PEXIOVi7R3XWlaK0Mhj8l1m7DKHYoHDgoq/k37Vvg
         FhJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h201si2178856qke.118.2019.03.19.10.45.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 10:45:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9E6C43089ECB;
	Tue, 19 Mar 2019 17:45:55 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7908560141;
	Tue, 19 Mar 2019 17:45:54 +0000 (UTC)
Date: Tue, 19 Mar 2019 13:45:52 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Alex Deucher <alexander.deucher@amd.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190319174552.GA3769@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com>
 <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
 <20190319165802.GA3656@redhat.com>
 <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
 <20190319171847.GC3656@redhat.com>
 <CAPcyv4iesGET_PV-QcdBbxJGgmJ_HhoGczyvb=0+SnLkFDhRuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iesGET_PV-QcdBbxJGgmJ_HhoGczyvb=0+SnLkFDhRuQ@mail.gmail.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 19 Mar 2019 17:45:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 10:33:57AM -0700, Dan Williams wrote:
> On Tue, Mar 19, 2019 at 10:19 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Mar 19, 2019 at 10:12:49AM -0700, Andrew Morton wrote:
> > > On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> [..]
> > > Also, the discussion regarding [07/10] is substantial and is ongoing so
> > > please let's push along wth that.
> >
> > I can move it as last patch in the serie but it is needed for ODP RDMA
> > convertion too. Otherwise i will just move that code into the ODP RDMA
> > code and will have to move it again into HMM code once i am done with
> > the nouveau changes and in the meantime i expect other driver will want
> > to use this 2 helpers too.
> 
> I still hold out hope that we can find a way to have productive
> discussions about the implementation of this infrastructure.
> Threatening to move the code elsewhere to bypass the feedback is not
> productive.

I am not threatening anything that code is in ODP _today_ with that
patchset i was factering it out so that i could also use it in nouveau.
nouveau is built in such way that right now i can not use it directly.
But i wanted to factor out now in hope that i can get the nouveau
changes in 5.2 and then convert nouveau in 5.3.

So when i said that code will be in ODP it just means that instead of
removing it from ODP i will keep it there and it will just delay more
code sharing for everyone.


> 
> >
> > >
> > > What is the review/discussion status of "[PATCH 09/10] mm/hmm: allow to
> > > mirror vma of a file on a DAX backed filesystem"?
> >
> > I explained that this is needed for the ODP RDMA convertion as ODP RDMA
> > does supported DAX today and thus i can not push that convertion without
> > that support as otherwise i would regress RDMA ODP.
> >
> > Also this is to be use by nouveau which is upstream and there is no
> > reasons to not support vma that happens to be mmap of a file on a file-
> > system that is using a DAX block device.
> >
> > I do not think Dan had any comment code wise, i think he was complaining
> > about the wording of the commit not being clear and i proposed an updated
> > wording that he seemed to like.
> 
> Yes, please resend with the updated changelog and I'll ack.

