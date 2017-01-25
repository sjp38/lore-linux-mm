Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D25996B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:44:55 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r144so39790510wme.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:44:55 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id b27si13304889wmi.98.2017.01.25.09.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 09:44:54 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id r144so44107558wme.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:44:54 -0800 (PST)
Date: Wed, 25 Jan 2017 20:44:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/12] uprobes: split THPs before trying replace them
Message-ID: <20170125174452.GA4157@node>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
 <20170124162824.91275-2-kirill.shutemov@linux.intel.com>
 <20170124132849.73135e8c6e9572be00dbbe79@linux-foundation.org>
 <20170124222217.GB19920@node.shutemov.name>
 <20170125165522.GA11569@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125165522.GA11569@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jan 25, 2017 at 08:55:22AM -0800, Srikar Dronamraju wrote:
> > > 
> > > > For THPs page_check_address() always fails. It's better to split them
> > > > first before trying to replace.
> > > 
> > > So what does this mean.  uprobes simply fails to work when trying to
> > > place a probe into a THP memory region?
> > 
> > Looks like we can end up with endless retry loop in uprobe_write_opcode().
> > 
> > > How come nobody noticed (and reported) this when using the feature?
> > 
> > I guess it's not often used for anon memory.
> > 
> 
> The first time the breakpoint is hit on a page, it replaces the text
> page with anon page.  Now lets assume we insert breakpoints in all the
> pages in a range. Here each page is individually replaced by a non THP
> anonpage. (since we dont have bulk breakpoint insertion support,
> breakpoint insertion happens one at a time). Now the only interesting
> case may be when each of these replaced pages happen to be physically
> contiguous so that THP kicks in to replace all of these pages with one
> THP page. Can happen in practice?

The problem is with the page you try to replace, not with page that you
replace it with.

> Are there any other cases that I have missed?

The binary on tmpfs with huge pages. I wrote test-case that triggers the
problem.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
