From: David Howells <dhowells@redhat.com>
In-Reply-To: <65dd6fd50610101705t3db93a72sc0847cd120aa05d3@mail.gmail.com> 
References: <65dd6fd50610101705t3db93a72sc0847cd120aa05d3@mail.gmail.com> 
Subject: Re: Removing MAX_ARG_PAGES (request for comments/assistance) 
Date: Tue, 02 Jan 2007 17:52:14 +0000
Message-ID: <22336.1167760334@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, Linus Torvalds <torvalds@osdl.org>, Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@muc.de>, linux-arch@vger.kernel.org, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

Ollie Wild <aaw@google.com> wrote:

> - I haven't tested this on a NOMMU architecture.  Could someone please
> validate this?

There are a number of potential problems with NOMMU:

 (1) The argument data is copied twice (once into kernel memory and once out
     of kernel memory).

 (2) The permitted amount of argument data is governed by the stack size of
     the program to be exec'd.  You should assume that NOMMU stacks cannot
     grow.

 (3) VMAs on NOMMU are a shared resource.

However, we might be able to extend your idea to improve things.  If we work
out the stack size required earlier, we can allocate the VMA and the memory
for the stack *before* we reach the point of no return.  We can then fill in
the stack and load up all the parameters *before* releasing the original
executable.  That would eliminate one of the copied mentioned in (1).  Working
out the stack size earlier may be difficult though, as we may need to load the
interpreter header before we can do so.

Overall, I don't think there should be too many problems with this for NOMMU.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
