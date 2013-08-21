Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B6BDC6B00A1
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 08:26:54 -0400 (EDT)
In-Reply-To: <1377080143-28455-6-git-send-email-tangchen@cn.fujitsu.com>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com> <1377080143-28455-6-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [PATCH 5/8] x86, brk: Make extend_brk() available with va/pa.
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Wed, 21 Aug 2013 08:26:05 -0400
Message-ID: <18d71946-6de9-4af2-a6a8-05fae51755af@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Tang Chen <tangchen@cn=2Efujitsu=2Ecom> wrote:
>We are going to do acpi_ini=
trd_override() at very early time:
>
>On 32bit: do it in head_32=2ES, befor=
e paging is enabled=2E In this case,
>we can
>          access initrd with =
physical address without page tables=2E
>
>On 64bit: do it in head_64=2Ec, =
after paging is enabled but before direct
>mapping
>          is setup=2E
>=

>   On 64bit, we have an early page fault handler to help to access data
>=
     with direct mapping page tables=2E So it is easy to do in head_64=2Ec=
=2E
>
>And we need to allocate memory to store override tables=2E At such a=
n
>early time,
>no memory allocator works=2E So we can only use BRK=2E
>
>A=
s mentioned above, on 32bit before paging is enabled, we have to
>access va=
riables
>with pa=2E So introduce a "bool is_phys" parameter to extend_brk()=
, and
>convert va
>to pa is it is true=2E

Could you do it differently? Mea=
ning have a global symbol (paging_enabled) which will be used by most of th=
e functions you changed in this patch and the next ones? It would naturally=
 be enabled when paging is on and __va addresses can be used=2E 

That coul=
d also be used in the printk case to do a BUG_ON before paging is enabled o=
n 32bit=2E Or perhaps use a different code path to deal with using __pa add=
ress=2E 

? 
>
>Signed-off-by: Tang Chen <tangchen@cn=2Efujitsu=2Ecom>
>---=

> arch/x86/include/asm/dmi=2Eh   |    2 +-
> arch/x86/include/asm/setup=2E=
h |    2 +-
> arch/x86/kernel/setup=2Ec      |   20 ++++++++++++++------
> =
arch/x86/mm/init=2Ec           |    2 +-
> arch/x86/xen/enlighten=2Ec     |=
    2 +-
> arch/x86/xen/mmu=2Ec           |    6 +++---
> arch/x86/xen/p2m=
=2Ec           |   27 ++++++++++++++-------------
> drivers/acpi/osl=2Ec   =
        |    2 +-
> 8 files changed, 36 insertions(+), 27 deletions(-)
>
>d=
iff --git a/arch/x86/include/asm/dmi=2Eh b/arch/x86/include/asm/dmi=2Eh
>in=
dex fd8f9e2=2E=2E3b51d81 100644
>--- a/arch/x86/include/asm/dmi=2Eh
>+++ b/=
arch/x86/include/asm/dmi=2Eh
>@@ -9,7 +9,7 @@
> 
> static __always_inline _=
_init void *dmi_alloc(unsigned len)
> {
>-	return extend_brk(len, sizeof(in=
t));
>+	return extend_brk(len, sizeof(int), false);
> }
> 
> /* Use early I=
O mappings for DMI because it's initialized early */
>diff --git a/arch/x86=
/include/asm/setup=2Eh
>b/arch/x86/include/asm/setup=2Eh
>index 4f71d48=2E=
=2E96d00da 100644
>--- a/arch/x86/include/asm/setup=2Eh
>+++ b/arch/x86/inc=
lude/asm/setup=2Eh
>@@ -75,7 +75,7 @@ extern struct boot_params boot_params=
;
> 
> /* exceedingly early brk-like allocator */
> extern unsigned long _b=
rk_end;
>-void *extend_brk(size_t size, size_t align);
>+void *extend_brk(s=
ize_t size, size_t align, bool is_phys);
> 
> /*
>  * Reserve space in the =
brk section=2E  The name must be unique within
>diff --git a/arch/x86/kerne=
l/setup=2Ec b/arch/x86/kernel/setup=2Ec
>index 51fcd5d=2E=2Ea189909 100644
=
>--- a/arch/x86/kernel/setup=2Ec
>+++ b/arch/x86/kernel/setup=2Ec
>@@ -259,=
19 +259,27 @@ static inline void __init copy_edd(void)
> }
> #endif
> 
>-vo=
id * __init extend_brk(size_t size, size_t align)
>+void * __init extend_br=
k(size_t size, size_t align, bool is_phys)
> {
> 	size_t mask =3D align - 1=
;
> 	void *ret;
>+	unsigned long *brk_start, *brk_end, *brk_limit;
> 
>-	BU=
G_ON(_brk_start =3D=3D 0);
>+	brk_start =3D is_phys ? (unsigned long *)__pa=
_nodebug(&_brk_start) :
>+			      (unsigned long *)&_brk_start;
>+	brk_end=
 =3D is_phys ? (unsigned long *)__pa_nodebug(&_brk_end) :
>+			    (unsigne=
d long *)&_brk_end;
>+	brk_limit =3D is_phys ? (unsigned long *)__pa_nodebu=
g(__brk_limit) :
>+			      (unsigned long *)__brk_limit;
>+
>+	BUG_ON(*brk=
_start =3D=3D 0);
> 	BUG_ON(align & mask);
> 
>-	_brk_end =3D (_brk_end + m=
ask) & ~mask;
>-	BUG_ON((char *)(_brk_end + size) > __brk_limit);
>+	*brk_e=
nd =3D (*brk_end + mask) & ~mask;
>+	BUG_ON((char *)(*brk_end + size) > brk=
_limit);
> 
>-	ret =3D (void *)_brk_end;
>-	_brk_end +=3D size;
>+	ret =3D =
(void *)(*brk_end);
>+	*brk_end +=3D size;
> 
> 	memset(ret, 0, size);
> 
>=
diff --git a/arch/x86/mm/init=2Ec b/arch/x86/mm/init=2Ec
>index 2ec29ac=2E=
=2E189a9e2 100644
>--- a/arch/x86/mm/init=2Ec
>+++ b/arch/x86/mm/init=2Ec
>=
@@ -86,7 +86,7 @@ void  __init early_alloc_pgt_buf(void)
> 	unsigned long t=
ables =3D INIT_PGT_BUF_SIZE;
> 	phys_addr_t base;
> 
>-	base =3D __pa(exten=
d_brk(tables, PAGE_SIZE));
>+	base =3D __pa(extend_brk(tables, PAGE_SIZE, f=
alse));
> 
> 	pgt_buf_start =3D base >> PAGE_SHIFT;
> 	pgt_buf_end =3D pgt_=
buf_start;
>diff --git a/arch/x86/xen/enlighten=2Ec b/arch/x86/xen/enlighte=
n=2Ec
>index 193097e=2E=2E2d5a34f 100644
>--- a/arch/x86/xen/enlighten=2Ec
=
>+++ b/arch/x86/xen/enlighten=2Ec
>@@ -1629,7 +1629,7 @@ void __ref xen_hvm=
_init_shared_info(void)
> 
> 	if (!shared_info_page)
> 		shared_info_page =
=3D (struct shared_info *)
>-			extend_brk(PAGE_SIZE, PAGE_SIZE);
>+			exte=
nd_brk(PAGE_SIZE, PAGE_SIZE, false);
> 	xatp=2Edomid =3D DOMID_SELF;
> 	xat=
p=2Eidx =3D 0;
> 	xatp=2Espace =3D XENMAPSPACE_shared_info;
>diff --git a/a=
rch/x86/xen/mmu=2Ec b/arch/x86/xen/mmu=2Ec
>index fdc3ba2=2E=2E573bc50 1006=
44
>--- a/arch/x86/xen/mmu=2Ec
>+++ b/arch/x86/xen/mmu=2Ec
>@@ -1768,7 +176=
8,7 @@ static void __init xen_map_identity_early(pmd_t
>*pmd, unsigned long=
 max_pfn)
> 	unsigned long pfn;
> 
> 	level1_ident_pgt =3D extend_brk(sizeo=
f(pte_t) * LEVEL1_IDENT_ENTRIES,
>-				      PAGE_SIZE);
>+				      PAGE_S=
IZE, false);
> 
> 	ident_pte =3D 0;
> 	pfn =3D 0;
>@@ -1980,7 +1980,7 @@ st=
atic void __init xen_write_cr3_init(unsigned
>long cr3)
> 	 * swapper_pg_di=
r=2E
> 	 */
> 	swapper_kernel_pmd =3D
>-		extend_brk(sizeof(pmd_t) * PTRS_P=
ER_PMD, PAGE_SIZE);
>+		extend_brk(sizeof(pmd_t) * PTRS_PER_PMD, PAGE_SIZE,=
 false);
> 	copy_page(swapper_kernel_pmd, initial_kernel_pmd);
> 	swapper_p=
g_dir[KERNEL_PGD_BOUNDARY] =3D
> 		__pgd(__pa(swapper_kernel_pmd) | _PAGE_P=
RESENT);
>@@ -2003,7 +2003,7 @@ void __init xen_setup_kernel_pagetable(pgd_=
t
>*pgd, unsigned long max_pfn)
> 	pmd_t *kernel_pmd;
> 
> 	initial_kernel_=
pmd =3D
>-		extend_brk(sizeof(pmd_t) * PTRS_PER_PMD, PAGE_SIZE);
>+		extend=
_brk(sizeof(pmd_t) * PTRS_PER_PMD, PAGE_SIZE, false);
> 
> 	max_pfn_mapped =
=3D PFN_DOWN(__pa(xen_start_info->pt_base) +
> 				  xen_start_info->nr_pt_=
frames * PAGE_SIZE +
>diff --git a/arch/x86/xen/p2m=2Ec b/arch/x86/xen/p2m=
=2Ec
>index 95fb2aa=2E=2Ebbdcf20 100644
>--- a/arch/x86/xen/p2m=2Ec
>+++ b/=
arch/x86/xen/p2m=2Ec
>@@ -281,13 +281,13 @@ void __ref xen_build_mfn_list_l=
ist(void)
> 
> 	/* Pre-initialize p2m_top_mfn to be completely missing */
>=
 	if (p2m_top_mfn =3D=3D NULL) {
>-		p2m_mid_missing_mfn =3D extend_brk(PAG=
E_SIZE, PAGE_SIZE);
>+		p2m_mid_missing_mfn =3D extend_brk(PAGE_SIZE, PAGE_=
SIZE, false);
> 		p2m_mid_mfn_init(p2m_mid_missing_mfn);
> 
>-		p2m_top_mfn=
_p =3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+		p2m_top_mfn_p =3D extend_brk(P=
AGE_SIZE, PAGE_SIZE, false);
> 		p2m_top_mfn_p_init(p2m_top_mfn_p);
> 
>-		=
p2m_top_mfn =3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+		p2m_top_mfn =3D exten=
d_brk(PAGE_SIZE, PAGE_SIZE, false);
> 		p2m_top_mfn_init(p2m_top_mfn);
> 	}=
 else {
> 		/* Reinitialise, mfn's all change after migration */
>@@ -322,7=
 +322,7 @@ void __ref xen_build_mfn_list_list(void)
> 			 * runtime=2E  ext=
end_brk() will BUG if we call
> 			 * it too late=2E
> 			 */
>-			mid_mfn_=
p =3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+			mid_mfn_p =3D extend_brk(PAGE_=
SIZE, PAGE_SIZE, false);
> 			p2m_mid_mfn_init(mid_mfn_p);
> 
> 			p2m_top_=
mfn_p[topidx] =3D mid_mfn_p;
>@@ -351,16 +351,16 @@ void __init
>xen_build_=
dynamic_phys_to_machine(void)
> 
> 	xen_max_p2m_pfn =3D max_pfn;
> 
>-	p2m_=
missing =3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+	p2m_missing =3D extend_brk=
(PAGE_SIZE, PAGE_SIZE, false);
> 	p2m_init(p2m_missing);
> 
>-	p2m_mid_miss=
ing =3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+	p2m_mid_missing =3D extend_brk=
(PAGE_SIZE, PAGE_SIZE, false);
> 	p2m_mid_init(p2m_mid_missing);
> 
>-	p2m_=
top =3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+	p2m_top =3D extend_brk(PAGE_SI=
ZE, PAGE_SIZE, false);
> 	p2m_top_init(p2m_top);
> 
>-	p2m_identity =3D ext=
end_brk(PAGE_SIZE, PAGE_SIZE);
>+	p2m_identity =3D extend_brk(PAGE_SIZE, PA=
GE_SIZE, false);
> 	p2m_init(p2m_identity);
> 
> 	/*
>@@ -373,7 +373,8 @@ v=
oid __init xen_build_dynamic_phys_to_machine(void)
> 		unsigned mididx =3D =
p2m_mid_index(pfn);
> 
> 		if (p2m_top[topidx] =3D=3D p2m_mid_missing) {
>-=
			unsigned long **mid =3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+			unsigned =
long **mid =3D extend_brk(PAGE_SIZE, PAGE_SIZE,
>+							 false);
> 			p2m_=
mid_init(mid);
> 
> 			p2m_top[topidx] =3D mid;
>@@ -609,7 +610,7 @@ static=
 bool __init early_alloc_p2m_middle(unsigned
>long pfn, bool check_boundary=

> 		return false;
> 
> 	/* Boundary cross-over for the edges: */
>-	p2m =
=3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+	p2m =3D extend_brk(PAGE_SIZE, PAGE=
_SIZE, false);
> 
> 	p2m_init(p2m);
> 
>@@ -635,7 +636,7 @@ static bool __i=
nit early_alloc_p2m(unsigned long
>pfn)
> 	mid =3D p2m_top[topidx];
> 	mid_=
mfn_p =3D p2m_top_mfn_p[topidx];
> 	if (mid =3D=3D p2m_mid_missing) {
>-		m=
id =3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+		mid =3D extend_brk(PAGE_SIZE, =
PAGE_SIZE, false);
> 
> 		p2m_mid_init(mid);
> 
>@@ -645,7 +646,7 @@ static=
 bool __init early_alloc_p2m(unsigned long
>pfn)
> 	}
> 	/* And the save/re=
store P2M tables=2E=2E */
> 	if (mid_mfn_p =3D=3D p2m_mid_missing_mfn) {
>-=
		mid_mfn_p =3D extend_brk(PAGE_SIZE, PAGE_SIZE);
>+		mid_mfn_p =3D extend_=
brk(PAGE_SIZE, PAGE_SIZE, false);
> 		p2m_mid_mfn_init(mid_mfn_p);
> 
> 		p=
2m_top_mfn_p[topidx] =3D mid_mfn_p;
>@@ -858,7 +859,7 @@ static void __init=
 m2p_override_init(void)
> 	unsigned i;
> 
>	m2p_overrides =3D extend_brk(s=
izeof(*m2p_overrides) * M2P_OVERRIDE_HASH,
>-				   sizeof(unsigned long));=

>+				   sizeof(unsigned long), false);
> 
> 	for (i =3D 0; i < M2P_OVERRI=
DE_HASH; i++)
> 		INIT_LIST_HEAD(&m2p_overrides[i]);
>diff --git a/drivers/=
acpi/osl=2Ec b/drivers/acpi/osl=2Ec
>index 4c1baa7=2E=2Edff7fcc 100644
>---=
 a/drivers/acpi/osl=2Ec
>+++ b/drivers/acpi/osl=2Ec
>@@ -563,7 +563,7 @@ RE=
SERVE_BRK(acpi_override_tables_alloc,
>ACPI_OVERRIDE_TABLES_SIZE);
> void _=
_init early_alloc_acpi_override_tables_buf(void)
> {
> 	acpi_tables_addr =
=3D __pa(extend_brk(ACPI_OVERRIDE_TABLES_SIZE,
>-					   PAGE_SIZE));
>+			=
		   PAGE_SIZE, false));
> }
> 
> void __init acpi_initrd_override(void *da=
ta, size_t size)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
