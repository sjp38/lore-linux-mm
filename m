Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	SUBJ_ALL_CAPS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25510C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:24:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF96B21783
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:24:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="L/+gVqcn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF96B21783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 625896B0319; Fri,  9 Aug 2019 12:24:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AFF86B031B; Fri,  9 Aug 2019 12:24:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 429416B031C; Fri,  9 Aug 2019 12:24:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09EF26B0319
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:24:52 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g18so57726883plj.19
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:24:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xrswoPf44Z03S3Xl/6YllPqCJtXJb0iLf7341inGhrY=;
        b=iG5OPc1pGh1L4Keuke4ZovW1gp2H2lzmRNENClFWUU/b3LMzqFkdS5/6dyKYoPL9e5
         g1+F2Gel9FmvEAGx4ChA1vl0nP5dvQqFBC1Y7n6J2Alzr3JsBYx3odpjILbu8Yylv2Lw
         S/QEYLO1S5Zwp45Fe8F3GZi6aIosEyVK4iX2Y93iA93NtCF3UukJV3fa7Ek6bOFS4P7w
         GQwU34+usUj631dDmT/yzniJZ+LP0VcLieOmWXMA828rXTh86aE0QdG9s4IH/FJqTc89
         r7xCnFx0AJmwqArCPxx728DjienTMW67v2qCBvbNoLDq3pZJLV9/NzLzEVsn4AxdgptQ
         XwGg==
X-Gm-Message-State: APjAAAXKukvHIRgdz6wLlrF3JAVadTKLa480MkZ7WpehlnrPDzeWtjh9
	ZzNG7sdT8zfkhCnLHMeDln7Uefwu+hkqNCKLt5IFG4LIcnJuLz+kSxTg0Yhlj811gaXRC8HLOL8
	0EZgvxTiiIy1A2H73oVp3412EJLox98Qeyx2bWYqMezXzwQKHd/+7UlC4RkdCVxpgWA==
X-Received: by 2002:a17:90a:c24e:: with SMTP id d14mr2761938pjx.129.1565367891736;
        Fri, 09 Aug 2019 09:24:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbpgL0W+SDZJmVIiJ9v2SMhAXhI5SwbupG7NCcVYc2iBQblGVs3kml4z0vmnCpHbuCbvuU
X-Received: by 2002:a17:90a:c24e:: with SMTP id d14mr2761786pjx.129.1565367889997;
        Fri, 09 Aug 2019 09:24:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565367889; cv=none;
        d=google.com; s=arc-20160816;
        b=IBCma/pTIa/PcBEjGmuIGOFtAQe3H/G216ij9rRmrfR2qr9u5fKEjsbcAWVS5vOhlP
         vE3DmaQRGwQ1R8fC+YFdAqd8M++xHhhDo0OqOY0/RzktXa+iFnvUedPpTkvFDuQxlH6H
         uqIbtJHuXarn93Gy4PoPJCJb7OShjhLB9DpaF/LluKyZgNYkiQHOdTeiHWEfF50o5XKC
         FiVIjQbn8uSK0jozh5LRNwTqJPxYccjD8OoRkksUSmT1KyJvS1mSvKc5cRBRIF/vD6KH
         jlC8Dt+XA9+8IT41a2k9VMIkFY6aAgzd7mdswmltDraDTn68mRyZjDlB5Jk7iAX369Sp
         hdbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=xrswoPf44Z03S3Xl/6YllPqCJtXJb0iLf7341inGhrY=;
        b=yz5obsHYMUnxKfZQjCj/aBKBUop3Pny6+PX1vrNrRvjJ41Sf8Udyp345zu0jZx02S8
         lmFR2G9ZwAIR9EmAsN5wWSDHOrHdfaEsVEixIjxPHM+7LAS7DAh73cWhRlSiqaSxFMT9
         /AYWU6VsHk9tsJ5toGH8DR4OXNE2vYP29WXrBGvg5ch9kUVkf1gT1stKLv0Nrh1qmHul
         AGQ17HRHBWDzVxR0lQqlO/V7yHAkrxQscJ5eUazqAbJSKMrm5Y1b884tjkTl2vgSuxRk
         AKOCtgMF6M4FN5nJvaXNgS3DNnQGonDgQxMhpPCK+mz4dKzmIdk37VStbHsjuKVDL65t
         87pA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="L/+gVqcn";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q67si68604826pgq.83.2019.08.09.09.24.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 09 Aug 2019 09:24:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="L/+gVqcn";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=xrswoPf44Z03S3Xl/6YllPqCJtXJb0iLf7341inGhrY=; b=L/+gVqcnLKq6HpffUaAVFqOEg/
	w/yz5wAhB2ZX9xaTvGMhg3d/oxasNMn6WEoztRV50n1/KEjpJ/9nDd9FhWMHF4+yBMe6p4P69i0YJ
	pppEFS+j5sas14zZhl8onbamHjBNJAs8PQuUgusm75o4tCRktPw3NQkaAtyIvtnC2RCm1rWjWrhao
	+5SPhkhUQvBoOhYBvhyoozqezG0bD0P7iq+/VCAdq1eq6PHxF+7UHNYbkNFeG5LNBc16apjYo84JG
	CXoNZDvJJeDtCQAJLwU5ZcyJFjSozwDjepJrwhTnhs6AYo6XzJR3ok/b5uFooBeE/plaXChgCdihB
	2w9t3wAQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hw7h6-0006cM-Uc; Fri, 09 Aug 2019 16:24:44 +0000
Date: Fri, 9 Aug 2019 09:24:44 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?Q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
Subject: DANGER WILL ROBINSON, DANGER
Message-ID: <20190809162444.GP5482@bombadil.infradead.org>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-72-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190809160047.8319-72-alazar@bitdefender.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000019, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 07:00:26PM +0300, Adalbert Lazăr wrote:
> +++ b/include/linux/page-flags.h
> @@ -417,8 +417,10 @@ PAGEFLAG(Idle, idle, PF_ANY)
>   */
>  #define PAGE_MAPPING_ANON	0x1
>  #define PAGE_MAPPING_MOVABLE	0x2
> +#define PAGE_MAPPING_REMOTE	0x4

Uh.  How do you know page->mapping would otherwise have bit 2 clear?
Who's guaranteeing that?

This is an awfully big patch to the memory management code, buried in
the middle of a gigantic series which almost guarantees nobody would
look at it.  I call shenanigans.

> @@ -1021,7 +1022,7 @@ void page_move_anon_rmap(struct page *page, struct vm_area_struct *vma)
>   * __page_set_anon_rmap - set up new anonymous rmap
>   * @page:	Page or Hugepage to add to rmap
>   * @vma:	VM area to add page to.
> - * @address:	User virtual address of the mapping	
> + * @address:	User virtual address of the mapping

And mixing in fluff changes like this is a real no-no.  Try again.

