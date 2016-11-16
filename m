Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA7206B0260
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 06:13:04 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so21945237wma.2
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 03:13:04 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id y130si6825535wmc.29.2016.11.16.03.13.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 03:13:03 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id a20so9966332wme.2
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 03:13:03 -0800 (PST)
Date: Wed, 16 Nov 2016 14:13:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/21] mm: Join struct fault_env and vm_fault
Message-ID: <20161116111301.GA27027@node.shutemov.name>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-2-git-send-email-jack@suse.cz>
 <20161115215021.GA23021@node>
 <20161116105132.GR3142@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161116105132.GR3142@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 16, 2016 at 11:51:32AM +0100, Peter Zijlstra wrote:
> On Wed, Nov 16, 2016 at 12:50:21AM +0300, Kirill A. Shutemov wrote:
> > On Fri, Nov 04, 2016 at 05:24:57AM +0100, Jan Kara wrote:
> > > Currently we have two different structures for passing fault information
> > > around - struct vm_fault and struct fault_env. DAX will need more
> > > information in struct vm_fault to handle its faults so the content of
> > > that structure would become event closer to fault_env. Furthermore it
> > > would need to generate struct fault_env to be able to call some of the
> > > generic functions. So at this point I don't think there's much use in
> > > keeping these two structures separate. Just embed into struct vm_fault
> > > all that is needed to use it for both purposes.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > 
> > I'm not necessary dislike this, but I remember Peter had objections before
> > when I proposed something similar.
> > 
> > Peter?
> 
> My objection was that it would be a layering violation. The 'filesystem'
> shouldn't know about page-tables, all it should do is return a page
> matching a specific offset.

Well, this layering violation is already there (blame me): see
vm_ops->map_pages(). :P

> So fault_env manages the core vm parts and has the page-table bits in,
> vm_fault manages the filesystem interface and gets us a page given an
> offset.
> 
> Now, I'm entirely out of touch wrt DAX, so I've not idea what that
> needs/wants.

I think we are better off with one structure. It streamlines code in quite
a few places.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
