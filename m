Message-ID: <3CD317DD.2C9FBD11@zip.com.au>
Date: Fri, 03 May 2002 16:06:05 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: page-flags.h
References: <20020501192737.R29327@suse.de> <20020501200452.S29327@suse.de> <3CD1FB78.B3314F4B@zip.com.au> <200205032241.g43MfC39082721@smtpzilla1.xs4all.nl>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ekonijn@xs4all.nl
Cc: Christoph Hellwig <hch@infradead.org>, Dave Jones <davej@suse.de>, kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Erik van Konijnenburg wrote:
> 
> Hi Andrew,
> 
> Do you really have to edit 119 files if you just want to avoid
> processing the PageFoo macros?  Include page-flags.h in pagemap.h,
> and you only have to add include lines to 13 files to get the kernel
> compiled, while still getting rid of 1050 times reading of page-flags.h.
> 
> Motivation:
>     --  linux/mm.h is included in 1163 files
>     --  linux/pagemap.h is included in only 109 files.
>     --  In pagemap.h, wait_on_page_locked() and PageLocked()
>         are mixed rather awkwardly.  Moving wait_on_page_locked()
>         to page-flags.h as you suggested doesn't really help:
>         you'd have to move the ___wait_on_page_locked declaration
>         as well, resulting in other ugliness, so we might as well
>         include page-flags.h.
>     --  most of the added includes are for page-flags.h, so it makes
>         sense not to merge page-flags.h and pagemap.h.
>     --  yes, the number 1050 is wrong, since pagemap.h is also
>         included indirectly.  I'm not sufficiently familiar with
>         the kernel to make a better estimate, so this whole
>         thing may be a red herring.
> 

I guess so.  Certainly, not having to alter that many files
is a bonus.

Part of my uncertainty here is that we just don't seem to
have a "plan".  Is the objective to completely flatten
the include heirarchy, no nested includes, and make all
.c files include all headers to which they (and their included
headers) refer?

That's pretty aggressive, but I think it's the only sane
objective.

BTW,


akpm-1:/usr/src/25> grep pagemap.h include/linux/*.h
include/linux/blkdev.h:#include <linux/pagemap.h>
include/linux/locks.h:#include <linux/pagemap.h>
include/linux/nfs_fs.h:#include <linux/pagemap.h>
include/linux/smb_fs.h:#include <linux/pagemap.h>

These need to be pulled out first.  locks.h and blkdev.h
really don't need the include at all.  page.h
would suffice.

And locks.h can just be deleted from the kernel.  Move
its two definitions into fs.h.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
