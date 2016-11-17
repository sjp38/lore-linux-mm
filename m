Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5FB6B031A
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 04:07:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so44418880wmw.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 01:07:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jv4si1846283wjb.64.2016.11.17.01.07.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 01:07:49 -0800 (PST)
Date: Thu, 17 Nov 2016 10:07:42 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/21] mm: Join struct fault_env and vm_fault
Message-ID: <20161117090742.GR21785@quack2.suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-2-git-send-email-jack@suse.cz>
 <20161115215021.GA23021@node>
 <20161116105132.GR3142@twins.programming.kicks-ass.net>
 <20161116110101.GE21785@quack2.suse.cz>
 <20161116172108.GV3142@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161116172108.GV3142@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 16-11-16 18:21:08, Peter Zijlstra wrote:
> On Wed, Nov 16, 2016 at 12:01:01PM +0100, Jan Kara wrote:
> > On Wed 16-11-16 11:51:32, Peter Zijlstra wrote:
> 
> > > Now, I'm entirely out of touch wrt DAX, so I've not idea what that
> > > needs/wants.
> > 
> > Yeah, DAX does not have 'struct page' for its pages so it directly installs
> > PFNs in the page tables. As a result it needs to know about page tables and
> > stuff.
> 
> Not convinced, a physical address should then be the equivalent of a
> struct page. You still don't need access to the actual pages tables. The
> VM core can then convert the physical address to a PFN and stuff it in
> the PTE entry.
> 
> > Now I've abstracted knowledge about that into helper functions back
> > in mm/ but still we need to pass the information through the ->fault handler
> > into those helpers and vm_fault structure is simply natural for that.
> > So far we have tried to avoid that but the result was not pretty (special
> > return codes from DAX ->fault handlers essentially leaking information
> > about DAX internal locking into mm/ code to direct generic mm code to do
> > the right thing for DAX).
> 
> Its probably the DAX locking bit I'm missing, because I cannot see why
> VM_FAULT_DAX_LOCKED is 'broken' -- also, I'd have called that
> VM_FAULT_PFN or similar and not have used the full entry but only the
> PFN bits from it.

The problem really is in the locking. Currently fault code expects to get a
locked page from the ->fault() handler (or it locks the returned page on
its own). When we don't have struct page, we don't have a page lock. So we
use different locks to synchronize against truncate, or other page faults
of the same page by a different process. And modification of page tables
needs to be protected by these locks in the same way as it needs to be
protected by the page lock for normal pages.

So I find it to be bigger layering violation for generic mm layer to know
how DAX decided to serialize racing page faults, than for DAX layer to call
helpers from mm layer to update page tables when it holds appropriate
locks.

Essentially we just switch from a model "Return data from a fault handler
so that generic layer can finish the page fault" to a model "Call helper
from the fault handler passing it necessary information to finish the page
fault". That model is more flexible (I agree it offers more opportunities
for abuse as well) but overall result looks IMHO cleaner.

And I would add that modifying page tables from a fault handler is nothing
new - basically every video driver does it. They just generally don't have
that comprehensive support for mmap so they get away with less exported
functionality.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
