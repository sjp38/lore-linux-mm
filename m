Message-Id: <200205040646.g446kZrO008548@smtpzilla5.xs4all.nl>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Erik van Konijnenburg <ekonijn@xs4all.nl>
Reply-To: ekonijn@xs4all.nl
Subject: Re: page-flags.h
Date: Sat, 4 May 2002 08:46:33 +0200
References: <20020501192737.R29327@suse.de> <3CD317DD.2C9FBD11@zip.com.au> <20020504013938.G30500@suse.de>
In-Reply-To: <20020504013938.G30500@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@suse.de>, Andrew Morton <akpm@zip.com.au>
Cc: Christoph Hellwig <hch@infradead.org>, kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

With pagemap.h being the worst of the lot.  Why is this?
In principle it's just some declarations for functions that take
structure pointers as arguments and interesting defines like

	#define page_cache_get(x)       get_page(x)

You don't need include files to compile that: the compiler is perfectly
capable of translating a structure pointer without knowing what's 
inside the structure.

What hurts are the static inline functions; these access structure
fields and do need the structure definitions, sucking in all those
includes.  For pagemap.h, just three functions are responsible for
an 82Kb callgraph: page_cache_alloc, add_to_page_cache, 
wait_on_page_locked.

So what we do is remove all includes and the three evil inline functions
from pagemap.h and put them in pagemap-bonus.h.  Include pagemap-bonus.h
only in the 10 or so files that use it.

Alternatively, put the meat of pagemap.h in a pagemap-diet.h, and leave
the includes and static inlines in pagemap.h; that would make for easier
transition to faster compile times.  I guess something similar can be done 
for the other big three.

The plan would be not to flatten the complete include graph,
but only to avoid the overhead of deeply nested include hierarchies
that are caused by static inline.

Regards,
Erik

On Saturday 04 May 2002 01:39 am, Dave Jones wrote:
> On Fri, May 03, 2002 at 04:06:05PM -0700, Andrew Morton wrote:
>  > Part of my uncertainty here is that we just don't seem to
>  > have a "plan".  Is the objective to completely flatten
>  > the include heirarchy, no nested includes, and make all
>  > .c files include all headers to which they (and their included
>  > headers) refer?
>  > 
>  > That's pretty aggressive, but I think it's the only sane
>  > objective.
> 
> <linux/fs.h>, <linux/mm.h>, <linux/sched.h>, <linux/pagemap.h>
> are usually the main culprits. Each of these suckers pulls in
> dozens and dozens of includes.

>     Dave.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
