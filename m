Date: Tue, 2 Aug 2005 18:27:59 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <Pine.LNX.4.58.0508020942360.3341@g5.osdl.org>
Message-ID: <Pine.LNX.4.61.0508021821310.5659@goblin.wat.veritas.com>
References: <OF3BCB86B7.69087CF8-ON42257051.003DCC6C-42257051.00420E16@de.ibm.com>
 <Pine.LNX.4.58.0508020829010.3341@g5.osdl.org>
 <Pine.LNX.4.61.0508021645050.4921@goblin.wat.veritas.com>
 <Pine.LNX.4.58.0508020911480.3341@g5.osdl.org> <Pine.LNX.4.58.0508020942360.3341@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Aug 2005, Linus Torvalds wrote:
> 
> Since we will have dropped the page table lock when calling
> handle_mm_fault() (which will just re-get the lock and then drop it 
> again) _and_ since we don't actually mark the page dirty if it was 
> writable, it's entirely possible that the VM scanner comes in and just 
> drops the page from the page tables.
> 
> Now, that doesn't sound so bad, but what we have then is a page that is
> marked dirty in the "struct page", but hasn't been actually dirtied yet.  
> It could get written out and marked clean (can anybody say "preemptible
> kernel"?) before we ever actually do the write to the page.
> 
> The thing is, we should always set the dirty bit either atomically with
> the access (normal "CPU sets the dirty bit on write") _or_ we should set
> it after the write (having kept a reference to the page).
> 
> Or does anybody see anything that protects us here?
> 
> Now, I don't think we can fix that race (which is probably pretty much 
> impossible to hit in practice) in the 2.6.13 timeframe.

I believe this particular race has been recognized since day one of
get_user_pages, and we've always demanded that the caller must do a
SetPageDirty (I should probably say set_page_dirty) before freeing
the pages held for writing.

Which is why I was a bit puzzled to see that prior set_page_dirty
in __follow_page, which Andrew identified as for s390.

> Maybe I'll have to just accept the horrid "VM_FAULT_RACE" patch. I don't
> much like it, but.. 

I've not yet reached a conclusion on that,
need to think more about doing mkclean in copy_one_pte.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
