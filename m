Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 916246B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 09:39:57 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b2so93006277pgc.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 06:39:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m7si7587456pgd.112.2017.03.02.06.39.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 06:39:56 -0800 (PST)
Date: Thu, 2 Mar 2017 06:39:49 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170302143949.GP16328@bombadil.infradead.org>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228181547.GM5680@worktop>
 <20170302042021.GN16328@bombadil.infradead.org>
 <004101d2930f$d51a9f90$7f4fdeb0$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <004101d2930f$d51a9f90$7f4fdeb0$@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "byungchul.park" <byungchul.park@lge.com>
Cc: 'Peter Zijlstra' <peterz@infradead.org>, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Mar 02, 2017 at 01:45:35PM +0900, byungchul.park wrote:
> From: Matthew Wilcox [mailto:willy@infradead.org]
> > On Tue, Feb 28, 2017 at 07:15:47PM +0100, Peter Zijlstra wrote:
> > > (And we should not be returning to userspace with locks held anyway --
> > > lockdep already has a check for that).
> > 
> > Don't we return to userspace with page locks held, eg during async
> > directio?
> 
> Hello,
> 
> I think that the check when returning to user with crosslocks held
> should be an exception. Don't you think so?

Oh yes.  We have to keep the pages locked during reads, and we have to
return to userspace before I/O is complete, therefore we have to return
to userspace with pages locked.  They'll be unlocked by the interrupt
handler in page_endio().

Speaking of which ... this feature is far too heavy for use in production
on pages.  You're almost trebling the size of struct page.  Can we
do something like make all struct pages share the same lockdep_map?
We'd have to not complain about holding one crossdep lock and acquiring
another one of the same type, but with millions of pages in the system,
it must surely be creating a gargantuan graph right now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
