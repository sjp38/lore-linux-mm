Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADD96B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 17:10:53 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z12so16465195pgv.6
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 14:10:53 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t189si14096379pgt.317.2017.12.21.14.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 14:10:52 -0800 (PST)
Date: Thu, 21 Dec 2017 15:10:50 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/2] Introduce __cond_lock_err
Message-ID: <20171221221050.GD9087@linux.intel.com>
References: <20171219165823.24243-1-willy@infradead.org>
 <20171219165823.24243-2-willy@infradead.org>
 <20171221214810.GC9087@linux.intel.com>
 <20171221220015.GA14919@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171221220015.GA14919@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Thu, Dec 21, 2017 at 02:00:16PM -0800, Josh Triplett wrote:
> On Thu, Dec 21, 2017 at 02:48:10PM -0700, Ross Zwisler wrote:
> > On Tue, Dec 19, 2017 at 08:58:23AM -0800, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > The __cond_lock macro expects the function to return 'true' if the lock
> > > was acquired and 'false' if it wasn't.  We have another common calling
> > > convention in the kernel, which is returning 0 on success and an errno
> > > on failure.  It's hard to use the existing __cond_lock macro for those
> > > kinds of functions, so introduce __cond_lock_err() and convert the
> > > two existing users.
> > 
> > This is much cleaner!  One quick issue below.
> > 
> > > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > > ---
> > >  include/linux/compiler_types.h | 2 ++
> > >  include/linux/mm.h             | 9 ++-------
> > >  mm/memory.c                    | 9 ++-------
> > >  3 files changed, 6 insertions(+), 14 deletions(-)
> > > 
> > > diff --git a/include/linux/compiler_types.h b/include/linux/compiler_types.h
> > > index 6b79a9bba9a7..ff3c41c78efa 100644
> > > --- a/include/linux/compiler_types.h
> > > +++ b/include/linux/compiler_types.h
> > > @@ -16,6 +16,7 @@
> > >  # define __acquire(x)	__context__(x,1)
> > >  # define __release(x)	__context__(x,-1)
> > >  # define __cond_lock(x,c)	((c) ? ({ __acquire(x); 1; }) : 0)
> > > +# define __cond_lock_err(x,c)	((c) ? 1 : ({ __acquire(x); 0; }))
> > 					       ^
> > I think we actually want this to return c here ^
> 
> Then you want to use ((c) ?: ...), to avoid evaluating c twice.

Oh, yep, great catch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
