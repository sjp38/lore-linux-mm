Date: Wed, 19 Oct 2005 16:47:32 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
Message-ID: <20051019204732.GA9922@localhost.localdomain>
References: <1129570219.23632.34.camel@localhost.localdomain> <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com> <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com> <1129651502.23632.63.camel@localhost.localdomain> <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com> <1129747855.8716.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1129747855.8716.12.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Chris Wright <chrisw@osdl.org>, linux-mm <linux-mm@kvack.org>, dvhltc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 19, 2005 at 11:50:55AM -0700, Badari Pulavarty wrote:
> Darren Hart is working on patch to add madvise(DISCARD) to extend
> the functionality of madvise(DONTNEED) to really drop those pages.
> I was going to ask your opinion on that approach :) 
> 
> shmget(SHM_NORESERVE) + madvise(DISCARD) should do what I was
> hoping for. (BTW, none of this has been tested with database stuff -
> I am just concentrating on reasonable extensions.

madvise(DISCARD) has a promising name, but the implementation seems to be
very differant from what the name says.

This would seem to throw out all pages in the file after offset, which
makes the end parameter kind of pointless:

+               down(i_sem);
+               truncate_inode_pages(vma->vm_file->f_mapping, offset);
+               up(i_sem);

It will also fully truncate files which you have only partially
mapped, which is somewhat counterintuitive.

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
