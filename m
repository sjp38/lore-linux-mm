Date: Fri, 26 May 2006 08:39:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/3] mm: tracking shared dirty pages 
In-Reply-To: <24747.1148653985@warthog.cambridge.redhat.com>
Message-ID: <Pine.LNX.4.64.0605260825160.31609@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605250921300.23726@schroedinger.engr.sgi.com>
 <20060525135534.20941.91650.sendpatchset@lappy> <20060525135555.20941.36612.sendpatchset@lappy>
  <24747.1148653985@warthog.cambridge.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 26 May 2006, David Howells wrote:

> page_mkwrite() is called just before the _PTE_ is dirtied.  Take do_wp_page()
> for example, set_page_dirty() is called after a lot of stuff, including some
> stuff that marks the PTE dirty... by which time it's too late as another
> thread sharing the page tables can come along and modify the page before the
> first thread calls set_page_dirty().

Since we are terminating the application with extreme prejudice on an 
error (SIGBUS) it does not matter if another process has written to the 
page in the meantime.

> And also as you pointed out, set_page_dirty() needs to be able to sleep.
> There are places where it's called still, even with Peter's patch, with the
> page table lock held - zap_pte_range() for example.  In that particular case,
> dropping the lock for each PTE would be bad for performance.

zap_pte_range would only have to dirty anonymous pages. The pages of 
shared mappings would already be dirty.

> Basically, you can look at it as page_mkwrite() is called upfront, and
> set_page_dirty() is called at the end.

The end is that the page is written back. I think we can still solve this 
with set_page_dirty being called when a page is about to be dirtied or
was dirtied.

The page_mkwrite() method does not really allow the tracking of dirty 
pages. It is a way to track the potentially dirty pages that is useful if 
one is not able to track dirty pages. Moreover, unmapped dirtied pages do 
not factor into that scheme probably because it was thought that they are
already sufficiently tracked by nr_dirty. However, having two methods
of accounting for dirty pages creates problems in correlating the number 
of dirty pages. This is unnecessarily complex.

In order to consistently reach the goal of of tracking dirty pages we 
have to deal with set_page_dirty(). In the first stage lets just
be satified with being able to throttle dirty pages by having an accurate
nr_dirty.

We can then avoid doing too many things on set_page_dirty so that we do 
not have to sleep or return an error.  Maybe add the support for errors 
(SIGBUS) later. But then we should consistently check everytime we dirty a 
page be it mapped or unmapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
