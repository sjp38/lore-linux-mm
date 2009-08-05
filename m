Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D4B256B0085
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:12:27 -0400 (EDT)
Date: Wed, 5 Aug 2009 23:12:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [11/19] HWPOISON: Refactor truncate to allow direct
	truncating of page v2
Message-ID: <20090805151220.GB6210@localhost>
References: <200908051136.682859934@firstfloor.org> <20090805093638.D3754B15D8@basil.firstfloor.org> <20090805102008.GB17190@wotan.suse.de> <20090805134607.GH11385@basil.fritz.box> <20090805140145.GB28563@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805140145.GB28563@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hidehiro.kawai.ez@hitachi.com" <hidehiro.kawai.ez@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 10:01:45PM +0800, Nick Piggin wrote:
> On Wed, Aug 05, 2009 at 03:46:08PM +0200, Andi Kleen wrote:
> > On Wed, Aug 05, 2009 at 12:20:08PM +0200, Nick Piggin wrote:
> > > >  truncate_complete_page(struct address_space *mapping, struct page *page)
> > > >  {
> > > >  	if (page->mapping != mapping)
> > > > -		return;
> > > > +		return -EIO;
> > > 
> > > Hmm, at this point, the page must have been removed from pagecache,
> > > so I don't know if you need to pass an error back?
> > 
> > It could be reused, which would be bad for us?
>  
> I haven't brought up the caller at this point, but IIRC you had
> the page locked and mapping confirmed at this point anyway so
> it would never be an error for your code.

Right, that 'if' will always evaluate to false for the hwpoison case.
Because that 'mapping' was taken from 'page->mapping' inside page lock
and they will just remain the same values.

> Probably it would be nice to just force callers to verify the page.
> Normally IMO it is much nicer and clearer to do it at the time the
> page gets locked, unless there is good reason otherwise.

Yes we do checked page->mapping after taking page lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
