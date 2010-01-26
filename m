Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1ABF36003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 11:21:58 -0500 (EST)
Date: Tue, 26 Jan 2010 17:19:19 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126161919.GP30452@random.random>
References: <patchbomb.1264054824@v2.random>
 <alpine.DEB.2.00.1001220845000.2704@router.home>
 <20100122151947.GA3690@random.random>
 <alpine.DEB.2.00.1001221008360.4176@router.home>
 <20100123175847.GC6494@random.random>
 <alpine.DEB.2.00.1001251529070.5379@router.home>
 <4B5E3CC0.2060006@redhat.com>
 <20100126065303.GJ8483@redhat.com>
 <20100126123533.GF30452@random.random>
 <alpine.DEB.2.00.1001260955130.23549@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001260955130.23549@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 09:55:43AM -0600, Christoph Lameter wrote:
> How does it do that? Take a reference on each of the 512 pieces? Or does
> it take one reference?

_zero_ reference! gup_fast is there only to pagein, in fact we need to
add one new type of gup_fast that won't take a reference at all and
only ensures the pmd_trans_huge pmd or the regular pte is mapped
before returning (or it will page it in before returning if it
wasn't), with mmu notifier it is always wasteful to take page
pins.

So for now you will run put_page immediately after gup_fast
returns. The whole point of mmu notifier is not to require any
refcount on the pages (or if there are, they are forced to be released
by the mmu notifier methods before they return, otherwise they defeat
the whole purpose of registering into mmu notifier). So the best is
not to take refcounts at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
