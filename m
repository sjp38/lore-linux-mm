Date: Wed, 7 Nov 2007 10:28:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 04/23] dentries: Extract common code to remove dentry
 from lru
In-Reply-To: <20071107085027.GA6243@cataract>
Message-ID: <Pine.LNX.4.64.0711071024260.9857@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011227.298491275@sgi.com>
 <20071107085027.GA6243@cataract>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundatin.org
Cc: Johannes Weiner <hannes-kernel@saeurebad.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Nov 2007, Johannes Weiner wrote:

> Hi Christoph,
> 
> On Tue, Nov 06, 2007 at 05:11:34PM -0800, Christoph Lameter wrote:
> > @@ -613,11 +606,7 @@ static void shrink_dcache_for_umount_sub
> >  			spin_lock(&dcache_lock);
> >  			list_for_each_entry(loop, &dentry->d_subdirs,
> >  					    d_u.d_child) {
> > -				if (!list_empty(&loop->d_lru)) {
> > -					dentry_stat.nr_unused--;
> > -					list_del_init(&loop->d_lru);
> > -				}
> > -
> > +				dentry_lru_remove(dentry);
> 
> Shouldn't this be dentry_lru_remove(loop)?

Correct. Andrew: This needs to go into your tree to fix the patch that is 
already there:


[PATCH] dcache: use the correct variable.

We need to use "loop" instead of "dentry"

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/fs/dcache.c
===================================================================
--- linux-2.6.orig/fs/dcache.c	2007-11-07 10:26:20.000000000 -0800
+++ linux-2.6/fs/dcache.c	2007-11-07 10:26:27.000000000 -0800
@@ -610,7 +610,7 @@ static void shrink_dcache_for_umount_sub
 			spin_lock(&dcache_lock);
 			list_for_each_entry(loop, &dentry->d_subdirs,
 					    d_u.d_child) {
-				dentry_lru_remove(dentry);
+				dentry_lru_remove(loop);
 				__d_drop(loop);
 				cond_resched_lock(&dcache_lock);
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
