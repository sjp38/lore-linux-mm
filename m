Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F03B6C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 12:53:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAE5A206A3
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 12:53:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UUmN5Ppr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAE5A206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F6BE8E0003; Mon, 18 Feb 2019 07:53:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37F498E0002; Mon, 18 Feb 2019 07:53:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 247E28E0003; Mon, 18 Feb 2019 07:53:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2DC48E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 07:53:45 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id o9so7659844wra.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:53:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=o9duW35qkVBByBckeYSVEKqqj00p/T7Hi5MwdEAEhQc=;
        b=gK+PnWYzmlunrur+CTRp2OjHpRjymhXHl2O+nw9yVHvBvH727K1ONqFUzMyDPU732w
         sKUEDnlnjc+QNOPOWJLcpMLwQwRwy6+3gE/JVnoIZQhZ1YJBAONPMpEuZw4o/tE8ulGe
         mco2KQSTtIPrcpmx65AxQVKNJVgZA04TclMno0zAe65VBo056WVY7Ok9R4ZqLHRPfBCT
         /3KGoMKZ3KZsxxYECg0lveck6vZJUHlg06RoTLZqpkwrQ5DUu3V1kwnwnnndkW2BK8uk
         PZtQK/tqfdl8vrWtMlQA840epcMaXv2ZMLoCAfoQpJ9CQxGnTj8HUR5RkYCiUitK+ziJ
         h22A==
X-Gm-Message-State: AHQUAuYAGLZ1Jd1RvKhzBzi7yzzx/zLm/DzyCggxy8/nIP+JkEHipUBs
	0PRlXJd36sCBQ0OKpT6QQfHMSDKWpUiKflArlEecHN8nVrqopUE0uPdRiUaTlCJLy/5rsjR2tpQ
	7csy1U13nChy9J3z5ExAG7mH+lnOZd1fvKHnGgE8ikrUKSY+/EUURBLfLOzhiUdlrFg==
X-Received: by 2002:adf:eb85:: with SMTP id t5mr16027057wrn.157.1550494425289;
        Mon, 18 Feb 2019 04:53:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaB//z43C8Dy5TXd0PN7a26ntxXVGEoHbXELnVc0QP58Q7tV+oMPWNDfdd6VqTMTlqxvxTl
X-Received: by 2002:adf:eb85:: with SMTP id t5mr16027024wrn.157.1550494424563;
        Mon, 18 Feb 2019 04:53:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550494424; cv=none;
        d=google.com; s=arc-20160816;
        b=lmZzZhlxSk0Y1fbqdW7iPpQRdW2LukaJZhJhYwIT6U7kQkqFJNeIl6Db+/5fRMYZH6
         g/3MGl8Qc3eLE5g3/O2fzxb43Ooy0882jU77kHJvQcbiE+tJjPwjUERVyCmDJPgwGGiu
         qbLZr4AZq0OKQeBcrmUJfJ7S5L8RKz1Y5GVS+kpn+y8OAx1mdfRbex+kD6Nan/AG2N+i
         3tatMAVVVRpRLS0beVMpYuLVAe9EOkQHnRgtyMb9FwjY+2ZC03QIkUmCeVqKeZD4HBM6
         lolE133aqf0xhKupBFQCnq27xtgRpB1JgqzOu8pYN6xbz9K7W8VMhmfbZxfF8jrdRtJO
         pMxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=o9duW35qkVBByBckeYSVEKqqj00p/T7Hi5MwdEAEhQc=;
        b=pAh14eafY4G8yb3wHe1oYrFrzwvAdsz9hIhk+bG25HV2j2VtYbNsffk4sgAlu063uK
         dfEfdVpyUX9iviYZoVda8QLDpO1xt9s7ps4Wh//jr42L5Upnf7q0exdcOi2gd86uKMI2
         8iiiWjp1AaKW30/0fuME4B7jJyhAhLnnZl8i/+5J/13e3Oo/irZ9OHvw1KHPpzvrcttv
         tKpMeEm+IGz3cV9RBqS1WKhG+hFlwrv6Ata28MEyW0Fk/W+y0IneKGV54DLVs/KwInSy
         x1vPluIIffuavRdVmPQgmR5DLcpqp6fgRNPY9wH3/NNgvHcXeR4a1yYZzHZpYyZmQy64
         8dQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=UUmN5Ppr;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x17si8843381wru.399.2019.02.18.04.53.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 04:53:42 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=UUmN5Ppr;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=o9duW35qkVBByBckeYSVEKqqj00p/T7Hi5MwdEAEhQc=; b=UUmN5PprHGZoQhOVHvZZxxJb6
	hHw50LSLCBROSQL9dckvU4QK0G/XtpZkGlOE+IrG+Y3MjB8IcVVJNHqDu2HdKKRDJA+2dmdwNvo15
	QwQpbpiQ16sHm+WUw5EUSP0G9AE4KToH8ivrK8ZBdcvtxBcc+HLCzZHeDamtsfBX8gS0Em6FACMYx
	68vR6PCWS0O5qe7x/LTU2hEqxCztkwJImv7YffHR/lCLtRvtVOd2imCaEFcFFI+1zU3HPd7ZVlQsK
	POL7d7amdHmnvg8t+qHVMR96ym+N+D/NMxmBIr0C85eSdoo2UoOIgwOv7pgu8BDdKkFfUU4Ns+nfL
	vsFqBi97Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gviQL-0006Mc-Hs; Mon, 18 Feb 2019 12:53:29 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0F9C9286A33C8; Mon, 18 Feb 2019 13:53:27 +0100 (CET)
Date: Mon, 18 Feb 2019 13:53:27 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Mark Rutland <Mark.Rutland@arm.com>
Cc: Steven Price <Steven.Price@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"x86@kernel.org" <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <Will.Deacon@arm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <James.Morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Subject: Re: [PATCH 03/13] mm: Add generic p?d_large() macros
Message-ID: <20190218125327.GT32494@hirez.programming.kicks-ass.net>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-4-steven.price@arm.com>
 <20190218111421.GC8036@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218111421.GC8036@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 11:14:23AM +0000, Mark Rutland wrote:
> > +#ifndef pgd_large
> > +#define pgd_large(x)0
> > +#endif
> > +#ifndef pud_large
> > +#define pud_large(x)0
> > +#endif
> > +#ifndef pmd_large
> > +#define pmd_large(x)0
> > +#endif
> 
> It might be worth a comment defining the semantics of these, e.g. how
> they differ from p?d_huge() and p?d_trans_huge().

Yes; I took it to mean any large page mapping, so it would explicitly
include huge and thp.


