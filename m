Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CD6BC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:22:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8F47206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:22:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="V344DF0e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8F47206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56E4A8E0006; Mon, 29 Jul 2019 11:22:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51F308E0002; Mon, 29 Jul 2019 11:22:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40DD88E0006; Mon, 29 Jul 2019 11:22:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 26B958E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:22:39 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id y13so67841876iol.6
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:22:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=734mJqtkBi3LN0zhuGIgMjFn+GEEE5inKPVe1QAy5/0=;
        b=otgOxWPNkL85aHq0DpUZCzp0CcYMl3U8eqNUhaYbnegtfM2tFZjdsGTHZ8mK9f846o
         OeU0sinXPzBwxLVvxpZiEb/gzS3RRfZtsAjQAuWTvw1Iqo3wJUC5zFx7aLbN7j6BKRBh
         GWrOeyUyv3atTWMKD8S0/RhLEISv6qkTO9AzMpQOBBEUmcRPt/WXjiINLdeYGxqR4GUn
         DfTwFUPsIU3uzQ1fUFJFMYamuuy5rgpHiHvTkCT5UHKvLDL4v5c3lXZmc5cPlc0KSoMd
         jf6/O9xFCo5td545pU4LGIm57Zw35iVeMA7XgfWofMXn6soW8GyLpRAtCBNZaZvkViEJ
         4vLA==
X-Gm-Message-State: APjAAAVSESwL2Y4qoockKKAUBJxksm94vHZiMRRTrR7cEvw4GXFxe6Pt
	diF/G6LMv6OqqhUkNTL89+yBYUyek6hQvREKSadtt0IJXm0GDXMtSsVNb1UvXmDuZcaD/VbVJ3a
	De53Ja8XQcp6jE/eu5VxsHCSzt7Elkya075+II0YmDDZ8PImWw3OLnrxpAtYFYBEVvA==
X-Received: by 2002:a5e:8c16:: with SMTP id n22mr48327519ioj.105.1564413758909;
        Mon, 29 Jul 2019 08:22:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxW5ixgm92DeJlZQjexzieOnvP7WTJqQlYzL2+N1bLiLwLysAbZB9aw9bnUcmw4oWdVYX17
X-Received: by 2002:a5e:8c16:: with SMTP id n22mr48327472ioj.105.1564413758374;
        Mon, 29 Jul 2019 08:22:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564413758; cv=none;
        d=google.com; s=arc-20160816;
        b=gjDq/5SAITfy6jeqYqiMJbmGECoNTFnnxD7ac4tvdeajfLmcHjIAZV9XrqLfH7WWTX
         p9XqhUejoqLwHJApiv2nFcccRN7rA76E9h+ZI4MAJWqdoMQYz3DLoga0TAHALOBjgJPb
         pygnij1x5H5uhnPLFPELpLqOT+UDZAf/dlubj575oo5pIOGVz4S1O7efKsXtZ7FBDVco
         Jtvk6CKJtWI5Q/f4qruylFz7bl1qcvlR/CFzYY/PrkD204qjBkrfMQXpESnJqf7/jwGz
         z0uGxNmAPsGwFFG/ZAtpNUFiEP1idFh0bVj8/53BRsPluiI64JZ4yZLTptbudH+PQV4U
         Uo9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=734mJqtkBi3LN0zhuGIgMjFn+GEEE5inKPVe1QAy5/0=;
        b=eUpLbJSr2Zj53xlZpEPbzfzrmrlqOHKgf7FPRWi0XJwJBiW0NE49ju073YREYjBXWY
         sPcYTbr3R9ygkZ08tmBRYlEY1HcTrTplz35p/rSCFc00UNJrY63VWiHm6sBwCOgylC4E
         nLWajCNSMB+37k8g0T3tN6Ver1GbPVwvh9JXYrtMTix5TQbC/605GHq2ySKiJLNPrMib
         uymBR1EySmzHR7L+jnTTYBsApMFmWc4+vctlBbq8TCtviu1H6bkKj+tRxJKQYT6+BH0o
         PaDuM+Py30Tn7G5TxRGKCyR/nptAdOY9Lf1Rw8OiRSazhRZ/PUlX/uSSVZzbnfyD1yfq
         ujWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=V344DF0e;
       spf=temperror (google.com: error in processing during lookup of peterz@infradead.org: DNS error) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org ([2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i9si79028801jam.38.2019.07.29.08.22.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 08:22:38 -0700 (PDT)
Received-SPF: temperror (google.com: error in processing during lookup of peterz@infradead.org: DNS error) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=V344DF0e;
       spf=temperror (google.com: error in processing during lookup of peterz@infradead.org: DNS error) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=734mJqtkBi3LN0zhuGIgMjFn+GEEE5inKPVe1QAy5/0=; b=V344DF0eHmejI1+FylehubPRA
	ki3FVPGVRK4c/zroRMso6w37G0qm8Y+zZ9UJJBUtFOMokqSPLXbHoa7dj9r3zWLSivRHkAQnG6mqW
	N4tKvuQHPvsTfbFUvPP3p6xK/T27xWtuZqqyzN05fhXF8KkQQJLDYa6/N5xbttr3c8Fyk2ENSvZhJ
	5LrP5A3h2tBLfvI8Bbkx5H2O4JrgWMSdo5pLynuIX5qbctDFCdnDn+Eo5djn0Hz4Juhiq3b8/vg1A
	fOErOByXK0YtMiRXfBZrUu48fv3RPePiHs3zCC4lOifSsZpphxwCieqmvaNuzL5tSdeKRwjw1p8++
	g/NjbWxMQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs7Tq-0003Tk-M4; Mon, 29 Jul 2019 15:22:30 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 22B6320AFFE9E; Mon, 29 Jul 2019 17:22:29 +0200 (CEST)
Date: Mon, 29 Jul 2019 17:22:29 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>, riel@surriel.com, luto@kernel.org,
	mathieu.desnoyers@efficios.com
Subject: Re: [PATCH] sched: Clean up active_mm reference counting
Message-ID: <20190729152229.GG31398@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
 <20190729142450.GE31425@hirez.programming.kicks-ass.net>
 <45546d31-4efb-c303-deae-7c866b0071a9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45546d31-4efb-c303-deae-7c866b0071a9@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 11:16:55AM -0400, Waiman Long wrote:
> On 7/29/19 10:24 AM, Peter Zijlstra wrote:
> > On Mon, Jul 29, 2019 at 10:52:35AM +0200, Peter Zijlstra wrote:
> >
> > ---
> > Subject: sched: Clean up active_mm reference counting
> > From: Peter Zijlstra <peterz@infradead.org>
> > Date: Mon Jul 29 16:05:15 CEST 2019
> >
> > The current active_mm reference counting is confusing and sub-optimal.
> >
> > Rewrite the code to explicitly consider the 4 separate cases:
> >
> >     user -> user
> >
> > 	When switching between two user tasks, all we need to consider
> > 	is switch_mm().
> >
> >     user -> kernel
> >
> > 	When switching from a user task to a kernel task (which
> > 	doesn't have an associated mm) we retain the last mm in our
> > 	active_mm. Increment a reference count on active_mm.
> >
> >   kernel -> kernel
> >
> > 	When switching between kernel threads, all we need to do is
> > 	pass along the active_mm reference.
> >
> >   kernel -> user
> >
> > 	When switching between a kernel and user task, we must switch
> > 	from the last active_mm to the next mm, hoping of course that
> > 	these are the same. Decrement a reference on the active_mm.
> >
> > The code keeps a different order, because as you'll note, both 'to
> > user' cases require switch_mm().
> >
> > And where the old code would increment/decrement for the 'kernel ->
> > kernel' case, the new code observes this is a neutral operation and
> > avoids touching the reference count.
> 
> I am aware of that behavior which is indeed redundant, but it is not
> what I am trying to fix and so I kind of leave it alone in my patch.

Oh sure; and it's not all that important either. It is jst that every
time I look at that code I get confused.

On top of that, the new is easier to rip the active_mm stuff out of,
which is where it came from.


