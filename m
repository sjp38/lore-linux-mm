Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 572E16B0279
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 12:21:14 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o1so55476165ito.7
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 09:21:14 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id n128si6153554itg.92.2016.11.16.09.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 09:21:13 -0800 (PST)
Date: Wed, 16 Nov 2016 18:21:08 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 01/21] mm: Join struct fault_env and vm_fault
Message-ID: <20161116172108.GV3142@twins.programming.kicks-ass.net>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-2-git-send-email-jack@suse.cz>
 <20161115215021.GA23021@node>
 <20161116105132.GR3142@twins.programming.kicks-ass.net>
 <20161116110101.GE21785@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161116110101.GE21785@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 16, 2016 at 12:01:01PM +0100, Jan Kara wrote:
> On Wed 16-11-16 11:51:32, Peter Zijlstra wrote:

> > Now, I'm entirely out of touch wrt DAX, so I've not idea what that
> > needs/wants.
> 
> Yeah, DAX does not have 'struct page' for its pages so it directly installs
> PFNs in the page tables. As a result it needs to know about page tables and
> stuff.

Not convinced, a physical address should then be the equivalent of a
struct page. You still don't need access to the actual pages tables. The
VM core can then convert the physical address to a PFN and stuff it in
the PTE entry.

> Now I've abstracted knowledge about that into helper functions back
> in mm/ but still we need to pass the information through the ->fault handler
> into those helpers and vm_fault structure is simply natural for that.
> So far we have tried to avoid that but the result was not pretty (special
> return codes from DAX ->fault handlers essentially leaking information
> about DAX internal locking into mm/ code to direct generic mm code to do
> the right thing for DAX).

Its probably the DAX locking bit I'm missing, because I cannot see why
VM_FAULT_DAX_LOCKED is 'broken' -- also, I'd have called that
VM_FAULT_PFN or similar and not have used the full entry but only the
PFN bits from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
