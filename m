Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 50E266B01AE
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:42:24 -0400 (EDT)
Date: Thu, 25 Mar 2010 23:41:19 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
Message-ID: <20100325224119.GY10659@random.random>
References: <20100318234923.GV29874@random.random>
 <alpine.DEB.2.00.1003190812560.10759@router.home>
 <20100319144101.GB29874@random.random>
 <alpine.DEB.2.00.1003221027590.16606@router.home>
 <20100322170619.GQ29874@random.random>
 <alpine.DEB.2.00.1003231200430.10178@router.home>
 <20100323190805.GH10659@random.random>
 <alpine.DEB.2.00.1003241600001.16492@router.home>
 <20100324212249.GI10659@random.random>
 <alpine.DEB.2.00.1003251708170.10999@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003251708170.10999@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 25, 2010 at 05:17:23PM -0500, Christoph Lameter wrote:
> On Wed, 24 Mar 2010, Andrea Arcangeli wrote:
> 
> > On Wed, Mar 24, 2010 at 04:03:03PM -0500, Christoph Lameter wrote:
> > > If a delay is "altered behavior" then we should no longer run reclaim
> > > because it "alters" the behavior of VM functions.
> >
> > You're comparing the speed of ram with speed of disk. If why it's not
> > acceptable to me isn't clear try booting with mem=100m and I'm sure
> > you'll get it.
> 
> Are you talking about the wait for writeback to be complete? Dirty pages
> can be migrated. With some effort you could avoid the writeback complete
> wait since you are not actually moving the page.

It seems we're derailing, let's try to go back to the context. You
said we can avoid get_page/put_page changes if we do like
migration. Migration bails out if there's a gup reference on the
page. It's _gup_ not writeback we're talking about. gup is used for
I/O too like O_DIRECT (which is mandatory feature for virtual
machines, if not for databases). So the I/O I'm talking about is the
one that any driver or subsystem can do after calling gup. And it's
not a lock on the page or a writeback bitflag, but the gup reference
that we're waiting the I/O to complete, in order to be released. Not
to tell drivers like old KVM pre-mmu-notifier that may never release
the gup reference (these days any driver keeping gup references for
"indefinite" time has to use mmu notifier to play nicely with the VM
but there will always be temporary I/O at the speed-of-disk and
hanging mprotect and mremap on that isn't ok with me).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
