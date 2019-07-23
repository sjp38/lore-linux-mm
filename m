Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88491C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:11:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B641218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:11:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="I9Ao+ylY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B641218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9E048E0006; Tue, 23 Jul 2019 14:11:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D27878E0002; Tue, 23 Jul 2019 14:11:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEF478E0006; Tue, 23 Jul 2019 14:11:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83EF28E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:11:26 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y66so26704401pfb.21
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:11:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PtkDHY09nL+AaT/QB8borVWjMlOkOsCWyGNywWHu9dY=;
        b=g05vlnRTCv0UYE7a9hHzjN3cJA3ETg7eAqQAdgRZI4aWJJdgMzs24CrkmEym12ZMd5
         ewbbzUetDYkAqj7UkGDvAimTCZ0+6Kz6va4t3qaIsRtXlo9I61ahGiyhdgtAAYGdUKQL
         jsKKMqf1Ibs63gLl5psZYxgHC3jbHc4ftKbZUZQ8Cfj9VQi6qhIS6iCb4OIK7iaodSBG
         mZ+HQMj8y9tTvHu0pZ93H+8eVplyFamPhTv8EEguCvo2Faq53KBV9Svf0MpfP7MTbySa
         HjjzFiDHFdQvxJT1rPF7mxSvV5PMykXohPQRIJUC3OB58wnOIJzE0+rXiZdwOSKQrC/Y
         3qFg==
X-Gm-Message-State: APjAAAWbNRccw0+SfJsMjngO5M58qgukBG4J5tm7pncyXc+JRXMbd+BJ
	TNLWQnOcmuQVD6U0CtDd6eCR9ezqKROx4DNURYHqsw1h9gTzZpNj/q2Qly0ktConGZhtdXN893w
	QcMuebKH9iMXh85qts5PVrH5JE9AX6pBIABLi7c/BMsqM8wCGzkJnNTpOsSY1OExpXA==
X-Received: by 2002:a17:90a:24ac:: with SMTP id i41mr82591927pje.124.1563905486168;
        Tue, 23 Jul 2019 11:11:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3nCl8+ecfheHnuECNyT46y6ZwnCjMjJnl+ata+dWtRmjGZj1Y3wXiW/FzbddpNHpto/Cx
X-Received: by 2002:a17:90a:24ac:: with SMTP id i41mr82591880pje.124.1563905485573;
        Tue, 23 Jul 2019 11:11:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563905485; cv=none;
        d=google.com; s=arc-20160816;
        b=vleG4K3kno30vXVOI9ywTsjS85QL2E//oT0tE9D7pbaCcS3Woh5pEqASteJfZi13qn
         TRZaTzfvueRwrGdpSVJ+jteQRtKJeMvJsj7XuVfvzrokM0mgTvxXbOOONohsEWAOyOqF
         7KJXl2x/Vs01C0CYViF0XubHYryIqWKmSSDeUsLyxA8Jsd0JE2GUTBPMpLl8rh9u9vdK
         H0MhwubbRVl/+9Spfvfvqgt/ZZNLMbHIYtJMTM5BdEZTAfH3VlGLhzalTUqo+TMi42nd
         qST1F8NpJ0ym6Q0FFxmpFec5P9+KUPQSHBQvP+A0MRKosJuIWPg+NDzq9O5KCP3mpDcI
         46NA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PtkDHY09nL+AaT/QB8borVWjMlOkOsCWyGNywWHu9dY=;
        b=AshguKRYI+eIe9UgIQ7YxNSgWl6YiSotdOIt5rk8stwMfnpLw1jartIhuBBKbl95uc
         Q5FU/Jjd+2qsid6Nl3Su/OC6782Rb1Wbi27xXMbBGQG/GEuHAYOCvyYF+gRNnoAGO/As
         4sVbAg77MsI6X+F3LTKPagI25T5t4aE9ejpuWVUmMWcN5VsfwhXRIasxMWnMfberW+T3
         6NcNtrfBnF7Flm92YzDfY/r1gHamJEK8rZw7GW2ZvheNIXsXhP/ejDylWCdMJjcIo6dp
         jZV/tyAM6gFR3bVfzd/a4LsTLP1uREN77D8VamoDVqpLPF3n7UexY8dzrIPSU851nLNg
         Eraw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=I9Ao+ylY;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w5si13062332pfi.264.2019.07.23.11.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 11:11:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=I9Ao+ylY;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PtkDHY09nL+AaT/QB8borVWjMlOkOsCWyGNywWHu9dY=; b=I9Ao+ylYbfPsG82DBSU7ktLiX
	4mFNsEoBkXYA6Zop7f+67r/JWnHsYBUo/JyWrJpbf9ac4U4ScV3Ke117Av1aZtxmu0TBOFmYcBkSX
	K1fdaIEgelFroiIQKV+fqL+/kaCzKTC1C3gn8Z1aqPRDi1OHonx5IBVpedCDuyEyFG7E7SGavpPkm
	9OoBLh58J+z9Rup71QNO/XnauElmstPsj8Cm6gJkP0AaC0xJ2RP6FDwsZexddr/2Q4apdT4HaCUsa
	ntB+tu18mYpYM2/hWkot0ngAEKl7DEOkkWPcUWRKTBM1qirdtaNDVWRkdk9a7UQFD7m5po2KPKLV4
	+pUcEueiQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hpzG0-00019M-Np; Tue, 23 Jul 2019 18:11:24 +0000
Date: Tue, 23 Jul 2019 11:11:24 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
	lhenriques@suse.com, cmaiolino@redhat.com,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm: check for sleepable context in kvfree
Message-ID: <20190723181124.GM363@bombadil.infradead.org>
References: <20190723131212.445-1-jlayton@kernel.org>
 <3622a5fe9f13ddfd15b262dbeda700a26c395c2a.camel@kernel.org>
 <20190723175543.GL363@bombadil.infradead.org>
 <f43c131d9b635994aafed15cb72308b32d2eef67.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f43c131d9b635994aafed15cb72308b32d2eef67.camel@kernel.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 02:05:11PM -0400, Jeff Layton wrote:
> On Tue, 2019-07-23 at 10:55 -0700, Matthew Wilcox wrote:
> > > HCH points out that xfs uses kvfree as a generic "free this no matter
> > > what it is" sort of wrapper and expects the callers to work out whether
> > > they might be freeing a vmalloc'ed address. If that sort of usage turns
> > > out to be prevalent, then we may need another approach to clean this up.
> > 
> > I think it's a bit of a landmine, to be honest.  How about we have kvfree()
> > call vfree_atomic() instead?
> 
> Not a bad idea, though it means more overhead for the vfree case.
> 
> Since we're spitballing here...could we have kvfree figure out whether
> it's running in a context where it would need to queue it instead and
> only do it in that case?
> 
> We currently have to figure that out for the might_sleep_if anyway. We
> could just have it DTRT instead of printk'ing and dumping the stack in
> that case.

I don't think we have a generic way to determine if we're currently
holding a spinlock.  ie this can fail:

spin_lock(&my_lock);
kvfree(p);
spin_unlock(&my_lock);

If we're preemptible, we can check the preempt count, but !CONFIG_PREEMPT
doesn't record the number of spinlocks currently taken.

