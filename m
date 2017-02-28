Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6CCF6B03B1
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 08:35:31 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id f103so10288267ioi.5
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 05:35:31 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 4si2232196ioy.25.2017.02.28.05.35.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 05:35:31 -0800 (PST)
Date: Tue, 28 Feb 2017 14:35:21 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228133521.GJ5680@worktop>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228130513.GH5680@worktop>
 <20170228132820.GH3817@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228132820.GH3817@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Feb 28, 2017 at 10:28:20PM +0900, Byungchul Park wrote:
> On Tue, Feb 28, 2017 at 02:05:13PM +0100, Peter Zijlstra wrote:
> > On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> > > +#define MAX_XHLOCKS_NR 64UL
> > 
> > > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > > +	if (tsk->xhlocks) {
> > > +		void *tmp = tsk->xhlocks;
> > > +		/* Disable crossrelease for current */
> > > +		tsk->xhlocks = NULL;
> > > +		vfree(tmp);
> > > +	}
> > > +#endif
> > 
> > > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > > +	p->xhlock_idx = 0;
> > > +	p->xhlock_idx_soft = 0;
> > > +	p->xhlock_idx_hard = 0;
> > > +	p->xhlock_idx_nmi = 0;
> > > +	p->xhlocks = vzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR);
> > 
> > I don't think we need vmalloc for this now.
> 
> Really? When is a better time to do it?
> 
> I think the time creating a task is the best time to initialize it. No?

The place is fine, but I would use kmalloc() now (and subsequently kfree
on the other end) for the allocation. Its not _that_ large anymore,
right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
