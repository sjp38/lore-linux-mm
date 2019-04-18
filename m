Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3088DC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:51:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E272921479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:51:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E272921479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 820E06B0007; Thu, 18 Apr 2019 17:51:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7ABA56B0008; Thu, 18 Apr 2019 17:51:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64CD56B000A; Thu, 18 Apr 2019 17:51:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6E06B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:51:21 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id u66so2861063qkh.9
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:51:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=EtVaK/ICxtbARtdMEhaPEO0EcVbxquWtM8HlIo2WXps=;
        b=VTeMfMzlQL9r+b7XkXSvBWtwjE/zk0r8K0WIRaegOvHG5Fk3JjY+9V63gbD/AAyY+N
         YvZr8fVPns4LvoJL4cQBlZ+UnLwaf1BTMU8G7qoyLulgWOFCenuNxPbkRPHm45SgOd3V
         Et6APD/2dha3lptR7pSk0CLGjr4MvaJZRHESPznMABzy/YYrDoa5ZNev37kf7eRwPfjC
         4coOqs98p3Q/N4YjTMabb9B9ZdtSQnQ+a8n0FKqsW+PheITCLhZ+xCecjOI5t3i+D3Hy
         kIe8JFwSBKHwjwzczykRM3S0j4njTMFHyRu2ZhYKSsdsKqhzvP7cAk10AhQrECdexLDO
         xM7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWgmQzGTTL1xLz3KnGVJlMQyrqRhc49pRdBBYWcKMm9tfUon1mf
	PWGwfyMXGl83fKYEgGXogGQ+fZemJdKrBGD7ciJry4fiMNEiHcB6JsfBjmDsp80c6L5RszFLpFS
	aJxgf5ORp61cB4Eu070hfgVmKxIgU32Hoesy9UpxJj6gjYXJ/XfuPiUbNWH0dHm1HGg==
X-Received: by 2002:ac8:28d0:: with SMTP id j16mr359633qtj.15.1555624281039;
        Thu, 18 Apr 2019 14:51:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA0U+2ZUUpQn+Jp+vieCPt6YQa8JeSEx5iiOzwqj9V2g5PbkUgL/p2FOtD4jYnpHpzpsq0
X-Received: by 2002:ac8:28d0:: with SMTP id j16mr359597qtj.15.1555624280424;
        Thu, 18 Apr 2019 14:51:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555624280; cv=none;
        d=google.com; s=arc-20160816;
        b=obPS4mloOlm8lVvXRX1ui7a7FED4YkAOANLgbDWXI6VzLYTr6W3+xqRBeYXYYlHT4Z
         ANtImDdvNvTQtd6+uy098Y6CPRZ7FMyQDICGFwhbufCD/cYkBBD571xSKDjmBo4pS+b1
         BtkFDCTqc5fVxxLCgzxarkFveAdy+GCQtoiSWXfqW+VfyyvuhWeHalmvqAzd9pQLJ5pR
         /dNSa9MB1CRhcur+QW6txgrOgoM8+Yrw/ICIKlqdO5c85B/gH4RoFuwdG5o4zNl0SlfE
         kfsNmg0uPdtZiuYUZ0a8Ska4M45vv3akcQM3BNG8LGJtkgfILby7Oib0iC43F4lVGBnn
         oMOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=EtVaK/ICxtbARtdMEhaPEO0EcVbxquWtM8HlIo2WXps=;
        b=0pezOA8tAG2dOLKZPtiqMtI3FcIMTk3S9PY+dwIsOyQ2NeJ+QD2lTYQS0EkTSJAHSM
         XY349GK1WpdE5OrczGTItjJzPgpri+T7i234ziZ2o+he8r3hiXasKil91/J8XdQ0QBcn
         MkvAGe825pY/Y+6DRnMZcSrOqfB0Ui1zAmsquI9VmZjdijm7AKhBPJVpxLfxi6M0bvAz
         dB4WRb/OxMZmothXafAJVbZECYV242bKVaz2o72E7qTvqTuom+1ZVn6EwD7TvCMMWa1X
         74oo6q3x+X3kUzlb+k7mabhR+MAhsY3qBYZu+Jqlukhq04Lrt1Toubat5PWu+QFQZEp3
         N1yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c7si906928qtq.255.2019.04.18.14.51.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 14:51:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 40F2E30B96D2;
	Thu, 18 Apr 2019 21:51:19 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 939A45C21F;
	Thu, 18 Apr 2019 21:51:15 +0000 (UTC)
Date: Thu, 18 Apr 2019 17:51:13 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Laurent Dufour <ldufour@linux.ibm.com>, akpm@linux-foundation.org,
	mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name,
	ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz,
	Matthew Wilcox <willy@infradead.org>, aneesh.kumar@linux.ibm.com,
	benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 04/31] arm64/mm: define
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Message-ID: <20190418215113.GD11645@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-5-ldufour@linux.ibm.com>
 <20190416142710.GA54515@lakrids.cambridge.arm.com>
 <4ef9ff4b-2230-0644-2254-c1de22d41e6c@linux.ibm.com>
 <20190416144156.GB54708@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416144156.GB54708@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 18 Apr 2019 21:51:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:41:56PM +0100, Mark Rutland wrote:
> On Tue, Apr 16, 2019 at 04:31:27PM +0200, Laurent Dufour wrote:
> > Le 16/04/2019 à 16:27, Mark Rutland a écrit :
> > > On Tue, Apr 16, 2019 at 03:44:55PM +0200, Laurent Dufour wrote:
> > > > From: Mahendran Ganesh <opensource.ganesh@gmail.com>
> > > > 
> > > > Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
> > > > enables Speculative Page Fault handler.
> > > > 
> > > > Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> > > 
> > > This is missing your S-o-B.
> > 
> > You're right, I missed that...
> > 
> > > The first patch noted that the ARCH_SUPPORTS_* option was there because
> > > the arch code had to make an explicit call to try to handle the fault
> > > speculatively, but that isn't addeed until patch 30.
> > > 
> > > Why is this separate from that code?
> > 
> > Andrew was recommended this a long time ago for bisection purpose. This
> > allows to build the code with CONFIG_SPECULATIVE_PAGE_FAULT before the code
> > that trigger the spf handler is added to the per architecture's code.
> 
> Ok. I think it would be worth noting that in the commit message, to
> avoid anyone else asking the same question. :)

Should have read this thread before looking at x86 and ppc :)

In any case the patch is:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

