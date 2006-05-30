Date: Tue, 30 May 2006 10:02:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/3] mm: tracking shared dirty pages 
In-Reply-To: <7966.1149006374@warthog.cambridge.redhat.com>
Message-ID: <Pine.LNX.4.64.0605300953390.17716@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605300818080.16904@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605260825160.31609@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605250921300.23726@schroedinger.engr.sgi.com>
 <20060525135534.20941.91650.sendpatchset@lappy> <20060525135555.20941.36612.sendpatchset@lappy>
 <24747.1148653985@warthog.cambridge.redhat.com> <12042.1148976035@warthog.cambridge.redhat.com>
  <7966.1149006374@warthog.cambridge.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 May 2006, David Howells wrote:

> > If set_page_dirty cannot reserve the page then we know that some severe
> > action is required. The FS method set_page_dirty() could:
> 
> But by the time set_page_dirty() is called, it's too late as the code
> currently stands.  We've already marked the PTE writable and dirty.  The
> page_mkwrite() op is called _first_.

We are in set_page_dirty and this would be part of set_page_dirty 
processing.

> > 2. Track down all processes that use the mapping (or maybe less
> 
> That's bad, even if you restrict it to those that have MAP_SHARED and
> PROT_WRITE set.  They should not be terminated if they haven't attempted to
> write to the mapping.

Its bad but the out of space situation is an exceptional situation. We do 
similar contortions when we run out of memory space. As I said: One can 
track down the processes that have dirtied the pte to the page in question 
and just terminate those and remove the page.

> What's wrong with my suggestion anyway?

Adds yet another method with functionality that for the most part 
is the same as set_page_dirty().

The advantage of such a method seems to be that it reserves filesystem 
space for pages that could potentially be written to. This allows the 
filesystem to accurately deal with out of space situations (a very rare 
condition. Is this really justifiable?). Maybe having already reserved 
space could speed up the real dirtying of pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
