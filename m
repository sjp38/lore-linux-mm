Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9IG3shm014066
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 12:03:54 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9IG6UP5508972
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 10:06:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9IG5bPG019744
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 10:05:37 -0600
Subject: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
References: <1129570219.23632.34.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>
	 <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
Content-Type: multipart/mixed; boundary="=-HE9fpKEKoZB/XK3fpDEB"
Date: Tue, 18 Oct 2005 09:05:02 -0700
Message-Id: <1129651502.23632.63.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Chris Wright <chrisw@osdl.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-HE9fpKEKoZB/XK3fpDEB
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2005-10-17 at 19:25 +0100, Hugh Dickins wrote:
> On Mon, 17 Oct 2005, Hugh Dickins wrote:
> > On Mon, 17 Oct 2005, Badari Pulavarty wrote:
> > > 
> > > I have been looking at possible ways to extend OVERCOMMIT_ALWAYS
> > > to avoid its abuse.
> > > 
> > > Few of the applications (database) would like to overcommit
> > > memory (by creating shared memory segments more than RAM+swap),
> > > but use only portion of it at any given time and get rid
> > > of portions of them through madvise(DONTNEED), when needed. 
> > > They want this, especially to handle hotplug memory situations 
> > > (where apps may not have clear idea on how much memory they have 
> > > in the system at the time of shared memory create). Currently, 
> > > they are using OVERCOMMIT_ALWAYS system wide to do this - but 
> > > they are affecting every other application on the system.
> > > 
> > > I am wondering, if there is a better way to do this. Simple solution
> > > would be to add IPC_OVERCOMMIT flag or add CAP_SYS_ADMIN to
> > > do the overcommit. This way only specific applications, requesting
> > > this would be able to overcommit. I am worried about, the over
> > > all affects it has on the system. But again, this can't be worse
> > > than system wide  OVERCOMMIT_ALWAYS. Isn't it ?
> > 
> > mmap has MAP_NORESERVE, without CAP_SYS_ADMIN or other restriction,
> > which exempts that mmap from security_vm_enough_memory checking -
> > unless current setting is OVERCOMMIT_NEVER, in which case
> > MAP_NORESERVE is ignored.
> 
> Having written that, it does seem rather odd that we have a flag
> anyone can set to evade that security_ checking.  It was okay when
> it was just vm_enough_memory, but now it's security_vm_enough_memory,
> I wonder if this is a significant oversight, and some CAP required.
> Might break things though.  CC'ed Chris.
> 
> Ah, there's a security_file_mmap earlier, which could reject the
> MAP_NORESERVE flag if it feels so inclined.  Perhaps you'll need
> to allow a similar opportunity for rejection in your approach.
> 
> Hugh
> 
> > So if you're content to move to the OVERCOMMIT_GUESS world, I
> > don't think you could be blamed for adding an IPC_NORESERVE which
> > behaves in the same way, without CAP_SYS_ADMIN restriction.
> > 
> > But if you want to move to OVERCOMMIT_NEVER, yet have a flag which
> > says overcommit now, you'll get into a tussle with NEVER-adherents.
> > 
> > Hugh
> 

Hugh,

As you suggested, here is the patch to add SHM_NORESERVE which does 
same thing as MAP_NORESERVE. This flag is ignored for OVERCOMMIT_NEVER.
I decided to do SHM_NORESERVE instead of IPC_NORESERVE - just to limit
its scope.

BTW, there is a call to security_shm_alloc() earlier, which could
be modified to reject shmget() if it needs to.

Is this reasonable ? Please review.

Thanks,
Badari



--=-HE9fpKEKoZB/XK3fpDEB
Content-Disposition: attachment; filename=shm-noreserve.patch
Content-Type: text/x-patch; name=shm-noreserve.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
--- linux-2.6.14-rc3.org/include/linux/shm.h	2005-10-18 08:44:28.000000000 -0700
+++ linux-2.6.14-rc3/include/linux/shm.h	2005-10-18 08:46:03.000000000 -0700
@@ -92,6 +92,7 @@ struct shmid_kernel /* private to the ke
 #define	SHM_DEST	01000	/* segment will be destroyed on last detach */
 #define SHM_LOCKED      02000   /* segment will not be swapped */
 #define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
+#define SHM_NORESERVE   010000  /* don't check for reservations */
 
 #ifdef CONFIG_SYSVIPC
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr);
--- linux-2.6.14-rc3.org/ipc/shm.c	2005-10-17 16:57:40.000000000 -0700
+++ linux-2.6.14-rc3/ipc/shm.c	2005-10-18 08:55:50.000000000 -0700
@@ -212,8 +212,16 @@ static int newseg (key_t key, int shmflg
 		file = hugetlb_zero_setup(size);
 		shp->mlock_user = current->user;
 	} else {
+		int acctflag = VM_ACCOUNT;
+		/*
+		 * Do not allow no accouting for OVERCOMMIT_NEVER, even
+	 	 * its asked for.
+		 */
+		if  ((shmflg & SHM_NORESERVE) && 
+		     sysctl_overcommit_memory != OVERCOMMIT_NEVER)
+			acctflag = 0;
 		sprintf (name, "SYSV%08x", key);
-		file = shmem_file_setup(name, size, VM_ACCOUNT);
+		file = shmem_file_setup(name, size, acctflag);
 	}
 	error = PTR_ERR(file);
 	if (IS_ERR(file))

--=-HE9fpKEKoZB/XK3fpDEB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
