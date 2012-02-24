Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id C94AB6B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 15:40:05 -0500 (EST)
Date: Fri, 24 Feb 2012 12:40:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than
 PAGE_SIZE
Message-Id: <20120224124003.93780408.akpm@linux-foundation.org>
In-Reply-To: <20120224133431.GA3913@phenom.ffwll.local>
References: <1329393696-4802-1-git-send-email-daniel.vetter@ffwll.ch>
	<1329393696-4802-2-git-send-email-daniel.vetter@ffwll.ch>
	<20120223143658.0e318ce2.akpm@linux-foundation.org>
	<20120224133431.GA3913@phenom.ffwll.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Fri, 24 Feb 2012 14:34:31 +0100
Daniel Vetter <daniel@ffwll.ch> wrote:

> > > --- a/include/linux/pagemap.h
> > > +++ b/include/linux/pagemap.h
> > > @@ -408,6 +408,7 @@ extern void add_page_wait_queue(struct page *page, wait_queue_t *waiter);
> > >  static inline int fault_in_pages_writeable(char __user *uaddr, int size)
> > >  {
> > >  	int ret;
> > > +	char __user *end = uaddr + size - 1;
> > >  
> > >  	if (unlikely(size == 0))
> > >  		return 0;
> > > @@ -416,17 +417,20 @@ static inline int fault_in_pages_writeable(char __user *uaddr, int size)
> > >  	 * Writing zeroes into userspace here is OK, because we know that if
> > >  	 * the zero gets there, we'll be overwriting it.
> > >  	 */
> > > -	ret = __put_user(0, uaddr);
> > > +	while (uaddr <= end) {
> > > +		ret = __put_user(0, uaddr);
> > > +		if (ret != 0)
> > > +			return ret;
> > > +		uaddr += PAGE_SIZE;
> > > +	}
> > 
> > The callsites in filemap.c are pretty hot paths, which is why this
> > thing remains explicitly inlined.  I think it would be worth adding a
> > bit of code here to avoid adding a pointless test-n-branch and larger
> > cache footprint to read() and write().
> > 
> > A way of doing that is to add another argument to these functions, say
> > "bool multipage".  Change the code to do
> > 
> > 	if (multipage) {
> > 		while (uaddr <= end) {
> > 			...
> > 		}
> > 	}
> > 
> > and change the callsites to pass in constant "true" or "false".  Then
> > compile it up and manually check that the compiler completely removed
> > the offending code from the filemap.c callsites.
> > 
> > Wanna have a think about that?  If it all looks OK then please be sure
> > to add code comments explaining why we did this.
> 
> I wasn't really happy with the added branch either, but failed to come up
> with a trick to avoid it. Imho adding new _multipage variants of these
> functions instead of adding a constant argument is simpler because the
> functions don't really share much thanks to the block below. I'll see what
> it looks like (and obviously add a comment explaining what's going on).

well... that's just syntactic sugar:

static inline int __fault_in_pages_writeable(char __user *uaddr, int size, bool multipage)
{
	...
}

static inline int fault_in_pages_writeable(char __user *uaddr, int size)
{
	return __fault_in_pages_writeable(uaddr, size, false);
}

static inline int fault_in_multipages_writeable(char __user *uaddr, int size)
{
	return __fault_in_pages_writeable(uaddr, size, true);
}

which I don't think is worth bothering with given the very small number
of callsites.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
