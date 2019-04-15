Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69537C10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 21:22:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BCF6218DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 21:22:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BCF6218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3E5F6B0003; Mon, 15 Apr 2019 17:22:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1E626B0006; Mon, 15 Apr 2019 17:22:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDD8A6B0007; Mon, 15 Apr 2019 17:22:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE4B6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 17:22:24 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id f67so16499872wme.3
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 14:22:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=N557HIANKhXGKUJ4Ge47thMexocixYRlmLPCoH7ScnM=;
        b=CEnOOHYRdbX1Y/4hYMDUMfgfg3CLYlmn5NSnrLJzPV/i057S/W8i3iMIfSjJbJLGqw
         jbWTTxV9Gb8yjqwASYzovAkbCGgxDORmFlHOhthDMj1YNWoEiH2Ct5nGl/T16tRXel+F
         nQOdzbHOb4Qtt696Xehf92Lm6131aZ/x0/SUkhAsWSsn+4VPIi10hUHvnJurgjDtd3ax
         RjvHx3qypgjldPOsdQeuk2O4GGe4FSpP2OQ4VLQvX9JtqentMmSZ5d2opOUQsqXI56bV
         OqW+Vz9gj16W+dgDSFIQHYA8ghxR7upH/3UkTq/NmTlJM+vtkQte+P/gaDdwUARuy5ly
         3yYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXgi8+Fbbr2oKdMhuIIKw0nm+0ngk/IN5FDs1GLHZ4XWIqt+vyV
	ciLqi7s5oJRsUiQ7wdHQLWKwQX8N58SfSzpFNILKKjSa71Zv+ZY1lwprAmd1FXss59qDVs6mY1D
	I1QD09IFU+T5H1apvr+afiD3HMFoGnYoAdwQ7soAK4+PVmjC2t1n7vsfW1XlPo27uVQ==
X-Received: by 2002:a1c:804c:: with SMTP id b73mr22727939wmd.116.1555363344023;
        Mon, 15 Apr 2019 14:22:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySnSzxjn2yf5ssjWxje//6aDJYmndv5JO/vXlQHRoJ1+vG/Se5pHsPTU81JgiaxeO4uOPC
X-Received: by 2002:a1c:804c:: with SMTP id b73mr22727926wmd.116.1555363343355;
        Mon, 15 Apr 2019 14:22:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555363343; cv=none;
        d=google.com; s=arc-20160816;
        b=ESd9+F36ftHmTs3BbwP9IYRmjoARVijLI6BN2l5iZ0FYLdtA2DVbEVO45x/FpXZyt0
         S7ApQVTmEesShORRWrCytzIyvTwhYRSGRJNY2ynHo63dwiU0vNFi2eHq7zAAz1+cOe/b
         dlWJaRZw7fAIGiQ7mHUmFGfk40UcgdULlI+Dwb8XuoRNdy0VyJl24uMwe01QGYGkHIf7
         IPnBxKzDBufbsFHM+Wi1O1HYGxr2tCrZVXlj20riGjOYRUxXMPGfqxilh7L9OsBKJQL6
         Id2f9z+oApc+960lRlHHW0U9aG0RuYqpbvBmkRU/KH2Wkz3VEKHtw7j0is/1Mwz9qY+s
         o56A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=N557HIANKhXGKUJ4Ge47thMexocixYRlmLPCoH7ScnM=;
        b=bMi1zAgGLXqHQizFaEvydTMtkZYW22T/9NkVRfJ7ZYZZItVXEj3Vem0PNca56T+PSC
         BtBLJfQe3U12VQoQiQx1D2DHslvaso5vHvWu3MBzEpaPKiz9PWezQH2x1sNAB2yNECpM
         4s41RVLITVzHstGNLZTn4Nxykbiai2bWLIh8YxFeqqB1CFIcCN2+IYXCVi10J4Q/Qfnc
         yd5UY8Bk7dYs0t0TIah4B+jz5A3eFrNh9BqGfWHc3A1ln3va2NEs9zxD5f6zuwKqWA1l
         a/Fw++mDbUvf610HXU2D5G9T17C2832fpbPO8rYPwmtGI83K+LECGNaLZW+p0W9wQuI6
         7XEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h6si32346883wru.130.2019.04.15.14.22.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Apr 2019 14:22:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hG93S-0005wV-Aq; Mon, 15 Apr 2019 23:22:18 +0200
Date: Mon, 15 Apr 2019 23:22:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Andy Lutomirski <luto@kernel.org>
cc: Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
    X86 ML <x86@kernel.org>, 
    Sean Christopherson <sean.j.christopherson@intel.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch V4 01/32] mm/slab: Fix broken stack trace storage
In-Reply-To: <CALCETrXLa9ec8Lcz2WPML8qQiStpTtDSAGkW=Rv9bMSiunNNMw@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1904152320540.1806@nanos.tec.linutronix.de>
References: <20190414155936.679808307@linutronix.de> <20190414160143.591255977@linutronix.de> <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com> <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de> <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
 <20190415132339.wiqyzygqklliyml7@treble> <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de> <20190415161657.2zwboghblj5ducux@treble> <CALCETrXLa9ec8Lcz2WPML8qQiStpTtDSAGkW=Rv9bMSiunNNMw@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Apr 2019, Andy Lutomirski wrote:
> On Mon, Apr 15, 2019 at 9:17 AM Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> > On Mon, Apr 15, 2019 at 06:07:44PM +0200, Thomas Gleixner wrote:
> > > > Looks like stack_trace.nr_entries isn't initialized?  (though this code
> > > > gets eventually replaced by a later patch)
> > >
> > > struct initializer initialized the non mentioned fields to 0, if I'm not
> > > totally mistaken.
> >
> > Hm, it seems you are correct.  And I thought I knew C.
> >
> > > > Who actually reads this stack trace?  I couldn't find a consumer.
> > >
> > > It's stored directly in the memory pointed to by @addr and that's the freed
> > > cache memory. If that is used later (UAF) then the stack trace can be
> > > printed to see where it was freed.
> >
> > Right... but who reads it?
> 
> That seems like a reasonable question.  After some grepping and some
> git searching, it looks like there might not be any users.  I found

Anymore. There was something 10y+ ago...

> SLAB_STORE_USER, but that seems to be independent.
> 
> So maybe the whole mess should just be deleted.  If anyone ever
> notices, they can re-add it better.

No objections from my side, but the mm people might have opinions.

Thanks,

	tglx

