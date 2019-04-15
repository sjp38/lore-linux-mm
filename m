Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72E37C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 16:21:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B3822075B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 16:21:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DblUgg0M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B3822075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD53B6B0007; Mon, 15 Apr 2019 12:21:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B84656B0008; Mon, 15 Apr 2019 12:21:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4E496B000A; Mon, 15 Apr 2019 12:21:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 557216B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 12:21:54 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f15so16170465wrq.0
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 09:21:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dqrr3CkKLNtBh20lOnWpTx6Xh80kM8mkgkJB9rxuKGI=;
        b=Se1ksL8VqsLAi0ewzDczJEaD2qSP8Q068pHQrq1SGCytH3M2uy+JoQugmG6aAvQ7+g
         gdUSrY5QCCuZXGU2lLT94e2lME2tNmM0sQ5j24LzHYq5jkaN2fyMdr8BtFGj38ZhUJY+
         X/JR1CAhUl+ztZTy1uZbzXzMB93Job+sncKyqaQ6yAFgq/TUwqwQYU06g5hV+k2fPkRs
         iog9sG8bpaxzid6akjRyhbboHqeC4G6cuVnp1gsbFKXh3IRQIDsR5CUrXULYJTHoN6eZ
         jacW9ZZSamkQu/h3pL437VIztC7/40OK7jKtVsMYK6K0IY+vy7+EnroiGa7lDl8XgGIR
         HpuQ==
X-Gm-Message-State: APjAAAVk7zhxvre5czmxxLXKqUou5i7FCHj/2kbEvlhxrXZGCjuOWkuK
	Ld2YTk5/nmXMxXzoTzEHzsY5mrvP5H8mBQWZIgfuo46oL/W6/5ireW9z91GHQ4uPo/8SOsOZgO1
	Pb3ldPpK0VpG/qdItfg+s0lVOhI1KW4A56v0ZR5ZT6ddB8vyfACsE7auupXsbuWkL2w==
X-Received: by 2002:adf:f285:: with SMTP id k5mr34300668wro.110.1555345313853;
        Mon, 15 Apr 2019 09:21:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxGKHeCIrqv2kNElXL5g9gZUKnrLH7WF6NxS/k67xN62x3D18wjVE7zF03c/W7w21hDUyZ
X-Received: by 2002:adf:f285:: with SMTP id k5mr34300624wro.110.1555345313237;
        Mon, 15 Apr 2019 09:21:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555345313; cv=none;
        d=google.com; s=arc-20160816;
        b=c2vHnpwHzF7mVDFig0kZhaknwZNAi8XgIMhV93lOaeYm8gUJZkBKsLMCNMzoVgqriO
         KoyfEzEv038aRKQJHKe6NLW67wjMHnzXgMvKhvmpXHc7H4W7FEVGY++pQWeVIAEKwf6C
         s6bDoqRDt/ow09mkVsrkAceZAfYVkV3xLi2qgJVcv+nCOSTSaXSZCbUGKothCUYEi/H+
         h88p/FsU0lbf41VDmKdn11XLnnOXCvYxMLI+TjafzP8aK4cLstc0+HTDS2V6A5FtYY6K
         BMpAJRmzUzG+SLt+cdhXb1kkct2rmizXuYj4C2G3084RwmL/EngktkfaLN5LcCM1r1dN
         6SWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dqrr3CkKLNtBh20lOnWpTx6Xh80kM8mkgkJB9rxuKGI=;
        b=qhJFTCkTRojhRzktnshk222VNVq106cpUKEUabl6QrY2eyvGmrVlVxPaTiUu2KV8Qj
         fJhbyMp4Qn+hup0KGWdAjjnUwXpb8HdvCB7E/HAWHmzs3zWvNwaY2MOaicUGy7D0jMQ0
         3X9Qf9GA3o+PBjBjXFVtP07UDBziUZGE252unVHYunaFBSp2SOMLu/+MSUPjL12yv3cW
         RbMJidUuPm6WBKbZJAy5VUVzyZyP/nIaW9pxNlx51NSLyi9BRuDNHvOXpSafsVqMs9aE
         uH22VMtS2QxjE6MxO5SXvDtBjmj2nWnp3C+GnULloJ23UL/F2gr9qycZo3ygjR1fXsI2
         Kb5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=DblUgg0M;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f136si11620528wmf.198.2019.04.15.09.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Apr 2019 09:21:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=DblUgg0M;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dqrr3CkKLNtBh20lOnWpTx6Xh80kM8mkgkJB9rxuKGI=; b=DblUgg0MVlMFn4rxcAawPMN+F
	TTxfsfdlN/NB9IQmbQ+z7EYh3FUkUMjyfaEr4KBvUmjxvJV4AEeqdJ1Ww94IEJWE9TDhfntSUaN//
	yhCEq2IHFDqVtkuDmwIOo+0tn5uXKe3W17J8mOr6NqEFaJXJXS7pY9KiQ7MGRzSIz+/ijlmsfzced
	OoTxgxlivoKoLopk1LpuNi9hqFFjOJOniWxryojabFVtvaZyKpRBq3urR6vxaslOC+7cL1ik+tTYi
	Gyf8rcyznvXlJnBxpyPDQI6t3VK1j/OqZfzjOZAPb2z0Myimzi80omeqcGv/vXige5WVA5K41Nxkr
	ZQGodA+0w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hG4Mf-0002yi-Rj; Mon, 15 Apr 2019 16:21:50 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 9B5FA29AD7C3D; Mon, 15 Apr 2019 18:21:48 +0200 (CEST)
Date: Mon, 15 Apr 2019 18:21:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, Andy Lutomirski <luto@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Sean Christopherson <sean.j.christopherson@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch V4 01/32] mm/slab: Fix broken stack trace storage
Message-ID: <20190415162148.GM4038@hirez.programming.kicks-ass.net>
References: <20190414155936.679808307@linutronix.de>
 <20190414160143.591255977@linutronix.de>
 <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
 <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
 <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
 <20190415132339.wiqyzygqklliyml7@treble>
 <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 06:07:44PM +0200, Thomas Gleixner wrote:
> On Mon, 15 Apr 2019, Josh Poimboeuf wrote:
> > > +		struct stack_trace trace = {
> > > +			/* Leave one for the end marker below */
> > > +			.max_entries	= size - 1,
> > > +			.entries	= addr,
> > > +			.skip		= 3,
> > > +		};

> > Looks like stack_trace.nr_entries isn't initialized?  (though this code
> > gets eventually replaced by a later patch)
> 
> struct initializer initialized the non mentioned fields to 0, if I'm not
> totally mistaken.

Correct.

