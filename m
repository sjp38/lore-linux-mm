Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id MAA00242
	for <linux-mm@kvack.org>; Tue, 22 Oct 2002 12:23:43 -0700 (PDT)
Message-ID: <3DB5A5BD.D3E00B4A@digeo.com>
Date: Tue, 22 Oct 2002 12:23:41 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
References: <Pine.LNX.4.44.0210221936010.18790-100000@localhost.localdomain> <20021022184938.A2395@infradead.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> 
> On Tue, Oct 22, 2002 at 07:57:00PM +0200, Ingo Molnar wrote:
> > the attached patch (ontop of 2.5.44-mm2) implements generic (swappable!)
> > nonlinear mappings and sys_remap_file_pages() support. Ie. no more
> > MAP_LOCKED restrictions and strange pagefault semantics.
> >
> > to implement this i added a new pte concept: "file pte's". This means that
> > upon swapout, shared-named mappings do not get cleared but get converted
> > into file pte's, which can then be decoded by the pagefault path and can
> > be looked up in the pagecache.
> >
> > the normal linear pagefault path from now on does not assume linearity and
> > decodes the offset in the pte. This also tests pte encoding/decoding in
> > the pagecache case, and the ->populate functions.
> 
> Ingo,
> 
> what is the reason for that interface?  It looks like a gross performance
> hack for misdesigned applications to me, kindof windowsish..
> 

So that evicted pages in non-linear mappings can be reestablished
at fault time by the kernel, rather than by delegation to userspace
via SIGBUS.


We seem to have lost a pte_page_unlock() from fremap.c:zap_pte()?
I fixed up the ifdef tangle in there within the shpte-ng patch
and then put the pte_page_unlock() back.

I also added a page_cache_release() to the error path in filemap_populate(),
if install_page() failed.

The 2TB file size limit for mmap on non-PAE is a little worrisome.
I wonder if we can only instantiate the pte_file() bit if the
mapping is using MAP_POPULATE?  Seems hard to do.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
