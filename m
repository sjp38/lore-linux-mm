Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA56B6B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 13:01:06 -0400 (EDT)
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <E1LxMlO-0000sU-1J@pomaz-ex.szeredi.hu>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org>
	 <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu>
	 <1240519320.5602.9.camel@heimdal.trondhjem.org>
	 <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> <20090424104137.GA7601@sgi.com>
	 <E1LxMlO-0000sU-1J@pomaz-ex.szeredi.hu>
Content-Type: text/plain
Date: Fri, 24 Apr 2009 13:00:48 -0400
Message-Id: <1240592448.4946.35.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: holt@sgi.com, npiggin@suse.de, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-04-24 at 16:52 +0200, Miklos Szeredi wrote:
> On Fri, 24 Apr 2009, Robin Holt wrote:
> > I am not sure how you came to this conclusion.  The address_space has
> > the vma's chained together and protected by the i_mmap_lock.  That is
> > acquired prior to the cleaning operation.  Additionally, the cleaning
> > operation walks the process's page tables and will remove/write-protect
> > the page before releasing the i_mmap_lock.
> > 
> > Maybe I misunderstand.  I hope I have not added confusion.
> 
> Looking more closely, I think you're right.
> 
> I thought that detach_vmas_to_be_unmapped() also removed them from
> mapping->i_mmap, but that is not the case, it only removes them from
> the process's mm_struct.  The vma is only removed from ->i_mmap in
> unmap_region() _after_ zapping the pte's.
> 
> This means that while the pte zapping is going on, any page faults
> will fail but page_mkclean() (and all of rmap) will continue to work.
> 
> But then I don't see how we get a dirty pte without also first getting
> a page fault.  Weird...

You don't, but unless you unmap the page when you write it out, you will
not get any further page faults. The VM will just redirty the page
without calling page_mkwrite().

As I said, I think I can fix the NFS problem by simply unmapping the
page inside ->writepage() whenever we know the write request was
originally set up by a page fault.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
