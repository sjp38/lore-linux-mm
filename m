Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id EB3E76B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 05:26:27 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id g15so3866752eak.17
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 02:26:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8si16376987eeh.116.2014.01.22.02.26.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 02:26:26 -0800 (PST)
Date: Wed, 22 Jan 2014 10:26:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: thp: Add per-mm_struct flag to control THP
Message-ID: <20140122102621.GU4963@suse.de>
References: <1389383718-46031-1-git-send-email-athorlton@sgi.com>
 <20140110202310.GB1421@node.dhcp.inet.fi>
 <20140110220155.GD3066@sgi.com>
 <20140110221010.GP31570@twins.programming.kicks-ass.net>
 <20140110223909.GA8666@sgi.com>
 <20140114154457.GD4963@suse.de>
 <20140114193801.GV10649@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140114193801.GV10649@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On Tue, Jan 14, 2014 at 01:38:01PM -0600, Alex Thorlton wrote:
> On Tue, Jan 14, 2014 at 03:44:57PM +0000, Mel Gorman wrote:
> > On Fri, Jan 10, 2014 at 04:39:09PM -0600, Alex Thorlton wrote:
> > > On Fri, Jan 10, 2014 at 11:10:10PM +0100, Peter Zijlstra wrote:
> > > > We already have the information to determine if a page is shared across
> > > > nodes, Mel even had some prototype code to do splits under those
> > > > conditions.
> > > 
> > > I'm aware that we can determine if pages are shared across nodes, but I
> > > thought that Mel's code to split pages under these conditions had some
> > > performance issues.  I know I've seen the code that Mel wrote to do
> > > this, but I can't seem to dig it up right now.  Could you point me to
> > > it?
> > > 
> > 
> > It was a lot of revisions ago! The git branches no longer exist but the
> > diff from the monolithic patches is below. The baseline was v3.10 and
> > this will no longer apply but you'll see the two places where I added a
> > split_huge_page and prevented khugepaged collapsing them again. 
> 
> Thanks, Mel.  I remember seeing this code a while back when we were
> discussing THP/locality issues.
> 
> > At the time, the performance with it applied was much worse but it was a
> > 10 minute patch as a distraction. There was a range of basic problems that
> > had to be tackled before there was any point looking at splitting THP due
> > to locality. I did not pursue it further and have not revisited it since.
> 
> So, in your opinion, is this something we should look into further
> before moving towards the per-mm switch that I propose here? 

No because they have different purposes. Any potential split of THP from
automatic NUMA balancing context is due to it detecting that threads running
on CPUs on different nodes are accessing a THP. You are proposing to have
a per-mm flag that prevents THP being allocated in the first place. They
are two separate problems with decisions that are made at completely
different times.

> I
> personally think that it will be tough to get this to perform as well as
> a method that totally disables THP when requested, or a method that
> tries to prevent THPs from being handed out in certain situations, since
> we'll be doing the work of both making and splitting a THP in the case
> where remote accesses are made to the page.
> 

I would expect that the alternative solution to a per-mm switch is to
reserve the naturally aligned pages for a THP promotion. Have a threshold
of pages pages that must be faulted before the full THP's worth of pages
is allocated, zero'd and a huge pmd established. That would defer the
THP setup costs until it was detected that it was necessary.

The per-mm THP switch is a massive hammer but not necessarily a bad one.

> I also think there could be some issues with over-zealously splitting
> pages, since it sounds like we can only determine if an access is from a
> remote node.  We don't have a good way of determining how many accesses
> are remote vs. local, or how many separate nodes are accessing a page.
> 

Indeed not, but it's a different problem. We also do not know if the
remote accesses are to a single page in which case splitting it would
have zero benefit anyway.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
