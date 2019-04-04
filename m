Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E003AC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:26:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0F6D20449
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:26:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lXimA78f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0F6D20449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2652C6B0007; Thu,  4 Apr 2019 05:26:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ED956B0008; Thu,  4 Apr 2019 05:26:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08FF86B000A; Thu,  4 Apr 2019 05:26:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA44D6B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:26:04 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id v11so5108910itb.1
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:26:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=X+EiJspXrthvhY7cDQYnv6wc4+xKqln42WsdUBF2ewQ=;
        b=kdkd15xBqjBbYthVBxLI8DZ/bqJlUBa6u8ZenVodYLc+Jgy4Jw0Y746kW+QSC5UxRA
         EQOlycSEtLHeasdPUKpUc4/8yHvPF59xfiSFO8+RPu8sy9odmbOmAru3uucwMlPD2FN0
         ra03t+tbTQI9CHJZUYNKuLT/g7ODSWhUw6n88kz0l6UR7XXNIIpez+QuN7L2eWaCG5ap
         L9aHPVIrr943dxnXscMd1/aL81O6mZsMyU6ClFTbZYztU+n1iUkNMSH6AcGWyzgmmCKF
         EEUARmyg01cvWt4MClF2+yPmyJk22LsQQKo6lDpvHjjdhLpxu2tXbxkl/QZEaiChtYuc
         /Pjg==
X-Gm-Message-State: APjAAAVzpeKu5KKF0X1nYGWT89o1/z3BYyqz6ibslkiv4dBPgAkxGd2/
	0DGbgowQDzH8zYOYXLsoielQclkCeTmLPFPLKlimIJ5L3nDKHlU7ywBuXdpbbu3LO4/qFw4x/l2
	Cur/KUfiEavQ15tAMzbMZfx3u0EDm/cbyBbk5P5S3wZWJpvR84GTIpG1Dof0wnvFmHw==
X-Received: by 2002:a5e:8418:: with SMTP id h24mr3393031ioj.170.1554369964627;
        Thu, 04 Apr 2019 02:26:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycLm1OOo6kI/TG2CeYmCbuDcmNub3BQIFr9FeIL4KXs+/YMYqEX0Ik04HL+oxgh5Ej8ZOA
X-Received: by 2002:a5e:8418:: with SMTP id h24mr3392996ioj.170.1554369963703;
        Thu, 04 Apr 2019 02:26:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554369963; cv=none;
        d=google.com; s=arc-20160816;
        b=jn1jTyGJ13YA6SgnYpCiV+29JgDUf0cvlOxBzGxXaCwkNyq9VW3ks0+yVUhakkfjF9
         vIhmY9N1a0NJEWh75ira5giQIr7VfYExjQYDPShHT9bbdJZmnlOBvB0C2VDPbYvg6XhK
         Z3tCS/JclhCkOg3gu4s14mkTxOxCVO5ZITHr+LhT7D8lt4K5ujELH7sPdCqpt4erDBj7
         wZdSaCGrYBzEd/fiCfwBpX1eermivjM9WzmtXk8zePzf53Zb/j1GI0LelctzwSSYpViN
         7CxmXB6++U21X2fzmswFhrX9nP4+xSkQ0Oc/+cmegtTPxA2XPRWbMdyQrCF32+Fbw4Nx
         SNNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=X+EiJspXrthvhY7cDQYnv6wc4+xKqln42WsdUBF2ewQ=;
        b=Xu/NBg/ipD1u3/F9MG2OQA8HNoyEIh4PC8c5JXVQbucXaOi0e3tIxPOcFRggBjpNqR
         EyvV8aTvs2wl47Wspvih8zGwo/Tvd1NC6+j+LjG1OLXRb0zzo3bMWfolJcE/aI/ggrkL
         XzNJD/+xmh1JweohBuFVWKPg03JnKq4hMwhnVlHF9BLEoZdUdQ4kb+3Nsw2ppxW4W8Xw
         wfOz5n1nX7AYsZVR3GjO+P/Ci4W7+5G+BPTV80Px/Z1sAyHxcUPEmB+yuL0i6jwZGqA0
         i0VaPJhHzhIWjYuE2J8tYAmT6gUWra4sSiMQrwkQhv2/oT9aOFotKYUUd+KigOUxD0wb
         EQwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=lXimA78f;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n32si10347018jac.105.2019.04.04.02.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 02:26:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=lXimA78f;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=X+EiJspXrthvhY7cDQYnv6wc4+xKqln42WsdUBF2ewQ=; b=lXimA78fwS8UjbrqTeMj6TJtL
	+Y02yuivEU35LV0e7zjb9RR38MHad76DV8JTThj68HG4BTESroqZUnOlMZeizL0f5MWwAWTJ56zRX
	YoLqgzc5aOyb1xJ7LazSoQf+AzftKj30wdmdnwDtJNZSg5Ec2X5NZsY9c227nVZlV+fTdTXdgt5Lp
	BlwRrhXm5gwgz3LPSxFHjuX/3LQTKEIwQ6g8ozwxnmKYDtgvgSkWiINBS2hPO1CganrbSJVUAE/rc
	VMPGXZdcR+R5gBAVsRDKXO8csbsDQqEnl5x7DaGWJv0wHpRkWdOYc4DtO5N1L3TS36/Uhz9ILLZI2
	SwrC9HavQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBycO-0002Bh-1i; Thu, 04 Apr 2019 09:25:08 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 76E92203C12D9; Thu,  4 Apr 2019 11:25:06 +0200 (CEST)
Date: Thu, 4 Apr 2019 11:25:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
	ak@linux.intel.com, liran.alon@oracle.com, keescook@google.com,
	konrad.wilk@oracle.com,
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
	serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
	vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
	yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
	ying.huang@intel.com, zhangshaokun@hisilicon.com,
	iommu@lists.linux-foundation.org, x86@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20190404092506.GC14281@hirez.programming.kicks-ass.net>
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

So if you use the original kmap_atomic/kmap code from i386 and create
an alias per user you can do away with all that.

Now, that leaves you with the fixmap kmap_atomic code, which I also
hate, but it gets rid of a lot of the ugly you introduce in these here
patches.

As to the fixmap kmap_atomic; so fundamentally the PTEs are only used on
a single CPU and therefore CPU local TLB invalidation _should_ suffice.

However, speculation...

Another CPU can speculatively hit upon a fixmap entry for another CPU
and populate it's own TLB entry. Then the TLB invalidate is
insufficient, it leaves a stale entry in a remote TLB.

If the remote CPU then re-uses that fixmap slot to alias another page,
we have two CPUs with different translations for the same VA, a
condition that AMD CPU's dislike enough to machine check on (IIRC).

Actually hitting that is incredibly difficult (we have to have
speculation, fixmap reuse and not get a full TLB invalidate in between),
but, afaict, not impossible.

Your monstrosity from the last patch avoids this particular issue by not
aliasing in this manner, but it comes at the cost of this page-frame
bloat. Also, I'm still not sure there's not other problems with it.

Bah..

