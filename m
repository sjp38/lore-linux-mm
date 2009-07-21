Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B82CA6B004F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 03:16:54 -0400 (EDT)
Date: Tue, 21 Jul 2009 09:16:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 05/10] ksm: no debug in page_dup_rmap()
Message-ID: <20090721071654.GB7816@wotan.suse.de>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com> <1247851850-4298-3-git-send-email-ieidus@redhat.com> <1247851850-4298-4-git-send-email-ieidus@redhat.com> <1247851850-4298-5-git-send-email-ieidus@redhat.com> <1247851850-4298-6-git-send-email-ieidus@redhat.com> <4A64B342.8070002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A64B342.8070002@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Jul 20, 2009 at 02:11:14PM -0400, Rik van Riel wrote:
> Izik Eidus wrote:
> >From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> >
> >page_dup_rmap(), used on each mapped page when forking,  was originally
> >just an inline atomic_inc of mapcount.  2.6.22 added CONFIG_DEBUG_VM
> >out-of-line checks to it, which would need to be ever-so-slightly
> >complicated to allow for the PageKsm() we're about to define.
> >
> >But I think these checks never caught anything.  And if it's coding
> >errors we're worried about, such checks should be in page_remove_rmap()
> >too, not just when forking; whereas if it's pagetable corruption we're
> >worried about, then they shouldn't be limited to CONFIG_DEBUG_VM.
> 
> Acked-by: Rik van Riel <riel@redhat.com>

I like debug code like this as it helps comment the code a litte
bit too. We've got lots of debug checks in the VM and probably
very few of them catch anything useful... I'd kind of like to see
it be ever-so-slightly complicated with PageKsm, and even a call
to page_check_anon_rmap put into page_remove_rmap (which is a good
idea).

pagetable corruption/struct page corruption I think is good to
check for, but it is fine to have such checks under DEBUG_VM --
we have a couple of orders of magnitude more memory that is not
for struct page, so decent coverage of memory corruption kind of
wants slab and page debugging too, don't you think?

/checks the sky for pigs...
  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
