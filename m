Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C79B06B006A
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 19:08:58 -0500 (EST)
Date: Sat, 14 Nov 2009 01:08:49 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Allow memory hotplug and hibernation in the same kernel
Message-ID: <20091114000849.GG30880@basil.fritz.box>
References: <20091113105944.GA16028@basil.fritz.box> <20091113155102.3480907f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091113155102.3480907f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, gerald.schaefer@de.ibm.com, rjw@sisk.pl, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 03:51:02PM -0800, Andrew Morton wrote:
> > ...
> >
> > +extern struct mutex pm_mutex;
> 
> Am a bit worried by the new mutex.

It's not a new mutex, just the existing one already used by suspend.
I only extended it's coverage to two more code paths.

> 
> > -extern struct mutex pm_mutex;
> > +static inline void lock_hibernation(void) {}
> > +static inline void unlock_hibernation(void) {}
> > +
> > +#else
> > +
> > +/* Let some subsystems like memory hotadd exclude hibernation */
> > +
> > +static inline void lock_hibernation(void)
> > +{
> > +	mutex_lock(&pm_mutex);
> > +}
> > +
> > +static inline void unlock_hibernation(void)
> > +{
> > +	mutex_unlock(&pm_mutex);
> > +}
> > +#endif
> 
> Has this been carefully reviewed and lockdep-tested to ensure that we
> didn't introduce any ab/ba nasties?

It's a "outer" global mutex for both, so I don't expect ABBA issues.

I tested hotadd/hotremove with lockdep and nothing showed up.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
