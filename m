Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C82D6B02CF
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:18:36 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id y3so805841uao.23
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:18:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 188sor6908741vsi.53.2018.10.30.23.18.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Oct 2018 23:18:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com> <1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
From: Li Wang <liwang@redhat.com>
Date: Wed, 31 Oct 2018 14:18:33 +0800
Message-ID: <CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
Content-Type: multipart/alternative; boundary="000000000000a832be0579804529"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

--000000000000a832be0579804529
Content-Type: text/plain; charset="UTF-8"

On Tue, Oct 16, 2018 at 12:42 AM, Martin Schwidefsky <schwidefsky@de.ibm.com
> wrote:

> In case a fork or a clone system fails in copy_process and the error
> handling does the mmput() at the bad_fork_cleanup_mm label, the
> following warning messages will appear on the console:
>
>   BUG: non-zero pgtables_bytes on freeing mm: 16384
>
> The reason for that is the tricks we play with mm_inc_nr_puds() and
> mm_inc_nr_pmds() in init_new_context().
>
> A normal 64-bit process has 3 levels of page table, the p4d level and
> the pud level are folded. On process termination the free_pud_range()
> function in mm/memory.c will subtract 16KB from pgtable_bytes with a
> mm_dec_nr_puds() call, but there actually is not really a pud table.
>
> One issue with this is the fact that pgtable_bytes is usually off
> by a few kilobytes, but the more severe problem is that for a failed
> fork or clone the free_pgtables() function is not called. In this case
> there is no mm_dec_nr_puds() or mm_dec_nr_pmds() that go together with
> the mm_inc_nr_puds() and mm_inc_nr_pmds in init_new_context().
> The pgtable_bytes will be off by 16384 or 32768 bytes and we get the
> BUG message. The message itself is purely cosmetic, but annoying.
>
> To fix this override the mm_pmd_folded, mm_pud_folded and mm_p4d_folded
> function to check for the true size of the address space.
>

I can confirm that it works to the problem, the warning message is gone
after applying this patch on s390x. And I also done ltp syscalls/cve test
for the patch set on x86_64 arch, there has no new regression.

Tested-by: Li Wang <liwang@redhat.com>


> Reported-by: Li Wang <liwang@redhat.com>
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---
>  arch/s390/include/asm/mmu_context.h |  5 -----
>  arch/s390/include/asm/pgalloc.h     |  6 +++---
>  arch/s390/include/asm/pgtable.h     | 18 ++++++++++++++++++
>  arch/s390/include/asm/tlb.h         |  6 +++---
>  4 files changed, 24 insertions(+), 11 deletions(-)
>
> diff --git a/arch/s390/include/asm/mmu_context.h
> b/arch/s390/include/asm/mmu_context.h
> index 0717ee76885d..f1ab9420ccfb 100644
> --- a/arch/s390/include/asm/mmu_context.h
> +++ b/arch/s390/include/asm/mmu_context.h
> @@ -45,8 +45,6 @@ static inline int init_new_context(struct task_struct
> *tsk,
>                 mm->context.asce_limit = STACK_TOP_MAX;
>                 mm->context.asce = __pa(mm->pgd) | _ASCE_TABLE_LENGTH |
>                                    _ASCE_USER_BITS | _ASCE_TYPE_REGION3;
> -               /* pgd_alloc() did not account this pud */
> -               mm_inc_nr_puds(mm);
>                 break;
>         case -PAGE_SIZE:
>                 /* forked 5-level task, set new asce with new_mm->pgd */
> @@ -62,9 +60,6 @@ static inline int init_new_context(struct task_struct
> *tsk,
>                 /* forked 2-level compat task, set new asce with new
> mm->pgd */
>                 mm->context.asce = __pa(mm->pgd) | _ASCE_TABLE_LENGTH |
>                                    _ASCE_USER_BITS | _ASCE_TYPE_SEGMENT;
> -               /* pgd_alloc() did not account this pmd */
> -               mm_inc_nr_pmds(mm);
> -               mm_inc_nr_puds(mm);
>         }
>         crst_table_init((unsigned long *) mm->pgd, pgd_entry_type(mm));
>         return 0;
> diff --git a/arch/s390/include/asm/pgalloc.h
> b/arch/s390/include/asm/pgalloc.h
> index f0f9bcf94c03..5ee733720a57 100644
> --- a/arch/s390/include/asm/pgalloc.h
> +++ b/arch/s390/include/asm/pgalloc.h
> @@ -36,11 +36,11 @@ static inline void crst_table_init(unsigned long
> *crst, unsigned long entry)
>
>  static inline unsigned long pgd_entry_type(struct mm_struct *mm)
>  {
> -       if (mm->context.asce_limit <= _REGION3_SIZE)
> +       if (mm_pmd_folded(mm))
>                 return _SEGMENT_ENTRY_EMPTY;
> -       if (mm->context.asce_limit <= _REGION2_SIZE)
> +       if (mm_pud_folded(mm))
>                 return _REGION3_ENTRY_EMPTY;
> -       if (mm->context.asce_limit <= _REGION1_SIZE)
> +       if (mm_p4d_folded(mm))
>                 return _REGION2_ENTRY_EMPTY;
>         return _REGION1_ENTRY_EMPTY;
>  }
> diff --git a/arch/s390/include/asm/pgtable.h
> b/arch/s390/include/asm/pgtable.h
> index 0e7cb0dc9c33..de05466ce50c 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -485,6 +485,24 @@ static inline int is_module_addr(void *addr)
>                                    _REGION_ENTRY_PROTECT | \
>                                    _REGION_ENTRY_NOEXEC)
>
> +static inline bool mm_p4d_folded(struct mm_struct *mm)
> +{
> +       return mm->context.asce_limit <= _REGION1_SIZE;
> +}
> +#define mm_p4d_folded(mm) mm_p4d_folded(mm)
> +
> +static inline bool mm_pud_folded(struct mm_struct *mm)
> +{
> +       return mm->context.asce_limit <= _REGION2_SIZE;
> +}
> +#define mm_pud_folded(mm) mm_pud_folded(mm)
> +
> +static inline bool mm_pmd_folded(struct mm_struct *mm)
> +{
> +       return mm->context.asce_limit <= _REGION3_SIZE;
> +}
> +#define mm_pmd_folded(mm) mm_pmd_folded(mm)
> +
>  static inline int mm_has_pgste(struct mm_struct *mm)
>  {
>  #ifdef CONFIG_PGSTE
> diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
> index 457b7ba0fbb6..b31c779cf581 100644
> --- a/arch/s390/include/asm/tlb.h
> +++ b/arch/s390/include/asm/tlb.h
> @@ -136,7 +136,7 @@ static inline void pte_free_tlb(struct mmu_gather
> *tlb, pgtable_t pte,
>  static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
>                                 unsigned long address)
>  {
> -       if (tlb->mm->context.asce_limit <= _REGION3_SIZE)
> +       if (mm_pmd_folded(tlb->mm))
>                 return;
>         pgtable_pmd_page_dtor(virt_to_page(pmd));
>         tlb_remove_table(tlb, pmd);
> @@ -152,7 +152,7 @@ static inline void pmd_free_tlb(struct mmu_gather
> *tlb, pmd_t *pmd,
>  static inline void p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d,
>                                 unsigned long address)
>  {
> -       if (tlb->mm->context.asce_limit <= _REGION1_SIZE)
> +       if (mm_p4d_folded(tlb->mm))
>                 return;
>         tlb_remove_table(tlb, p4d);
>  }
> @@ -167,7 +167,7 @@ static inline void p4d_free_tlb(struct mmu_gather
> *tlb, p4d_t *p4d,
>  static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
>                                 unsigned long address)
>  {
> -       if (tlb->mm->context.asce_limit <= _REGION2_SIZE)
> +       if (mm_pud_folded(tlb->mm))
>                 return;
>         tlb_remove_table(tlb, pud);
>  }
> --
> 2.16.4
>
>


-- 
Regards,
Li Wang

--000000000000a832be0579804529
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div class=3D"gmail_default" style=3D"fon=
t-size:small"><br></div><div class=3D"gmail_extra"><br><div class=3D"gmail_=
quote">On Tue, Oct 16, 2018 at 12:42 AM, Martin Schwidefsky <span dir=3D"lt=
r">&lt;<a href=3D"mailto:schwidefsky@de.ibm.com" target=3D"_blank">schwidef=
sky@de.ibm.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);pad=
ding-left:1ex">In case a fork or a clone system fails in copy_process and t=
he error<br>
handling does the mmput() at the bad_fork_cleanup_mm label, the<br>
following warning messages will appear on the console:<br>
<br>
=C2=A0 BUG: non-zero pgtables_bytes on freeing mm: 16384<br>
<br>
The reason for that is the tricks we play with mm_inc_nr_puds() and<br>
mm_inc_nr_pmds() in init_new_context().<br>
<br>
A normal 64-bit process has 3 levels of page table, the p4d level and<br>
the pud level are folded. On process termination the free_pud_range()<br>
function in mm/memory.c will subtract 16KB from pgtable_bytes with a<br>
mm_dec_nr_puds() call, but there actually is not really a pud table.<br>
<br>
One issue with this is the fact that pgtable_bytes is usually off<br>
by a few kilobytes, but the more severe problem is that for a failed<br>
fork or clone the free_pgtables() function is not called. In this case<br>
there is no mm_dec_nr_puds() or mm_dec_nr_pmds() that go together with<br>
the mm_inc_nr_puds() and mm_inc_nr_pmds in init_new_context().<br>
The pgtable_bytes will be off by 16384 or 32768 bytes and we get the<br>
BUG message. The message itself is purely cosmetic, but annoying.<br>
<br>
To fix this override the mm_pmd_folded, mm_pud_folded and mm_p4d_folded<br>
function to check for the true size of the address space.<br></blockquote><=
div><br></div><div><div class=3D"gmail_default" style=3D"font-size:small">I=
 can confirm that it works to the problem, the warning message is gone afte=
r applying this patch on s390x. And I also done ltp syscalls/cve test for t=
he patch set on x86_64 arch, there has no new regression.</div></div><div><=
br></div><div><div class=3D"gmail_default" style=3D"font-size:small">Tested=
-by: <span class=3D"gmail_default" style=3D"background-color:rgb(255,255,25=
5);text-decoration-style:initial;text-decoration-color:initial"></span><spa=
n style=3D"background-color:rgb(255,255,255);text-decoration-style:initial;=
text-decoration-color:initial;float:none;display:inline">Li Wang &lt;</span=
><a href=3D"mailto:liwang@redhat.com" style=3D"color:rgb(17,85,204);backgro=
und-color:rgb(255,255,255)" target=3D"_blank">liwang@redhat.com</a><span st=
yle=3D"background-color:rgb(255,255,255);text-decoration-style:initial;text=
-decoration-color:initial;float:none;display:inline">&gt;</span></div><br><=
/div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bo=
rder-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
Reported-by: <span class=3D"gmail_default" style=3D"font-size:small"></span=
>Li Wang &lt;<a href=3D"mailto:liwang@redhat.com" target=3D"_blank">liwang@=
redhat.com</a>&gt;<br>
Signed-off-by: Martin Schwidefsky &lt;<a href=3D"mailto:schwidefsky@de.ibm.=
com" target=3D"_blank">schwidefsky@de.ibm.com</a>&gt;<br>
---<br>
=C2=A0arch/s390/include/asm/mmu_con<wbr>text.h |=C2=A0 5 -----<br>
=C2=A0arch/s390/include/asm/<wbr>pgalloc.h=C2=A0 =C2=A0 =C2=A0|=C2=A0 6 +++=
---<br>
=C2=A0arch/s390/include/asm/<wbr>pgtable.h=C2=A0 =C2=A0 =C2=A0| 18 ++++++++=
++++++++++<br>
=C2=A0arch/s390/include/asm/tlb.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =
6 +++---<br>
=C2=A04 files changed, 24 insertions(+), 11 deletions(-)<br>
<br>
diff --git a/arch/s390/include/asm/mmu_co<wbr>ntext.h b/arch/s390/include/a=
sm/mmu_co<wbr>ntext.h<br>
index 0717ee76885d..f1ab9420ccfb 100644<br>
--- a/arch/s390/include/asm/mmu_co<wbr>ntext.h<br>
+++ b/arch/s390/include/asm/mmu_co<wbr>ntext.h<br>
@@ -45,8 +45,6 @@ static inline int init_new_context(struct task_struct *ts=
k,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mm-&gt;context.asce=
_limit =3D STACK_TOP_MAX;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mm-&gt;context.asce=
 =3D __pa(mm-&gt;pgd) | _ASCE_TABLE_LENGTH |<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0_ASCE_USER_BITS | _ASCE=
_TYPE_REGION3;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* pgd_alloc() did =
not account this pud */<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mm_inc_nr_puds(mm);=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 case -PAGE_SIZE:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* forked 5-level t=
ask, set new asce with new_mm-&gt;pgd */<br>
@@ -62,9 +60,6 @@ static inline int init_new_context(struct task_struct *ts=
k,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* forked 2-level c=
ompat task, set new asce with new mm-&gt;pgd */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mm-&gt;context.asce=
 =3D __pa(mm-&gt;pgd) | _ASCE_TABLE_LENGTH |<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0_ASCE_USER_BITS | _ASCE=
_TYPE_SEGMENT;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* pgd_alloc() did =
not account this pmd */<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mm_inc_nr_pmds(mm);=
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mm_inc_nr_puds(mm);=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 crst_table_init((unsigned long *) mm-&gt;pgd, p=
gd_entry_type(mm));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;<br>
diff --git a/arch/s390/include/asm/pgallo<wbr>c.h b/arch/s390/include/asm/p=
gallo<wbr>c.h<br>
index f0f9bcf94c03..5ee733720a57 100644<br>
--- a/arch/s390/include/asm/pgallo<wbr>c.h<br>
+++ b/arch/s390/include/asm/pgallo<wbr>c.h<br>
@@ -36,11 +36,11 @@ static inline void crst_table_init(unsigned long *crst,=
 unsigned long entry)<br>
<br>
=C2=A0static inline unsigned long pgd_entry_type(struct mm_struct *mm)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm-&gt;context.asce_limit &lt;=3D _REGION3_=
SIZE)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm_pmd_folded(mm))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return _SEGMENT_ENT=
RY_EMPTY;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm-&gt;context.asce_limit &lt;=3D _REGION2_=
SIZE)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm_pud_folded(mm))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return _REGION3_ENT=
RY_EMPTY;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm-&gt;context.asce_limit &lt;=3D _REGION1_=
SIZE)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm_p4d_folded(mm))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return _REGION2_ENT=
RY_EMPTY;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return _REGION1_ENTRY_EMPTY;<br>
=C2=A0}<br>
diff --git a/arch/s390/include/asm/pgtabl<wbr>e.h b/arch/s390/include/asm/p=
gtabl<wbr>e.h<br>
index 0e7cb0dc9c33..de05466ce50c 100644<br>
--- a/arch/s390/include/asm/pgtabl<wbr>e.h<br>
+++ b/arch/s390/include/asm/pgtabl<wbr>e.h<br>
@@ -485,6 +485,24 @@ static inline int is_module_addr(void *addr)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0_REGION_ENTRY_PROTECT |=
 \<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0_REGION_ENTRY_NOEXEC)<b=
r>
<br>
+static inline bool mm_p4d_folded(struct mm_struct *mm)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return mm-&gt;context.asce_limit &lt;=3D _REGIO=
N1_SIZE;<br>
+}<br>
+#define mm_p4d_folded(mm) mm_p4d_folded(mm)<br>
+<br>
+static inline bool mm_pud_folded(struct mm_struct *mm)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return mm-&gt;context.asce_limit &lt;=3D _REGIO=
N2_SIZE;<br>
+}<br>
+#define mm_pud_folded(mm) mm_pud_folded(mm)<br>
+<br>
+static inline bool mm_pmd_folded(struct mm_struct *mm)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return mm-&gt;context.asce_limit &lt;=3D _REGIO=
N3_SIZE;<br>
+}<br>
+#define mm_pmd_folded(mm) mm_pmd_folded(mm)<br>
+<br>
=C2=A0static inline int mm_has_pgste(struct mm_struct *mm)<br>
=C2=A0{<br>
=C2=A0#ifdef CONFIG_PGSTE<br>
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h<br>
index 457b7ba0fbb6..b31c779cf581 100644<br>
--- a/arch/s390/include/asm/tlb.h<br>
+++ b/arch/s390/include/asm/tlb.h<br>
@@ -136,7 +136,7 @@ static inline void pte_free_tlb(struct mmu_gather *tlb,=
 pgtable_t pte,<br>
=C2=A0static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long address)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (tlb-&gt;mm-&gt;context.asce_limit &lt;=3D _=
REGION3_SIZE)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm_pmd_folded(tlb-&gt;mm))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 pgtable_pmd_page_dtor(virt_to_<wbr>page(pmd));<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 tlb_remove_table(tlb, pmd);<br>
@@ -152,7 +152,7 @@ static inline void pmd_free_tlb(struct mmu_gather *tlb,=
 pmd_t *pmd,<br>
=C2=A0static inline void p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d,<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long address)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (tlb-&gt;mm-&gt;context.asce_limit &lt;=3D _=
REGION1_SIZE)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm_p4d_folded(tlb-&gt;mm))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 tlb_remove_table(tlb, p4d);<br>
=C2=A0}<br>
@@ -167,7 +167,7 @@ static inline void p4d_free_tlb(struct mmu_gather *tlb,=
 p4d_t *p4d,<br>
=C2=A0static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long address)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (tlb-&gt;mm-&gt;context.asce_limit &lt;=3D _=
REGION2_SIZE)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (mm_pud_folded(tlb-&gt;mm))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 tlb_remove_table(tlb, pud);<br>
=C2=A0}<br>
<span class=3D"m_8020028286965395775gmail-HOEnZb"><font color=3D"#888888">-=
- <br>
2.16.4<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div class=3D"m_8020028286965395775gmail_signature"><div dir=3D"ltr"><div=
>Regards,<br></div><div>Li Wang<br></div></div></div>
</div></div></div>

--000000000000a832be0579804529--
