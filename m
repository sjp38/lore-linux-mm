Date: Tue, 2 Oct 2007 13:19:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Inconsistent mmap()/mremap() flags
In-Reply-To: <1191308772.5200.66.camel@phantasm.home.enterpriseandprosperity.com>
Message-ID: <Pine.LNX.4.64.0710021304230.26719@blonde.wat.veritas.com>
References: <1190958393.5128.85.camel@phantasm.home.enterpriseandprosperity.com>
  <200710011313.30171.andi@firstfloor.org>
 <1191293830.5200.22.camel@phantasm.home.enterpriseandprosperity.com>
 <20071002051526.GA29615@one.firstfloor.org>
 <1191308772.5200.66.camel@phantasm.home.enterpriseandprosperity.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thayne Harbaugh <thayne@c2.net>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Oct 2007, Thayne Harbaugh wrote:
> On Tue, 2007-10-02 at 07:15 +0200, Andi Kleen wrote:
> 
> > For mmap you can emulate it by passing a low hint != 0 (e.g. getpagesize()) 
> > in address but without MAP_FIXED and checking if the result is not beyond
> > your range.
> 
> Cool.  That's a much better solution for multiple reasons - like you
> mention, MAP_32BIT is only 2GB as well as it's only available on x86_64.
> 
> > > > Given for mremap() it is not that easy because there is no "hint" argument
> > > > without MREMAP_FIXED; but unless someone really needs it i would prefer
> > > > to not propagate the hack. If it's really needed it's probably better
> > > > to implement a start search hint for mremap()

I think you can do it already, without us complicating mremap further
with such a start search hint.

First call mmap with a low hint address, the new size you'll be wanting
from the mremap, PROT_NONE, MAP_ANONYMOUS, -1, 0.  Then call mremap with
old address, old size, new size, MREMAP_MAYMOVE|MREMAP_FIXED, and new
address as returned by the preparatory mmap.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
