Subject: Re: RFC: Remove swap file support
References: <3B472C06.78A9530C@mandrakesoft.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 14 Jul 2001 00:07:38 -0600
In-Reply-To: <3B472C06.78A9530C@mandrakesoft.com>
Message-ID: <m1elrk3uxh.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, viro@math.psu.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeff Garzik <jgarzik@mandrakesoft.com> writes:

> Since you can make any file into a block device using loop,
> is there any value to supporting swap files in 2.5?
> 
> swap files seem like a special case that is no longer necessary...

Yes, and no.  I'd say what we need to do is update rw_swap_page to
use the address space functions directly.  With block devices and
files going through the page cache in 2.5 that should remove any
special cases cleanly.

In 2.4 the swap code really hasn't been updated, the old code has only
been patched enough to work on 2.4.  This adds layers of work that we
really don't need to be doing.  Removing the extra redirection has the
potential to give a small performance boost to swapping.

The case to watch out for are deadlocks doing things like using
swapfiles on an NFS mount.  As you point out we can already do this
with the loop back devices so it isn't really a special case.  The
only new case I can see working are swapfiles with holes in them, or
swapfiles that do automatic compression.  I doubt those cases are
significant improvements but it looks like they will fall out
naturally. 

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
