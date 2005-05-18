Date: 18 May 2005 03:26:27 +0200
Date: Wed, 18 May 2005 03:26:27 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: manual page migration and madvise/mbind
Message-ID: <20050518012627.GA33395@muc.de>
References: <428A1F6F.2020109@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <428A1F6F.2020109@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Christoph Hellwig <hch@engr.sgi.com>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Sorry for late answer.

On Tue, May 17, 2005 at 11:44:31AM -0500, Ray Bryant wrote:
> (Remember that the migrate_pages() system call takes a pid, a count,
> and a list of old and new node so that this process is allowed to
> migrate that process over there, which is what the batch manager needs
> to do.  Running madvise() in the current process's address space doesn't
> help much unless it marks something deeper in the address space hierarchy
> than a vma.)
> 
> This is something quite a bit different than what madvise() or mbind()
> do today.  (They just manipulate vma's AFAIK.)

Nah, mbind manipulates backing objects too, in particular for shared 
memory. It is not right now implemented for files, but that was planned
and Steve L's patches went into that direction with some limitations.

And yes, the state would need to be stored in the address_space, which
is shared.  In my version it was in private backing store objects.
Check Steve's patch.

The main problem I see with the "hack ld.so" approach is that it 
doesn't work for non program files. So if you really want to handle
them you would need a daemon that sets the policies once a file 
is mapped or hack all the programs to set the policies. I don't
see that as being practicable. Ok you could always add a "sticky" process
policy that actually allocates mempolicies for newly read files
and so marks them using your new flags. But that would seem
somewhat ugly to me and is probably incompatible with your batch manager
anyways.  The only sane way to handle arbitary files like this
would be the xattr.

If you ignore data files then it would be ok to keep it to 
ELF loaders and ld.so I guess.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
