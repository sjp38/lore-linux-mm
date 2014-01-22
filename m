Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id D26D86B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 16:46:10 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id c41so391756yho.6
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:46:10 -0800 (PST)
Received: from mail-yh0-x234.google.com (mail-yh0-x234.google.com [2607:f8b0:4002:c01::234])
        by mx.google.com with ESMTPS id f25si12557884yho.278.2014.01.22.13.46.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 13:46:09 -0800 (PST)
Received: by mail-yh0-f52.google.com with SMTP id v1so395026yhn.39
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:46:08 -0800 (PST)
Date: Wed, 22 Jan 2014 13:46:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm: thp: Add per-mm_struct flag to control THP
In-Reply-To: <20140122175328.GO18196@sgi.com>
Message-ID: <alpine.DEB.2.02.1401221343580.22014@chino.kir.corp.google.com>
References: <1389383718-46031-1-git-send-email-athorlton@sgi.com> <20140110202310.GB1421@node.dhcp.inet.fi> <20140110220155.GD3066@sgi.com> <20140110221010.GP31570@twins.programming.kicks-ass.net> <20140110223909.GA8666@sgi.com> <20140114154457.GD4963@suse.de>
 <20140114193801.GV10649@sgi.com> <20140122102621.GU4963@suse.de> <20140122175328.GO18196@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On Wed, 22 Jan 2014, Alex Thorlton wrote:

> > I would expect that the alternative solution to a per-mm switch is to
> > reserve the naturally aligned pages for a THP promotion. Have a threshold
> > of pages pages that must be faulted before the full THP's worth of pages
> > is allocated, zero'd and a huge pmd established. That would defer the
> > THP setup costs until it was detected that it was necessary.
> 
> I have some half-finished patches that I was working on a month or so
> ago, to do exactly this (I think you were involved with some of the
> discussion, maybe?  I'd have to dig up the e-mails to be sure).  After
> cycling through numerous other methods of handling this problem, I still
> like that idea, but I think it's going to require a decent amount of
> effort to get finished.  
> 

If you're going to go this route, I think a sane value would be 
max_ptes_none that controls when khugepaged would re-collapse a split 
hugepage into another hugepage after something does madvise(MADV_DONTNEED) 
to a region, for example.  Otherwise it could collapse that memory into a 
hugepage even though it wasn't faulted as huge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
