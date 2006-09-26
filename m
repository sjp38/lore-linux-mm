Received: from midway.site ([71.117.233.155]) by xenotime.net for <linux-mm@kvack.org>; Tue, 26 Sep 2006 12:07:18 -0700
Date: Tue, 26 Sep 2006 12:08:34 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [RFC/PATCH mmap2: better determine overflow
Message-Id: <20060926120834.df719e85.rdunlap@xenotime.net>
In-Reply-To: <Pine.LNX.4.64.0609261902150.1641@blonde.wat.veritas.com>
References: <20060926103504.82bd9409.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0609261902150.1641@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Sep 2006 19:10:41 +0100 (BST) Hugh Dickins wrote:

> On Tue, 26 Sep 2006, Randy Dunlap wrote:
> > From: Randy Dunlap <rdunlap@xenotime.net>
> > 
> > mm/mmap.c::do_mmap_pgoff() checks for overflow like:
> > 
> > 	/* offset overflow? */
> > 	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
> >                return -EOVERFLOW;
> > 
> > However, using pgoff (page indexes) to determine address range
> > overflow doesn't overflow.  Change to use byte offsets instead,
> > so that overflow can actually happen and be noticed.
> 
> I think you're mistaken there.  Thinking in particular of 32-bit
> arches, isn't the check precisely about allowing an mmap at a high
> offset of a file >4GB in length; but not at so high an offset that
> pgoff (page index) wraps back to 0?  Whereas you're changing it
> now to fail at 4GB.

OK, I think I see.  I'll check/test/verify more.

> > Also return EOVERFLOW instead of ENOMEM when PAGE_ALIGN(len)
> > is 0.
> 
> Which standard mandates that change?

It was an interpretation.  Perhaps a mis-interpretation.
This comes after:

	if (!len)
		return -EINVAL;
...then

 	len = PAGE_ALIGN(len);
b:
-	if (!len || len > TASK_SIZE)
-		return -ENOMEM;
+	if (!len)
+		return -EOVERFLOW;

so if len is 0 at b:, then it was a very large unsigned long number
(larger than 0 - PAGE_SIZE, i.e., >= 0xfffff001 on 32-bit or
>= 0xffffffff_fffff001 on 64-bit), and PAGE_ALIGN() rounded it "up"
to 0.  That seems more like an overflow than a NOMEM to me.
That's all.


So, I'm interested in the EOVERFLOW case(s).
Would you attempt to translate this return value case for me?
(from http://www.opengroup.org/onlinepubs/009695399/functions/mmap.html:)

[EOVERFLOW]
    The file is a regular file and the value of off plus len exceeds the offset maximum established in the open file description associated with fildes.

I'm not concerned about the "off plus len" since I am looking at
mmap2() [using pgoff's instead].  I'm more concerned about the
"offset maximum established in the open file description associated
with fildes."

Does mmap2() on Linux use the actual filesize as a limit for the
mmap() area [not that I can see] or does it just use (effectively)
ULONG_MAX, without regard file actual filesize?

Thanks for looking/helping.

> Hugh
> 
> > 
> > Tested on i686 and x86_64.
> > 
> > Test program is at:  http://www.xenotime.net/linux/src/mmap-test.c
> > 
> > Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> > ---
> >  mm/mmap.c |    9 ++++++---
> >  1 file changed, 6 insertions(+), 3 deletions(-)
> > 
> > --- linux-2618-work.orig/mm/mmap.c
> > +++ linux-2618-work/mm/mmap.c
> > @@ -923,13 +923,16 @@ unsigned long do_mmap_pgoff(struct file 
> >  
> >  	/* Careful about overflows.. */
> >  	len = PAGE_ALIGN(len);
> > -	if (!len || len > TASK_SIZE)
> > -		return -ENOMEM;
> > +	if (!len)
> > +		return -EOVERFLOW;
> >  
> >  	/* offset overflow? */
> > -	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
> > +	if (((pgoff << PAGE_SHIFT) + len) < (pgoff << PAGE_SHIFT))
> >                 return -EOVERFLOW;
> >  
> > +	if (len > TASK_SIZE)
> > +		return -ENOMEM;
> > +
> >  	/* Too many mappings? */
> >  	if (mm->map_count > sysctl_max_map_count)
> >  		return -ENOMEM;
> > 
> > ---

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
