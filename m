Date: Fri, 25 Jul 2008 18:29:09 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080725232907.GA243187@sgi.com>
References: <20080724143949.GB12897@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080724143949.GB12897@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, andrea@qumranet.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> 
> I also think we should be cautious to make this slowpath so horribly
> slow. For KVM it's fine, but perhaps for GRU we'd actually want to
> register quite a lot of notifiers, unregister them, and perhaps even
> do per-vma registrations if we don't want to slow down other memory
> management operations too much (eg. if it is otherwise just some
> regular processes just doing accelerated things with GRU).

I can't speak for other possible users of the mmu notifier mechanism
but the GRU will only register a single notifier for a process.
The notifier is registered when the GRU is opened and (currently)
unregistered when the GRU is closed.

If a task opens multiple GRUs (quite possible for threaded apps), all
shared the same notifier. Regardless of the number of threads/opens,
there will be a single notifier. 


At least one version of mmu notifiers did not support unregistration.
The notifier was left in the chain until the task exited. This
also worked for the GRU. If the gru was subsequently reopened
the notifier was reused. Providing the ability to unregister is the
right thing to do if the cost is not excessive. From a practical
standpoint, for the GRU usage, unregistration is not a big issue
either way.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
