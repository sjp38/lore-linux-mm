Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C51986B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 06:41:03 -0400 (EDT)
Date: Fri, 24 Apr 2009 05:41:37 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Message-ID: <20090424104137.GA7601@sgi.com>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org> <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: trond.myklebust@fys.uio.no, npiggin@suse.de, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 24, 2009 at 09:15:22AM +0200, Miklos Szeredi wrote:
> On Thu, 23 Apr 2009, Trond Myklebust wrote:
> > On Thu, 2009-04-23 at 21:52 +0200, Miklos Szeredi wrote:
> > > Now this is mostly done at page fault time, and the pte's are always
> > > being re-protected whenever the PG_dirty flag is cleared (see
> > > page_mkclean()).
> > > 
> > > But in some cases (shmfs being the example I know) pages are not write
> > > protected and so zap_pte_range(), and other functions, still need to
> > > transfer the pte dirtyness to the page flag.
> > 
> > My main worry is that this is all happening at munmap() time. There
> > shouldn't be any more page faults after that completes (am I right?), so
> > what other mechanism would transfer the pte dirtyness?
> 
> After munmap() a page fault will result in SIGSEGV.  A write access
> during munmap(), when the vma has been removed but the page table is
> still intact is more interesting.  But in that case the write fault
> should also result in a SEGV, because it won't be able to find the
> matching VMA.
> 
> Now lets see what happens if writeback is started against the page
> during this limbo period.  page_mkclean() is called, which doesn't
> find the vma, so it doesn't re-protect the pte.  But the PG_dirty will

I am not sure how you came to this conclusion.  The address_space has
the vma's chained together and protected by the i_mmap_lock.  That is
acquired prior to the cleaning operation.  Additionally, the cleaning
operation walks the process's page tables and will remove/write-protect
the page before releasing the i_mmap_lock.

Maybe I misunderstand.  I hope I have not added confusion.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
