Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA02777
	for <linux-mm@kvack.org>; Mon, 3 Mar 2003 13:16:02 -0800 (PST)
Date: Mon, 3 Mar 2003 13:12:10 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH 2.5.63] Teach page_mapped about the anon flag
Message-Id: <20030303131210.36645af6.akpm@digeo.com>
In-Reply-To: <103400000.1046725581@baldur.austin.ibm.com>
References: <20030227025900.1205425a.akpm@digeo.com>
	<200302280822.09409.kernel@kolivas.org>
	<20030227134403.776bf2e3.akpm@digeo.com>
	<118810000.1046383273@baldur.austin.ibm.com>
	<20030227142450.1c6a6b72.akpm@digeo.com>
	<103400000.1046725581@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> 
> --On Thursday, February 27, 2003 14:24:50 -0800 Andrew Morton
> <akpm@digeo.com> wrote:
> 
> > I'm just looking at page_mapped().  It is now implicitly assuming that the
> > architecture's representation of a zero-count atomic_t is all-bits-zero.
> > 
> > This is not true on sparc32 if some other CPU is in the middle of an
> > atomic_foo() against that counter.  Maybe the assumption is false on other
> > architectures too.
> > 
> > So page_mapped() really should be performing an atomic_read() if that is
> > appropriate to the particular page.  I guess this involves testing
> > page->mapping.  Which is stable only when the page is locked or
> > mapping->page_lock is held.
> > 
> > It appears that all page_mapped() callers are inside lock_page() at
> > present, so a quick audit and addition of a comment would be appropriate
> > there please.
> 
> I'm not at all confident that page_mapped() is adequately protected.

It is.  All callers which need to be 100% accurate are under
pte_chain_lock().

> Here's a patch that explicitly handles the atomic_t case.

OK..  But it increases dependency on PageAnon.  Wasn't the plan to remove
that at some time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
