Received: from e6.ny.us.ibm.com ([9.14.6.106])
	by pokfb.esmtp.ibm.com (8.12.2/8.12.2) with ESMTP id g8IGCDqw088548
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=OK)
	for <linux-mm@kvack.org>; Wed, 18 Sep 2002 12:12:14 -0400
From: Hubertus Franke <frankeh@watson.ibm.com>
Reply-To: frankeh@watson.ibm.com
Subject: [PATCH] recognize MAP_LOCKED in mmap() call
Date: Wed, 18 Sep 2002 12:07:26 -0400
References: <3D815C8C.4050000@us.ibm.com> <1031922352.9056.14.camel@irongate.swansea.linux.org.uk> <20020913213042.GD3530@holomorphy.com>
In-Reply-To: <20020913213042.GD3530@holomorphy.com>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_E46NZG7A4M3X1RKLRVT1"
Message-Id: <200209181207.26655.frankeh@watson.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------Boundary-00=_E46NZG7A4M3X1RKLRVT1
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit


Andrew, at the current time an mmap() ignores a MAP_LOCKED passed to it.
The only way we can get VM_LOCKED associated with the newly created VMA
is to have previously called mlockall() on the process which sets the 
mm->def_flags != VM_LOCKED or subsequently call mlock() on the
newly created VMA.

The attached patch checks for MAP_LOCKED being passed and if so checks
the capabilities of the process. Limit checks were already in place.
-- 
-- Hubertus Franke  (frankeh@watson.ibm.com)

--------------------------------< PATCH >------------------------------
--- linux-2.5.35/mm/mmap.c	Wed Sep 18 11:12:13 2002
+++ linux-2.5.35-fix/mm/mmap.c	Wed Sep 18 11:44:32 2002
@@ -461,6 +461,11 @@
 	 */
 	vm_flags = calc_vm_flags(prot,flags) | mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
+	if (flags & MAP_LOCKED) {
+		if (!capable(CAP_IPC_LOCK))
+			return -EPERM;
+		vm_flags |= VM_LOCKED;
+	}
 	/* mlock MCL_FUTURE? */
 	if (vm_flags & VM_LOCKED) {
 		unsigned long locked = mm->locked_vm << PAGE_SHIFT;




--------------Boundary-00=_E46NZG7A4M3X1RKLRVT1
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="patch.2.5.35.mmap_locked"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="patch.2.5.35.mmap_locked"

--- linux-2.5.35/mm/mmap.c	Wed Sep 18 11:12:13 2002
+++ linux-2.5.35-fix/mm/mmap.c	Wed Sep 18 11:44:32 2002
@@ -461,6 +461,11 @@
 	 */
 	vm_flags = calc_vm_flags(prot,flags) | mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
+	if (flags & MAP_LOCKED) {
+		if (!capable(CAP_IPC_LOCK))
+			return -EPERM;
+		vm_flags |= VM_LOCKED;
+	}
 	/* mlock MCL_FUTURE? */
 	if (vm_flags & VM_LOCKED) {
 		unsigned long locked = mm->locked_vm << PAGE_SHIFT;

--------------Boundary-00=_E46NZG7A4M3X1RKLRVT1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
