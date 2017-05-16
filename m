Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2ACEE6B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 12:16:10 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v195so65266105qka.1
        for <linux-mm@kvack.org>; Tue, 16 May 2017 09:16:10 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id m2si2338606qkc.8.2017.05.16.09.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 09:16:08 -0700 (PDT)
Received: from mr1.cc.vt.edu (mr1.cc.ipv6.vt.edu [IPv6:2607:b400:92:8300:0:31:1732:8aa4])
	by omr2.cc.vt.edu (8.14.4/8.14.4) with ESMTP id v4GGG7QI030366
	for <linux-mm@kvack.org>; Tue, 16 May 2017 12:16:07 -0400
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by mr1.cc.vt.edu (8.14.7/8.14.7) with ESMTP id v4GGG2jv005093
	for <linux-mm@kvack.org>; Tue, 16 May 2017 12:16:07 -0400
Received: by mail-vk0-f69.google.com with SMTP id y190so37371500vkc.12
        for <linux-mm@kvack.org>; Tue, 16 May 2017 09:16:07 -0700 (PDT)
MIME-Version: 1.0
From: Sarunya Pumma <sarunya@vt.edu>
Date: Tue, 16 May 2017 12:16:00 -0400
Message-ID: <CAC2c7Jts5uZOLXVi9N7xYXxxycv9xM1TBxcC3nMyn0NL-O+spw@mail.gmail.com>
Subject: [PATCH] Patch for remapping pages around the fault page
Content-Type: multipart/alternative; boundary="001a1143a92ad0e36d054fa67ca3"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com, lstoakes@gmail.com, dave.jiang@intel.com
Cc: linux-mm@kvack.org

--001a1143a92ad0e36d054fa67ca3
Content-Type: text/plain; charset="UTF-8"

After the fault handler performs the __do_fault function to read a fault
page when a page fault occurs, it does not map other pages that have been
read together with the fault page. This can cause a number of minor page
faults to be large. Therefore, this patch is developed to remap pages
around the fault page by aiming to map the pages that have been read
with the fault page.

The major function of this patch is the redo_fault_around function. This
function computes the start and end offsets of the pages to be mapped,
determines whether to do the page remapping, remaps pages using the
map_pages function, and returns. In the redo_fault_around function, the
start and end offsets are computed the same way as the do_fault_around
function. To determine whether to do the remapping, we determine if the
pages around the fault page are already mapped. If they are, the remapping
will not be performed.

As checking every page can be inefficient if a number of pages to be mapped
is large, we have added a threshold called "vm_nr_rempping" to consider
whether to check the status of every page around the fault page or just
some pages. Note that the vm_nr_rempping parameter can be adjusted via the
Sysctl interface. In the case that a number of pages to be mapped is
smaller than the vm_nr_rempping threshold, we check all pages around the
fault page (within the start and end offsets). Otherwise, we check only the
adjacent pages (left and right).

The page remapping is beneficial when performing the "almost sequential"
page accesses, where pages are accessed in order but some pages are
skipped.

The following is one example scenario that we can reduce one page fault
every 16 page:

Assume that we want to access pages sequentially and skip every page that
marked as PG_readahead. Assume that the read-ahead size is 32 pages and the
number of pages to be mapped each time (fault_around_pages) is 16.

When accessing a page at offset 0, a major page fault occurs, so pages from
page 0 to page 31 is read from the disk to the page cache. With this, page
24 is marked as a read-ahead page (PG_readahead). Then only page 0 is
mapped to the virtual memory space.

When accessing a page at offset 1, a minor page fault occurs, pages from
page 0 to page 15 will be mapped.

We keep accessing pages until page 31. Note that we skip page 24.

When accessing a page at offset 32, a major page fault occurs.  The same
process will be repeated. The other 32 pages will be read from the disk.
Only page 32 is mapped. Then a minor page fault at the next page (page
33) will occur.

>From this example, two page faults occur every 16 page. With this patch, we
can eliminate the minor page fault in every 16 page.

Thank you very much for your time for reviewing the patch.

Signed-off-by: Sarunya Pumma <sarunya@vt.edu>
---
 include/linux/mm.h |  2 ++
 kernel/sysctl.c    |  8 +++++
 mm/memory.c        | 90
++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 100 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7cb17c6..2d533a3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -34,6 +34,8 @@ struct bdi_writeback;

 void init_mm_internals(void);

+extern unsigned long vm_nr_remapping;
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES /* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 4dfba1a..16c7efe 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1332,6 +1332,14 @@ static struct ctl_table vm_table[] = {
  .extra1 = &zero,
  .extra2 = &one_hundred,
  },
+ {
+ .procname = "nr_remapping",
+ .data = &vm_nr_remapping,
+ .maxlen = sizeof(vm_nr_remapping),
+ .mode = 0644,
+ .proc_handler = proc_doulongvec_minmax,
+ .extra1 = &zero,
+ },
 #ifdef CONFIG_HUGETLB_PAGE
  {
  .procname = "nr_hugepages",
diff --git a/mm/memory.c b/mm/memory.c
index 6ff5d72..3d0dca9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -83,6 +83,9 @@
 #warning Unfortunate NUMA and NUMA Balancing config, growing page-frame
for last_cpupid.
 #endif

+/* A preset threshold for considering page remapping */
+unsigned long vm_nr_remapping = 32;
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
@@ -3374,6 +3377,82 @@ static int do_fault_around(struct vm_fault *vmf)
  return ret;
 }

+static int redo_fault_around(struct vm_fault *vmf)
+{
+ unsigned long address = vmf->address, nr_pages, mask;
+ pgoff_t start_pgoff = vmf->pgoff;
+ pgoff_t end_pgoff;
+ pte_t *lpte, *rpte;
+ int off, ret = 0, is_mapped = 0;
+
+ nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
+ mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
+
+ vmf->address = max(address & mask, vmf->vma->vm_start);
+ off = ((address - vmf->address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
+ start_pgoff -= off;
+
+ /*
+ *  end_pgoff is either end of page table or end of vma
+ *  or fault_around_pages() from start_pgoff, depending what is nearest.
+ */
+ end_pgoff = start_pgoff -
+ ((vmf->address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
+ PTRS_PER_PTE - 1;
+ end_pgoff = min3(end_pgoff, vma_pages(vmf->vma) + vmf->vma->vm_pgoff - 1,
+ start_pgoff + nr_pages - 1);
+
+ if (nr_pages < vm_nr_remapping) {
+ int i, start_off = 0, end_off = 0;
+
+ lpte = vmf->pte - off;
+ for (i = 0; i < nr_pages; i++) {
+ if (!pte_none(*lpte)) {
+ is_mapped++;
+ } else {
+ if (!start_off)
+ start_off = i;
+ end_off = i;
+ }
+ lpte++;
+ }
+ if (is_mapped != nr_pages) {
+ is_mapped = 0;
+ end_pgoff = start_pgoff + end_off;
+ start_pgoff += start_off;
+ vmf->pte += start_off;
+ }
+ lpte = NULL;
+ } else {
+ lpte = vmf->pte - 1;
+ rpte = vmf->pte + 1;
+ if (!pte_none(*lpte) && !pte_none(*rpte))
+ is_mapped = 1;
+ lpte = NULL;
+ rpte = NULL;
+ }
+
+ if (!is_mapped) {
+ vmf->pte -= off;
+ vmf->vma->vm_ops->map_pages(vmf, start_pgoff, end_pgoff);
+ vmf->pte -= (vmf->address >> PAGE_SHIFT) - (address >> PAGE_SHIFT);
+ }
+
+ /* Huge page is mapped? Page fault is solved */
+ if (pmd_trans_huge(*vmf->pmd)) {
+ ret = VM_FAULT_NOPAGE;
+ goto out;
+ }
+
+ if (vmf->pte)
+ pte_unmap_unlock(vmf->pte, vmf->ptl);
+
+out:
+ vmf->address = address;
+ vmf->pte = NULL;
+ return ret;
+}
+
 static int do_read_fault(struct vm_fault *vmf)
 {
  struct vm_area_struct *vma = vmf->vma;
@@ -3394,6 +3473,17 @@ static int do_read_fault(struct vm_fault *vmf)
  if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
  return ret;

+ /*
+ * Remap pages after read
+ */
+ if (!(vma->vm_flags & VM_RAND_READ) && vma->vm_ops->map_pages
+ && fault_around_bytes >> PAGE_SHIFT > 1) {
+ ret |= alloc_set_pte(vmf, vmf->memcg, vmf->page);
+ unlock_page(vmf->page);
+ redo_fault_around(vmf);
+ return ret;
+ }
+
  ret |= finish_fault(vmf);
  unlock_page(vmf->page);
  if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
-- 
2.7.4

--001a1143a92ad0e36d054fa67ca3
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>After the fault handler performs the __do_fault funct=
ion to read a fault<br></div><div><div>page when a page fault occurs, it do=
es not map other pages that have been</div><div>read together with the faul=
t page. This can cause a number of minor page</div><div>faults to be large.=
 Therefore, this patch is developed to remap pages</div><div>around the fau=
lt page by aiming to map the pages that have been read</div><div>with the f=
ault page.</div><div><br></div><div>The major function of this patch is the=
 redo_fault_around function. This</div><div>function computes the start and=
 end offsets of the pages to be mapped,</div><div>determines whether to do =
the page remapping, remaps pages using the</div><div>map_pages function, an=
d returns. In the redo_fault_around function, the</div><div>start and end o=
ffsets are computed the same way as the do_fault_around</div><div>function.=
 To determine whether to do the remapping, we determine if the</div><div>pa=
ges around the fault page are already mapped. If they are, the remapping</d=
iv><div>will not be performed.=C2=A0</div><div><br></div><div>As checking e=
very page can be inefficient if a number of pages to be mapped</div><div>is=
 large, we have added a threshold called &quot;vm_nr_rempping&quot; to cons=
ider</div><div>whether to check the status of every page around the fault p=
age or just</div><div>some pages. Note that the vm_nr_rempping parameter ca=
n be adjusted via the</div><div>Sysctl interface. In the case that a number=
 of pages to be mapped is</div><div>smaller than the vm_nr_rempping thresho=
ld, we check all pages around the</div><div>fault page (within the start an=
d end offsets). Otherwise, we check only the</div><div>adjacent pages (left=
 and right).=C2=A0</div><div><br></div><div>The page remapping is beneficia=
l when performing the &quot;almost sequential&quot;</div><div>page accesses=
, where pages are accessed in order but some pages are</div><div>skipped.</=
div><div><br></div><div>The following is one example scenario that we can r=
educe one page fault</div><div>every 16 page:</div><div><br></div><div>Assu=
me that we want to access pages sequentially and skip every page that</div>=
<div>marked as PG_readahead. Assume that the read-ahead size is 32 pages an=
d the</div><div>number of pages to be mapped each time (fault_around_pages)=
 is 16.</div><div><br></div><div>When accessing a page at offset 0, a major=
 page fault occurs, so pages from</div><div>page 0 to page 31 is read from =
the disk to the page cache. With this, page</div><div>24 is marked as a rea=
d-ahead page (PG_readahead). Then only page 0 is</div><div>mapped to the vi=
rtual memory space.</div><div><br></div><div>When accessing a page at offse=
t 1, a minor page fault occurs, pages from</div><div>page 0 to page 15 will=
 be mapped.=C2=A0</div><div><br></div><div>We keep accessing pages until pa=
ge 31. Note that we skip page 24.</div><div><br></div><div>When accessing a=
 page at offset 32, a major page fault occurs.=C2=A0 The same</div><div>pro=
cess will be repeated. The other 32 pages will be read from the disk.</div>=
<div>Only page 32 is mapped. Then a minor page fault at the next page (page=
</div><div>33) will occur.=C2=A0</div><div><br></div><div>From this example=
, two page faults occur every 16 page. With this patch, we=C2=A0</div><div>=
can eliminate the minor page fault in every 16 page.=C2=A0</div><div><br></=
div><div>Thank you very much for your time for reviewing the patch.</div></=
div><div><br></div><div><div>Signed-off-by: Sarunya Pumma &lt;<a href=3D"ma=
ilto:sarunya@vt.edu">sarunya@vt.edu</a>&gt;</div><div>---</div><div>=C2=A0i=
nclude/linux/mm.h | =C2=A02 ++</div><div>=C2=A0kernel/sysctl.c =C2=A0 =C2=
=A0| =C2=A08 +++++</div><div>=C2=A0mm/memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
 90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++</div><div>=C2=A0=
3 files changed, 100 insertions(+)</div><div><br></div><div>diff --git a/in=
clude/linux/mm.h b/include/linux/mm.h</div><div>index 7cb17c6..2d533a3 1006=
44</div><div>--- a/include/linux/mm.h</div><div>+++ b/include/linux/mm.h</d=
iv><div>@@ -34,6 +34,8 @@ struct bdi_writeback;</div><div>=C2=A0</div><div>=
=C2=A0void init_mm_internals(void);</div><div>=C2=A0</div><div>+extern unsi=
gned long vm_nr_remapping;</div><div>+</div><div>=C2=A0#ifndef CONFIG_NEED_=
MULTIPLE_NODES<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre=
">	</span>/* Don&#39;t use mapnrs, do it properly */</div><div>=C2=A0extern=
 unsigned long max_mapnr;</div><div>=C2=A0</div><div>diff --git a/kernel/sy=
sctl.c b/kernel/sysctl.c</div><div>index 4dfba1a..16c7efe 100644</div><div>=
--- a/kernel/sysctl.c</div><div>+++ b/kernel/sysctl.c</div><div>@@ -1332,6 =
+1332,14 @@ static struct ctl_table vm_table[] =3D {</div><div>=C2=A0<span =
class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span>.extra1<s=
pan class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span>=3D &=
amp;zero,</div><div>=C2=A0<span class=3D"gmail-Apple-tab-span" style=3D"whi=
te-space:pre">		</span>.extra2<span class=3D"gmail-Apple-tab-span" style=3D=
"white-space:pre">		</span>=3D &amp;one_hundred,</div><div>=C2=A0<span clas=
s=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>},</div><div>+=
<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>{</d=
iv><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		<=
/span>.procname<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pr=
e">	</span>=3D &quot;nr_remapping&quot;,</div><div>+<span class=3D"gmail-Ap=
ple-tab-span" style=3D"white-space:pre">		</span>.data<span class=3D"gmail-=
Apple-tab-span" style=3D"white-space:pre">		</span>=3D &amp;vm_nr_remapping=
,</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre"=
>		</span>.maxlen<span class=3D"gmail-Apple-tab-span" style=3D"white-space:=
pre">		</span>=3D sizeof(vm_nr_remapping),</div><div>+<span class=3D"gmail-=
Apple-tab-span" style=3D"white-space:pre">		</span>.mode<span class=3D"gmai=
l-Apple-tab-span" style=3D"white-space:pre">		</span>=3D 0644,</div><div>+<=
span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span>.pro=
c_handler<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</=
span>=3D proc_doulongvec_minmax,</div><div>+<span class=3D"gmail-Apple-tab-=
span" style=3D"white-space:pre">		</span>.extra1<span class=3D"gmail-Apple-=
tab-span" style=3D"white-space:pre">		</span>=3D &amp;zero,</div><div>+<spa=
n class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>},</div>=
<div>=C2=A0#ifdef CONFIG_HUGETLB_PAGE</div><div>=C2=A0<span class=3D"gmail-=
Apple-tab-span" style=3D"white-space:pre">	</span>{</div><div>=C2=A0<span c=
lass=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span>.procname<=
span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>=3D &=
quot;nr_hugepages&quot;,</div><div>diff --git a/mm/memory.c b/mm/memory.c</=
div><div>index 6ff5d72..3d0dca9 100644</div><div>--- a/mm/memory.c</div><di=
v>+++ b/mm/memory.c</div><div>@@ -83,6 +83,9 @@</div><div>=C2=A0#warning Un=
fortunate NUMA and NUMA Balancing config, growing page-frame for last_cpupi=
d.</div><div>=C2=A0#endif</div><div>=C2=A0</div><div>+/* A preset threshold=
 for considering page remapping */</div><div>+unsigned long vm_nr_remapping=
 =3D 32;</div><div>+</div><div>=C2=A0#ifndef CONFIG_NEED_MULTIPLE_NODES</di=
v><div>=C2=A0/* use the per-pgdat data instead for discontigmem - mbligh */=
</div><div>=C2=A0unsigned long max_mapnr;</div><div>@@ -3374,6 +3377,82 @@ =
static int do_fault_around(struct vm_fault *vmf)</div><div>=C2=A0<span clas=
s=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>return ret;</d=
iv><div>=C2=A0}</div><div>=C2=A0</div><div>+static int redo_fault_around(st=
ruct vm_fault *vmf)</div><div>+{</div><div>+<span class=3D"gmail-Apple-tab-=
span" style=3D"white-space:pre">	</span>unsigned long address =3D vmf-&gt;a=
ddress, nr_pages, mask;</div><div>+<span class=3D"gmail-Apple-tab-span" sty=
le=3D"white-space:pre">	</span>pgoff_t start_pgoff =3D vmf-&gt;pgoff;</div>=
<div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</spa=
n>pgoff_t end_pgoff;</div><div>+<span class=3D"gmail-Apple-tab-span" style=
=3D"white-space:pre">	</span>pte_t *lpte, *rpte;</div><div>+<span class=3D"=
gmail-Apple-tab-span" style=3D"white-space:pre">	</span>int off, ret =3D 0,=
 is_mapped =3D 0;</div><div>+</div><div>+<span class=3D"gmail-Apple-tab-spa=
n" style=3D"white-space:pre">	</span>nr_pages =3D READ_ONCE(fault_around_by=
tes) &gt;&gt; PAGE_SHIFT;</div><div>+<span class=3D"gmail-Apple-tab-span" s=
tyle=3D"white-space:pre">	</span>mask =3D ~(nr_pages * PAGE_SIZE - 1) &amp;=
 PAGE_MASK;</div><div>+</div><div>+<span class=3D"gmail-Apple-tab-span" sty=
le=3D"white-space:pre">	</span>vmf-&gt;address =3D max(address &amp; mask, =
vmf-&gt;vma-&gt;vm_start);</div><div>+<span class=3D"gmail-Apple-tab-span" =
style=3D"white-space:pre">	</span>off =3D ((address - vmf-&gt;address) &gt;=
&gt; PAGE_SHIFT) &amp; (PTRS_PER_PTE - 1);</div><div>+<span class=3D"gmail-=
Apple-tab-span" style=3D"white-space:pre">	</span>start_pgoff -=3D off;</di=
v><div>+</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-spa=
ce:pre">	</span>/*</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D=
"white-space:pre">	</span> * =C2=A0end_pgoff is either end of page table or=
 end of vma</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-=
space:pre">	</span> * =C2=A0or fault_around_pages() from start_pgoff, depen=
ding what is nearest.</div><div>+<span class=3D"gmail-Apple-tab-span" style=
=3D"white-space:pre">	</span> */</div><div>+<span class=3D"gmail-Apple-tab-=
span" style=3D"white-space:pre">	</span>end_pgoff =3D start_pgoff -</div><d=
iv>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span=
>((vmf-&gt;address &gt;&gt; PAGE_SHIFT) &amp; (PTRS_PER_PTE - 1)) +</div><d=
iv>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span=
>PTRS_PER_PTE - 1;</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D=
"white-space:pre">	</span>end_pgoff =3D min3(end_pgoff, vma_pages(vmf-&gt;v=
ma) + vmf-&gt;vma-&gt;vm_pgoff - 1,</div><div>+<span class=3D"gmail-Apple-t=
ab-span" style=3D"white-space:pre">			</span>start_pgoff + nr_pages - 1);</=
div><div>+</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-s=
pace:pre">	</span>if (nr_pages &lt; vm_nr_remapping) {</div><div>+<span cla=
ss=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span>int i, start=
_off =3D 0, end_off =3D 0;</div><div>+</div><div>+<span class=3D"gmail-Appl=
e-tab-span" style=3D"white-space:pre">		</span>lpte =3D vmf-&gt;pte - off;<=
/div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	=
	</span>for (i =3D 0; i &lt; nr_pages; i++) {</div><div>+<span class=3D"gma=
il-Apple-tab-span" style=3D"white-space:pre">			</span>if (!pte_none(*lpte)=
) {</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pr=
e">				</span>is_mapped++;</div><div>+<span class=3D"gmail-Apple-tab-span" =
style=3D"white-space:pre">			</span>} else {</div><div>+<span class=3D"gmai=
l-Apple-tab-span" style=3D"white-space:pre">				</span>if (!start_off)</div=
><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">					=
</span>start_off =3D i;</div><div>+<span class=3D"gmail-Apple-tab-span" sty=
le=3D"white-space:pre">				</span>end_off =3D i;</div><div>+<span class=3D"=
gmail-Apple-tab-span" style=3D"white-space:pre">			</span>}</div><div>+<spa=
n class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">			</span>lpte++=
;</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre"=
>		</span>}</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-=
space:pre">		</span>if (is_mapped !=3D nr_pages) {</div><div>+<span class=
=3D"gmail-Apple-tab-span" style=3D"white-space:pre">			</span>is_mapped =3D=
 0;</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pr=
e">			</span>end_pgoff =3D start_pgoff + end_off;</div><div>+<span class=3D=
"gmail-Apple-tab-span" style=3D"white-space:pre">			</span>start_pgoff +=3D=
 start_off;</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-=
space:pre">			</span>vmf-&gt;pte +=3D start_off;</div><div>+<span class=3D"=
gmail-Apple-tab-span" style=3D"white-space:pre">		</span>}</div><div>+<span=
 class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span>lpte =3D=
 NULL;</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space=
:pre">	</span>} else {</div><div>+<span class=3D"gmail-Apple-tab-span" styl=
e=3D"white-space:pre">		</span>lpte =3D vmf-&gt;pte - 1;</div><div>+<span c=
lass=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span>rpte =3D v=
mf-&gt;pte + 1;</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"wh=
ite-space:pre">		</span>if (!pte_none(*lpte) &amp;&amp; !pte_none(*rpte))</=
div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		=
	</span>is_mapped =3D 1;</div><div>+<span class=3D"gmail-Apple-tab-span" st=
yle=3D"white-space:pre">		</span>lpte =3D NULL;</div><div>+<span class=3D"g=
mail-Apple-tab-span" style=3D"white-space:pre">		</span>rpte =3D NULL;</div=
><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</sp=
an>}</div><div>+</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"w=
hite-space:pre">	</span>if (!is_mapped) {</div><div>+<span class=3D"gmail-A=
pple-tab-span" style=3D"white-space:pre">		</span>vmf-&gt;pte -=3D off;</di=
v><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</=
span>vmf-&gt;vma-&gt;vm_ops-&gt;map_pages(vmf, start_pgoff, end_pgoff);</di=
v><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</=
span>vmf-&gt;pte -=3D (vmf-&gt;address &gt;&gt; PAGE_SHIFT) - (address &gt;=
&gt; PAGE_SHIFT);</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"=
white-space:pre">	</span>}</div><div>+</div><div>+<span class=3D"gmail-Appl=
e-tab-span" style=3D"white-space:pre">	</span>/* Huge page is mapped? Page =
fault is solved */</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D=
"white-space:pre">	</span>if (pmd_trans_huge(*vmf-&gt;pmd)) {</div><div>+<s=
pan class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span>ret =
=3D VM_FAULT_NOPAGE;</div><div>+<span class=3D"gmail-Apple-tab-span" style=
=3D"white-space:pre">		</span>goto out;</div><div>+<span class=3D"gmail-App=
le-tab-span" style=3D"white-space:pre">	</span>}</div><div>+</div><div>+<sp=
an class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>if (vmf=
-&gt;pte)</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-sp=
ace:pre">		</span>pte_unmap_unlock(vmf-&gt;pte, vmf-&gt;ptl);</div><div>+</=
div><div>+out:</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"whi=
te-space:pre">	</span>vmf-&gt;address =3D address;</div><div>+<span class=
=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>vmf-&gt;pte =3D=
 NULL;</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space=
:pre">	</span>return ret;</div><div>+}</div><div>+</div><div>=C2=A0static i=
nt do_read_fault(struct vm_fault *vmf)</div><div>=C2=A0{</div><div>=C2=A0<s=
pan class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>struct=
 vm_area_struct *vma =3D vmf-&gt;vma;</div><div>@@ -3394,6 +3473,17 @@ stat=
ic int do_read_fault(struct vm_fault *vmf)</div><div>=C2=A0<span class=3D"g=
mail-Apple-tab-span" style=3D"white-space:pre">	</span>if (unlikely(ret &am=
p; (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))</div><div>=C2=A0<s=
pan class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</span>retur=
n ret;</div><div>=C2=A0</div><div>+<span class=3D"gmail-Apple-tab-span" sty=
le=3D"white-space:pre">	</span>/*</div><div>+<span class=3D"gmail-Apple-tab=
-span" style=3D"white-space:pre">	</span> * Remap pages after read</div><di=
v>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span> =
*/</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre=
">	</span>if (!(vma-&gt;vm_flags &amp; VM_RAND_READ) &amp;&amp; vma-&gt;vm_=
ops-&gt;map_pages</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"=
white-space:pre">			</span>&amp;&amp; fault_around_bytes &gt;&gt; PAGE_SHIF=
T &gt; 1) {</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-=
space:pre">		</span>ret |=3D alloc_set_pte(vmf, vmf-&gt;memcg, vmf-&gt;page=
);</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre=
">		</span>unlock_page(vmf-&gt;page);</div><div>+<span class=3D"gmail-Apple=
-tab-span" style=3D"white-space:pre">		</span>redo_fault_around(vmf);</div>=
<div>+<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">		</sp=
an>return ret;</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D"whi=
te-space:pre">	</span>}</div><div>+</div><div>=C2=A0<span class=3D"gmail-Ap=
ple-tab-span" style=3D"white-space:pre">	</span>ret |=3D finish_fault(vmf);=
</div><div>=C2=A0<span class=3D"gmail-Apple-tab-span" style=3D"white-space:=
pre">	</span>unlock_page(vmf-&gt;page);</div><div>=C2=A0<span class=3D"gmai=
l-Apple-tab-span" style=3D"white-space:pre">	</span>if (unlikely(ret &amp; =
(VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))</div><div>--=C2=A0</d=
iv><div>2.7.4</div></div><div><br></div></div>

--001a1143a92ad0e36d054fa67ca3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
