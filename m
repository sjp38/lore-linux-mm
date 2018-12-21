Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1E238E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 14:44:02 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id u20so5881906pfa.1
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 11:44:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x23si21250403pgk.272.2018.12.21.11.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 11:44:01 -0800 (PST)
Date: Fri, 21 Dec 2018 11:43:51 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 03/12] __wr_after_init: generic functionality
Message-ID: <20181221194351.GH10600@bombadil.infradead.org>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
 <20181221181423.20455-4-igor.stoppa@huawei.com>
 <20181221184120.GG10600@bombadil.infradead.org>
 <14487401-dec3-6a7d-a0b1-e369e93aa9c4@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14487401-dec3-6a7d-a0b1-e369e93aa9c4@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 21, 2018 at 09:07:54PM +0200, Igor Stoppa wrote:
> On 21/12/2018 20:41, Matthew Wilcox wrote:
> > On Fri, Dec 21, 2018 at 08:14:14PM +0200, Igor Stoppa wrote:
> > > +static inline int memtst(void *p, int c, __kernel_size_t len)
> > 
> > I don't understand why you're verifying that writes actually happen
> > in production code.  Sure, write lib/test_wrmem.c or something, but
> > verifying every single rare write seems like a mistake to me.
> 
> This is actually something I wrote more as a stop-gap.
> I have the feeling there should be already something similar available.
> And probably I could not find it. Unless it's so trivial that it doesn't
> deserve to become a function?
> 
> But if there is really no existing alternative, I can put it in a separate
> file.

I'm not questioning the implementation, I'm questioning why it's ever
called.  If I type 'p = q', I don't then verify that p actually is equal
to q.  I just assume that the compiler did its job.

> > > +#ifndef CONFIG_PRMEM
> > 
> > So is this PRMEM or wr_mem?  It's not obvious that CONFIG_PRMEM controls
> > wrmem.
> 
> In my mind (maybe still clinging to the old implementation), PRMEM is the
> master toggle, for protected memory.
> 
> Then there are various types and the first one being now implemented is
> write rare after init (because ro after init already exists).
> 
> However, the same levels of protection should then follow for dynamically
> allocated memory (ye old pmalloc).
> 
> PRMEM would then become the moniker for the whole shebang.

To my mind, what we have in this patchset is support for statically
allocated protected (or write-rare) memory.  Later, we'll add dynamically
allocated protected memory.  So it's all protected memory, and we'll
use the same accessors for both ... right?

> > > +#define wr_rcu_assign_pointer(p, v)	rcu_assign_pointer(p, v)
> > > +#define wr_assign(var, val) ({			\
> > > +	typeof(var) tmp = (typeof(var))val;	\
> > > +						\
> > > +	wr_memcpy(&var, &tmp, sizeof(var));	\
> > > +	var;					\
> > > +})
> > 
> > Doesn't wr_memcpy return 'var' anyway?
> 
> It should return the destination, which is &var.
> 
> But I wanted to return the actual value of the assignment, val
> 
> Like if I do  (a = 7)  it evaluates to 7,
> 
> similarly wr_assign(a, 7) would also evaluate to 7
> 
> The reason why i returned var instead of val is that it would allow to
> detect any error.

Ah, good point; I missed the var vs &var distinction.

> > > +void *wr_memcpy(void *p, const void *q, __kernel_size_t size)
> > > +{
> > > +	wr_state_t wr_state;
> > > +	void *wr_poking_addr = __wr_addr(p);
> > > +
> > > +	if (WARN_ONCE(!wr_ready, "No writable mapping available") ||
> > 
> > Surely not.  If somebody's called wr_memcpy() before wr_ready is set,
> > that means we can just call memcpy().
> 
> What I was trying to catch is the case where, after a failed init, the
> writable mapping doesn't exist. In that case wr_ready is also not set.
> 
> The problem is that I just don't know what to do in a case where there has
> been such a major error which prevents he creation of hte alternate mapping.
> 
> I understand that we still want to continue, to provide as much debug info
> as possible, but I am at a loss about finding the saner course of actions.

I don't think there's anything to be done in that case.  Indeed,
I think the only thing to do is panic and stop the whole machine if
initialisation fails.  We'd be in a situation where nothing can update
protected memory, and the machine just won't work.

I suppose we could "fail insecure" and never protect the memory, but I
think that's asking for trouble.

Anyway, my concern was for a driver which can be built either as a
module or built-in.  Its init code will be called before write-protection
happens when it's built in, and after write-protection happens when it's
a module.  It should be able to use wr_assign() in either circumstance.
One might also have a utility function which is called from both init
and non-init code and want to use wr_assign() whether initialisation
has completed or not.
