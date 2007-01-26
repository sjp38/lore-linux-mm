Date: Thu, 25 Jan 2007 21:09:50 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] nfs: fix congestion control -v4
Message-Id: <20070125210950.bcdaa7f6.akpm@osdl.org>
In-Reply-To: <1169739148.6189.68.camel@twins>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	<20070116135325.3441f62b.akpm@osdl.org>
	<1168985323.5975.53.camel@lappy>
	<Pine.LNX.4.64.0701171158290.7397@schroedinger.engr.sgi.com>
	<1169070763.5975.70.camel@lappy>
	<1169070886.6523.8.camel@lade.trondhjem.org>
	<1169126868.6197.55.camel@twins>
	<1169135375.6105.15.camel@lade.trondhjem.org>
	<1169199234.6197.129.camel@twins>
	<1169212022.6197.148.camel@twins>
	<Pine.LNX.4.64.0701190912540.14617@schroedinger.engr.sgi.com>
	<1169229461.6197.154.camel@twins>
	<1169231212.5775.29.camel@lade.trondhjem.org>
	<1169276500.6197.159.camel@twins>
	<1169482343.6083.7.camel@lade.trondhjem.org>
	<1169739148.6189.68.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jan 2007 16:32:28 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Hopefully the last version ;-)
> 
> 
> ---
> Subject: nfs: fix congestion control
> 
> The current NFS client congestion logic is severly broken, it marks the backing
> device congested during each nfs_writepages() call but doesn't mirror this in
> nfs_writepage() which makes for deadlocks. Also it implements its own waitqueue.
> 
> Replace this by a more regular congestion implementation that puts a cap on the
> number of active writeback pages and uses the bdi congestion waitqueue.
> 
> Also always use an interruptible wait since it makes sense to be able to 
> SIGKILL the process even for mounts without 'intr'.
> 
> ..
>
> --- linux-2.6-git.orig/include/linux/nfs_fs_sb.h	2007-01-25 16:07:03.000000000 +0100
> +++ linux-2.6-git/include/linux/nfs_fs_sb.h	2007-01-25 16:07:12.000000000 +0100
> @@ -82,6 +82,7 @@ struct nfs_server {
>  	struct rpc_clnt *	client_acl;	/* ACL RPC client handle */
>  	struct nfs_iostats *	io_stats;	/* I/O statistics */
>  	struct backing_dev_info	backing_dev_info;
> +	atomic_t		writeback;	/* number of writeback pages */

We're going to get in trouble with this sort of thing within a few years. 
atomic_t is 32-bit.  Put 16TB of memory under writeback and blam.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
