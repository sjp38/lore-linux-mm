Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7062B6B0047
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 06:49:50 -0400 (EDT)
Date: Tue, 10 Mar 2009 11:49:47 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: possible bug in find_get_pages
Message-ID: <20090310104947.GB4594@wotan.suse.de>
References: <20090306192625.GA3267@linux.intel.com> <alpine.DEB.1.10.0903061426190.20182@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903061426190.20182@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: mark gross <mgross@linux.intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 06, 2009 at 02:28:50PM -0500, Christoph Lameter wrote:
> On Fri, 6 Mar 2009, mark gross wrote:
> 
> > It seems that page->_count == 0 at some point on some overnight runs
> > with locks the system into a tight loop from the repeat: and a goto
> > repeat in find_get_pages.
> 
> A page with ref count zero should not be in any mapping. If the page is in
> a mapping then the page is used. Therefore the refcount should be > 0.
> 
> If there is a page with zero refcount and its in a mapping then something
> erroneously decreased the refcount.

Just for posterity, this isn't _quite_ true any more with Hugh's
variation to the speculative reference method. We now in some
places set the page's refcount to 0 in order to hold off new
speculative references from turning into real references (eg. right
before final checks before page reclaim).

But yes, such a page should not remain both in a mapping and with a
0 refcount for long periods.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
