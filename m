Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 975196B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 07:28:31 -0400 (EDT)
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in
 the VM II
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20090429090501.GB15488@localhost>
References: <20090407509.382219156@firstfloor.org>
	 <20090407151010.E72A91D0471@basil.firstfloor.org>
	 <1239210239.28688.15.camel@think.oraclecorp.com>
	 <20090409072949.GF14687@one.firstfloor.org>
	 <20090409075805.GG14687@one.firstfloor.org>
	 <1239283829.23150.34.camel@think.oraclecorp.com>
	 <20090409140257.GI14687@one.firstfloor.org>
	 <1239287859.23150.57.camel@think.oraclecorp.com>
	 <20090429081616.GA8339@localhost>
	 <20090429083655.GA23223@one.firstfloor.org>
	 <20090429090501.GB15488@localhost>
Content-Type: text/plain
Date: Wed, 29 Apr 2009 07:27:36 -0400
Message-Id: <1241004456.15136.91.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "npiggin@suse.de" <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-29 at 17:05 +0800, Wu Fengguang wrote:
> On Wed, Apr 29, 2009 at 04:36:55PM +0800, Andi Kleen wrote:
> > > > I'll have to read harder next week, the FS invalidatepage may expect
> > > > truncate to be the only caller.
> > > 
> > > If direct de-dirty is hard for some pages, how about just ignore them?
> > 
> > You mean just ignoring it for the pages where it is hard?
> 
> Yes.
> 
> > Yes that is what it is essentially doing right now. But at least
> > some dirty pages need to be handled because most user space
> > pages tend to be dirty.
> 
> Sure.  There are three types of dirty pages:
> 
> A. now dirty, can be de-dirty in the current code
> B. now dirty, cannot be de-dirty
> C. now dirty and writeback, cannot be de-dirty
> 
> I mean B and C can be handled in one single place - the block layer.
> 
> If B is hard to be de-dirtied now, ignore them for now and they will
> eventually be going to IO and become C.
> 
> > > There are the PG_writeback pages anyway. We can inject code to
> > > intercept them at the last stage of IO request dispatching.
> > 
> > That would require adding error out code through all the file systems,
> > right?
> 
> Not necessarily. The file systems deal with buffer head, extend map
> and bios, they normally won't touch the poisoned page content at all.
> 

They often do when zeroing parts of the page that straddle i_size.  At
least for btrfs its enough to change grab_cache_page and find_get_page
(and friends) to do the poison magic, along with the functions uses by
write_cache_pages.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
