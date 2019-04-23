Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D4FBC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:44:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C13C2175B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DGFJ0uzR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C13C2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F1356B0008; Tue, 23 Apr 2019 11:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0777F6B000A; Tue, 23 Apr 2019 11:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5B756B000C; Tue, 23 Apr 2019 11:44:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACFF56B0008
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:44:29 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w9so10540936plz.11
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:44:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+K0qQkMPhyOnz59Oaseee2QX30i0QPa2TDYTaUA1ZuA=;
        b=dkVuWrxoPAzj1WdKqBozxUJxen7BYbS519/8CUK9BVBEJTNECqyMCoYtAkxt9O0GhA
         ayaq2t3k8D9Ehc/2qiHlcoj1KqF4KIkGKvyuFQrdfx4Dn8EYG8RpQ7broOo76Hlg9/BQ
         B+9zMnJoFi5Ftqj2VbUk56wh7KUpeBZ9BUBpnrNMYwrHT3vDEmk5LPTk1q8o4Tn/H4do
         kEO9t0gkCSeifF9deOcFl+xctgBE4a0vmi/pMSlUkkZ7jAczmOwVzBIYYAAYnvj2Rx1Z
         9IH92hclSYnQUQkjLXMsYMcF6lh45f32zekyHXHmv27oRGjHiFokU4+1XHEDaOX6t4zk
         7aLw==
X-Gm-Message-State: APjAAAXx8fodAgVA4HzrO/tXlz9Io7mDsFGqUNbGWKhfuTfO7njLl//o
	98KTEWaEFn8Ehi48s+CubnnezCrdpfjxNoFnOv+GmWWtMYAG5RLamP0uacEp1De4YF0EcQtotGP
	jVPMOEE/nbljutS/T08iPXyKQNWqt+Ln5vGrILq3tgAa1ON0IiX5Bl5BPw4iCFvPorQ==
X-Received: by 2002:a17:902:9341:: with SMTP id g1mr27320979plp.81.1556034269222;
        Tue, 23 Apr 2019 08:44:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw17FlpkW0EsFkeKp/kHbt2giSPGaOSL4CWtCh8Pl4NpistPYZ7w4gcQscNpebVZHJf2tdk
X-Received: by 2002:a17:902:9341:: with SMTP id g1mr27320916plp.81.1556034268554;
        Tue, 23 Apr 2019 08:44:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556034268; cv=none;
        d=google.com; s=arc-20160816;
        b=gMBE5KHI/gVcTR4x6bK2uRgWHaKK1c7HrMFfVpvhejIMuWYoieXuqPfuPlxl+k3Nhg
         ogvB7fCxbP+nJzDuKHoJbcN8ISupisgjvv0Z4dBAIL7Wr+DxcgPDOfK7FJ+f08Zn7pf0
         1NL8Yib4AtTw+lv9bDjsAV4x6KYN2+H2iHRj1rh6jF/KI5nKeJ4GPShWClK5JWAjGqGn
         ViO75kC4FW8muAbaSy4Y2TIZkHke3SX9eLUPkZe/1tRPMaIlJVTuTZpi15Yv1ozNDuXQ
         klx+iDtWdjvCpxwSUY40hMyM3JFua3aBYXeYRfI3/5S2bfGLSbwp6DXFqDdClVxkliTd
         ASBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+K0qQkMPhyOnz59Oaseee2QX30i0QPa2TDYTaUA1ZuA=;
        b=sRRZPCEVSWdwkE6Su/Yhgmt+nqW0HOZs07vCu33mD3R+kgrUpHUzT3mh9NdeAIEjh0
         8vdxZYEA9JlitwIiQ896T3L9Vt2uH6QetmLsRrHf+s+l7aLxM7RVhzfxRO4ncTbuduaJ
         As5oAinU2fSbRlXDQhKmtfCQD4G0b2rdUlZEKan7PJMwKDrs7kfS0XsufUPK8mQjtrkC
         GXoRHitBHF+OP5NkvKOO37Mkw1LzJJIV46YFBqn5Bp12fl7NX9g6LADMGWfVu8elt6YG
         PxYs+R/AcKIMqXCXcqfmW1Jeg7+f6D6i+IT4m2ZZHk/ZGfOGWuttpkLzEC+m5iiyu3fR
         rcQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DGFJ0uzR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u22si16237825plq.193.2019.04.23.08.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 08:44:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DGFJ0uzR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+K0qQkMPhyOnz59Oaseee2QX30i0QPa2TDYTaUA1ZuA=; b=DGFJ0uzRQz4B1HqRz/5Dx9nOD
	QGgXKNpcRkcjjOoU/iQfadRwOvYwjKjEVEexgm2sgHK7FdXUF2nBWerqyIud4WjMCOCz2IWA52R2K
	mZHc+Wwnh7ACTSZAlBxzcqGBvhWqh+QBAJsv9RWCv+nZsFe+wqj3qfmMDCPaz6BQC+zBUcF9jDM/n
	TfFhgOQP52WzFRP/25AczbcCko5xNofRAILBILxezaKYK2pqgluLcwu9m5DBcGjYZ/gZk6YrqbJbF
	4mjVGaAyq5a+NYlIyLUPZq6vcqMfdM8nM5/mkmPJu3FD97kf0Ba7zCgsih5105Truw37ChSq5mbML
	OKB8is8ww==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIxaJ-0001JO-98; Tue, 23 Apr 2019 15:43:51 +0000
Date: Tue, 23 Apr 2019 08:43:51 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
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
Subject: Re: [PATCH v12 07/31] mm: make pte_unmap_same compatible with SPF
Message-ID: <20190423154351.GB19031@bombadil.infradead.org>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-8-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190416134522.17540-8-ldufour@linux.ibm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:44:58PM +0200, Laurent Dufour wrote:
> +static inline vm_fault_t pte_unmap_same(struct vm_fault *vmf)
>  {
> -	int same = 1;
> +	int ret = 0;

Surely 'ret' should be of type vm_fault_t?

> +			ret = VM_FAULT_RETRY;

... this should have thrown a sparse warning?

