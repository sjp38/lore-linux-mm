Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07DC86B026A
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:38:43 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so34705002wjb.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:38:42 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id j133si23362486wma.124.2017.01.25.10.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:38:41 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id d140so44570277wmd.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:38:41 -0800 (PST)
Date: Wed, 25 Jan 2017 21:38:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/12] uprobes: split THPs before trying replace them
Message-ID: <20170125183839.GC4157@node>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
 <20170124162824.91275-2-kirill.shutemov@linux.intel.com>
 <20170124132849.73135e8c6e9572be00dbbe79@linux-foundation.org>
 <20170124222217.GB19920@node.shutemov.name>
 <20170125165522.GA11569@linux.vnet.ibm.com>
 <20170125183510.GB17286@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125183510.GB17286@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jan 25, 2017 at 01:35:10PM -0500, Johannes Weiner wrote:
> On Wed, Jan 25, 2017 at 08:55:22AM -0800, Srikar Dronamraju wrote:
> > > > 
> > > > > For THPs page_check_address() always fails. It's better to split them
> > > > > first before trying to replace.
> > > > 
> > > > So what does this mean.  uprobes simply fails to work when trying to
> > > > place a probe into a THP memory region?
> > > 
> > > Looks like we can end up with endless retry loop in uprobe_write_opcode().
> > > 
> > > > How come nobody noticed (and reported) this when using the feature?
> > > 
> > > I guess it's not often used for anon memory.
> > > 
> > 
> > The first time the breakpoint is hit on a page, it replaces the text
> > page with anon page.  Now lets assume we insert breakpoints in all the
> > pages in a range. Here each page is individually replaced by a non THP
> > anonpage. (since we dont have bulk breakpoint insertion support,
> > breakpoint insertion happens one at a time). Now the only interesting
> > case may be when each of these replaced pages happen to be physically
> > contiguous so that THP kicks in to replace all of these pages with one
> > THP page. Can happen in practice?
> > 
> > Are there any other cases that I have missed?
> 
> We use a hack in our applications where we open /proc/self/maps, copy
> text segments to a staging area, then create overlay anon mappings on
> top and copy the text back into them. Now we have THP-backed text and
> very little iTLB pressure :-)

Just use tmpfs with huge pages :)

> That said, we haven't run into the uprobes issue yet.

Is it possible to have uprobes in anon memory?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
