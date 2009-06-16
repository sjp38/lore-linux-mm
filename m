Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 380486B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 10:21:38 -0400 (EDT)
Date: Tue, 16 Jun 2009 16:22:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: 2.6.29.4: softlockup at find_get_page() et al
Message-ID: <20090616142214.GB18444@wotan.suse.de>
References: <20090616110051.GA4864@x200.localdomain> <20090616130833.GA27925@wotan.suse.de> <20090616131454.GA6168@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090616131454.GA6168@x200.localdomain>
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 05:14:54PM +0400, Alexey Dobriyan wrote:
> On Tue, Jun 16, 2009 at 03:08:33PM +0200, Nick Piggin wrote:
> > Thanks. Is it rebooted? It would be interesting to know what other
> > CPUs are doing (and even what other tasks are doing) if it is
> > still up.
> 
> It was rebooted, sorry.

Thanks. It is hard to know where it is looping, but I see a put_page
in there which seems to suggest it reached at least the "Has the page
moved" test. But if the stack trace is 100% accurate, then it seems
like it has hit the "Has the page been truncated" part of find_lock_page.

And it is an ext2 dir page. And these pages should not get truncated
unless rmdir. But we can't be in rmdir I think because we are doing a
mkdir.

It would seem like the page is still in the pagecache, but ->mapping
is wrong. But actually that is strange because we should have a
new inode here, so find_get_page should not even find a page in
find_or_create_page. There should be no way for a racing thread to
add a page there either.

I would almost have to suspect hardware or software error causing
random memory scribble. I would definitely be very interested if
you can reproduce (I suspect it won't be reproducable though).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
