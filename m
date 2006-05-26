From: David Howells <dhowells@redhat.com>
In-Reply-To: <Pine.LNX.4.64.0605250921300.23726@schroedinger.engr.sgi.com> 
References: <Pine.LNX.4.64.0605250921300.23726@schroedinger.engr.sgi.com>  <20060525135534.20941.91650.sendpatchset@lappy> <20060525135555.20941.36612.sendpatchset@lappy> 
Subject: Re: [PATCH 1/3] mm: tracking shared dirty pages 
Date: Fri, 26 May 2006 15:33:05 +0100
Message-ID: <24747.1148653985@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:

> >  - rebased on top of David Howells' page_mkwrite() patch.
> 
> I am a bit confused about the need for Davids patch. set_page_dirty() is 
> already a notification that a page is to be dirtied. Why do we need it 
> twice? set_page_dirty could return an error code and the file system can 
> use the set_page_dirty() hook to get its notification. What we would need 
> to do is to make sure that set_page_dirty can sleep.

page_mkwrite() is called just before the _PTE_ is dirtied.  Take do_wp_page()
for example, set_page_dirty() is called after a lot of stuff, including some
stuff that marks the PTE dirty... by which time it's too late as another
thread sharing the page tables can come along and modify the page before the
first thread calls set_page_dirty().

Furthermore, by that point, it's pointless to have set_page_dirty() return an
error by then.  The deed is effectively done: the PTE is marked dirty and
writable.

And also as you pointed out, set_page_dirty() needs to be able to sleep.
There are places where it's called still, even with Peter's patch, with the
page table lock held - zap_pte_range() for example.  In that particular case,
dropping the lock for each PTE would be bad for performance.

Basically, you can look at it as page_mkwrite() is called upfront, and
set_page_dirty() is called at the end.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
