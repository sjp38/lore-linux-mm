Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 840406B0102
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 14:14:03 -0400 (EDT)
Received: by fxh2 with SMTP id 2so3948916fxh.9
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 11:14:00 -0700 (PDT)
Date: Thu, 21 Jul 2011 22:13:00 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC v3 2/5] slab: implement slab object boundaries assertion
Message-ID: <20110721181300.GA23960@albatros>
References: <1311252815-6733-1-git-send-email-segoon@openwall.com>
 <alpine.DEB.2.00.1107211127050.3995@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107211127050.3995@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Jul 21, 2011 at 11:28 -0500, Christoph Lameter wrote:
> On Thu, 21 Jul 2011, Vasiliy Kulikov wrote:
> 
> > +bool slab_access_ok(const void *ptr, unsigned long len)
> > +{
> > +	struct page *page;
> > +	struct kmem_cache *s = NULL;
> 
> Useless assignment.
> 
> > +	unsigned long offset;
> > +
> > +	if (!virt_addr_valid(ptr))
> > +		return true;
> > +	page = virt_to_head_page(ptr);
> > +	if (!PageSlab(page))
> > +		return true;
> > +
> > +	s = page->slab;
> > +	offset = (ptr - page_address(page)) % s->size;
> > +	if (offset <= s->objsize && len <= s->objsize - offset)
> > +		return true;
> 
> I thought this was going to be offset < s->objectsize ...?

Looks like I did these 2 things in SLAB only, left SLUB untouched.
Will fix, thanks.

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
