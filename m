Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 941566B005A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:51:00 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 380B682CCA0
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:05:46 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gMlPbA2X4UUY for <linux-mm@kvack.org>;
	Wed,  3 Jun 2009 11:05:46 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 39ACA82CC9E
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:05:40 -0400 (EDT)
Date: Wed, 3 Jun 2009 10:50:46 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Security fix for remapping of page 0 (was [PATCH] Change ZERO_SIZE_PTR
 to point at unmapped space)
In-Reply-To: <20090602203405.GC6701@oblivion.subreption.com>
Message-ID: <alpine.DEB.1.10.0906031047390.15621@gentwo.org>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com>
 <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Tue, 2 Jun 2009, Larry H. wrote:

> Why would mmap_min_addr have been created in first place, if NULL can't
> be mapped to force the kernel into accessing userland memory? This is
> the way a long list of public and private kernel exploits have worked to
> elevate privileges, and disable SELinux/LSMs atomically, too.
>
> Take a look at these:
> http://www.grsecurity.net/~spender/exploit.tgz (disables LSMs)
> http://milw0rm.com/exploits/4172
> http://milw0rm.com/exploits/3587
>
> I would like to know what makes you think I can't mmap(0) from within
> the same process that triggers your 'not so exploitable NULL page
> fault', which instead of generating the oops will lead to 100% reliable,
> cross-arch exploitation to get root privileges (again, after disabling
> SELinux and anything else that would supposedly prevent this situation).
> Or leaked memory, like a kmalloc(0) situation will most likely lead to,
> given the current circumstances.

Ok. So what we need to do is stop this toying around with remapping of
page 0. The following patch contains a fix and a test program that
demonstrates the issue.


Subject: [Security] Do not allow remapping of page 0 via MAP_FIXED

If one remaps page 0 then the kernel checks for NULL pointers of various
flavors are bypassed and this may be exploited in various creative ways
to transfer data from kernel space to user space.

Fix this by not allowing the remapping of page 0. Return -EINVAL if
such a mapping is attempted.

Simple test program that shows the problem:

#include <sys/mman.h>

int main(int argc, char *argv)
{
        printf("%ld\n", mmap(0L, 4096, PROT_WRITE, MAP_FIXED|MAP_PRIVATE|MAP_ANONYMOUS, 0,0));
        *((char *)8) = 3;
        printf("Value at address 8 is %d\n", *((char *)8));
        return 0;
}

If the remapping of page 0 succeeds then the value at 8 is 3.
After the patch the program segfaults as it should.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/mmap.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2009-06-03 09:44:43.000000000 -0500
+++ linux-2.6/mm/mmap.c	2009-06-03 09:45:31.000000000 -0500
@@ -1273,8 +1273,12 @@ arch_get_unmapped_area(struct file *filp
 	if (len > TASK_SIZE)
 		return -ENOMEM;

-	if (flags & MAP_FIXED)
-		return addr;
+	if (flags & MAP_FIXED) {
+		if (addr & PAGE_MASK)
+			return addr;
+		/* Do not allow remapping of the first page */
+		return -EINVAL;
+	}

 	if (addr) {
 		addr = PAGE_ALIGN(addr);
@@ -1349,8 +1353,12 @@ arch_get_unmapped_area_topdown(struct fi
 	if (len > TASK_SIZE)
 		return -ENOMEM;

-	if (flags & MAP_FIXED)
-		return addr;
+	if (flags & MAP_FIXED) {
+		if (addr & PAGE_MASK)
+			return addr;
+		/* Do not allow remapping of the first page */
+		return -EINVAL;
+	}

 	/* requesting a specific address */
 	if (addr) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
