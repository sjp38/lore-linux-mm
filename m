Received: from sbustd.stud.uni-sb.de (IDENT:VH/Yne9YgiCEuK+D8Z4ZKEYs4RZyb9N8@eris.rz.uni-sb.de [134.96.7.8])
	by indyio.rz.uni-sb.de (8.9.3/8.9.3) with ESMTP id NAA4212457
	for <linux-mm@kvack.org>; Thu, 29 Jul 1999 13:59:58 +0200 (CST)
Received: from clmsdev (acc3-98.telip.uni-sb.de [134.96.127.98])
	by sbustd.stud.uni-sb.de (8.9.3/8.9.3) with SMTP id NAA29841
	for <linux-mm@kvack.org>; Thu, 29 Jul 1999 13:59:56 +0200 (CST)
Message-ID: <002401bed9ba$16e9fb50$c80c17ac@clmsdev.local>
From: "Manfred Spraul" <masp0008@stud.uni-sb.de>
Subject: [PATCH] tlb flush: further bugs? (2.3.12-9)
Date: Thu, 29 Jul 1999 13:57:23 +0200
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_001E_01BED9CA.483FBB30"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------=_NextPart_000_001E_01BED9CA.483FBB30
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

I think I found 2 minor bugs in the current tlb flush code:
- during crossing TLB flushes, mm->cpu_mask is not set.
- flush_tlb_current_task() contains a race between
flush_tlb_other_cpus(the IPI could set mm->cpu_mask)
& the next line.
effectively, my patch means that flush_tlb_current_task() 
is identical to flush_tlb_mm(current->mm), perhaps this should
be replaced with a #define.

I've attached a patch (untested) against 2.3.12-9,

    Manfred


------=_NextPart_000_001E_01BED9CA.483FBB30
Content-Type: application/octet-stream;
	name="smp.c.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="smp.c.diff"

--- smp.c.old	Thu Jul 29 13:06:18 1999
+++ SMP.C	Thu Jul 29 13:55:41 1999
@@ -1617,6 +1617,8 @@
 			if (test_bit(cpu, &smp_invalidate_needed)) {
 				clear_bit(cpu, &smp_invalidate_needed);
 				local_flush_tlb();
+                                if(current->mm)
+                                        atomic_set_mask(1 << cpu, =
&current->mm->cpu_vm_mask);
 			}
 			--stuck;
 			if (!stuck) {
@@ -1637,14 +1639,16 @@
  */=09
 void flush_tlb_current_task(void)
 {
-	unsigned long vm_mask =3D 1 << current->processor;
 	struct mm_struct *mm =3D current->mm;
+	unsigned long vm_mask =3D 1 << current->processor;
+	unsigned long cpu_mask =3D mm->cpu_vm_mask & ~vm_mask;
=20
-	if (mm->cpu_vm_mask !=3D vm_mask) {
-		flush_tlb_others(mm->cpu_vm_mask & ~vm_mask);
+	mm->cpu_vm_mask =3D 0;
+	if (current->active_mm =3D=3D mm) {
 		mm->cpu_vm_mask =3D vm_mask;
+		local_flush_tlb();
 	}
-	local_flush_tlb();
+	flush_tlb_others(cpu_mask);
 }
=20
 void flush_tlb_mm(struct mm_struct * mm)

------=_NextPart_000_001E_01BED9CA.483FBB30--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
