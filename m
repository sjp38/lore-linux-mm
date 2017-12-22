Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 895AE6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 23:21:29 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n13so4858609wmc.3
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 20:21:29 -0800 (PST)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id n61si8384349wrb.189.2017.12.21.20.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 20:21:28 -0800 (PST)
Date: Thu, 21 Dec 2017 20:21:20 -0800
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 2/2] Introduce __cond_lock_err
Message-ID: <20171222042120.GA18036@localhost>
References: <20171219165823.24243-1-willy@infradead.org>
 <20171219165823.24243-2-willy@infradead.org>
 <20171221214810.GC9087@linux.intel.com>
 <20171222011000.GB23624@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222011000.GB23624@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Thu, Dec 21, 2017 at 05:10:00PM -0800, Matthew Wilcox wrote:
> On Thu, Dec 21, 2017 at 02:48:10PM -0700, Ross Zwisler wrote:
> > > +++ b/include/linux/compiler_types.h
> > > @@ -16,6 +16,7 @@
> > >  # define __acquire(x)	__context__(x,1)
> > >  # define __release(x)	__context__(x,-1)
> > >  # define __cond_lock(x,c)	((c) ? ({ __acquire(x); 1; }) : 0)
> > > +# define __cond_lock_err(x,c)	((c) ? 1 : ({ __acquire(x); 0; }))
> > 					       ^
> > I think we actually want this to return c here ^
> > 
> > The old code saved off the actual return value from __follow_pte_pmd() (say,
> > -EINVAL) in 'res', and that was what was returned on error from both
> > follow_pte_pmd() and follow_pte().  The value of 1 returned by __cond_lock()
> > was just discarded (after we cast it to void for some reason).
> > 
> > With this new code we actually return the value from __cond_lock_err(), which
> > means that instead of returning -EINVAL, we'll return 1 on error.
> 
> Yes, but this define is only #if __CHECKER__, so it doesn't matter what we
> return as this code will never run.

It does matter slightly, as Sparse does some (very limited) value-based
analyses. Let's future-proof it.

> That said, if sparse supports the GNU syntax of ?: then I have no
> objection to doing that.

Sparse does support that syntax.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
