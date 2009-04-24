Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E90866B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 12:18:10 -0400 (EDT)
Date: Fri, 24 Apr 2009 17:18:19 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Message-ID: <20090424161819.GD11199@shareable.org>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org> <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> <E1LxFuD-0008M9-1a@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1LxFuD-0008M9-1a@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: trond.myklebust@fys.uio.no, npiggin@suse.de, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi wrote:
> On Fri, 24 Apr 2009, Miklos Szeredi wrote:
> > Hmm, I guess this is a bit nasty: the VM promises filesystems that
> > ->page_mkwrite() will be called when the page is dirtied through a
> > mapping, _almost_ all of the time.  Except when munmap happens to race
> > with clear_page_dirty_for_io().
> > 
> > I don't have any ideas how this could be fixed, CC-ing linux-mm...
> 
> On second thought, we could possibly just ignore the dirty bit in that
> case.  Trying to write to a mapping _during_ munmap() will have pretty
> undefined results, I don't think any sane application out there should
> rely on the results of this.
> 
> But how knows, the world is a weird place...

I think it's a sane but unusual thing to do.

App has a thread writing to random places in a mapped file, and
another calling munmap() or mprotect() to trap writes to some parts of
the file in order to track what parts the first thread is dirtying.
Second thread's SIGSEGV handler reinstates those mappings.  First
thread doesn't know about any of this, it just writes and the only
side effect is timing.  Or should be.

Think garbage collection, change tracking, tracing, and debugging.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
