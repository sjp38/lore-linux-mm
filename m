Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DC1A16B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 01:13:44 -0500 (EST)
Date: Fri, 16 Jan 2009 07:13:41 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] Remove needless flush_dcache_page call
Message-ID: <20090116061341.GB22810@wotan.suse.de>
References: <20090116052804.GA18737@barrios-desktop> <20090116053338.GC31013@parisc-linux.org> <20090116055119.GA6515@barrios-desktop> <20090116055729.GF31013@parisc-linux.org> <20090116060830.GB6515@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090116060830.GB6515@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 16, 2009 at 03:08:30PM +0900, MinChan Kim wrote:
> On Thu, Jan 15, 2009 at 10:57:30PM -0700, Matthew Wilcox wrote:
> > Most I/O devices will do DMA to the page in question and thus the kernel
> > hasn't written to it and the CPU won't have the data in cache.  For the
> > few devices which can't do DMA, it's the responsibility of the device
> > driver to call flush_dcache_page() (or some other flushing primitive).
> 
> Hmm.. Now I am confusing. 
> If devicer driver or with DMA makes sure cache consistency,
> Why filesystem code have to handle it ?

Because the filesystem is accessing the page directly rathe rthan going to
IO.

Basically, whoever reads or writes the page is responsible to avoid user
aliases. You see these calls in the VM for anonymous pages, in bounce
buffer layers, in filesystems that read or write from pages that are
exposed to userspace (ie. metadata generally need not be flushed because
it will not be mmapped by userspace).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
