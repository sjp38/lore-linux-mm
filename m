Date: Thu, 29 Jun 2006 23:08:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: ZVC/zone_reclaim: Leave 1% of unmapped pagecache pages for file
 I/O
In-Reply-To: <20060629200743.04e49eb9.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0606292254400.31045@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0606291949320.30754@schroedinger.engr.sgi.com>
 <20060629200743.04e49eb9.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: schamp@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jun 2006, Andrew Morton wrote:

> On Thu, 29 Jun 2006 19:51:38 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > It turns out that it is advantageous to leave a small portion of
> > unmapped file backed pages if a zone is overallocated.
> >
> > This allows recently used file I/O buffers to stay on the node and
> > reduces the times that zone reclaim is invoked if file I/O occurs
> > when we run out of memory in a zone.
> 
> I don't really understand this.  Can you expand? ie:
> 
> define "overallocated".

All pages (or almost all pages) in the zone are allocated and so the page 
allocator has to go off node.

> "turns out" how?  What problems were observed, and was was the behaviour
> after the patch?

The problem is that zone reclaim runs too frequently when the page cache 
is used for file I/O (read write and therefore unmapped pages!) alone and 
we have almost all pages of the zone allocated. Zone reclaim may remove 32 
unmapped pages. File I/O will use these pages for the next read/write 
requests and the unmapped pages increase. After the zone has filled up 
again zone reclaim will remove it again after only 32 pages. This cycle is 
too inefficient and there are potentially too many zone reclaim cycles.

With the 1% boundary we may still remove all unmapped pages for file 
I/O in zone reclaim pass. However. it will take a large number of read 
and writes to get back to 1% again where we trigger zone reclaim 
again.

The zone reclaim 2.6.16/17 does not show this behavior because
we have a 30 second timeout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
