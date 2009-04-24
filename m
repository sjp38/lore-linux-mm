Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B5ADD6B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 10:51:51 -0400 (EDT)
In-reply-to: <20090424104137.GA7601@sgi.com> (message from Robin Holt on Fri,
	24 Apr 2009 05:41:37 -0500)
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
References: <1240510668.11148.40.camel@heimdal.trondhjem.org> <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> <20090424104137.GA7601@sgi.com>
Message-Id: <E1LxMlO-0000sU-1J@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 24 Apr 2009 16:52:26 +0200
Sender: owner-linux-mm@kvack.org
To: holt@sgi.com
Cc: miklos@szeredi.hu, trond.myklebust@fys.uio.no, npiggin@suse.de, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Apr 2009, Robin Holt wrote:
> I am not sure how you came to this conclusion.  The address_space has
> the vma's chained together and protected by the i_mmap_lock.  That is
> acquired prior to the cleaning operation.  Additionally, the cleaning
> operation walks the process's page tables and will remove/write-protect
> the page before releasing the i_mmap_lock.
> 
> Maybe I misunderstand.  I hope I have not added confusion.

Looking more closely, I think you're right.

I thought that detach_vmas_to_be_unmapped() also removed them from
mapping->i_mmap, but that is not the case, it only removes them from
the process's mm_struct.  The vma is only removed from ->i_mmap in
unmap_region() _after_ zapping the pte's.

This means that while the pte zapping is going on, any page faults
will fail but page_mkclean() (and all of rmap) will continue to work.

But then I don't see how we get a dirty pte without also first getting
a page fault.  Weird...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
