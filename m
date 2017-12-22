Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4076B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 20:10:02 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id q12so12486980pli.12
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 17:10:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m7si14212971pgp.669.2017.12.21.17.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 17:10:01 -0800 (PST)
Date: Thu, 21 Dec 2017 17:10:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] Introduce __cond_lock_err
Message-ID: <20171222011000.GB23624@bombadil.infradead.org>
References: <20171219165823.24243-1-willy@infradead.org>
 <20171219165823.24243-2-willy@infradead.org>
 <20171221214810.GC9087@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171221214810.GC9087@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Josh Triplett <josh@joshtriplett.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Thu, Dec 21, 2017 at 02:48:10PM -0700, Ross Zwisler wrote:
> > +++ b/include/linux/compiler_types.h
> > @@ -16,6 +16,7 @@
> >  # define __acquire(x)	__context__(x,1)
> >  # define __release(x)	__context__(x,-1)
> >  # define __cond_lock(x,c)	((c) ? ({ __acquire(x); 1; }) : 0)
> > +# define __cond_lock_err(x,c)	((c) ? 1 : ({ __acquire(x); 0; }))
> 					       ^
> I think we actually want this to return c here ^
> 
> The old code saved off the actual return value from __follow_pte_pmd() (say,
> -EINVAL) in 'res', and that was what was returned on error from both
> follow_pte_pmd() and follow_pte().  The value of 1 returned by __cond_lock()
> was just discarded (after we cast it to void for some reason).
> 
> With this new code we actually return the value from __cond_lock_err(), which
> means that instead of returning -EINVAL, we'll return 1 on error.

Yes, but this define is only #if __CHECKER__, so it doesn't matter what we
return as this code will never run.

That said, if sparse supports the GNU syntax of ?: then I have no
objection to doing that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
