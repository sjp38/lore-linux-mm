Subject: Re: [PATCH] nfs: fix congestion control
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1169225506.5775.15.camel@lade.trondhjem.org>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	 <20070116135325.3441f62b.akpm@osdl.org> <1168985323.5975.53.camel@lappy>
	 <Pine.LNX.4.64.0701171158290.7397@schroedinger.engr.sgi.com>
	 <1169070763.5975.70.camel@lappy>
	 <1169070886.6523.8.camel@lade.trondhjem.org>
	 <1169126868.6197.55.camel@twins>
	 <1169135375.6105.15.camel@lade.trondhjem.org>
	 <1169199234.6197.129.camel@twins>  <1169212022.6197.148.camel@twins>
	 <1169225506.5775.15.camel@lade.trondhjem.org>
Content-Type: text/plain
Date: Fri, 19 Jan 2007 18:54:36 +0100
Message-Id: <1169229276.6197.150.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-01-19 at 11:51 -0500, Trond Myklebust wrote:

> > So with that out of the way I now have this
> 
> Looks much better. Just one obvious buglet...

> > @@ -1565,6 +1579,23 @@ int __init nfs_init_writepagecache(void)
> >  	if (nfs_commit_mempool == NULL)
> >  		return -ENOMEM;
> >  
> > +	/*
> > +	 * NFS congestion size, scale with available memory.
> > +	 *
> > +	 *  64MB:    8192k
> > +	 * 128MB:   11585k
> > +	 * 256MB:   16384k
> > +	 * 512MB:   23170k
> > +	 *   1GB:   32768k
> > +	 *   2GB:   46340k
> > +	 *   4GB:   65536k
> > +	 *   8GB:   92681k
> > +	 *  16GB:  131072k
> > +	 *
> > +	 * This allows larger machines to have larger/more transfers.
> > +	 */
> > +	nfs_congestion_size = 32*int_sqrt(totalram_pages);
> > +
>           ^^^^^^^^^^^^^^^^^^^ nfs_congestion_pages?

Ah, yeah, forgot to refresh the patch one last time before sending
out :-(.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
