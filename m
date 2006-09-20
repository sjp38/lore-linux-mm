Date: Tue, 19 Sep 2006 20:05:33 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
Message-Id: <20060919200533.2874ce36.akpm@osdl.org>
In-Reply-To: <1158717429.6002.231.camel@localhost.localdomain>
References: <1158274508.14473.88.camel@localhost.localdomain>
	<20060915001151.75f9a71b.akpm@osdl.org>
	<45107ECE.5040603@google.com>
	<1158709835.6002.203.camel@localhost.localdomain>
	<1158710712.6002.216.camel@localhost.localdomain>
	<20060919172105.bad4a89e.akpm@osdl.org>
	<1158717429.6002.231.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Mike Waychison <mikew@google.com>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2006 11:57:09 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> > You forget that the point of this optimisation is to undo mmap_sem while
> > waiting on the disk IO.  Once we've done that we cannot go looking at ptes
> > or vmas: another thread could have munapped the whole lot or anything. 
> > (And we always need to be afraid of use_mm()..)
> 
> Wait wait .. .we don't need to have the mmap sem to -look- at a PTE.

The pte resides in a pagetable page.  Once we've dropped mmap_sem, that
pagetable page might not be there any more: munmap() might have freed it. 
We have to retake mmap_sem, do a find_vma() and a new pagetable walk.

There are some optimisations we could make to avoid all of that in the
common case, but this is the conceptual behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
