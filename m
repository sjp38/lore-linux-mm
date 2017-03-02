Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB696B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 18:50:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id t184so109471505pgt.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 15:50:21 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id v35si8735518pgn.161.2017.03.02.15.50.19
        for <linux-mm@kvack.org>;
        Thu, 02 Mar 2017 15:50:20 -0800 (PST)
Date: Fri, 3 Mar 2017 08:50:03 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170302235003.GE28562@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228181547.GM5680@worktop>
 <20170302042021.GN16328@bombadil.infradead.org>
 <004101d2930f$d51a9f90$7f4fdeb0$@lge.com>
 <20170302143949.GP16328@bombadil.infradead.org>
MIME-Version: 1.0
In-Reply-To: <20170302143949.GP16328@bombadil.infradead.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: 'Peter Zijlstra' <peterz@infradead.org>, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Mar 02, 2017 at 06:39:49AM -0800, Matthew Wilcox wrote:
> On Thu, Mar 02, 2017 at 01:45:35PM +0900, byungchul.park wrote:
> > From: Matthew Wilcox [mailto:willy@infradead.org]
> > > On Tue, Feb 28, 2017 at 07:15:47PM +0100, Peter Zijlstra wrote:
> > > > (And we should not be returning to userspace with locks held anyway --
> > > > lockdep already has a check for that).
> > > 
> > > Don't we return to userspace with page locks held, eg during async
> > > directio?
> > 
> > Hello,
> > 
> > I think that the check when returning to user with crosslocks held
> > should be an exception. Don't you think so?
> 
> Oh yes.  We have to keep the pages locked during reads, and we have to
> return to userspace before I/O is complete, therefore we have to return
> to userspace with pages locked.  They'll be unlocked by the interrupt
> handler in page_endio().

Agree.

> Speaking of which ... this feature is far too heavy for use in production
> on pages.  You're almost trebling the size of struct page.  Can we
> do something like make all struct pages share the same lockdep_map?
> We'd have to not complain about holding one crossdep lock and acquiring
> another one of the same type, but with millions of pages in the system,
> it must surely be creating a gargantuan graph right now?

Um.. I will try it for page locks to work with one lockmap. That is also
what Peterz pointed out and what I worried about when implementing..

Thanks for your opinion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
