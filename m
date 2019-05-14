Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C696CC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 11:43:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CB1720818
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 11:43:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OcAcBuO+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CB1720818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A89026B0005; Tue, 14 May 2019 07:43:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A12906B0006; Tue, 14 May 2019 07:43:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B3576B0007; Tue, 14 May 2019 07:43:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4257A6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 07:43:54 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id b19so3461627wrh.17
        for <linux-mm@kvack.org>; Tue, 14 May 2019 04:43:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BhD3OnVLQKwBnDmageAbFQrzsjIjd55x6Z/qXnxU1kc=;
        b=Oe/kZFJY8dFzxhmttygKczOLEoeRbv8gxRTtoBYXhiaIVdF05Imp37MASHL6wlD+6T
         6Mle1JjFVY+b1H+Uw3gkBg6zK/yClb56lfyBd6TEqs3tVgsb/Q3aixWanyXED+03Cetm
         A+7LlrpOi9xNud7Q9YJSOj8KUlOkCNvWICMxxxCbqDByfkSPwXBwN7E6YKNfFQ2FZ4Py
         Xb/Zxno+SyUuxM/amqmpjQLfrz7eJN9JI86CPk9Iw6NJwnfwUkTekKPNHy7RY906oHec
         5Dmr07tIM6X5ix+UO6FO2wtmRgh/VWEP14ubKrfxFVL/v0bkW3AH38gn3T6S87uyGX8z
         Ph8w==
X-Gm-Message-State: APjAAAU4j40FwzIc3eqDkjgF6GC11rBTcZKu9ROfvpmTebn/FqlQDhEe
	4z8taUShiRXiVsFOe5lqmgZYzXFeuzSvtzHhURg0o/aoMui5z+qPPWNbiqdN5xNEsJ8a0oQyhts
	bwTXMjxgL9Y4sdwyQ5+RX5RP/7xEg822+GuWI5XIcb7jBrDjCO//as/V0kmXb46CQIA==
X-Received: by 2002:a7b:c5c7:: with SMTP id n7mr20007372wmk.9.1557834233752;
        Tue, 14 May 2019 04:43:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybB7MF2Iz+PGn11uY2kUbUuTAB+L03XRU31wZ8DQZC/0tGjz9BKpRPuh1BsFu4WwlF57Fm
X-Received: by 2002:a7b:c5c7:: with SMTP id n7mr20007331wmk.9.1557834232841;
        Tue, 14 May 2019 04:43:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557834232; cv=none;
        d=google.com; s=arc-20160816;
        b=T6Sc4qkdV5N44Jr6oZYZANGrWlkabKZCpxTk2yUC31zbvQR6InEHIDnmdN4OK8gPUL
         a78rZ5CZMI9xBU9YfwwcV7YT3YaBibSiJlv2dSC2L6Dm88ppdIh9/Z40dE+8Z1Beqp4F
         nMlCum0DP01eNlQwoXTAoUWD+vrVErspNQcGo/IhC1rYuC6+JQh5DxqSvLYPykO2kNWR
         QJ3C05omjOvw2K5bPbqrxXZgjiOXLm/njOC8Wka5tU0yYU55qOwEGg1vdgA11wGB6rvH
         YpDhewLj5oTrNSvfpujNeymU9C8mCaa/FdgxOee+UP6Am5SyXEPIksSmFcjBHXfvIEh+
         N04A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BhD3OnVLQKwBnDmageAbFQrzsjIjd55x6Z/qXnxU1kc=;
        b=wTQPdaQpOWNhHObwPeIllEGgKDfzQ0nUsqrHMQvcEJgq/lGZB1STPZQha4LwAdkCuW
         mwQIT6K8iNsdryCPMqns4X3TmSr6LAZ2bgO4NoMaVGIWc0Bc97gCCCfL/mtrgtQjIhFc
         CotwD2Pqg0NvpB9s/CpjsFGBzPh8Gyif0/WZePdoo/pD7LuCiXFKO/pWMnv/h3VDcv/C
         U2YLcPpOCcGnTzJ3Ciu14kFUIBwuN2yJolAfzGIgoSrKkpDIIakz7lkRlDRe2nYdgNAZ
         H4oVMACgg5Ra2L0XAk1Ad32Rbc8Jf0HqaH3fs6OhwK+HGdP30DJknXqODlTM30W1RFrr
         2g4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=OcAcBuO+;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q14si12325000wrv.156.2019.05.14.04.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 04:43:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=OcAcBuO+;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=BhD3OnVLQKwBnDmageAbFQrzsjIjd55x6Z/qXnxU1kc=; b=OcAcBuO+E2YaqxTh3wmNWEvgt
	2g29keOO2R7/iXEpa20Ny/fs7AIjc/V3rlYKvWyJ61CCBW5dDp7aRqQVXg/upu4BdfdrtNfW5sDmx
	DwyT4egWskNMSnKAovv3pM52FDdLby2NbIqXpuKIG5a6XdOtPlCDgCBJLlndATU44YwRY8ZUAnMFv
	EFbhmIs+bNDjyydTm6CYE1cHqnX3nCrIL18yxSjPeNmgpLuMJ8TXgETsY23iduPliKI/nC4uLiYDy
	vYGNTdy6oga4h32Cv0/AFpgyMz4F4dpmGQ/V3d5gz9MPIux5zNPOABopjcu1/56rtQNUuPj/h8U1d
	3Ab6xsRhA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQVqT-0007fJ-Vr; Tue, 14 May 2019 11:43:46 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 8D0FC2029F877; Tue, 14 May 2019 13:43:43 +0200 (CEST)
Date: Tue, 14 May 2019 13:43:43 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Nadav Amit <namit@vmware.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	Will Deacon <will.deacon@arm.com>,
	"jstancek@redhat.com" <jstancek@redhat.com>,
	"minchan@kernel.org" <minchan@kernel.org>,
	"mgorman@suse.de" <mgorman@suse.de>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190514114343.GN2589@hirez.programming.kicks-ass.net>
References: <45c6096e-c3e0-4058-8669-75fbba415e07@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45c6096e-c3e0-4058-8669-75fbba415e07@email.android.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 02:01:34AM +0000, Nadav Amit wrote:
> > diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> > index 99740e1dd273..cc251422d307 100644
> > --- a/mm/mmu_gather.c
> > +++ b/mm/mmu_gather.c
> > @@ -251,8 +251,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> >         * forcefully if we detect parallel PTE batching threads.
> >         */
> >        if (mm_tlb_flush_nested(tlb->mm)) {
> > +             tlb->fullmm = 1;
> >                __tlb_reset_range(tlb);
> > -             __tlb_adjust_range(tlb, start, end - start);
> > +             tlb->freed_tables = 1;
> >        }
> >
> >        tlb_flush_mmu(tlb);
> 
> 
> I think that this should have set need_flush_all and not fullmm.

Difficult, mmu_gather::need_flush_all is arch specific and not everybody
implements it.

And while mmu_gather::fullmm isn't strictly correct either; we can
(ab)use it here, because at tlb_finish_mmu() time the differences don't
matter anymore.

