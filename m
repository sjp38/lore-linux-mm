Received: from westrelay05.boulder.ibm.com (westrelay05.boulder.ibm.com [9.17.193.33])
	by e34.co.us.ibm.com (8.12.2/8.12.2) with ESMTP id g9UAGbhY018074
	for <linux-mm@kvack.org>; Wed, 30 Oct 2002 05:16:38 -0500
Received: from maze.in.ibm.com (maze.in.ibm.com [9.182.12.243])
	by westrelay05.boulder.ibm.com (8.12.3/NCO/VER6.4) with ESMTP id g9UAHAMY047042
	for <linux-mm@kvack.org>; Wed, 30 Oct 2002 03:17:11 -0700
Received: (from maneesh@localhost)
	by maze.in.ibm.com (8.11.6/8.11.2) id g9UASEA06656
	for linux-mm@kvack.org; Wed, 30 Oct 2002 15:58:14 +0530
Resent-Message-Id: <200210301028.g9UASEA06656@maze.in.ibm.com>
Date: Wed, 30 Oct 2002 15:18:46 +0530
From: Maneesh Soni <maneesh@in.ibm.com>
Subject: [FIX] Re: 2.5.42-mm2 hangs system
Message-ID: <20021030151846.D2613@in.ibm.com>
Reply-To: maneesh@in.ibm.com
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk> <20021016183907.B29405@in.ibm.com> <20021016154943.GA13695@hswn.dk> <20021016185908.GA863@hswn.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20021016185908.GA863@hswn.dk>; from henrik@hswn.dk on Wed, Oct 16, 2002 at 07:03:14PM +0000
Resent-To: linux-mm@kvack.org
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?Henrik_St=F8rner?= <henrik@hswn.dk>
List-ID: <linux-mm.kvack.org>

Hello Henrik,

I hope the following patch should solve your problem. The patch is made
over 2.5.44-mm6 kernel. The problem was due to anonymous dentries getting
connected with DCACHE_UNHASHED flag set.


diff -urN linux-2.5.44-mm6/fs/dcache.c linux-2.5.44-mm6-fix/fs/dcache.c
--- linux-2.5.44-mm6/fs/dcache.c	Wed Oct 30 14:42:33 2002
+++ linux-2.5.44-mm6-fix/fs/dcache.c	Wed Oct 30 13:13:43 2002
@@ -788,12 +788,15 @@
 		res = tmp;
 		tmp = NULL;
 		if (res) {
+			spin_lock(&res->d_lock);
 			res->d_sb = inode->i_sb;
 			res->d_parent = res;
 			res->d_inode = inode;
 			res->d_flags |= DCACHE_DISCONNECTED;
+			res->d_vfs_flags &= ~DCACHE_UNHASHED;
 			list_add(&res->d_alias, &inode->i_dentry);
 			list_add(&res->d_hash, &inode->i_sb->s_anon);
+			spin_unlock(&res->d_lock);
 		}
 		inode = NULL; /* don't drop reference */
 	}


Regards,
Maneesh


On Wed, Oct 16, 2002 at 07:03:14PM +0000, Henrik Storner wrote:
> Hi Maneesh,
> 
> On Wed, Oct 16, 2002 at 05:49:43PM +0200, Henrik Storner wrote:
> > On Wed, Oct 16, 2002 at 06:39:07PM +0530, Maneesh Soni wrote:
> > > As the hang looks like a loop in d_lookup can you  try
> > > recreating it *without* dcache_rcu.patch. You can backout this patch
> > > 
> > > http://www.zipworld.com.au/~akpm/linux/patches/2.5/2.5.42/2.5.42-mm2/broken-out/dcache_rcu.patch
> > > 
> > I've got some time tonight, so I will try un-doing the patch you
> > mention and see if that changes anything.
> 
> well you hit the nail right on the head there.
> 
> I've just been running the 2.5.42-mm2 kernel except for the dcache_rcu
> patch for a full hour, and I was unable to reproduce the hangs that I
> saw with the full -mm2 patch installed. Did two full kernel builds
> while reading some mail and doing other stuff - no problems what so
> ever.
> 
> Just to be sure, I re-applied the dcache_rcu patch, rebuilt the
> kernel, booted with the kernel containing dcache_rcu patch,
> and the system died within a few minutes.
> 
> So it is definitely something in the dcache_rcu patch that does it.
> 
> -- 
> Henrik Storner <henrik@hswn.dk> 

-- 
Maneesh Soni
IBM Linux Technology Center, 
IBM India Software Lab, Bangalore.
Phone: +91-80-5044999 email: maneesh@in.ibm.com
http://lse.sourceforge.net/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
