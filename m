Date: Tue, 9 Nov 2004 11:51:22 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-Id: <20041109115122.767f923f.akpm@osdl.org>
In-Reply-To: <20041109144659.GC17639@x30.random>
References: <20041021223613.GA8756@dualathlon.random>
	<20041021160233.68a84971.akpm@osdl.org>
	<20041021232059.GE8756@dualathlon.random>
	<20041021164245.4abec5d2.akpm@osdl.org>
	<20041022003004.GA14325@dualathlon.random>
	<20041022012211.GD14325@dualathlon.random>
	<20041021190320.02dccda7.akpm@osdl.org>
	<20041022161744.GF14325@dualathlon.random>
	<20041022162433.509341e4.akpm@osdl.org>
	<1100009730.7478.1.camel@localhost>
	<20041109144659.GC17639@x30.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: shaggy@austin.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@novell.com> wrote:
>
> On Tue, Nov 09, 2004 at 08:15:30AM -0600, Dave Kleikamp wrote:
>  > Andrew & Andrea,
>  > What is the status of this patch?  It would be nice to have it in the
>  > -mm4 kernel.
> 
>  I think we should add an msync in front of O_DIRECT reads too (msync
>  won't hurt other users, and it'll provide full coherency), everything
>  else is ok (the msync can be added as an incremental patch).

I don't think we have a simple way of syncing all ptes which map the pages
without actually shooting those pte's down, via zap_page_range().  A
filemap_sync() will only sync the caller's mm's ptes.

I guess it would be pretty simple to add a sync_but_dont_unmap field to
struct zap_details, and propagate that down.  So we can reuse all the
unmap_vmas() code for an all-mms pte sync.

It could all get very expensive if someone has a bit of the file mapped
though.  Testing is needed there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
