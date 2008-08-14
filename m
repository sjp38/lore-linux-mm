Subject: Re: [rfc][patch] mm: dirty page accounting race fix
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0808141210200.4398@blonde.site>
References: <20080814094537.GA741@wotan.suse.de>
	 <Pine.LNX.4.64.0808141210200.4398@blonde.site>
Content-Type: text/plain
Date: Thu, 14 Aug 2008 14:18:38 +0200
Message-Id: <1218716318.10800.209.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-08-14 at 12:55 +0100, Hugh Dickins wrote:

> But I got a bit distracted: mprotect's change_pte_range is
> traditionally where the pte_modify operation has been split up into
> stages on some arches, that really can be restricting permissions
> and needs to tread carefully.  Now I go to look there, I see its
> 		/*
> 		 * Avoid taking write faults for pages we know to be
> 		 * dirty.
> 		 */
> 		if (dirty_accountable && pte_dirty(ptent))
> 			ptent = pte_mkwrite(ptent);
> 
> and get rather worried: isn't that likely to be giving write permission
> to a pte in a vma we are precisely taking write permission away from?

Exactly, we do that because the page is already dirty, therefore we do
not need to trap on write to mark it dirty - at least, that was the idea
behind this optimization.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
