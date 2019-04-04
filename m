Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5D39C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:48:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A11E2082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:48:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="TEANgONm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A11E2082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 199D06B0007; Thu,  4 Apr 2019 10:48:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14BD36B000A; Thu,  4 Apr 2019 10:48:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2D6D6B000C; Thu,  4 Apr 2019 10:48:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id D09266B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 10:48:13 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id l203so2111781ywb.11
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 07:48:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+N5wfpaFfFnXreJqi5rThtHj0ioJdPO99KBwVABJYUU=;
        b=hKhT6y8ELfGgG6T3ep4pQ4a4tcOPTDe8BdF2PCCRteezvxArO4EHvsdTQseD0RSwu/
         1Tdu+ohNXqzqRRsXfch/qYIcGzZJIL6UAh3Xm1cboXTysn2fP0iERa/8vm1dHTCJzU2M
         fimS360PuX1hW+xG3tGlMRW2OR0vi8HQGHGqdszHZau1Jitm6nfTVv5363Zch/YcjJ0E
         U2/fYb0vE7TJ6GE3lyr4NdMIy8Wc8+/IzA/6TVIDVBVdqKjeX5Fo5R7N3PBh4eqyoLi8
         2vUNHpG7t0mX00oOamHI3czKyl8CF1eX/RdvutWuIISDp6UXxaMqQd87sG7DhR5cX20r
         qSbw==
X-Gm-Message-State: APjAAAVEZYqZfUMTi54XLCrCG+xJ/thLesz85nwzhCUZArbKrLECyuKa
	aTvhC8WIi3OYrWZ4kABicnkFEcGShdi7e/XRtfI6Q6RvvjQFTt8/cKvfd40hwm2USQyLilWvoJA
	ZMnd6QSFhhGVCMOl8WZlDJm7jO1bDQIn2kZAoQ4TGY6tCgReIFoRdLN5H9OE008B84g==
X-Received: by 2002:a5b:842:: with SMTP id v2mr5886603ybq.156.1554389293532;
        Thu, 04 Apr 2019 07:48:13 -0700 (PDT)
X-Received: by 2002:a5b:842:: with SMTP id v2mr5886550ybq.156.1554389292921;
        Thu, 04 Apr 2019 07:48:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554389292; cv=none;
        d=google.com; s=arc-20160816;
        b=yHqvKW4dkabo5YUn6xOkolG6+BtugzMI5Fdk0Q9dyJC3p/U1NYHKnhZrZjQjqGr5XY
         FrArXc2vmuPsC3axVKrIY9MDuJJDUM5T0LpDreuT1TpHlXKlEbkEt0I+daLWlm41uxBy
         hwXreSJgncG1ZaUYDIMhwNAmqWeY/QXWcVdmNJXgGp6BjVGnQQVh6H6lp5PU6DiQkcYp
         6S0zq+KsOK2Y2AhUEGBOdtDOvVH2y2pnRkrL+5PU0gYnHCg7q3hSbBP+AdZNzDDilbzu
         fzgGSCkqvGskb51tDqAh3iqRsFGE5WLy58FbGEQoT+obj39UdvGGiLCm+um3PZNJaDIM
         thpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+N5wfpaFfFnXreJqi5rThtHj0ioJdPO99KBwVABJYUU=;
        b=d/eMtm031T4r4tUUCr11/dQ54Wjjj1AFnoBxdkTQ59/qQX5vi7ljENoBBEBAiGinaa
         Gbv3JAfNtGypP6piKvq5/N6VlD1mGAxFLPKVuRxlvtgrkh+6wGh5Meo9Q0v5xVLBpJ30
         Uj/IqeZePTdywS9TJZz545uZ4UUUw60Uj3viIr44botiorzb2bJtp1fOLd1hxpfA/CL1
         QSXXKFkyrLmoyHBz/yx1fyaIt30z9yppBOGlgDUL0zXB10ixJWwyhVbEjbPR3fDLUbEp
         d4PV7qnxUQU1Dwn2819n61jpR/CRP48uexx3UnStKSgMXn7rUa9S83MKoe7nDzXuvC/h
         a7Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=TEANgONm;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 9sor10445935yby.102.2019.04.04.07.48.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 07:48:12 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=TEANgONm;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+N5wfpaFfFnXreJqi5rThtHj0ioJdPO99KBwVABJYUU=;
        b=TEANgONm47iB9J8y3CEUrM6DdTd2DkTdxXGKZZo7nOyZN3cd5JWM6ol7RapfuTThie
         /mlFRVuGS5R1mnwEU84+6b0qB/iHPsHQazXxz/cmLY32djeeilwERu15JL6mSr/6cB9O
         oukE/sbGBPkxt61I9pF+qXswwc+bfq9oqZGv6gPYj6R+QbazepNKm3jLPhM58pxT5uoz
         m1QQkblLLtqqbXsKkTC7OrOt+IBQ6FaPYRldkZ0d+YnXvKeBoLtU5nWppG/2S3UhmeJZ
         67LMONoxk4nVj+gYSLarExIc3ViA6uC/D0kIMf98owWR1SER8ZkQ9ZSVDVvsmz19z2jx
         wIlw==
X-Google-Smtp-Source: APXvYqwFKv0mJl6vzyjHG5dLr3/7Yx/SptmAwVPnJLFNaftR3k2gUIulb5tszhT6R1G3I1RO3YCIEA==
X-Received: by 2002:a25:5b55:: with SMTP id p82mr5787278ybb.23.1554389292186;
        Thu, 04 Apr 2019 07:48:12 -0700 (PDT)
Received: from cisco ([2601:282:901:dd7b:38ae:7ccc:265c:2d2c])
        by smtp.gmail.com with ESMTPSA id p7sm6700527ywl.17.2019.04.04.07.48.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 07:48:11 -0700 (PDT)
Date: Thu, 4 Apr 2019 08:48:00 -0600
From: Tycho Andersen <tycho@tycho.ws>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com,
	jsteckli@amazon.de, ak@linux.intel.com, liran.alon@oracle.com,
	keescook@google.com, konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	kanth.ghatraju@oracle.com, joao.m.martins@oracle.com,
	jmattson@google.com, pradeep.vincent@oracle.com,
	john.haxby@oracle.com, tglx@linutronix.de,
	kirill.shutemov@linux.intel.com, hch@lst.de,
	steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
	dave.hansen@intel.com, aaron.lu@intel.com,
	akpm@linux-foundation.org, alexander.h.duyck@linux.intel.com,
	amir73il@gmail.com, andreyknvl@google.com,
	aneesh.kumar@linux.ibm.com, anthony.yznaga@oracle.com,
	ard.biesheuvel@linaro.org, arnd@arndb.de, arunks@codeaurora.org,
	ben@decadent.org.uk, bigeasy@linutronix.de, bp@alien8.de,
	brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
	cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
	dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
	hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
	james.morse@arm.com, jannh@google.com, jgross@suse.com,
	jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
	jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
	khlebnikov@yandex-team.ru, logang@deltatee.com,
	marco.antonio.780@gmail.com, mark.rutland@arm.com,
	mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
	mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
	m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
	paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
	rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
	rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
	rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
	serge@hallyn.com, vbabka@suse.cz, will.deacon@arm.com,
	willy@infradead.org, iommu@lists.linux-foundation.org,
	x86@kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20190404144712.GA1249@cisco>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190404072152.GN4038@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404072152.GN4038@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 09:21:52AM +0200, Peter Zijlstra wrote:
> On Wed, Apr 03, 2019 at 11:34:04AM -0600, Khalid Aziz wrote:
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 2c471a2c43fa..d17d33f36a01 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -204,6 +204,14 @@ struct page {
> >  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
> >  	int _last_cpupid;
> >  #endif
> > +
> > +#ifdef CONFIG_XPFO
> > +	/* Counts the number of times this page has been kmapped. */
> > +	atomic_t xpfo_mapcount;
> > +
> > +	/* Serialize kmap/kunmap of this page */
> > +	spinlock_t xpfo_lock;
> 
> NAK, see ALLOC_SPLIT_PTLOCKS
> 
> spinlock_t can be _huge_ (CONFIG_PROVE_LOCKING=y), also are you _really_
> sure you want spinlock_t and not raw_spinlock_t ? For
> CONFIG_PREEMPT_FULL spinlock_t turns into a rtmutex.
> 
> > +#endif
> 
> Growing the page-frame by 8 bytes (in the good case) is really sad,
> that's a _lot_ of memory.

Originally we had this in page_ext, it's not really clear to me why we
moved it out.

Julien?

Tycho

