Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA15368
	for <linux-mm@kvack.org>; Thu, 27 Feb 2003 14:28:14 -0800 (PST)
Date: Thu, 27 Feb 2003 14:24:50 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Rising io_load results Re: 2.5.63-mm1
Message-Id: <20030227142450.1c6a6b72.akpm@digeo.com>
In-Reply-To: <118810000.1046383273@baldur.austin.ibm.com>
References: <20030227025900.1205425a.akpm@digeo.com>
	<200302280822.09409.kernel@kolivas.org>
	<20030227134403.776bf2e3.akpm@digeo.com>
	<118810000.1046383273@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: kernel@kolivas.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> 
> --On Thursday, February 27, 2003 13:44:03 -0800 Andrew Morton
> <akpm@digeo.com> wrote:
> 
> >> ...
> >> Mapped:       4294923652 kB
> > 
> > Well that's gotta hurt.  This metric is used in making writeback
> > decisions.  Probably the objrmap patch.
> 
> Oops.  You're right.  Here's a patch to fix it.
> 

Thanks.

I'm just looking at page_mapped().  It is now implicitly assuming that the
architecture's representation of a zero-count atomic_t is all-bits-zero.

This is not true on sparc32 if some other CPU is in the middle of an
atomic_foo() against that counter.  Maybe the assumption is false on other
architectures too.

So page_mapped() really should be performing an atomic_read() if that is
appropriate to the particular page.  I guess this involves testing
page->mapping.  Which is stable only when the page is locked or
mapping->page_lock is held.

It appears that all page_mapped() callers are inside lock_page() at present,
so a quick audit and addition of a comment would be appropriate there please.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
