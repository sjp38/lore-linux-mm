Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1619D6B0037
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 17:10:40 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id hl1so451804igb.5
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:10:39 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id yx9si13913832icb.33.2014.01.10.14.10.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jan 2014 14:10:35 -0800 (PST)
Date: Fri, 10 Jan 2014 23:10:10 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH] mm: thp: Add per-mm_struct flag to control THP
Message-ID: <20140110221010.GP31570@twins.programming.kicks-ass.net>
References: <1389383718-46031-1-git-send-email-athorlton@sgi.com>
 <20140110202310.GB1421@node.dhcp.inet.fi>
 <20140110220155.GD3066@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140110220155.GD3066@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On Fri, Jan 10, 2014 at 04:01:55PM -0600, Alex Thorlton wrote:
> On Fri, Jan 10, 2014 at 10:23:10PM +0200, Kirill A. Shutemov wrote:
> > Do you know what cause the difference? I prefer to fix THP instead of
> > adding new knob to disable it.
> 
> The issue is that when you touch 1 byte of an untouched, contiguous 2MB
> chunk, a THP will be handed out, and the THP will be stuck on whatever
> node the chunk was originally referenced from.  If many remote nodes
> need to do work on that same chunk, they'll be making remote accesses.
> With THP disabled, 4K pages can be handed out to separate nodes as
> they're needed, greatly reducing the amount of remote accesses to
> memory.  I give a bit better description here:
> 
> https://lkml.org/lkml/2013/8/27/397
> 
> I had been looking into better ways to handle this issues, but after
> spinning through a few other ideas:
> 
> - Per cpuset flag to control THP:
> https://lkml.org/lkml/2013/6/10/331
> 
> - Threshold to determine when to hand out THPs:
> https://lkml.org/lkml/2013/12/12/394
> 
> We've arrived back here.  Andrea seemed to think that this is an
> acceptable approach to solve the problem, at least as a starting point:
> 
> https://lkml.org/lkml/2013/12/17/397
> 
> I agree that we should, ideally, come up with a way to appropriately
> handle this problem in the kernel, but as of right now, it appears that
> that might be a rather large undertaking.

We already have the information to determine if a page is shared across
nodes, Mel even had some prototype code to do splits under those
conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
