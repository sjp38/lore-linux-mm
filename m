Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57GMEOV009684
	for <linux-mm@kvack.org>; Thu, 7 Jun 2007 12:22:14 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57GM8lf269692
	for <linux-mm@kvack.org>; Thu, 7 Jun 2007 10:22:13 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57GM7ZA013560
	for <linux-mm@kvack.org>; Thu, 7 Jun 2007 10:22:08 -0600
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	 <20070606204432.b670a7b1.akpm@linux-foundation.org>
	 <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 07 Jun 2007 09:23:12 -0700
Message-Id: <1181233393.9995.14.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Albert Cahalan <acahalan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, ebiederm@xmission.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-07 at 00:53 -0400, Albert Cahalan wrote:
> On 6/6/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Wed, 6 Jun 2007 23:27:01 -0400 "Albert Cahalan" <acahalan@gmail.com> wrote:
> > > Eric W. Biederman writes:
> > > > Badari Pulavarty <pbadari@us.ibm.com> writes:
> > >
> > > >> Your recent cleanup to shm code, namely
> > > >>
> > > >> [PATCH] shm: make sysv ipc shared memory use stacked files
> > > >>
> > > >> took away one of the debugging feature for shm segments.
> > > >> Originally, shmid were forced to be the inode numbers and
> > > >> they show up in /proc/pid/maps for the process which mapped
> > > >> this shared memory segments (vma listing). That way, its easy
> > > >> to find out who all mapped this shared memory segment. Your
> > > >> patchset, took away the inode# setting. So, we can't easily
> > > >> match the shmem segments to /proc/pid/maps easily. (It was
> > > >> really useful in tracking down a customer problem recently).
> > > >> Is this done deliberately ? Anything wrong in setting this back ?
> > > >
> > > > Theoretically it makes the stacked file concept more brittle,
> > > > because it means the lower layers can't care about their inode
> > > > number.
> > > >
> > > > We do need something to tie these things together.
> > > >
> > > > So I suspect what makes most sense is to simply rename the
> > > > dentry SYSVID<segmentid>
> > >
> > > Please stop breaking things in /proc. The pmap command relys
> > > on the old behavior.
> >
> > What effect did this change have upon the pmap command?  Details, please.
> >
> > > It's time to revert.
> >
> > Probably true, but we'd need to understand what the impact was.
> 
> Very simply, pmap reports the shmid.
> 
> albert 0 ~$ pmap `pidof X` | egrep -2 shmid
> 30050000  16384K rw-s-  /dev/fb0
> 31050000    152K rw---    [ anon ]
> 31076000    384K rw-s-    [ shmid=0x3f428000 ]
> 310d6000    384K rw-s-    [ shmid=0x3f430001 ]
> 31136000    384K rw-s-    [ shmid=0x3f438002 ]
> 31196000    384K rw-s-    [ shmid=0x3f440003 ]
> 311f6000    384K rw-s-    [ shmid=0x3f448004 ]
> 31256000    384K rw-s-    [ shmid=0x3f450005 ]
> 312b6000    384K rw-s-    [ shmid=0x3f460006 ]
> 31316000    384K rw-s-    [ shmid=0x3f870007 ]
> 31491000    140K r----  /usr/share/fonts/type1/gsfonts/n021003l.pfb
> 3150e000   9496K rw---    [ anon ]

pmap seems to get shmid from "ino#" field of /proc/pid/map.
Its already broken in current mainline.

But, the breakage is not due to namespaces or container effort :(
Its due to noble effort from Eric to clean up the shm code,
take out the hacks to handle hugetlbfs and make the code
more streamlined and readable.

If we really really want old behaviour, we need my one line
patch to force shmid as inode# :(

BTW, I agree with Eric that its would be nice to use shmid as part
of name instead of forcing to be as inode number. It should be
possible for pmap to workout shmid from "key" or name. Isn't it ?

Andrew/Linus, its up to you to figure out if its worth breaking.
Here is the patch to base dentry-name on shmid - so we don't
need to use ino# to identify shmid.

Thanks,
Badari

Instead of basing dentry name on the shm "key", base it on
"shmid" - so it shows up clearly in /proc/pid/maps. Earlier
we were forcing ino# to match shmid.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
Index: linux-2.6.22-rc4/ipc/shm.c
===================================================================
--- linux-2.6.22-rc4.orig/ipc/shm.c	2007-06-04 17:57:25.000000000 -0700
+++ linux-2.6.22-rc4/ipc/shm.c	2007-06-06 13:43:36.000000000 -0700
@@ -364,6 +364,14 @@ static int newseg (struct ipc_namespace 
 		return error;
 	}
 
+	error = -ENOSPC;
+	id = shm_addid(ns, shp);
+	if(id == -1)
+		goto no_id;
+
+	/* Build an id, so we can use it for filename */
+	shp->id = shm_buildid(ns, id, shp->shm_perm.seq);
+
 	if (shmflg & SHM_HUGETLB) {
 		/* hugetlb_zero_setup takes care of mlock user accounting */
 		file = hugetlb_zero_setup(size);
@@ -377,34 +385,28 @@ static int newseg (struct ipc_namespace 
 		if  ((shmflg & SHM_NORESERVE) &&
 				sysctl_overcommit_memory != OVERCOMMIT_NEVER)
 			acctflag = 0;
-		sprintf (name, "SYSV%08x", key);
+		sprintf (name, "SYSVID%d", shp->id);
 		file = shmem_file_setup(name, size, acctflag);
 	}
 	error = PTR_ERR(file);
 	if (IS_ERR(file))
 		goto no_file;
 
-	error = -ENOSPC;
-	id = shm_addid(ns, shp);
-	if(id == -1) 
-		goto no_id;
-
 	shp->shm_cprid = current->tgid;
 	shp->shm_lprid = 0;
 	shp->shm_atim = shp->shm_dtim = 0;
 	shp->shm_ctim = get_seconds();
 	shp->shm_segsz = size;
 	shp->shm_nattch = 0;
-	shp->id = shm_buildid(ns, id, shp->shm_perm.seq);
 	shp->shm_file = file;
 
 	ns->shm_tot += numpages;
 	shm_unlock(shp);
 	return shp->id;
 
-no_id:
-	fput(file);
 no_file:
+	shm_rmid(ns, shp->id);
+no_id:
 	security_shm_free(shp);
 	ipc_rcu_putref(shp);
 	return error;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
