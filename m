Received: from localhost (hahn@localhost)
	by coffee.psychology.mcmaster.ca (8.9.3/8.9.3) with ESMTP id QAA31677
	for <linux-mm@kvack.org>; Wed, 30 May 2001 16:01:03 -0400
Date: Wed, 30 May 2001 16:01:02 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: Plain 2.4.5 VM
In-Reply-To: <Pine.LNX.4.21.0105301613520.13062-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.10.10105301539030.31487-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The "easy way out" seems to be physical -> virtual
> page reverse mappings, these make it trivial to apply
> balanced pressure on all pages.

hmm, I've been wondering if one of our problems is that while
the active/inactive-clean/inactive-dirty system does well
at preserving age info, but the only place we actually
*learn* NEW information about page use is in try_to_swap_out:

	if (ptep_test_and_clear_young(pte))
		age up;
	else		
		get rid of it;

shouldn't we try to gain more information by scanning page tables
at a good rate?  we don't have to blindly get rid of every page
that isn't young (referenced since last scan) - we could base that
on age.  admittedly, more scanning would eat some additional CPU,
but then again, we currently shuffle pages among lists based on relatively
sparse PAGE_ACCESSED info.

or am I missing something?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
