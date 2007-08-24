Received: from [10.10.97.15]([10.10.97.15]) (1729 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1IOWpi-000AIaC@megami.veritas.com>
	for <linux-mm@kvack.org>; Fri, 24 Aug 2007 03:56:06 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Fri, 24 Aug 2007 11:55:59 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: pte_none versus pte_present
In-Reply-To: <38b2ab8a0708240202o6570cf55j2d97e45663d8165e@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708241137180.13431@blonde.wat.veritas.com>
References: <38b2ab8a0708240202o6570cf55j2d97e45663d8165e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Francis Moreau <francis.moro@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Aug 2007, Francis Moreau wrote:
> 
> Sorry for being blind but I cannot see any differences between
> these 2 helpers.  When should we prefer using one rather the other ?

pte_present says if there's a real page table entry there (including
the exceptional case of a pte which is not-present to the MMU, but
otherwise a good pte: sometimes required when handling PROT_NONE).

pte_none says if the slot is empty: when a pte is not present, we may
use its slot to note where to find the page when it's to be faulted
in; or if that's not needed leave it empty as pte_none.

The common case of !pte_present && !pte_none is when an anonymous page
is swapped out: the slot notes where the required page can be found
on swap.  Oddly we don't have a macro for that case, but for the less
common case of pte_file: used in a VM_NONLINEAR vma, to note what
offset of the file to pull the page from when faulting in.  (And
page migration uses a swap-like value, without actually using swap.)

Hope that helps you to decide which one you need.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
