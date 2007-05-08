Date: Wed, 9 May 2007 00:35:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] optimise unlock_page
Message-ID: <20070508223518.GC20174@wotan.suse.de>
References: <20070508114003.GB19294@wotan.suse.de> <20070508113709.GA19294@wotan.suse.de> <9948.1178626415@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9948.1178626415@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-arch@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 08, 2007 at 01:13:35PM +0100, David Howells wrote:
> 
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > This patch trades a page flag for a significant improvement in the unlock_page
> > fastpath. Various problems in the previous version were spotted by Hugh and
> > Ben (and fixed in this one).
> 
> It looks reasonable at first glance, though it does consume yet another page
> flag:-/  However, I think that's probably a worthy trade.

Well, that's the big question :)


> >  }
> > -	
> > +
> > +static inline void unlock_page(struct page *page)
> > +{
> > +	VM_BUG_ON(!PageLocked(page));
> > +	ClearPageLocked_Unlock(page);
> > +	if (unlikely(PageWaiters(page)))
> > +		__unlock_page(page);
> > +}
> > +
> 
> Please don't simply discard the documentation, we have little enough as it is:

Oops, right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
