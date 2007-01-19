Subject: Re: [PATCH] nfs: fix congestion control
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1169229461.6197.154.camel@twins>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	 <20070116135325.3441f62b.akpm@osdl.org> <1168985323.5975.53.camel@lappy>
	 <Pine.LNX.4.64.0701171158290.7397@schroedinger.engr.sgi.com>
	 <1169070763.5975.70.camel@lappy>
	 <1169070886.6523.8.camel@lade.trondhjem.org>
	 <1169126868.6197.55.camel@twins>
	 <1169135375.6105.15.camel@lade.trondhjem.org>
	 <1169199234.6197.129.camel@twins> <1169212022.6197.148.camel@twins>
	 <Pine.LNX.4.64.0701190912540.14617@schroedinger.engr.sgi.com>
	 <1169229461.6197.154.camel@twins>
Content-Type: text/plain
Date: Fri, 19 Jan 2007 13:26:52 -0500
Message-Id: <1169231212.5775.29.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-01-19 at 18:57 +0100, Peter Zijlstra wrote:
> On Fri, 2007-01-19 at 09:20 -0800, Christoph Lameter wrote:
> > On Fri, 19 Jan 2007, Peter Zijlstra wrote:
> > 
> > > +	/*
> > > +	 * NFS congestion size, scale with available memory.
> > > +	 *
> > 
> > Well this all depends on the memory available to the running process.
> > If the process is just allowed to allocate from a subset of memory 
> > (cpusets) then this may need to be lower.
> > 
> > > +	 *  64MB:    8192k
> > > +	 * 128MB:   11585k
> > > +	 * 256MB:   16384k
> > > +	 * 512MB:   23170k
> > > +	 *   1GB:   32768k
> > > +	 *   2GB:   46340k
> > > +	 *   4GB:   65536k
> > > +	 *   8GB:   92681k
> > > +	 *  16GB:  131072k
> > 
> > Hmmm... lets say we have the worst case of an 8TB IA64 system with 1k 
> > nodes of 8G each.
> 
> Eeuh, right. Glad to have you around to remind how puny my boxens
> are :-)
> 
> >  On Ia64 the number of pages is 8TB/16KB pagesize = 512 
> > million pages. Thus nfs_congestion_size is 724064 pages which is 
> > 11.1Gbytes?
> > 
> > If we now restrict a cpuset to a single node then have a 
> > nfs_congestion_size of 11.1G vs an available memory on a node of 8G.
> 
> Right, perhaps cap this to a max of 256M. That would allow 128 2M RPC
> transfers, much more would not be needed I guess. Trond?

That would be good as a default, but I've been thinking that we could
perhaps also add a sysctl in /proc/sys/fs/nfs in order to make it a
tunable?

Cheers,
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
