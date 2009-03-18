Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C6EC36B004D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 08:37:56 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: fput under mmap_sem
Date: Wed, 18 Mar 2009 23:37:48 +1100
References: <200903151459.01320.denys@visp.net.lb> <20090315221921.GY26138@disturbed> <20090318071313.GA30011@infradead.org>
In-Reply-To: <20090318071313.GA30011@infradead.org>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200903182337.48789.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 18 March 2009 18:13:13 Christoph Hellwig wrote:
> On Mon, Mar 16, 2009 at 09:19:21AM +1100, Dave Chinner wrote:
> > This is a VM problem where it calls fput() with the mmap_sem() held
> > in remove_vma(). It makes the incorrect assumption that filesystems
> > will never use the same lock in the IO path and the inode release path.
> >
> > This can deadlock if you are really unlucky.
>
> I really wonder why other filesystems haven't hit this yet.  Any chance
> we can get the fput moved out of mmap_sem to get rid of this class of
> problems?

Yes I don't think there is any reason against holding the file refcount
a little longer, but it can be pretty nasty to do in practice because
of deep call chains and sometimes multiple fputs within a given lock
section.

Possibly the easiest and quickest way will be to move aio's deferred
__fput into a usable API and try that. If there are any performance
problems, then we can try to move those fputs out from the mmap_sem
one at a time (eg. I don't expect fput for vma replacement/merging to
often cause the refcount to reach 0, and this is one of the harder
places; wheras fput for a simple munmap might be more often causing
refcount to reach 0 but it should be simpler to move out of mmap_sem
if it is a problem).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
