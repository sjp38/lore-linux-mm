Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 1D2956B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 18:07:07 -0400 (EDT)
Received: by mail-qe0-f43.google.com with SMTP id k5so4737049qej.30
        for <linux-mm@kvack.org>; Tue, 13 Aug 2013 15:07:06 -0700 (PDT)
Date: Tue, 13 Aug 2013 18:07:00 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 2/2] mm: make lru_add_drain_all() selective
Message-ID: <20130813220700.GC28996@mtj.dyndns.org>
References: <5202CEAA.9040204@linux.vnet.ibm.com>
 <201308072335.r77NZZwl022494@farm-0012.internal.tilera.com>
 <20130812140520.c6a2255d2176a690fadf9ba7@linux-foundation.org>
 <52099187.80301@tilera.com>
 <20130813123512.3d6865d8bf4689c05d44738c@linux-foundation.org>
 <20130813201958.GA28996@mtj.dyndns.org>
 <20130813133135.3b580af557d1457e4ee8331a@linux-foundation.org>
 <20130813210719.GB28996@mtj.dyndns.org>
 <20130813141621.3f1c3415901d4236942ee736@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130813141621.3f1c3415901d4236942ee736@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Hello,

On Tue, Aug 13, 2013 at 02:16:21PM -0700, Andrew Morton wrote:
> I've yet to see any evidence that callback APIs have been abused and
> I've yet to see any reasoning which makes me believe that this one will
> be abused.

Well, off the top of my head.

* In general, it's clunkier.  Callbacks become artificial boundaries
  across which context has to be carried over explicitly.  It often
  involves packing data into a temporary struct.  The artificial
  barrier also generally makes the logic more difficult to follow.
  This is pretty general problem with callback based interface and why
  many programming languages / conventions prefer iterator style
  interface over callback based ones.  It makes the code a lot easier
  to organize around the looping construct.  Here, it isn't as
  pronounced because the thing naturally requires a callback anyway.

* From the API itself, it often isn't clear what restrictions the
  context the callback is called under would have.  It sure is partly
  documentation problem but is pretty easy to get wrong inadvertantly
  as the code evolves and can be difficult to spot as the context
  isn't apparent.

Moving away from callbacks started with higher level languages but the
kernel sure is on the boat too where possible.  This one is muddier as
the interface is async in nature but still it's at least partially
applicable.

> >  It feels a bit silly to me to push the API
> > that way when doing so doesn't even solve the allocation problem.
> 
> It removes the need to perform a cpumask allocation in
> lru_add_drain_all().

But that doesn't really solve anything, does it?

> >  It doesn't really buy us much while making the interface more complex.
> 
> It's a superior interface.

It is more flexible but at the same time clunkier.  I wouldn't call it
superior and the flexibility doesn't buy us much here.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
