Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C2DE600373
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 02:36:38 -0400 (EDT)
From: "Zhao, Leifu" <leifu.zhao@intel.com>
Date: Thu, 8 Apr 2010 14:36:15 +0800
Subject: [PATCH] race condition between __purge_vmap_area_lazy() and
 free_unmap_vmap_area_noflush()
Message-ID: <EAEEEBBE07F4F24C89FEF850CF8C77420142A21107@shzsmsx502.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi all,

I found a bug in 2.6.28 kernel and got the fix for it, see below bug descri=
ption, log information and the patch. As I know this bug still exists in at=
 least 2.6.32 kernel. I am new in the kernel development process, can someo=
ne tell me what should proceed next?

Bug description:

There is race condition between function __purge_vmap_area_lazy() and free_=
unmap_vmap_area_noflush() in vmalloc.c of kernel. In function free_unmap_vm=
ap_area_noflush(), if=A0 va->flags is updated and then is preempted to run =
__purge_vmap_area_lazy() before updating vmap_lazy_nr, then vmap_lazy_nr us=
ed in function __purge_vmap_area_lazy() has incorrect value, therefore caus=
e the crash(due to run BUG_ON function). So the updating va->flags and vmap=
_lazy_nr must execute atomicly, the solution is to use spinlock to protect =
updating va->flags and vmap_lazy_nr.


Captured log information:

kernel BUG at mm/vmalloc.c:507!
invalid opcode: 0000 [#1] PREEMPT=20
last sysfs file: /sys/class/sound/controlC0/dev
Modules linked in: avcap_nxp(P) avcap_synthetic(P) avcap_core(P) pvrsrvkm
alsa_shim(P) snd_usb_audio ]

Pid: 1022, comm: Audio_Timing Tainted: P=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 (2.6=
.28 #1)=20
EIP: 0060:[<c01537d5>] EFLAGS: 00010297 CPU: 0
EIP is at __purge_vmap_area_lazy+0x1b1/0x1b5
EAX: c4e1e000 EBX: c04e0cec ECX: c4e1fc9c EDX: c04e0d04
ESI: 000001e2 EDI: c4e1fcc4 EBP: c4e1fcc0 ESP: c4e1fc98



Patch:

--- linux-2.6.28/mm/vmalloc.c.orig      2010-04-10 14:16:47.000000000 +0800
+++ linux-2.6.28/mm/vmalloc.c   2010-04-10 14:19:03.000000000 +0800
@@ -467,6 +467,7 @@ static unsigned long lazy_max_pages(void

 static atomic_t vmap_lazy_nr =3D ATOMIC_INIT(0);

+static DEFINE_SPINLOCK(purge_lock);
 /*
  * Purges all lazily-freed vmap areas.
  *
@@ -480,7 +481,6 @@ static atomic_t vmap_lazy_nr =3D ATOMIC_IN
 static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *en=
d,
                                        int sync, int force_flush)
 {
-       static DEFINE_SPINLOCK(purge_lock);
        LIST_HEAD(valist);
        struct vmap_area *va;
        int nr =3D 0;
@@ -556,8 +556,10 @@ static void purge_vmap_area_lazy(void)
  */
 static void free_unmap_vmap_area_noflush(struct vmap_area *va)
 {
+       spin_lock(&purge_lock);
        va->flags |=3D VM_LAZY_FREE;
        atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr=
);
+       spin_unlock(&purge_lock);
        if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages()))
                try_purge_vmap_area_lazy();
 }



Signed-off-by: Leifu Zhao <Leifu.zhao@intel.com>



Best regards,
=A0
Leifu Zhao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
