Subject: Re: tracking dirty pages patches
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0605232131560.19019@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0605230917390.9731@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0605231937410.14985@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0605231223360.10836@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0605232131560.19019@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Wed, 24 May 2006 04:25:14 +0200
Message-Id: <1148437514.3049.18.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, Rohit Seth <rohitseth@google.com>, David Howells <dhowells@redhat.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-05-23 at 21:34 +0100, Hugh Dickins wrote:
> > 
> > Page migration currently also assumes that VM_LOCKED means do not move the 
> > page. At some point we may want to have a separate flag that guarantees
> > that a page should not be moved. This would enable the moving of VM_LOCKED 
> > pages.
> 
> Oh yes, I'd noticed that subject going by, and meant to speak up
> sometime.  I feel pretty strongly, and have so declared in the past,
> that VM_LOCKED should _not_ guarantee that the same physical page is
> used forever: get_user_pages is what's used to pin a physical page
> for that effect.  I remember Arjan sharing this opinion.

correct. 


> You mentioned in one of the mails that went past that you'd seen
> drivers enforcing VM_LOCKED in vm_flags: aren't those just drivers
> copying other drivers which did so, but achieving nothing thereby,
> to be cleaned up in due course?  (The pages aren't even on LRU.)


I would like to know which, because in general this is a security hole:
Any driver that depends on locked meaning "doesn't move" can be fooled
by the user into becoming unlocked... (by virtue of having another
thread do an munlock on the memory). As such no kernel driver should 
depend on this, and as far as I know, no kernel driver actually does.
(early infiniband drivers used to, but they fixed that well before
things got merged to use the get_user_pages API, exactly for this
reason)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
