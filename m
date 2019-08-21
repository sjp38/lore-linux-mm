Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6167FC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 10:30:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24EA32339F
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 10:30:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="a8L4Dq/a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24EA32339F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE0FB6B02B9; Wed, 21 Aug 2019 06:30:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A90CA6B02BA; Wed, 21 Aug 2019 06:30:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 982B26B02BB; Wed, 21 Aug 2019 06:30:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0159.hostedemail.com [216.40.44.159])
	by kanga.kvack.org (Postfix) with ESMTP id 77C546B02B9
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 06:30:18 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1DF297589
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:30:18 +0000 (UTC)
X-FDA: 75846065316.02.trees64_3ccc669e46948
X-HE-Tag: trees64_3ccc669e46948
X-Filterd-Recvd-Size: 3772
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:30:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8zp6S8Iv44NclUZi/IYCMzStVxccs6F1yCeJgKpoeH8=; b=a8L4Dq/aCr8gnwdzhMMrkGdX9
	BskOgh+y9z0CTn/F6FSad/M/j6HHWwSy+ZqDnBzj2u9kTLwcuN+giohlH1nNtFjtmDXxRrhKefmHh
	h3qH1yWlfgZLsJgrTF1Jji/uRxBau28zxmgLoHgetvsX4/H+sMV0xcrdLMQBHff1NKbICi8qAPKGn
	g1arbtzq1HcniDUYbJmejwx1T4KCm+SZ810uMKz+he2jHRV8m3cQ8/CGnv74ayQk2zCYXNzVVIc+s
	GdbdE0i7qc8DbfiHZW6VtwVNAUstNyfONn1rY7sDd/CJCG6pLDgSHje1hhbG4sI0it+T37usnkOOc
	fCNzqpNUw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=noisy.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i0Nsb-0002wj-V1; Wed, 21 Aug 2019 10:30:14 +0000
Received: from hirez.programming.kicks-ass.net (hirez.programming.kicks-ass.net [192.168.1.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by noisy.programming.kicks-ass.net (Postfix) with ESMTPS id 23ED2306B81;
	Wed, 21 Aug 2019 12:29:39 +0200 (CEST)
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id BA91920A21FC4; Wed, 21 Aug 2019 12:30:10 +0200 (CEST)
Date: Wed, 21 Aug 2019 12:30:10 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com,
	stable@vger.kernel.org, Joerg Roedel <jroedel@suse.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v2] x86/mm/pti: in pti_clone_pgtable(), increase addr
 properly
Message-ID: <20190821103010.GJ2386@hirez.programming.kicks-ass.net>
References: <20190820202314.1083149-1-songliubraving@fb.com>
 <20190821101008.GX2349@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821101008.GX2349@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 12:10:08PM +0200, Peter Zijlstra wrote:
> On Tue, Aug 20, 2019 at 01:23:14PM -0700, Song Liu wrote:

> > host-5.2-after # grep "x  pmd" /sys/kernel/debug/page_tables/dump_pid
> > 0x0000000000600000-0x0000000000e00000           8M USR ro         PSE         x  pmd
> > 0xffffffff81000000-0xffffffff81e00000          14M     ro         PSE     GLB x  pmd
> > 
> > So after this patch, the 5.2 based kernel has 7 PMDs instead of 1 PMD
> > in 4.16 kernel.
> 
> This basically gives rise to more questions than it provides answers.
> You seem to have 'forgotten' to provide the equivalent mappings on the
> two older kernels. The fact that they're not PMD is evident, but it
> would be very good to know what is mapped, and what -- if anything --
> lives in the holes we've (accidentally) created.
> 
> Can you please provide more complete mappings? Basically provide the
> whole cpu_entry_area mapping.

I tried on my local machine and:

  cat /debug/page_tables/kernel | awk '/^---/ { p=0 } /CPU entry/ { p=1 } { if (p) print $0 }' > ~/cea-{before,after}.txt

resulted in _identical_ files ?!?!

Can you share your before and after dumps?

