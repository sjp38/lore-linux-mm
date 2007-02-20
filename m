Subject: Re: [PATCH] nfs: fix congestion control -v4
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070126005117.5e376c16.akpm@osdl.org>
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
	 <1169231212.5775.29.camel@lade.trondhjem.org>
	 <1169276500.6197.159.camel@twins>
	 <1169482343.6083.7.camel@lade.trondhjem.org>
	 <1169739148.6189.68.camel@twins> <20070125210950.bcdaa7f6.akpm@osdl.org>
	 <Pine.LNX.4.64.0701252130500.7147@schroedinger.engr.sgi.com>
	 <20070125220457.a761ae6a.akpm@osdl.org> <1169798617.6189.83.camel@twins>
	 <20070126005117.5e376c16.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 20 Feb 2007 13:59:59 +0100
Message-Id: <1171976399.23046.3.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-01-26 at 00:51 -0800, Andrew Morton wrote:
> On Fri, 26 Jan 2007 09:03:37 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > On Thu, 2007-01-25 at 22:04 -0800, Andrew Morton wrote:
> > > On Thu, 25 Jan 2007 21:31:43 -0800 (PST)
> > > Christoph Lameter <clameter@sgi.com> wrote:
> > > 
> > > > On Thu, 25 Jan 2007, Andrew Morton wrote:
> > > > 
> > > > > atomic_t is 32-bit.  Put 16TB of memory under writeback and blam.
> > > > 
> > > > We have systems with 8TB main memory and are able to get to 16TB.
> > > 
> > > But I bet you don't use 4k pages on 'em ;)
> > > 
> > > > Better change it now.
> > > 
> > > yup.
> > 
> > I can change to atomic_long_t but that would make this patch depend on
> > Mathieu Desnoyers' atomic.h patch series.

    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

> > Do I send out a -v5 with this, or should I send an incremental patch
> > once that hits your tree?
> 
> A patch against next -mm would suit, thanks.


As promised change the atomic_t in struct nfs_server to atomic_long_t in
anticipation of machines that can handle 8+TB of (4K) pages under writeback.

However I suspect other things in NFS will start going *bang* by then.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/nfs/write.c            |    4 ++--
 include/linux/nfs_fs_sb.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -224,7 +224,7 @@ static void nfs_set_page_writeback(struc
 		struct inode *inode = page->mapping->host;
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
-		if (atomic_inc_return(&nfss->writeback) >
+		if (atomic_long_inc_return(&nfss->writeback) >
 				NFS_CONGESTION_ON_THRESH)
 			set_bdi_congested(&nfss->backing_dev_info, WRITE);
 	}
@@ -236,7 +236,7 @@ static void nfs_end_page_writeback(struc
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
-	if (atomic_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH) {
+	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH) {
 		clear_bdi_congested(&nfss->backing_dev_info, WRITE);
 		congestion_end(WRITE);
 	}
Index: linux-2.6/include/linux/nfs_fs_sb.h
===================================================================
--- linux-2.6.orig/include/linux/nfs_fs_sb.h
+++ linux-2.6/include/linux/nfs_fs_sb.h
@@ -82,7 +82,7 @@ struct nfs_server {
 	struct rpc_clnt *	client_acl;	/* ACL RPC client handle */
 	struct nfs_iostats *	io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
-	atomic_t		writeback;	/* number of writeback pages */
+	atomic_long_t		writeback;	/* number of writeback pages */
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
