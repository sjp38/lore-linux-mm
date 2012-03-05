Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id F0B6D6B00F3
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 04:48:02 -0500 (EST)
Received: by wgbds1 with SMTP id ds1so511317wgb.2
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 01:48:01 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 5 Mar 2012 15:18:01 +0530
Message-ID: <CAEEG8gePZ4heCtp00XVQ=SjXxT=EopYr0xSG6P1NEgU0ZKK-BA@mail.gmail.com>
Subject: [PATCH v1 1/2] kvm: Transcendent Memory on KVM
From: Akshay Karle <akshay.a.karle@gmail.com>
Content-Type: multipart/alternative; boundary=00504502dabf7081d204ba7bd2a3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, konrad.wilk@oracle.com, linux-mm@kvack.org, kvm@vger.kernel.org, ashu tripathi <er.ashutripathi@gmail.com>, nishant gulhane <nishant.s.gulhane@gmail.com>, Shreyas Mahure <shreyas.mahure@gmail.com>, amarmore2006 <amarmore2006@gmail.com>, mahesh mohan <mahesh6490@gmail.com>

--00504502dabf7081d204ba7bd2a3
Content-Type: text/plain; charset=ISO-8859-1

From: Akshay Karle <akshay.a.karle@gmail.com>
Subject: [PATCH v1 1/2] kvm: Transcendent Memory on KVM

Hi,

This patch implements:
Transcendent memory(tmem) for the kvm hypervisor. This patch was developed
for kernel-3.1.5.

The patch adds appropriate shims at the guest that invokes hypercalls, and
the host uses
zcache pools to implement the required functions.

To enable tmem on the kvm host add the boot parameter:
"kvmtmem"
And to enable Transcendent memory in the kvm guests add the boot parameter:
"tmem"
This part of the patch includes the changes made to zcache to support the
tmem requests of
the kvm guests running on the kvm host.

Any comments/suggestions are welcome.
Signed-off-by: Akshay Karle <akshay.a.karle@gmail.com>
--
 arch/x86/include/asm/kvm_host.h       |    1
 arch/x86/kvm/x86.c                           |    4
 drivers/staging/zcache/Makefile          |    2
 drivers/staging/zcache/kvm-tmem.c    |    356
+++++++++++++++++++++++++++++++++++
 drivers/staging/zcache/kvm-tmem.h    |    55 +++++
 drivers/staging/zcache/zcache-main.c |    98 ++++++++-
 include/linux/kvm_para.h                    |    1
 7 files changed, 508 insertions(+), 9 deletions(-)

diff -Napur vanilla/linux-3.1.5/arch/x86/include/asm/kvm_host.h
linux-3.1.5//arch/x86/include/asm/kvm_host.h
--- vanilla/linux-3.1.5/arch/x86/include/asm/kvm_host.h    2011-12-09
22:27:05.000000000 +0530
+++ linux-3.1.5//arch/x86/include/asm/kvm_host.h    2012-03-05
14:09:41.648006153 +0530
@@ -668,6 +668,7 @@ int emulator_write_phys(struct kvm_vcpu
               const void *val, int bytes);
 int kvm_pv_mmu_op(struct kvm_vcpu *vcpu, unsigned long bytes,
           gpa_t addr, unsigned long *ret);
+int kvm_pv_tmem_op(struct kvm_vcpu *vcpu, gpa_t addr, unsigned long *ret);
 u8 kvm_get_guest_memory_type(struct kvm_vcpu *vcpu, gfn_t gfn);

 extern bool tdp_enabled;
diff -Napur vanilla/linux-3.1.5/arch/x86/kvm/x86.c
linux-3.1.5//arch/x86/kvm/x86.c
--- vanilla/linux-3.1.5/arch/x86/kvm/x86.c    2011-12-09 22:27:05.000000000
+0530
+++ linux-3.1.5//arch/x86/kvm/x86.c    2012-03-05 14:09:41.652006083 +0530
@@ -5267,6 +5267,10 @@ int kvm_emulate_hypercall(struct kvm_vcp
     case KVM_HC_MMU_OP:
         r = kvm_pv_mmu_op(vcpu, a0, hc_gpa(vcpu, a1, a2), &ret);
         break;
+    case KVM_HC_TMEM:
+        r = kvm_pv_tmem_op(vcpu, a0, &ret);
+        ret = ret - 1000;
+        break;
     default:
         ret = -KVM_ENOSYS;
         break;
diff -Napur vanilla/linux-3.1.5/drivers/staging/zcache/zcache-main.c
linux-3.1.5//drivers/staging/zcache/zcache-main.c
--- vanilla/linux-3.1.5/drivers/staging/zcache/zcache-main.c    2011-12-09
22:27:05.000000000 +0530
+++ linux-3.1.5//drivers/staging/zcache/zcache-main.c    2012-03-05
14:10:31.264006031 +0530
@@ -30,6 +30,7 @@
 #include <linux/atomic.h>
 #include <linux/math64.h>
 #include "tmem.h"
+#include "kvm-tmem.h"

 #include "../zram/xvmalloc.h" /* if built in drivers/staging */

@@ -669,7 +670,6 @@ static struct zv_hdr *zv_create(struct x
     int chunks = (alloc_size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
     int ret;

-    BUG_ON(!irqs_disabled());
     BUG_ON(chunks >= NCHUNKS);
     ret = xv_malloc(xvpool, alloc_size,
             &page, &offset, ZCACHE_GFP_MASK);
@@ -1313,7 +1313,6 @@ static int zcache_compress(struct page *
     unsigned char *wmem = __get_cpu_var(zcache_workmem);
     char *from_va;

-    BUG_ON(!irqs_disabled());
     if (unlikely(dmem == NULL || wmem == NULL))
         goto out;  /* no buffer, so can't compress */
     from_va = kmap_atomic(from, KM_USER0);
@@ -1533,7 +1532,6 @@ static int zcache_put_page(int cli_id, i
     struct tmem_pool *pool;
     int ret = -1;

-    BUG_ON(!irqs_disabled());
     pool = zcache_get_pool_by_id(cli_id, pool_id);
     if (unlikely(pool == NULL))
         goto out;
@@ -1898,6 +1896,67 @@ struct frontswap_ops zcache_frontswap_re
 #endif

 /*
+ * tmem op to support tmem in kvm guests
+ */
+
+int kvm_pv_tmem_op(struct kvm_vcpu *vcpu, gpa_t addr, unsigned long *ret)
+{
+    struct tmem_op op;
+    struct tmem_oid oid;
+    uint64_t pfn;
+    struct page *page;
+    int r;
+
+    r = kvm_read_guest(vcpu->kvm, addr, &op, sizeof(op));
+    if (r < 0)
+        return r;
+
+    switch (op.cmd) {
+    case TMEM_NEW_POOL:
+        *ret = zcache_new_pool(op.u.new.cli_id, op.u.new.flags);
+        break;
+    case TMEM_DESTROY_POOL:
+        *ret = zcache_destroy_pool(op.u.gen.cli_id, op.pool_id);
+        break;
+    case TMEM_NEW_PAGE:
+        break;
+    case TMEM_PUT_PAGE:
+        pfn = gfn_to_pfn(vcpu->kvm, op.u.gen.pfn);
+        page = pfn_to_page(pfn);
+        oid.oid[0] = op.u.gen.oid[0];
+        oid.oid[1] = op.u.gen.oid[1];
+        oid.oid[2] = op.u.gen.oid[2];
+        VM_BUG_ON(!PageLocked(page));
+        *ret = zcache_put_page(op.u.gen.cli_id, op.pool_id,
+                &oid, op.u.gen.index, page);
+        break;
+    case TMEM_GET_PAGE:
+        pfn = gfn_to_pfn(vcpu->kvm, op.u.gen.pfn);
+        page = pfn_to_page(pfn);
+        oid.oid[0] = op.u.gen.oid[0];
+        oid.oid[1] = op.u.gen.oid[1];
+        oid.oid[2] = op.u.gen.oid[2];
+        *ret = zcache_get_page(TMEM_CLI, op.pool_id,
+                &oid, op.u.gen.index, page);
+        break;
+    case TMEM_FLUSH_PAGE:
+        oid.oid[0] = op.u.gen.oid[0];
+        oid.oid[1] = op.u.gen.oid[1];
+        oid.oid[2] = op.u.gen.oid[2];
+        *ret = zcache_flush_page(op.u.gen.cli_id, op.pool_id,
+                &oid, op.u.gen.index);
+        break;
+    case TMEM_FLUSH_OBJECT:
+        oid.oid[0] = op.u.gen.oid[0];
+        oid.oid[1] = op.u.gen.oid[1];
+        oid.oid[2] = op.u.gen.oid[2];
+        *ret = zcache_flush_object(op.u.gen.cli_id, op.pool_id, &oid);
+        break;
+    }
+    return 0;
+}
+
+/*
  * zcache initialization
  * NOTE FOR NOW zcache MUST BE PROVIDED AS A KERNEL BOOT PARAMETER OR
  * NOTHING HAPPENS!
@@ -1934,10 +1993,19 @@ static int __init no_frontswap(char *s)

 __setup("nofrontswap", no_frontswap);

+static int kvm_tmem_enabled = 0;
+
+static int __init enable_kvm_tmem(char *s)
+{
+    kvm_tmem_enabled = 1;
+    return 1;
+}
+
+__setup("kvmtmem", enable_kvm_tmem);
+
 static int __init zcache_init(void)
 {
     int ret = 0;
-
 #ifdef CONFIG_SYSFS
     ret = sysfs_create_group(mm_kobj, &zcache_attr_group);
     if (ret) {
@@ -1946,7 +2014,7 @@ static int __init zcache_init(void)
     }
 #endif /* CONFIG_SYSFS */
 #if defined(CONFIG_CLEANCACHE) || defined(CONFIG_FRONTSWAP)
-    if (zcache_enabled) {
+    if (zcache_enabled || kvm_tmem_enabled) {
         unsigned int cpu;

         tmem_register_hostops(&zcache_hostops);
@@ -1966,11 +2034,25 @@ static int __init zcache_init(void)
                 sizeof(struct tmem_objnode), 0, 0, NULL);
     zcache_obj_cache = kmem_cache_create("zcache_obj",
                 sizeof(struct tmem_obj), 0, 0, NULL);
-    ret = zcache_new_client(LOCAL_CLIENT);
-    if (ret) {
-        pr_err("zcache: can't create client\n");
+    if(kvm_tmem_enabled) {
+        ret = zcache_new_client(TMEM_CLI);
+        if(ret) {
+            pr_err("zcache: can't create client\n");
+            goto out;
+        }
+        zbud_init();
+        register_shrinker(&zcache_shrinker);
+        pr_info("zcache: transcendent memory enabled using kernel "
+            "for kvm guests\n");
         goto out;
     }
+    else {
+        ret = zcache_new_client(LOCAL_CLIENT);
+        if (ret) {
+            pr_err("zcache: can't create client\n");
+            goto out;
+        }
+    }
 #endif
 #ifdef CONFIG_CLEANCACHE
     if (zcache_enabled && use_cleancache) {

--00504502dabf7081d204ba7bd2a3
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

From: Akshay Karle &lt;<a href=3D"mailto:akshay.a.karle@gmail.com">akshay.a=
.karle@gmail.com</a>&gt;<br>Subject: [PATCH v1 1/2] kvm: Transcendent Memor=
y on KVM<br><br>Hi,<br><br>This patch implements:<br>Transcendent memory(tm=
em) for the kvm hypervisor. This patch was developed for kernel-3.1.5.<br>
<br>The patch adds appropriate shims at the guest that invokes hypercalls, =
and the host uses<br>zcache pools to implement the required functions.<br><=
br>To enable tmem on the kvm host add the boot parameter:<br>&quot;kvmtmem&=
quot;<br>
And to enable Transcendent memory in the kvm guests add the boot parameter:=
<br>&quot;tmem&quot;<br>This part of the patch includes the changes made to=
 zcache to support the tmem requests of<br>the kvm guests running on the kv=
m host.<br>
<br>Any comments/suggestions are welcome.<br clear=3D"all">Signed-off-by: A=
kshay Karle &lt;<a href=3D"mailto:akshay.a.karle@gmail.com">akshay.a.karle@=
gmail.com</a>&gt;<br>--<br>=A0arch/x86/include/asm/kvm_host.h=A0=A0=A0=A0=
=A0=A0 |=A0=A0=A0 1 <br>
=A0arch/x86/kvm/x86.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 |=A0=A0=A0 4 <br>=A0drivers/staging/zcache/Makefil=
e=A0=A0=A0=A0=A0=A0=A0=A0=A0 |=A0=A0=A0 2 <br>=A0drivers/staging/zcache/kvm=
-tmem.c=A0=A0=A0 |=A0=A0=A0 356 +++++++++++++++++++++++++++++++++++<br>=A0d=
rivers/staging/zcache/kvm-tmem.h=A0=A0=A0 |=A0=A0=A0 55 +++++<br>
=A0drivers/staging/zcache/zcache-main.c |=A0=A0=A0 98 ++++++++-<br>=A0inclu=
de/linux/kvm_para.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 |=A0=A0=A0 1 <br>=A07 files changed, 508 insertions(+), 9 deletions(-)<=
br><br>diff -Napur vanilla/linux-3.1.5/arch/x86/include/asm/kvm_host.h linu=
x-3.1.5//arch/x86/include/asm/kvm_host.h<br>
--- vanilla/linux-3.1.5/arch/x86/include/asm/kvm_host.h=A0=A0=A0 2011-12-09=
 22:27:05.000000000 +0530<br>+++ linux-3.1.5//arch/x86/include/asm/kvm_host=
.h=A0=A0=A0 2012-03-05 14:09:41.648006153 +0530<br>@@ -668,6 +668,7 @@ int =
emulator_write_phys(struct kvm_vcpu<br>
=A0=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0 const void *val, int bytes);<br>=A0int=
 kvm_pv_mmu_op(struct kvm_vcpu *vcpu, unsigned long bytes,<br>=A0=A0=A0=A0 =
=A0=A0=A0 =A0 gpa_t addr, unsigned long *ret);<br>+int kvm_pv_tmem_op(struc=
t kvm_vcpu *vcpu, gpa_t addr, unsigned long *ret);<br>
=A0u8 kvm_get_guest_memory_type(struct kvm_vcpu *vcpu, gfn_t gfn);<br>=A0<b=
r>=A0extern bool tdp_enabled;<br>diff -Napur vanilla/linux-3.1.5/arch/x86/k=
vm/x86.c linux-3.1.5//arch/x86/kvm/x86.c<br>--- vanilla/linux-3.1.5/arch/x8=
6/kvm/x86.c=A0=A0=A0 2011-12-09 22:27:05.000000000 +0530<br>
+++ linux-3.1.5//arch/x86/kvm/x86.c=A0=A0=A0 2012-03-05 14:09:41.652006083 =
+0530<br>@@ -5267,6 +5267,10 @@ int kvm_emulate_hypercall(struct kvm_vcp<br=
>=A0=A0=A0=A0 case KVM_HC_MMU_OP:<br>=A0=A0=A0=A0 =A0=A0=A0 r =3D kvm_pv_mm=
u_op(vcpu, a0, hc_gpa(vcpu, a1, a2), &amp;ret);<br>
=A0=A0=A0=A0 =A0=A0=A0 break;<br>+=A0=A0=A0 case KVM_HC_TMEM:<br>+=A0=A0=A0=
 =A0=A0=A0 r =3D kvm_pv_tmem_op(vcpu, a0, &amp;ret);<br>+=A0=A0=A0 =A0=A0=
=A0 ret =3D ret - 1000;<br>+=A0=A0=A0 =A0=A0=A0 break;<br>=A0=A0=A0=A0 defa=
ult:<br>=A0=A0=A0=A0 =A0=A0=A0 ret =3D -KVM_ENOSYS;<br>=A0=A0=A0=A0 =A0=A0=
=A0 break;<br>diff -Napur vanilla/linux-3.1.5/drivers/staging/zcache/zcache=
-main.c linux-3.1.5//drivers/staging/zcache/zcache-main.c<br>
--- vanilla/linux-3.1.5/drivers/staging/zcache/zcache-main.c=A0=A0=A0 2011-=
12-09 22:27:05.000000000 +0530<br>+++ linux-3.1.5//drivers/staging/zcache/z=
cache-main.c=A0=A0=A0 2012-03-05 14:10:31.264006031 +0530<br>@@ -30,6 +30,7=
 @@<br>=A0#include &lt;linux/atomic.h&gt;<br>
=A0#include &lt;linux/math64.h&gt;<br>=A0#include &quot;tmem.h&quot;<br>+#i=
nclude &quot;kvm-tmem.h&quot;<br>=A0<br>=A0#include &quot;../zram/xvmalloc.=
h&quot; /* if built in drivers/staging */<br>=A0<br>@@ -669,7 +670,6 @@ sta=
tic struct zv_hdr *zv_create(struct x<br>
=A0=A0=A0=A0 int chunks =3D (alloc_size + (CHUNK_SIZE - 1)) &gt;&gt; CHUNK_=
SHIFT;<br>=A0=A0=A0=A0 int ret;<br>=A0<br>-=A0=A0=A0 BUG_ON(!irqs_disabled(=
));<br>=A0=A0=A0=A0 BUG_ON(chunks &gt;=3D NCHUNKS);<br>=A0=A0=A0=A0 ret =3D=
 xv_malloc(xvpool, alloc_size,<br>=A0=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 &amp;pag=
e, &amp;offset, ZCACHE_GFP_MASK);<br>
@@ -1313,7 +1313,6 @@ static int zcache_compress(struct page *<br>=A0=A0=A0=
=A0 unsigned char *wmem =3D __get_cpu_var(zcache_workmem);<br>=A0=A0=A0=A0 =
char *from_va;<br>=A0<br>-=A0=A0=A0 BUG_ON(!irqs_disabled());<br>=A0=A0=A0=
=A0 if (unlikely(dmem =3D=3D NULL || wmem =3D=3D NULL))<br>
=A0=A0=A0=A0 =A0=A0=A0 goto out;=A0 /* no buffer, so can&#39;t compress */<=
br>=A0=A0=A0=A0 from_va =3D kmap_atomic(from, KM_USER0);<br>@@ -1533,7 +153=
2,6 @@ static int zcache_put_page(int cli_id, i<br>=A0=A0=A0=A0 struct tmem=
_pool *pool;<br>=A0=A0=A0=A0 int ret =3D -1;<br>
=A0<br>-=A0=A0=A0 BUG_ON(!irqs_disabled());<br>=A0=A0=A0=A0 pool =3D zcache=
_get_pool_by_id(cli_id, pool_id);<br>=A0=A0=A0=A0 if (unlikely(pool =3D=3D =
NULL))<br>=A0=A0=A0=A0 =A0=A0=A0 goto out;<br>@@ -1898,6 +1896,67 @@ struct=
 frontswap_ops zcache_frontswap_re<br>=A0#endif<br>
=A0<br>=A0/*<br>+ * tmem op to support tmem in kvm guests<br>+ */<br>+<br>+=
int kvm_pv_tmem_op(struct kvm_vcpu *vcpu, gpa_t addr, unsigned long *ret)<b=
r>+{<br>+=A0=A0=A0 struct tmem_op op;<br>+=A0=A0=A0 struct tmem_oid oid;<br=
>+=A0=A0=A0 uint64_t pfn;<br>
+=A0=A0=A0 struct page *page;<br>+=A0=A0=A0 int r;<br>+<br>+=A0=A0=A0 r =3D=
 kvm_read_guest(vcpu-&gt;kvm, addr, &amp;op, sizeof(op));<br>+=A0=A0=A0 if =
(r &lt; 0)<br>+=A0=A0=A0 =A0=A0=A0 return r;<br>+<br>+=A0=A0=A0 switch (op.=
cmd) {<br>+=A0=A0=A0 case TMEM_NEW_POOL:<br>+=A0=A0=A0 =A0=A0=A0 *ret =3D z=
cache_new_pool(op.u.new.cli_id, op.u.new.flags);<br>
+=A0=A0=A0 =A0=A0=A0 break;<br>+=A0=A0=A0 case TMEM_DESTROY_POOL:<br>+=A0=
=A0=A0 =A0=A0=A0 *ret =3D zcache_destroy_pool(op.u.gen.cli_id, op.pool_id);=
<br>+=A0=A0=A0 =A0=A0=A0 break;<br>+=A0=A0=A0 case TMEM_NEW_PAGE:<br>+=A0=
=A0=A0 =A0=A0=A0 break;<br>+=A0=A0=A0 case TMEM_PUT_PAGE:<br>+=A0=A0=A0 =A0=
=A0=A0 pfn =3D gfn_to_pfn(vcpu-&gt;kvm, op.u.gen.pfn);<br>
+=A0=A0=A0 =A0=A0=A0 page =3D pfn_to_page(pfn);<br>+=A0=A0=A0 =A0=A0=A0 oid=
.oid[0] =3D op.u.gen.oid[0];<br>+=A0=A0=A0 =A0=A0=A0 oid.oid[1] =3D op.u.ge=
n.oid[1];<br>+=A0=A0=A0 =A0=A0=A0 oid.oid[2] =3D op.u.gen.oid[2];<br>+=A0=
=A0=A0 =A0=A0=A0 VM_BUG_ON(!PageLocked(page));<br>+=A0=A0=A0 =A0=A0=A0 *ret=
 =3D zcache_put_page(op.u.gen.cli_id, op.pool_id,<br>
+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 &amp;oid, op.u.gen.index, page);<b=
r>+=A0=A0=A0 =A0=A0=A0 break;<br>+=A0=A0=A0 case TMEM_GET_PAGE:<br>+=A0=A0=
=A0 =A0=A0=A0 pfn =3D gfn_to_pfn(vcpu-&gt;kvm, op.u.gen.pfn);<br>+=A0=A0=A0=
 =A0=A0=A0 page =3D pfn_to_page(pfn);<br>+=A0=A0=A0 =A0=A0=A0 oid.oid[0] =
=3D op.u.gen.oid[0];<br>
+=A0=A0=A0 =A0=A0=A0 oid.oid[1] =3D op.u.gen.oid[1];<br>+=A0=A0=A0 =A0=A0=
=A0 oid.oid[2] =3D op.u.gen.oid[2];<br>+=A0=A0=A0 =A0=A0=A0 *ret =3D zcache=
_get_page(TMEM_CLI, op.pool_id,<br>+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0=
 &amp;oid, op.u.gen.index, page);<br>+=A0=A0=A0 =A0=A0=A0 break;<br>+=A0=A0=
=A0 case TMEM_FLUSH_PAGE:<br>
+=A0=A0=A0 =A0=A0=A0 oid.oid[0] =3D op.u.gen.oid[0];<br>+=A0=A0=A0 =A0=A0=
=A0 oid.oid[1] =3D op.u.gen.oid[1];<br>+=A0=A0=A0 =A0=A0=A0 oid.oid[2] =3D =
op.u.gen.oid[2];<br>+=A0=A0=A0 =A0=A0=A0 *ret =3D zcache_flush_page(op.u.ge=
n.cli_id, op.pool_id,<br>+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 &amp;oid,=
 op.u.gen.index);<br>
+=A0=A0=A0 =A0=A0=A0 break;<br>+=A0=A0=A0 case TMEM_FLUSH_OBJECT:<br>+=A0=
=A0=A0 =A0=A0=A0 oid.oid[0] =3D op.u.gen.oid[0];<br>+=A0=A0=A0 =A0=A0=A0 oi=
d.oid[1] =3D op.u.gen.oid[1];<br>+=A0=A0=A0 =A0=A0=A0 oid.oid[2] =3D op.u.g=
en.oid[2];<br>+=A0=A0=A0 =A0=A0=A0 *ret =3D zcache_flush_object(op.u.gen.cl=
i_id, op.pool_id, &amp;oid);<br>
+=A0=A0=A0 =A0=A0=A0 break;<br>+=A0=A0=A0 }<br>+=A0=A0=A0 return 0;<br>+}<b=
r>+<br>+/*<br>=A0 * zcache initialization<br>=A0 * NOTE FOR NOW zcache MUST=
 BE PROVIDED AS A KERNEL BOOT PARAMETER OR<br>=A0 * NOTHING HAPPENS!<br>@@ =
-1934,10 +1993,19 @@ static int __init no_frontswap(char *s)<br>
=A0<br>=A0__setup(&quot;nofrontswap&quot;, no_frontswap);<br>=A0<br>+static=
 int kvm_tmem_enabled =3D 0;<br>+<br>+static int __init enable_kvm_tmem(cha=
r *s)<br>+{<br>+=A0=A0=A0 kvm_tmem_enabled =3D 1;<br>+=A0=A0=A0 return 1;<b=
r>+}<br>+<br>+__setup(&quot;kvmtmem&quot;, enable_kvm_tmem);<br>
+<br>=A0static int __init zcache_init(void)<br>=A0{<br>=A0=A0=A0=A0 int ret=
 =3D 0;<br>-<br>=A0#ifdef CONFIG_SYSFS<br>=A0=A0=A0=A0 ret =3D sysfs_create=
_group(mm_kobj, &amp;zcache_attr_group);<br>=A0=A0=A0=A0 if (ret) {<br>@@ -=
1946,7 +2014,7 @@ static int __init zcache_init(void)<br>
=A0=A0=A0=A0 }<br>=A0#endif /* CONFIG_SYSFS */<br>=A0#if defined(CONFIG_CLE=
ANCACHE) || defined(CONFIG_FRONTSWAP)<br>-=A0=A0=A0 if (zcache_enabled) {<b=
r>+=A0=A0=A0 if (zcache_enabled || kvm_tmem_enabled) {<br>=A0=A0=A0=A0 =A0=
=A0=A0 unsigned int cpu;<br>=A0<br>=A0=A0=A0=A0 =A0=A0=A0 tmem_register_hos=
tops(&amp;zcache_hostops);<br>
@@ -1966,11 +2034,25 @@ static int __init zcache_init(void)<br>=A0=A0=A0=A0=
 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 sizeof(struct tmem_objnode), 0, 0, NULL);<br=
>=A0=A0=A0=A0 zcache_obj_cache =3D kmem_cache_create(&quot;zcache_obj&quot;=
,<br>=A0=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 sizeof(struct tmem_obj), 0,=
 0, NULL);<br>
-=A0=A0=A0 ret =3D zcache_new_client(LOCAL_CLIENT);<br>-=A0=A0=A0 if (ret) =
{<br>-=A0=A0=A0 =A0=A0=A0 pr_err(&quot;zcache: can&#39;t create client\n&qu=
ot;);<br>+=A0=A0=A0 if(kvm_tmem_enabled) {<br>+=A0=A0=A0 =A0=A0=A0 ret =3D =
zcache_new_client(TMEM_CLI);<br>+=A0=A0=A0 =A0=A0=A0 if(ret) {<br>
+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 pr_err(&quot;zcache: can&#39;t create client=
\n&quot;);<br>+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 goto out;<br>+=A0=A0=A0 =A0=A0=
=A0 }<br>+=A0=A0=A0 =A0=A0=A0 zbud_init();<br>+=A0=A0=A0 =A0=A0=A0 register=
_shrinker(&amp;zcache_shrinker);<br>+=A0=A0=A0 =A0=A0=A0 pr_info(&quot;zcac=
he: transcendent memory enabled using kernel &quot;<br>
+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 &quot;for kvm guests\n&quot;);<br>=A0=A0=A0=
=A0 =A0=A0=A0 goto out;<br>=A0=A0=A0=A0 }<br>+=A0=A0=A0 else {<br>+=A0=A0=
=A0 =A0=A0=A0 ret =3D zcache_new_client(LOCAL_CLIENT);<br>+=A0=A0=A0 =A0=A0=
=A0 if (ret) {<br>+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 pr_err(&quot;zcache: can&#=
39;t create client\n&quot;);<br>
+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 goto out;<br>+=A0=A0=A0 =A0=A0=A0 }<br>+=A0=
=A0=A0 }<br>=A0#endif<br>=A0#ifdef CONFIG_CLEANCACHE<br>=A0=A0=A0=A0 if (zc=
ache_enabled &amp;&amp; use_cleancache) {<br>

--00504502dabf7081d204ba7bd2a3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
