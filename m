Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 850536B0062
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 14:26:12 -0400 (EDT)
Date: Fri, 2 Nov 2012 14:24:30 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 2/5] mm: frontswap: lazy initialization to allow tmem
 backends to build/run as modules
Message-ID: <20121102182429.GA30100@konrad-lan.dumpdata.com>
References: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
 <1351696074-29362-3-git-send-email-dan.magenheimer@oracle.com>
 <50915A5C.8000303@linux.vnet.ibm.com>
 <d7588a48-9f47-4f3a-852c-3fac916de75c@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d7588a48-9f47-4f3a-852c-3fac916de75c@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

> > > +	frontswap_enabled = 1;
> > 
> > If frontswap_enabled is going to be on all the time, then what point
> > does it serve?  By extension, can all of the static inline wrappers in
> > frontswap.h be done away with?

Hm, or the frontswap_enabled can be converted to a "frontswap_flag"
which has:

#define FRONTSWAP_ON (1<<1)
#define FRONTSWAP_BACKEND_ON (1<<2)

or so? And then we can see if we can squash the 'backend_registerd'
and 'frontswap_enabled' together.
> 
> The intent of frontswap_enabled and cleancache_enabled was
> to avoid the overhead of a function call at the point where
> each frontswap/cleancache "hooks" is placed, using a global
> variable check instead.  I'm not sure if this minor
> performance tuning effort is worth preserving:  If not,
> I agree frontswap_enabled and the static inline wrappers (as
> well as their cleancache brethren) could be done away with **;
> if worth preserving, then I think frontswap_enabled could
> be set in the init method instead but the check for enabled
> in the frontswap init method and the cleancache init_fs
> method would need to be removed else lazy initialization
> wouldn't work.

Either way, that should be a seperate patch.
> 
> Dan
> 
> ** Note to anyone that tries this:  There is a subtle but
> clever hack in the wrappers suggested by Jeremy Fitzhardinge
> that disables the wrappers at compile-time as well as
> runtime.  IOW, make sure you test-compile both with
> CONFIG_{CLEANCACHE|FRONTSWAP} _and_ with them unconfig'd.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
