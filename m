Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81AE0C282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:43:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34FAA20700
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:43:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mSyEKQ6J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34FAA20700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A55926B0010; Fri,  5 Apr 2019 12:43:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A034E6B0266; Fri,  5 Apr 2019 12:43:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A5556B0269; Fri,  5 Apr 2019 12:43:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA986B0010
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 12:43:01 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id f67so3951361wme.3
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 09:43:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hZhTCIKAv1SX7OWxy0ZNyMB8ohuTPeMfZbFpPWX134E=;
        b=Tch9h2hNOweVv9E26u1HAGjGJ/eLEKM0LHLa3s8k0CsI97HBnmZrkZeRI3SCG2Ajqz
         k6eFeLkWT5QeRBN1mKAKMcnhmWrUAzNQR+ZvUA8Yx3Ua3LAs7bT3L+aoP7mPlXZasaui
         Rvt7Geo6jKn4jzSVVwpXHtwFxz1Y4os1MpQRzav6SiZ2rKYapx5zb7PTlAmaAc/P4vVE
         rmHulLaKDJLpGTNzJmUT30Is/2VsXgFpmInQ8BC0Is0vBUFeGoa2hF5pgK+sF1UjOxRW
         lSM8NQCnhZldwPEw0LPMJRuUGHkTfRO3P+8ISReugBVxKZt5OvGrveo7cL88VPXfazh/
         7BzQ==
X-Gm-Message-State: APjAAAWiYK6G04lXd0IRwuWAVFI4VFIVN43NsVqHGlKQScBPjC/w/+T+
	6UV2gbbIevjKcV9mtloIIVREBdvGa7dZWkw1RE/ocjPjqhmcykQExwQtLVEX/75Yz4bf1BqNxZI
	qILqG6YzU2STr038P5YXEoghjEzoHY0KdVZNOxGjNznmk6TXa0MncDL+MNa/212YfYg==
X-Received: by 2002:a5d:5188:: with SMTP id k8mr9302384wrv.183.1554482580812;
        Fri, 05 Apr 2019 09:43:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxG7V9Z2LOrg+boYrDtbUjBVoHtLgw8F+ZKWyPSLA7eG84gBy8nsYcNy3qbpCgOhbrdXdq4
X-Received: by 2002:a5d:5188:: with SMTP id k8mr9302354wrv.183.1554482580094;
        Fri, 05 Apr 2019 09:43:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554482580; cv=none;
        d=google.com; s=arc-20160816;
        b=wyrxYAt1RJbQiNdifZwx58oEG4zaCsbSMaZEmZ99N0EQkygq81ydTDm0zPwbxfGEBE
         VTP29/ippSuNuBknkYIT7vTdkSzffmP/BLGI5SFuVkks08/a6xhvLf7ncodlWMn8eHZw
         /dm0sseH04V0QgZUhGJ5ZpjZmeQABqaESLEV9+CGIsKAWOrSo3aqeqe4DdvV1hGYc/uq
         f7hh+SbFcg7813y0uXFCxMeqfCmK4IFt2M1n2vTWDsyTYo2okP1Fq3WLk+FKsi/cSZ8l
         y9ya8WQOEfZ/xns6VcGCZOj+cB8D+k5jMlWuEUVQ6L07tMr7SAhxiY2JWEQamuPZvFpK
         bhcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hZhTCIKAv1SX7OWxy0ZNyMB8ohuTPeMfZbFpPWX134E=;
        b=y0IP4bAk5SrO5uYu07FhZRVr7ZNB6YHELiyOGOmyjv9e1QolArAgQ2PWS2g+0A8cjT
         leoCBKRNJMa7jj0doh9i6XXUUxio85ZzTxC9NJIS3tx/uzPOgE9/d5fmhN5HLN6r9mlp
         1MdQ40S+iWUrItUH4jJucUTk7r/p4Qxy/YmC0J/gxMmZnkdeJ/zRHAJtL2bd4L6UQ9AE
         nGrcctm7nxuCTFLPtKBaFO51KymBaAgI4qDiJ31RLz+vZG/iBzJxjPxvyMwiWwbBlXqV
         kfqKnLPSPWie/QPvHT/BevYbGRme+Tzgu0QgeCv9Uo2FuzZrxXmisgrAPA3+QnBp3awh
         /PLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=mSyEKQ6J;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b15si14689770wrq.75.2019.04.05.09.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Apr 2019 09:43:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=mSyEKQ6J;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=hZhTCIKAv1SX7OWxy0ZNyMB8ohuTPeMfZbFpPWX134E=; b=mSyEKQ6JZ9GlE5lyhXCQh7u8P
	JA4MAqkaoxKIVkTuxNwnuhPTfHK8zPdr08TWvJ6JUIugUaxRVglFTjUylYGHaD+x2o8dvgpKcO0qz
	eUjrz8o+fWFx+CYfeZfmOIJ+aXdSmsXEImKgw+nnm+5NO88EzKR1Ru4oeJlFkZLN6b74Yjnuxk5x/
	YNCB9uZwVBdLfAFdwruvtEpxUeVrR2zOvWKfK6R7CDAbFlsptY/4EOBPFQyV+yAFaXGPn7y09TUB3
	Jes/EhjyBsBuQNRk23wzulz2u4Q54hhn7TZqlLOQu3QFVhULpEEsbU1aqllppWXWEwrrB31MMmbmP
	PtLOwsb/A==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hCRuO-0005wn-GU; Fri, 05 Apr 2019 16:41:40 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 984BF29AB6604; Fri,  5 Apr 2019 18:41:37 +0200 (CEST)
Date: Fri, 5 Apr 2019 18:41:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andy Lutomirski <luto@kernel.org>,
	Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>,
	jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>,
	liran.alon@oracle.com, Kees Cook <keescook@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
	Tyler Hicks <tyhicks@canonical.com>,
	"Woodhouse, David" <dwmw@amazon.co.uk>,
	Andrew Cooper <andrew.cooper3@citrix.com>,
	Jon Masters <jcm@redhat.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	kanth.ghatraju@oracle.com, Joao Martins <joao.m.martins@oracle.com>,
	Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com,
	John Haxby <john.haxby@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com,
	Laura Abbott <labbott@redhat.com>, Aaron Lu <aaron.lu@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	alexander.h.duyck@linux.intel.com,
	Amir Goldstein <amir73il@gmail.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	aneesh.kumar@linux.ibm.com, anthony.yznaga@oracle.com,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org,
	Ben Hutchings <ben@decadent.org.uk>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl,
	Catalin Marinas <catalin.marinas@arm.com>,
	Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	James Morse <james.morse@arm.com>, Jann Horn <jannh@google.com>,
	Juergen Gross <jgross@suse.com>, Jiri Kosina <jkosina@suse.cz>,
	James Morris <jmorris@namei.org>, Joe Perches <joe@perches.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com,
	Mark Rutland <mark.rutland@arm.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michal Hocko <mhocko@suse.com>, Michal Hocko <mhocko@suse.cz>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Ingo Molnar <mingo@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>,
	richard.weiyang@gmail.com, Rik van Riel <riel@surriel.com>,
	David Rientjes <rientjes@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Steve Capper <steve.capper@arm.com>, thymovanbeers@gmail.com,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will.deacon@arm.com>,
	Matthew Wilcox <willy@infradead.org>, yaojun8558363@gmail.com,
	Huang Ying <ying.huang@intel.com>, zhangshaokun@hisilicon.com,
	iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
Message-ID: <20190405164137.GF4038@hirez.programming.kicks-ass.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
 <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com>
 <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com>
 <alpine.DEB.2.21.1904050909520.1802@nanos.tec.linutronix.de>
 <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com>
 <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net>
 <36b999d4-adf6-08a3-2897-d77b9cba20f8@intel.com>
 <E0BBD625-6FE0-4A8A-884B-E10FAFC3319E@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E0BBD625-6FE0-4A8A-884B-E10FAFC3319E@amacapital.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 05, 2019 at 10:27:05AM -0600, Andy Lutomirski wrote:
> At the risk of asking stupid questions: we already have a mechanism
> for this: highmem.  Can we enable highmem on x86_64, maybe with some
> heuristics to make it work well?

That's what I said; but note that I'm still not convinced fixmap/highmem
is actually correct TLB wise.

