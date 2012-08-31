Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id F28016B0069
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 17:10:49 -0400 (EDT)
Date: Fri, 31 Aug 2012 17:10:38 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] frontswap: support exclusive gets if tmem backend is
 capable
Message-ID: <20120831211038.GA20594@localhost.localdomain>
References: <5557ec97-daa1-41a6-b3db-671f116ddc50@default>
 <20120831170814.GF18929@localhost.localdomain>
 <89702248-0c3f-465c-bc1f-2115a21c8c89@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89702248-0c3f-465c-bc1f-2115a21c8c89@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Fri, Aug 31, 2012 at 10:23:21AM -0700, Dan Magenheimer wrote:
> > From: Konrad Rzeszutek Wilk
> 
> Hi Konrad --
> 
> Thanks for the fast feedback!

Sure. Had a couple of minutes in between the talks.
> 
> > > +#define FRONTSWAP_HAS_EXCLUSIVE_GETS
> > > +extern void frontswap_tmem_exclusive_gets(bool);
> > 
> > I don't think you need the #define here..
> 
> The #define is used by an ifdef in the backend to ensure
> that it is using a version of frontswap that has this feature,
> so avoids the need for the frontend (frontswap) and
> the backend (e.g. zcache2) to merge in lockstep.

Then lets post the ramster patch as part of the patch series
which will include this patch as the first component and the
second would be the ramster part.

> 
> > > +EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);
> > 
> > We got two of these now - the writethrough and this one. Merging
> > them in one function and one flag might be better. So something like:
> > static int frontswap_mode = 0;
> >
> > void frontswap_set_mode(int set_mode)
> > {
> > 	if (mode & (FRONTSWAP_WRITETH | FRONTSWAP_EXCLUS..)
> > 		mode |= set_mode;
> > }
> 
> IMHO, it's too soon to try to optimize this.  One or
> both of these may go away.   Or the mode may become
> more fine-grained in the future (e.g. to allow individual
> gets to be exclusive).

Sure. At which point we can modify it/remove this. Lets
do the 'frontswap_set_mode' as it seems much nicer than just adding
extra frontswap_some_new_function.

> 
> So unless you object strongly, let's just leave this
> as is for now and revisit in the future if more "modes"
> are needed.

Nah. Lets do the mode.
>  
> > ... and
> > > +
> > > +/*
> > >   * Called when a swap device is swapon'd.
> > >   */
> > >  void __frontswap_init(unsigned type)
> > > @@ -174,8 +190,13 @@ int __frontswap_load(struct page *page)
> > >  	BUG_ON(sis == NULL);
> > >  	if (frontswap_test(sis, offset))
> > >  		ret = (*frontswap_ops.load)(type, offset, page);
> > > -	if (ret == 0)
> > > +	if (ret == 0) {
> > >  		inc_frontswap_loads();
> > > +		if (frontswap_tmem_exclusive_gets_enabled) {
> > 
> > For these perhaps use asm goto for optimization? Is this showing up in
> > perf as a hotspot? The asm goto might be a bit too much.
> 
> This is definitely not a performance hotspot.  Frontswap code
> only is ever executed in situations where a swap-to-disk would
> otherwise have occurred.  And in this case, this code only
> gets executed after the frontswap_test has confirmed that
> tmem does already contain the page of data, in which case
> there is thousands of cycles spent copying and/or decompressing.

Ok. Lets leave this with just a check: if (frontswap_flag &
FRONTSWAP_EXCLUSIVE_GET)...
> 
> Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
