Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23851C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:30:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4425208C2
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:30:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mKtDdwld"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4425208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 705196B0283; Mon, 13 May 2019 07:30:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B5856B0284; Mon, 13 May 2019 07:30:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A3596B0285; Mon, 13 May 2019 07:30:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4CA6B0283
	for <linux-mm@kvack.org>; Mon, 13 May 2019 07:30:13 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id t196so11913969ita.7
        for <linux-mm@kvack.org>; Mon, 13 May 2019 04:30:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=tSqs9AMTThdU8qxkTIlNJvkPD11kfEkOfLcrJZGQml0=;
        b=Q/IqF2Cn/Un1a/SWluMbSjPud+JAchdtzIcfkIxoQRJ2czmebdiNS8c/PhRQJkYYhf
         oKG1Rcqt1dUC50vSPSEBVpQNyaJ0pZopjtVAMxPUin7+2439TNqqaZOYmj++On9oyKCI
         XucImqTN36X/a/KUqsBE6dg4wu/DRuLgpj8rdRJN1+N6j4n6vd6oE5npxhTiTR9p9bro
         FrpibLaEz4on0i1az1cCFfGeSApHmdYYjtk8nB41nRAi+t9Xxkd/EVqCP2aHkh076MuE
         S1GMbByo/sUxP1jgilBtuydhZnEfI+GzcJQUhtwxJVH4x++79PG6+k0OELZ/wgHkMDU5
         n6Tw==
X-Gm-Message-State: APjAAAWUHDtygXc6T9y5wlB3S6bfMoWGObgwYjqhmbqPBH4RFw+NQSIC
	3DPYnoajz//eqMXNkMews9I5kB91FgFr1e7PnEiWy3yCD4591JfxEZuUaeJ06meu7A8M4xqElj4
	HEhvBB48vohrCiFs1ckLkhYZkx98ZaOmxZktVwlCtX+DW+0BHyE4+yHZCZLjggBuawg==
X-Received: by 2002:a6b:9306:: with SMTP id v6mr16036034iod.278.1557747013034;
        Mon, 13 May 2019 04:30:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXTceVLXxvfmfSZS3TsnUwtK8O8t5Hj42ybvG3IrYvjj4+hygOJ+1DTekHzBgfSANG58a+
X-Received: by 2002:a6b:9306:: with SMTP id v6mr16035999iod.278.1557747012457;
        Mon, 13 May 2019 04:30:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557747012; cv=none;
        d=google.com; s=arc-20160816;
        b=XePSz/Wudjqw/fYvGWxVwAJSwYkTZWTIfzTwyCK19ZXVKn3WWYkK70qr0+XU0Afc9j
         jk71+7VTvfXhnoNr/4v+JAZN+B+EH4/Xn6DOeLlHErMnt1v4Zz80o7QOQS6WGffHFfwZ
         A6H8+9bNCtYN7Y56YaVOls7/h13p0A44GZ9qnxfgJxXJpzpGmIUcmr9OtZFqDPdvFdQc
         PNKk7STDW4igJN2udytnyWcgT2tM1MM66wN1Mo8K1z9bJHcA7UJ+3YzUqJDCtFQkEJHE
         mC1ec49cQDzpherUKxCIYfkzGG3RTNQQPtzuklUewjLVXoK8Uw7t8iPKjGyoG1G50PJc
         6DcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=tSqs9AMTThdU8qxkTIlNJvkPD11kfEkOfLcrJZGQml0=;
        b=eU1+mkkejAlKCkOdLs/3onqOpIPXqSLzwTtk7qBgxMyVIsmBOyecpPTOytP4cXBuwI
         2IVnyrkiSVxxBaytYhwAmPZJkQlWXNfUIIRjjEhMIwDRcng9o9WaKQjpgAJek/7NQ8Bf
         eg6l3CQyUDyMR0hlJmTpgM47+n/Ei9DVceo2Zn3XoU+bxN/eVTKDkZ4OCWoOOyI78XMW
         3fVu8gIPi4siHZnSy23TeHuPtQc47bMQMzYTEFPYg6gkYPzD9A2X1iODhDYKKcOy45BB
         ilnvNOQsaBhvXEfrfTo+5x/P3NGO3xVnglvI9nvAHfazXQE8JTWU1kaj42PuQOE4cfnG
         xUhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=mKtDdwld;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n64si3277601itn.79.2019.05.13.04.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 04:30:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=mKtDdwld;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=tSqs9AMTThdU8qxkTIlNJvkPD11kfEkOfLcrJZGQml0=; b=mKtDdwldcN/kKtSFZ0OV1rUjFo
	L0YIrcHbDGvnobIZdBJsGGRK/3OtPHsv+pwLV+N1crHBYJixbIy69FalNoT/p/4bcCN1cV5IHVsPx
	1dNG/4Vk/9aCZc92b8CJgD+YNhgSRAcPNl3KZ/TLk9E74FIR2Az+lbD+LU+GGH7oobSmE/E+yuxCj
	3pUqBNcyeOrlFbqTfaU5n1OAQ1KlarZ24EXN5aLfmwf9029FrgMZyw06lw2T8ATqOEKpW1Zl5e5dr
	XA37mg6cSNUgXrYFzhKxP6jHEXXxL378IkxE64xhKU9bPeNOsQZxvzCakjNE7FqeoqOM0Usnku0qB
	J1UbWAYw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQ99k-0006em-4j; Mon, 13 May 2019 11:30:08 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E04FD2029F87D; Mon, 13 May 2019 13:30:06 +0200 (CEST)
Date: Mon, 13 May 2019 13:30:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Nadav Amit <namit@vmware.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	"jstancek@redhat.com" <jstancek@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@gmail.com>, Minchan Kim <minchan@kernel.org>,
	Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190513113006.GP2623@hirez.programming.kicks-ass.net>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <04668E51-FD87-4D53-A066-5A35ABC3A0D6@vmware.com>
 <20190509191120.GD2623@hirez.programming.kicks-ass.net>
 <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
 <20190513083606.GL2623@hirez.programming.kicks-ass.net>
 <75FD46B2-2E0C-41F2-9308-AB68C8780E33@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <75FD46B2-2E0C-41F2-9308-AB68C8780E33@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 09:11:38AM +0000, Nadav Amit wrote:
> BTW: sometimes you don’t see the effect of these full TLB flushes as much in
> VMs. I encountered a strange phenomenon at the time - INVLPG for an
> arbitrary page cause my Haswell machine flush the entire TLB, when the
> INVLPG was issued inside a VM. It took me quite some time to analyze this
> problem. Eventually Intel told me that’s part of what is called “page
> fracturing” - if the host uses 4k pages in the EPT, they (usually) need to
> flush the entire TLB for any INVLPG. That’s happens since they don’t know
> the size of the flushed page.

Cute... if only they'd given us an interface to tell them... :-)

