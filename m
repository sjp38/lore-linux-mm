Received: from midway.site ([71.117.233.155]) by xenotime.net for <linux-mm@kvack.org>; Tue, 26 Sep 2006 15:17:21 -0700
Date: Tue, 26 Sep 2006 15:18:37 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [RFC/PATCH mmap2: better determine overflow
Message-Id: <20060926151837.3d2a643f.rdunlap@xenotime.net>
In-Reply-To: <Pine.LNX.4.64.0609262124270.7644@blonde.wat.veritas.com>
References: <20060926103504.82bd9409.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0609261902150.1641@blonde.wat.veritas.com>
	<20060926120834.df719e85.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0609262124270.7644@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Sep 2006 21:44:09 +0100 (BST) Hugh Dickins wrote:

> On Tue, 26 Sep 2006, Randy Dunlap wrote:
> > 
> > It was an interpretation.  Perhaps a mis-interpretation.
> > This comes after:
> > 
> > 	if (!len)
> > 		return -EINVAL;
> > ...then
> > 
> >  	len = PAGE_ALIGN(len);
> > b:
> > -	if (!len || len > TASK_SIZE)
> > -		return -ENOMEM;
> > +	if (!len)
> > +		return -EOVERFLOW;
> > 
> > so if len is 0 at b:, then it was a very large unsigned long number
> > (larger than 0 - PAGE_SIZE, i.e., >= 0xfffff001 on 32-bit or
> > >= 0xffffffff_fffff001 on 64-bit), and PAGE_ALIGN() rounded it "up"
> > to 0.  That seems more like an overflow than a NOMEM to me.
> > That's all.
> 
> I agree that len 0 at that point arises from an extremely big len
> specified by the user: it's just another case of len > TASK_SIZE
> that the preceding PAGE_ALIGN has now disguised as len 0.  And
> the errno for "there is insufficient room in the address space
> to effect the mapping" is said to be ENOMEM.  That should stay.

I see.

> > So, I'm interested in the EOVERFLOW case(s).
> > Would you attempt to translate this return value case for me?
> > (from http://www.opengroup.org/onlinepubs/009695399/functions/mmap.html:)
> > 
> > [EOVERFLOW]
> >     The file is a regular file and the value of off plus len exceeds the offset maximum established in the open file description associated with fildes.
> > 
> > I'm not concerned about the "off plus len" since I am looking at
> > mmap2() [using pgoff's instead].  I'm more concerned about the
> > "offset maximum established in the open file description associated
> > with fildes."
> 
> I suspect it means that on a 32-bit system, if the file was not opened
> with O_LARGEFILE, off-plus-len needs to stay within 2GB.  Whereas on a
> 64-bit system, or when opened with O_LARGEFILE, off-plus-len needs to
> stay within the max the filesystem and VFS can support.  We're enforcing
> the latter, without regard to whether or not it was opened with
> O_LARGEFILE.  Change that?  I doubt it's worth the possibility
> of now breaking userspace.

Agreed.

> > Does mmap2() on Linux use the actual filesize as a limit for the
> > mmap() area [not that I can see]
> 
> That's right, it does not (and would be wrong to do so:
> the file can be extended or truncated while it's mapped).
> 
> > or does it just use (effectively)
> > ULONG_MAX, without regard file actual filesize?
> 
> I'd say that limit is TASK_SIZE rather than ULONG_MAX.

Right.

Thanks for all of your helpful comments.

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
