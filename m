Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7U2FDQc020578
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 22:15:13 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7U2FCWS458616
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 20:15:12 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7U2FC5d006300
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 20:15:12 -0600
Subject: Re: [RFC:PATCH 00/07] VM File Tails
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <20070829233802.GC29635@lazybastard.org>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
	 <20070829213154.GB29635@lazybastard.org>
	 <1188423942.6529.74.camel@norville.austin.ibm.com>
	 <20070829233802.GC29635@lazybastard.org>
Content-Type: text/plain; charset=ISO-8859-1
Date: Wed, 29 Aug 2007 21:15:11 -0500
Message-Id: <1188440111.9221.3.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-30 at 01:38 +0200, Jorn Engel wrote:
> On Wed, 29 August 2007 21:45:42 +0000, Dave Kleikamp wrote:
> > On Wed, 2007-08-29 at 23:31 +0200, Jorn Engel wrote:
> > > On Wed, 29 August 2007 16:53:25 -0400, Dave Kleikamp wrote:
> > > >
> > > > - benchmark!
> > > 
> > > I'd love to know how much difference this makes.  Basically four
> > > numbers:
> > > - number of address spaces
> > > - bytes allocated for file tails
> > > - number of pages allocated for non-tail storage
> > > - number of pages allocated for tail storage
> > 
> > The last one may be tricky, since I'm allocating the tails using
> > kmalloc.  The data will be interspersed with other kmalloc'ed data.  We
> > could keep track of the bytes, and the number of tails, but we wouldn't
> > know exactly how the tail bytes correspond to the number of pages needed
> > to store them.
> 
> Sorry, I should have been more precise.  Under some circumstances like
> mmap() you have to allocate a page and copy the tail to that page.  My
> last point was about the number of such pages, not the number of pages
> buried in slab caches.
> 
> Iiuc your current implementation would keep the kmalloc()-allocated tail
> in the address space and _additionally_ have a full page for the same
> data.  So the patches aimed to save memory may actually waste memory and
> depending on circumstances may waste more than they save.  Or did I
> misinterpret something?

Once the data is packed into the tail, the page is freed.  Later if the
page is needed, a new page is allocated and the tail is unpacked into
it.  Then the tail is freed (via kfree).
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
