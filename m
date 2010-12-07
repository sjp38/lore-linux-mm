Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 869756B008C
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 00:44:34 -0500 (EST)
Received: by iwn5 with SMTP id 5so648892iwn.14
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 21:44:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1012062027100.8572@tigran.mtv.corp.google.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<ca25c4e33beceeb3a96e8437671e5e0a188602fa.1291568905.git.minchan.kim@gmail.com>
	<alpine.LSU.2.00.1012062027100.8572@tigran.mtv.corp.google.com>
Date: Tue, 7 Dec 2010 14:44:30 +0900
Message-ID: <AANLkTindkfPJxxjR-nVy+Tmu6Q=fs2c=KOmdOQyfXaCP@mail.gmail.com>
Subject: Re: [PATCH v4 7/7] Prevent activation of page in madvise_dontneed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: multipart/mixed; boundary=002215046dcfa653dd0496cb7f0b
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

--002215046dcfa653dd0496cb7f0b
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 7, 2010 at 1:48 PM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, 6 Dec 2010, Minchan Kim wrote:
>
>> Now zap_pte_range alwayas activates pages which are pte_young &&
>> !VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
>> it's unnecessary since the page wouldn't use any more.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Acked-by: Rik van Riel <riel@redhat.com>
>> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: Hugh Dickins <hughd@google.com>
>>
>> Changelog since v3:
>> =A0- Change variable name - suggested by Johannes
>> =A0- Union ignore_references with zap_details - suggested by Hugh
>>
>> Changelog since v2:
>> =A0- remove unnecessary description
>>
>> Changelog since v1:
>> =A0- change word from promote to activate
>> =A0- add activate argument to zap_pte_range and family function
>> ---
>> =A0include/linux/mm.h | =A0 =A04 +++-
>> =A0mm/madvise.c =A0 =A0 =A0 | =A0 =A06 +++---
>> =A0mm/memory.c =A0 =A0 =A0 =A0| =A0 =A05 ++++-
>> =A03 files changed, 10 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 6522ae4..e57190f 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -771,12 +771,14 @@ struct zap_details {
>> =A0 =A0 =A0 pgoff_t last_index; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
/* Highest page->index to unmap */
>> =A0 =A0 =A0 spinlock_t *i_mmap_lock; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* F=
or unmap_mapping_range: */
>> =A0 =A0 =A0 unsigned long truncate_count; =A0 =A0 =A0 =A0 =A0 /* Compare=
 vm_truncate_count */
>> + =A0 =A0 bool ignore_references; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* For=
 page activation */
>> =A0};
>>
>> =A0#define __ZAP_DETAILS_INITIALIZER(name) \
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ .nonlinear_vma =3D NULL \
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 , .check_mapping =3D NULL \
>> - =A0 =A0 =A0 =A0 =A0 =A0 , .i_mmap_lock =3D NULL }
>> + =A0 =A0 =A0 =A0 =A0 =A0 , .i_mmap_lock =3D NULL =A0 \
>> + =A0 =A0 =A0 =A0 =A0 =A0 , .ignore_references =3D false }
>
> Okay.
>
>>
>> =A0#define DEFINE_ZAP_DETAILS(name) =A0 =A0 =A0 =A0 =A0 =A0 \
>> =A0 =A0 =A0 struct zap_details name =3D __ZAP_DETAILS_INITIALIZER(name)
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index bfa17aa..8e7aba3 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -163,6 +163,7 @@ static long madvise_dontneed(struct vm_area_struct *=
 vma,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long sta=
rt, unsigned long end)
>> =A0{
>> =A0 =A0 =A0 DEFINE_ZAP_DETAILS(details);
>> + =A0 =A0 details.ignore_references =3D true;
>>
>> =A0 =A0 =A0 *prev =3D vma;
>> =A0 =A0 =A0 if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
>> @@ -173,10 +174,9 @@ static long madvise_dontneed(struct vm_area_struct =
* vma,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 details.last_index =3D ULONG_MAX;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 zap_page_range(vma, start, end - start, &det=
ails);
>> - =A0 =A0 } else {
>> -
>> + =A0 =A0 } else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 zap_page_range(vma, start, end - start, &det=
ails);
>> - =A0 =A0 }
>> +
>
> As in the previous patch, you have the same in the if {} and the else.
>
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index c0879bb..44d87e1 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -897,6 +897,7 @@ static unsigned long zap_pte_range(struct mmu_gather=
 *tlb,
>> =A0 =A0 =A0 pte_t *pte;
>> =A0 =A0 =A0 spinlock_t *ptl;
>> =A0 =A0 =A0 int rss[NR_MM_COUNTERS];
>> + =A0 =A0 bool ignore_references =3D details->ignore_references;
>>
>> =A0 =A0 =A0 init_rss_vec(rss);
>>
>> @@ -952,7 +953,8 @@ static unsigned long zap_pte_range(struct mmu_gather=
 *tlb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pte_dirt=
y(ptent))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 set_page_dirty(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pte_youn=
g(ptent) &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 likely=
(!VM_SequentialReadHint(vma)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 likely=
(!VM_SequentialReadHint(vma)) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 !ignore_references)
>
> I think ignore_references is about as likely as VM_SequentialReadHint:
> I'd probably just omit that "likely()" nowadays, but you might prefer
> to put your "|| !ignore_references" inside.
>
> Hmm, actually it would probably be better to say something like
>
> =A0 =A0 =A0 =A0mark_accessed =3D true;
> =A0 =A0 =A0 =A0if (VM_SequentialReadHint(vma) ||
> =A0 =A0 =A0 =A0 =A0 =A0(details && details->ignore_references))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mark_accessed =3D false;
>
> on entry to zap_pte_range().
>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 mark_page_accessed(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rss[MM_FILEP=
AGES]--;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> @@ -1218,6 +1220,7 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsig=
ned long address,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long size)
>> =A0{
>> =A0 =A0 =A0 DEFINE_ZAP_DETAILS(details);
>> + =A0 =A0 details.ignore_references =3D true;
>> =A0 =A0 =A0 if (address < vma->vm_start || address + size > vma->vm_end =
||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(vma->vm_flags & VM_PFNMAP)=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> --
>
> Unnecessary here (would make more sense in the truncation case,
> but not necessary there either): zap_vma_ptes() is only being used on
> GRU's un-cowable VM_PFNMAP area, so vm_normal_page() won't even give
> you a non-NULL page to mark.

Thanks for the notice.

How about this? Although it doesn't remove null dependency, it meet my
goal without big overhead.
It's just quick patch. If you agree, I will resend this version as formal p=
atch.
(If you suffered from seeing below word-wrapped source, see the
attachment. I asked to google two time to support text-plain mode in
gmail web but I can't receive any response until now. ;(. Lots of
kernel developer in google. Please support this mode for us who can't
use SMTP although it's a very small VOC)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e097df6..14ae918 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -771,6 +771,7 @@ struct zap_details {
        pgoff_t last_index;                     /* Highest page->index
to unmap */
        spinlock_t *i_mmap_lock;                /* For unmap_mapping_range:=
 */
        unsigned long truncate_count;           /* Compare vm_truncate_coun=
t */
+       int ignore_reference;
 };

 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr=
,
diff --git a/mm/madvise.c b/mm/madvise.c
index 319528b..fdb0253 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -162,18 +162,22 @@ static long madvise_dontneed(struct vm_area_struct * =
vma,
                             struct vm_area_struct ** prev,
                             unsigned long start, unsigned long end)
 {
+       struct zap_details details ;
+
        *prev =3D vma;
        if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
                return -EINVAL;

        if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
-               struct zap_details details =3D {
-                       .nonlinear_vma =3D vma,
-                       .last_index =3D ULONG_MAX,
-               };
-               zap_page_range(vma, start, end - start, &details);
-       } else
-               zap_page_range(vma, start, end - start, NULL);
+               details.nonlinear_vma =3D vma;
+               details.last_index =3D ULONG_MAX;
+       } else {
+               details.nonlinear_vma =3D NULL;
+               details.last_index =3D NULL;
+       }
+
+       details.ignore_references =3D true;
+       zap_page_range(vma, start, end - start, &details);
        return 0;
 }

diff --git a/mm/memory.c b/mm/memory.c
index ebfeedf..d46ac42 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -897,9 +897,15 @@ static unsigned long zap_pte_range(struct mmu_gather *=
tlb,
        pte_t *pte;
        spinlock_t *ptl;
        int rss[NR_MM_COUNTERS];
-
+       bool ignore_reference =3D false;
        init_rss_vec(rss);

+       if (details && ((!details->check_mapping && !details->nonlinear_vma=
)
+                                        || !details->ignore_reference))
+               details =3D NULL;
+
        pte =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
        arch_enter_lazy_mmu_mode();
        do {
@@ -949,7 +955,8 @@ static unsigned long zap_pte_range(struct mmu_gather *t=
lb,
                                if (pte_dirty(ptent))
                                        set_page_dirty(page);
                                if (pte_young(ptent) &&
-                                   likely(!VM_SequentialReadHint(vma)))
+                                   likely(!VM_SequentialReadHint(vma)) &&
+                                   likely(!ignore_reference))
                                        mark_page_accessed(page);
                                rss[MM_FILEPAGES]--;
                        }
@@ -1038,8 +1045,6 @@ static unsigned long unmap_page_range(struct
mmu_gather *tlb,
        pgd_t *pgd;
        unsigned long next;

-       if (details && !details->check_mapping && !details->nonlinear_vma)
-               details =3D NULL;

        BUG_ON(addr >=3D end);
        mem_cgroup_uncharge_start();
@@ -1102,7 +1107,8 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
        unsigned long tlb_start =3D 0;    /* For tlb_finish_mmu */
        int tlb_start_valid =3D 0;
        unsigned long start =3D start_addr;
-       spinlock_t *i_mmap_lock =3D details? details->i_mmap_lock: NULL;
+       spinlock_t *i_mmap_lock =3D details ?
+               (detais->check_mapping ? details->i_mmap_lock: NULL) : NULL=
;
        int fullmm =3D (*tlbp)->fullmm;
        struct mm_struct *mm =3D vma->vm_mm;



>
> Hugh
>



--=20
Kind regards,
Minchan Kim

--002215046dcfa653dd0496cb7f0b
Content-Type: text/x-diff; charset=US-ASCII; name="madvise.patch"
Content-Disposition: attachment; filename="madvise.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ghecvw3l0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbW0uaCBiL2luY2x1ZGUvbGludXgvbW0uaAppbmRl
eCBlMDk3ZGY2Li4xNGFlOTE4IDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L21tLmgKKysrIGIv
aW5jbHVkZS9saW51eC9tbS5oCkBAIC03NzEsNiArNzcxLDcgQEAgc3RydWN0IHphcF9kZXRhaWxz
IHsKIAlwZ29mZl90IGxhc3RfaW5kZXg7CQkJLyogSGlnaGVzdCBwYWdlLT5pbmRleCB0byB1bm1h
cCAqLwogCXNwaW5sb2NrX3QgKmlfbW1hcF9sb2NrOwkJLyogRm9yIHVubWFwX21hcHBpbmdfcmFu
Z2U6ICovCiAJdW5zaWduZWQgbG9uZyB0cnVuY2F0ZV9jb3VudDsJCS8qIENvbXBhcmUgdm1fdHJ1
bmNhdGVfY291bnQgKi8KKwlpbnQgaWdub3JlX3JlZmVyZW5jZTsKIH07CiAKIHN0cnVjdCBwYWdl
ICp2bV9ub3JtYWxfcGFnZShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwgdW5zaWduZWQgbG9u
ZyBhZGRyLApkaWZmIC0tZ2l0IGEvbW0vbWFkdmlzZS5jIGIvbW0vbWFkdmlzZS5jCmluZGV4IDMx
OTUyOGIuLmZkYjAyNTMgMTAwNjQ0Ci0tLSBhL21tL21hZHZpc2UuYworKysgYi9tbS9tYWR2aXNl
LmMKQEAgLTE2MiwxOCArMTYyLDIyIEBAIHN0YXRpYyBsb25nIG1hZHZpc2VfZG9udG5lZWQoc3Ry
dWN0IHZtX2FyZWFfc3RydWN0ICogdm1hLAogCQkJICAgICBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3Qg
KiogcHJldiwKIAkJCSAgICAgdW5zaWduZWQgbG9uZyBzdGFydCwgdW5zaWduZWQgbG9uZyBlbmQp
CiB7CisJc3RydWN0IHphcF9kZXRhaWxzIGRldGFpbHMgOworCiAJKnByZXYgPSB2bWE7CiAJaWYg
KHZtYS0+dm1fZmxhZ3MgJiAoVk1fTE9DS0VEfFZNX0hVR0VUTEJ8Vk1fUEZOTUFQKSkKIAkJcmV0
dXJuIC1FSU5WQUw7CiAKIAlpZiAodW5saWtlbHkodm1hLT52bV9mbGFncyAmIFZNX05PTkxJTkVB
UikpIHsKLQkJc3RydWN0IHphcF9kZXRhaWxzIGRldGFpbHMgPSB7Ci0JCQkubm9ubGluZWFyX3Zt
YSA9IHZtYSwKLQkJCS5sYXN0X2luZGV4ID0gVUxPTkdfTUFYLAotCQl9OwotCQl6YXBfcGFnZV9y
YW5nZSh2bWEsIHN0YXJ0LCBlbmQgLSBzdGFydCwgJmRldGFpbHMpOwotCX0gZWxzZQotCQl6YXBf
cGFnZV9yYW5nZSh2bWEsIHN0YXJ0LCBlbmQgLSBzdGFydCwgTlVMTCk7CisJCWRldGFpbHMubm9u
bGluZWFyX3ZtYSA9IHZtYTsKKwkJZGV0YWlscy5sYXN0X2luZGV4ID0gVUxPTkdfTUFYOworCX0g
ZWxzZSB7CisJCWRldGFpbHMubm9ubGluZWFyX3ZtYSA9IE5VTEw7CisJCWRldGFpbHMubGFzdF9p
bmRleCA9IE5VTEw7CisJfQorCisJZGV0YWlscy5pZ25vcmVfcmVmZXJlbmNlID0gdHJ1ZTsKKwl6
YXBfcGFnZV9yYW5nZSh2bWEsIHN0YXJ0LCBlbmQgLSBzdGFydCwgJmRldGFpbHMpOwogCXJldHVy
biAwOwogfQogCmRpZmYgLS1naXQgYS9tbS9tZW1vcnkuYyBiL21tL21lbW9yeS5jCmluZGV4IGVi
ZmVlZGYuLjhhYTAxOTAgMTAwNjQ0Ci0tLSBhL21tL21lbW9yeS5jCisrKyBiL21tL21lbW9yeS5j
CkBAIC04OTcsOSArODk3LDEzIEBAIHN0YXRpYyB1bnNpZ25lZCBsb25nIHphcF9wdGVfcmFuZ2Uo
c3RydWN0IG1tdV9nYXRoZXIgKnRsYiwKIAlwdGVfdCAqcHRlOwogCXNwaW5sb2NrX3QgKnB0bDsK
IAlpbnQgcnNzW05SX01NX0NPVU5URVJTXTsKLQorCWJvb2wgaWdub3JlX3JlZmVyZW5jZSA9IGZh
bHNlOwogCWluaXRfcnNzX3ZlYyhyc3MpOwogCisJaWYgKGRldGFpbHMgJiYgKCghZGV0YWlscy0+
Y2hlY2tfbWFwcGluZyAmJiAhZGV0YWlscy0+bm9ubGluZWFyX3ZtYSkKKwkJCQkJIHx8ICFkZXRh
aWxzLT5pZ25vcmVfcmVmZXJlbmNlKSkKKwkJZGV0YWlscyA9IE5VTEw7CisKIAlwdGUgPSBwdGVf
b2Zmc2V0X21hcF9sb2NrKG1tLCBwbWQsIGFkZHIsICZwdGwpOwogCWFyY2hfZW50ZXJfbGF6eV9t
bXVfbW9kZSgpOwogCWRvIHsKQEAgLTk0OSw3ICs5NTMsOCBAQCBzdGF0aWMgdW5zaWduZWQgbG9u
ZyB6YXBfcHRlX3JhbmdlKHN0cnVjdCBtbXVfZ2F0aGVyICp0bGIsCiAJCQkJaWYgKHB0ZV9kaXJ0
eShwdGVudCkpCiAJCQkJCXNldF9wYWdlX2RpcnR5KHBhZ2UpOwogCQkJCWlmIChwdGVfeW91bmco
cHRlbnQpICYmCi0JCQkJICAgIGxpa2VseSghVk1fU2VxdWVudGlhbFJlYWRIaW50KHZtYSkpKQor
CQkJCSAgICBsaWtlbHkoIVZNX1NlcXVlbnRpYWxSZWFkSGludCh2bWEpKSAmJgorCQkJCSAgICBs
aWtlbHkoIWlnbm9yZV9yZWZlcmVuY2UpKQogCQkJCQltYXJrX3BhZ2VfYWNjZXNzZWQocGFnZSk7
CiAJCQkJcnNzW01NX0ZJTEVQQUdFU10tLTsKIAkJCX0KQEAgLTEwMzgsOCArMTA0Myw2IEBAIHN0
YXRpYyB1bnNpZ25lZCBsb25nIHVubWFwX3BhZ2VfcmFuZ2Uoc3RydWN0IG1tdV9nYXRoZXIgKnRs
YiwKIAlwZ2RfdCAqcGdkOwogCXVuc2lnbmVkIGxvbmcgbmV4dDsKIAotCWlmIChkZXRhaWxzICYm
ICFkZXRhaWxzLT5jaGVja19tYXBwaW5nICYmICFkZXRhaWxzLT5ub25saW5lYXJfdm1hKQotCQlk
ZXRhaWxzID0gTlVMTDsKIAogCUJVR19PTihhZGRyID49IGVuZCk7CiAJbWVtX2Nncm91cF91bmNo
YXJnZV9zdGFydCgpOwpAQCAtMTEwMiw3ICsxMTA1LDggQEAgdW5zaWduZWQgbG9uZyB1bm1hcF92
bWFzKHN0cnVjdCBtbXVfZ2F0aGVyICoqdGxicCwKIAl1bnNpZ25lZCBsb25nIHRsYl9zdGFydCA9
IDA7CS8qIEZvciB0bGJfZmluaXNoX21tdSAqLwogCWludCB0bGJfc3RhcnRfdmFsaWQgPSAwOwog
CXVuc2lnbmVkIGxvbmcgc3RhcnQgPSBzdGFydF9hZGRyOwotCXNwaW5sb2NrX3QgKmlfbW1hcF9s
b2NrID0gZGV0YWlscz8gZGV0YWlscy0+aV9tbWFwX2xvY2s6IE5VTEw7CisJc3BpbmxvY2tfdCAq
aV9tbWFwX2xvY2sgPSBkZXRhaWxzID8KKwkJKGRldGFpcy0+Y2hlY2tfbWFwcGluZyA/IGRldGFp
bHMtPmlfbW1hcF9sb2NrOiBOVUxMKSA6IE5VTEw7CiAJaW50IGZ1bGxtbSA9ICgqdGxicCktPmZ1
bGxtbTsKIAlzdHJ1Y3QgbW1fc3RydWN0ICptbSA9IHZtYS0+dm1fbW07CiAK
--002215046dcfa653dd0496cb7f0b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
