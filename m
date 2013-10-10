Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B09356B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 17:53:53 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so3246754pdj.35
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:53:53 -0700 (PDT)
Date: Fri, 11 Oct 2013 00:53:43 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 11/34] arm: handle pgtable_page_ctor() fail
Message-ID: <20131010215343.GA2359@otc-wbsnb-06>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1381428359-14843-12-git-send-email-kirill.shutemov@linux.intel.com>
 <20131010201805.GR25034@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <20131010201805.GR25034@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Oct 10, 2013 at 09:18:05PM +0100, Russell King - ARM Linux wrote:
> So, all I see is this patch, with such a brilliant description which
> describes what this change is about, why it is being made, and so
> forth, and you're sending it to me, presumably because you want me to
> do something with it.  No, not really.

Fair enough. Description should be better.

> What context do I have to say whether this is correct or not?  How can
> I test it when the mainline version of pgtable_page_ctor returns void,
> so if I were to apply this patch I'd get compile errors.
> 
> Oh, I guess you're changing pgtable_page_ctor() in some way.  What is
> the nature of that change?
> 
> Please, I'm not a mind reader.  Please ensure that your "generic" patch
> of your series reaches the appropriate recipients: if you don't want to
> explicitly Cc: all the people individually, please at least copy all
> relevant mailing lists found for the entire series.

The patchset touches every arch with MMU -- the list would be too long.
I hoped all maintainers has access to archive of linux-kernel/linux-arch
to get context.

mbox with cover letter and three relevant patches attached.

> (No, I am not on the excessively noisy linux-arch: I dropped off it
> years ago because it just became yet another mailing list to endlessly
> talk mainly about x86 rather than being a separate list to linux-kernel
> which discussed problems relevant to many arch maintainers.)
> 
> Thanks.
> 
> On Thu, Oct 10, 2013 at 09:05:36PM +0300, Kirill A. Shutemov wrote:
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Russell King <linux@arm.linux.org.uk>
> > ---
> >  arch/arm/include/asm/pgalloc.h | 12 +++++++-----
> >  1 file changed, 7 insertions(+), 5 deletions(-)
> > 
> > diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
> > index 943504f53f..78a7793616 100644
> > --- a/arch/arm/include/asm/pgalloc.h
> > +++ b/arch/arm/include/asm/pgalloc.h
> > @@ -102,12 +102,14 @@ pte_alloc_one(struct mm_struct *mm, unsigned long addr)
> >  #else
> >  	pte = alloc_pages(PGALLOC_GFP, 0);
> >  #endif
> > -	if (pte) {
> > -		if (!PageHighMem(pte))
> > -			clean_pte_table(page_address(pte));
> > -		pgtable_page_ctor(pte);
> > +	if (!pte)
> > +		return NULL;
> > +	if (!PageHighMem(pte))
> > +		clean_pte_table(page_address(pte));
> > +	if (!pgtable_page_ctor(pte)) {
> > +		__free_page(pte);
> > +		return NULL;
> >  	}
> > -
> >  	return pte;
> >  }
> >  
> > -- 
> > 1.8.4.rc3
> > 
-- 
 Kirill A. Shutemov

--ZGiS0Q5IWpPtfppv
Content-Type: application/mbox
Content-Disposition: attachment; filename="ptl.mbox"
Content-Transfer-Encoding: quoted-printable

=46rom kas@linux.intel.com Thu Oct 10 21:18:11 2013=0AReturn-Path: <kas@lin=
ux.intel.com>=0AX-Original-To: kirill.shutemov@linux.intel.com=0ADelivered-=
To: kirill.shutemov@linux.intel.com=0AReceived: from linux.jf.intel.com [10=
=2E23.219.25]=0A	by blue with POP3 (fetchmail-6.3.26)=0A	for <kas@localhost=
> (single-drop); Thu, 10 Oct 2013 21:18:11 +0300 (EEST)=0AReceived: from fm=
smga001.fm.intel.com (fmsmga001.fm.intel.com [10.253.24.23])=0A	by linux.in=
tel.com (Postfix) with ESMTP id 36C4A6A4004=0A	for <kirill.shutemov@linux.i=
ntel.com>; Thu, 10 Oct 2013 11:06:03 -0700 (PDT)=0AX-ExtLoop1: 1=0AX-IronPo=
rt-AV: E=3DSophos;i=3D"4.90,1073,1371106800"; =0A   d=3D"scan'208";a=3D"408=
987074"=0AReceived: from blue.fi.intel.com ([10.237.72.156])=0A  by fmsmga0=
01.fm.intel.com with ESMTP; 10 Oct 2013 11:06:02 -0700=0AReceived: by blue.=
fi.intel.com (Postfix, from userid 1000)=0A	id E3B5BE0090; Thu, 10 Oct 2013=
 21:06:01 +0300 (EEST)=0AFrom: "Kirill A. Shutemov" <kirill.shutemov@linux.=
intel.com>=0ATo: Andrew Morton <akpm@linux-foundation.org>,=0A	Peter Zijlst=
ra <peterz@infradead.org>,=0A	Ingo Molnar <mingo@redhat.com>=0ACc: linux-ke=
rnel@vger.kernel.org,=0A	linux-mm@kvack.org,=0A	linux-arch@vger.kernel.org,=
=0A	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>=0ASubject: [PATC=
H 00/34] dynamically allocate split ptl if it cannot be embedded to struct =
page=0ADate: Thu, 10 Oct 2013 21:05:25 +0300=0AMessage-Id: <1381428359-1484=
3-1-git-send-email-kirill.shutemov@linux.intel.com>=0AX-Mailer: git-send-em=
ail 1.8.4.rc3=0AStatus: RO=0AContent-Length: 5400=0A=0AIn split page table =
lock case, we embed spinlock_t into struct page. For=0Aobvious reason, we d=
on't want to increase size of struct page if=0Aspinlock_t is too big, like =
with DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC or on=0A-rt kernel. So we disble sp=
lit page table lock, if spinlock_t is too big.=0A=0AThis patchset allows to=
 allocate the lock dynamically if spinlock_t is=0Abig. In this page->ptl is=
 used to store pointer to spinlock instead of=0Aspinlock itself. It costs a=
dditional cache line for indirect access, but=0Afix page fault scalability =
for multi-threaded applications.=0A=0ALOCK_STAT depends on DEBUG_SPINLOCK, =
so on current kernel enabling=0ALOCK_STAT to analyse scalability issues bre=
aks scalability. ;)=0A=0AThe patchset mostly fixes this. Results for ./thp_=
memscale -c 80 -b 512M=0Aon 4-socket machine:=0A=0Abaseline, no CONFIG_LOCK=
_STAT:	9.115460703 seconds time elapsed=0Abaseline, CONFIG_LOCK_STAT=3Dy:	5=
3.890567123 seconds time elapsed=0Apatched, no CONFIG_LOCK_STAT:	8.85225036=
8 seconds time elapsed=0Apatched, CONFIG_LOCK_STAT=3Dy:	11.069770759 second=
s time elapsed=0A=0APatch count is scary, but most of them trivial. Overvie=
w:=0A=0A Patches 1-4	Few bug fixes. No dependencies to other patches.=0A		P=
robably should applied as soon as possible.=0A=0A Patch 5	Changes signature=
 of pgtable_page_ctor(). We will use it=0A		for dynamic lock allocation, so=
 it can fail.=0A=0A Patches 6-8	Add missing constructor/destructor calls on=
 few archs.=0A		It's fixes NR_PAGETABLE accounting and prepare to use=0A		s=
plit ptl.=0A=0A Patches 9-33	Add pgtable_page_ctor() fail handling to all a=
rchs.=0A=0A Patches 34	Finally adds support of dynamically-allocated page->=
pte.=0A		Also contains documentation for split page table lock.=0A=0AAny co=
mments?=0A=0AKirill A. Shutemov (34):=0A  x86: add missed pgtable_pmd_page_=
ctor/dtor calls for preallocated pmds=0A  cris: fix potential NULL-pointer =
dereference=0A  m32r: fix potential NULL-pointer dereference=0A  xtensa: fi=
x potential NULL-pointer dereference=0A  mm: allow pgtable_page_ctor() to f=
ail=0A  microblaze: add missing pgtable_page_ctor/dtor calls=0A  mn10300: a=
dd missing pgtable_page_ctor/dtor calls=0A  openrisc: add missing pgtable_p=
age_ctor/dtor calls=0A  alpha: handle pgtable_page_ctor() fail=0A  arc: han=
dle pgtable_page_ctor() fail=0A  arm: handle pgtable_page_ctor() fail=0A  a=
rm64: handle pgtable_page_ctor() fail=0A  avr32: handle pgtable_page_ctor()=
 fail=0A  cris: handle pgtable_page_ctor() fail=0A  frv: handle pgtable_pag=
e_ctor() fail=0A  hexagon: handle pgtable_page_ctor() fail=0A  ia64: handle=
 pgtable_page_ctor() fail=0A  m32r: handle pgtable_page_ctor() fail=0A  m68=
k: handle pgtable_page_ctor() fail=0A  metag: handle pgtable_page_ctor() fa=
il=0A  mips: handle pgtable_page_ctor() fail=0A  parisc: handle pgtable_pag=
e_ctor() fail=0A  powerpc: handle pgtable_page_ctor() fail=0A  s390: handle=
 pgtable_page_ctor() fail=0A  score: handle pgtable_page_ctor() fail=0A  sh=
: handle pgtable_page_ctor() fail=0A  sparc: handle pgtable_page_ctor() fai=
l=0A  tile: handle pgtable_page_ctor() fail=0A  um: handle pgtable_page_cto=
r() fail=0A  unicore32: handle pgtable_page_ctor() fail=0A  x86: handle pgt=
able_page_ctor() fail=0A  xtensa: handle pgtable_page_ctor() fail=0A  iommu=
/arm-smmu: handle pgtable_page_ctor() fail=0A  mm: dynamically allocate pag=
e->ptl if it cannot be embedded to struct=0A    page=0A=0A Documentation/vm=
/split_page_table_lock   | 90 ++++++++++++++++++++++++++++++++=0A arch/alph=
a/include/asm/pgalloc.h         |  5 +-=0A arch/arc/include/asm/pgalloc.h  =
         | 11 ++--=0A arch/arm/include/asm/pgalloc.h           | 12 +++--=
=0A arch/arm64/include/asm/pgalloc.h         |  9 ++--=0A arch/avr32/includ=
e/asm/pgalloc.h         |  5 +-=0A arch/cris/include/asm/pgalloc.h         =
 |  7 ++-=0A arch/frv/mm/pgalloc.c                    | 12 +++--=0A arch/he=
xagon/include/asm/pgalloc.h       | 10 ++--=0A arch/ia64/include/asm/pgallo=
c.h          |  5 +-=0A arch/m32r/include/asm/pgalloc.h          |  7 ++-=
=0A arch/m68k/include/asm/motorola_pgalloc.h |  5 +-=0A arch/m68k/include/a=
sm/sun3_pgalloc.h     |  5 +-=0A arch/metag/include/asm/pgalloc.h         |=
  8 ++-=0A arch/microblaze/include/asm/pgalloc.h    | 12 +++--=0A arch/mips=
/include/asm/pgalloc.h          |  9 ++--=0A arch/mn10300/include/asm/pgall=
oc.h       |  1 +=0A arch/mn10300/mm/pgtable.c                |  9 +++-=0A =
arch/openrisc/include/asm/pgalloc.h      | 10 +++-=0A arch/parisc/include/a=
sm/pgalloc.h        |  8 ++-=0A arch/powerpc/include/asm/pgalloc-64.h    | =
 5 +-=0A arch/powerpc/mm/pgtable_32.c             |  5 +-=0A arch/powerpc/m=
m/pgtable_64.c             |  7 +--=0A arch/s390/mm/pgtable.c              =
     | 11 +++-=0A arch/score/include/asm/pgalloc.h         |  9 ++--=0A arc=
h/sh/include/asm/pgalloc.h            |  5 +-=0A arch/sparc/mm/init_64.c   =
               | 11 ++--=0A arch/sparc/mm/srmmu.c                    |  5 +=
-=0A arch/tile/mm/pgtable.c                   |  6 ++-=0A arch/um/kernel/me=
m.c                     |  8 ++-=0A arch/unicore32/include/asm/pgalloc.h   =
  | 14 ++---=0A arch/x86/mm/pgtable.c                    | 19 +++++--=0A ar=
ch/x86/xen/mmu.c                       |  2 +-=0A arch/xtensa/include/asm/p=
galloc.h        | 11 +++-=0A drivers/iommu/arm-smmu.c                 |  5 =
+-=0A include/linux/mm.h                       | 73 +++++++++++++++++++----=
---=0A include/linux/mm_types.h                 |  5 +-=0A mm/Kconfig      =
                         |  2 -=0A mm/memory.c                             =
 | 19 +++++++=0A 39 files changed, 365 insertions(+), 97 deletions(-)=0A cr=
eate mode 100644 Documentation/vm/split_page_table_lock=0A=0A-- =0A1.8.4.rc=
3=0A=0A=0AFrom kas@linux.intel.com Thu Oct 10 21:18:14 2013=0AReturn-Path: =
<kas@linux.intel.com>=0AX-Original-To: kirill.shutemov@linux.intel.com=0ADe=
livered-To: kirill.shutemov@linux.intel.com=0AReceived: from linux.jf.intel=
=2Ecom [10.23.219.25]=0A	by blue with POP3 (fetchmail-6.3.26)=0A	for <kas@l=
ocalhost> (single-drop); Thu, 10 Oct 2013 21:18:14 +0300 (EEST)=0AReceived:=
 from fmsmga001.fm.intel.com (fmsmga001.fm.intel.com [10.253.24.23])=0A	by =
linux.intel.com (Postfix) with ESMTP id 01B856A4004=0A	for <kirill.shutemov=
@linux.intel.com>; Thu, 10 Oct 2013 11:06:05 -0700 (PDT)=0AX-ExtLoop1: 1=0A=
X-IronPort-AV: E=3DSophos;i=3D"4.90,1073,1371106800"; =0A   d=3D"scan'208";=
a=3D"408987092"=0AReceived: from blue.fi.intel.com ([10.237.72.156])=0A  by=
 fmsmga001.fm.intel.com with ESMTP; 10 Oct 2013 11:06:05 -0700=0AReceived: =
by blue.fi.intel.com (Postfix, from userid 1000)=0A	id 2ECB7E0094; Thu, 10 =
Oct 2013 21:06:02 +0300 (EEST)=0AFrom: "Kirill A. Shutemov" <kirill.shutemo=
v@linux.intel.com>=0ATo: Andrew Morton <akpm@linux-foundation.org>,=0A	Pete=
r Zijlstra <peterz@infradead.org>,=0A	Ingo Molnar <mingo@redhat.com>=0ACc: =
linux-kernel@vger.kernel.org,=0A	linux-mm@kvack.org,=0A	linux-arch@vger.ker=
nel.org,=0A	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>=0ASubjec=
t: [PATCH 05/34] mm: allow pgtable_page_ctor() to fail=0ADate: Thu, 10 Oct =
2013 21:05:30 +0300=0AMessage-Id: <1381428359-14843-6-git-send-email-kirill=
=2Eshutemov@linux.intel.com>=0AX-Mailer: git-send-email 1.8.4.rc3=0AIn-Repl=
y-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>=
=0AReferences: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.int=
el.com>=0AStatus: RO=0AContent-Length: 966=0A=0AChange pgtable_page_ctor() =
return type from void to bool.=0AReturns true, if initialization is success=
ful and false otherwise.=0A=0ACurrent implementation never fails, but it wi=
ll change later.=0A=0ASigned-off-by: Kirill A. Shutemov <kirill.shutemov@li=
nux.intel.com>=0A---=0A include/linux/mm.h | 3 ++-=0A 1 file changed, 2 ins=
ertions(+), 1 deletion(-)=0A=0Adiff --git a/include/linux/mm.h b/include/li=
nux/mm.h=0Aindex 75735f6171..f6467032a9 100644=0A--- a/include/linux/mm.h=
=0A+++ b/include/linux/mm.h=0A@@ -1254,10 +1254,11 @@ static inline pmd_t *=
pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a=0A #define pte_=
lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})=0A #endif /* USE_=
SPLIT_PTE_PTLOCKS */=0A =0A-static inline void pgtable_page_ctor(struct pag=
e *page)=0A+static inline bool pgtable_page_ctor(struct page *page)=0A {=0A=
 	pte_lock_init(page);=0A 	inc_zone_page_state(page, NR_PAGETABLE);=0A+	ret=
urn true;=0A }=0A =0A static inline void pgtable_page_dtor(struct page *pag=
e)=0A-- =0A1.8.4.rc3=0A=0A=0AFrom kas@linux.intel.com Thu Oct 10 21:18:16 2=
013=0AReturn-Path: <kas@linux.intel.com>=0AX-Original-To: kirill.shutemov@l=
inux.intel.com=0ADelivered-To: kirill.shutemov@linux.intel.com=0AReceived: =
=66rom linux.jf.intel.com [10.23.219.25]=0A	by blue with POP3 (fetchmail-6.=
3.26)=0A	for <kas@localhost> (single-drop); Thu, 10 Oct 2013 21:18:16 +0300=
 (EEST)=0AReceived: from orsmga001.jf.intel.com (orsmga001.jf.intel.com [10=
=2E7.209.18])=0A	by linux.intel.com (Postfix) with ESMTP id B61C56A4004=0A	=
for <kirill.shutemov@linux.intel.com>; Thu, 10 Oct 2013 11:06:06 -0700 (PDT=
)=0AX-ExtLoop1: 1=0AX-IronPort-AV: E=3DSophos;i=3D"4.90,1073,1371106800"; =
=0A   d=3D"scan'208";a=3D"391219905"=0AReceived: from blue.fi.intel.com ([1=
0.237.72.156])=0A  by orsmga001.jf.intel.com with ESMTP; 10 Oct 2013 11:06:=
05 -0700=0AReceived: by blue.fi.intel.com (Postfix, from userid 1000)=0A	id=
 73BB1E009B; Thu, 10 Oct 2013 21:06:02 +0300 (EEST)=0AFrom: "Kirill A. Shut=
emov" <kirill.shutemov@linux.intel.com>=0ATo: Andrew Morton <akpm@linux-fou=
ndation.org>,=0A	Peter Zijlstra <peterz@infradead.org>,=0A	Ingo Molnar <min=
go@redhat.com>=0ACc: linux-kernel@vger.kernel.org,=0A	linux-mm@kvack.org,=
=0A	linux-arch@vger.kernel.org,=0A	"Kirill A. Shutemov" <kirill.shutemov@li=
nux.intel.com>,=0A	Russell King <linux@arm.linux.org.uk>=0ASubject: [PATCH =
11/34] arm: handle pgtable_page_ctor() fail=0ADate: Thu, 10 Oct 2013 21:05:=
36 +0300=0AMessage-Id: <1381428359-14843-12-git-send-email-kirill.shutemov@=
linux.intel.com>=0AX-Mailer: git-send-email 1.8.4.rc3=0AIn-Reply-To: <13814=
28359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>=0AReferences:=
 <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>=0AStat=
us: RO=0AContent-Length: 839=0A=0ASigned-off-by: Kirill A. Shutemov <kirill=
=2Eshutemov@linux.intel.com>=0ACc: Russell King <linux@arm.linux.org.uk>=0A=
---=0A arch/arm/include/asm/pgalloc.h | 12 +++++++-----=0A 1 file changed, =
7 insertions(+), 5 deletions(-)=0A=0Adiff --git a/arch/arm/include/asm/pgal=
loc.h b/arch/arm/include/asm/pgalloc.h=0Aindex 943504f53f..78a7793616 10064=
4=0A--- a/arch/arm/include/asm/pgalloc.h=0A+++ b/arch/arm/include/asm/pgall=
oc.h=0A@@ -102,12 +102,14 @@ pte_alloc_one(struct mm_struct *mm, unsigned l=
ong addr)=0A #else=0A 	pte =3D alloc_pages(PGALLOC_GFP, 0);=0A #endif=0A-	i=
f (pte) {=0A-		if (!PageHighMem(pte))=0A-			clean_pte_table(page_address(pt=
e));=0A-		pgtable_page_ctor(pte);=0A+	if (!pte)=0A+		return NULL;=0A+	if (!=
PageHighMem(pte))=0A+		clean_pte_table(page_address(pte));=0A+	if (!pgtable=
_page_ctor(pte)) {=0A+		__free_page(pte);=0A+		return NULL;=0A 	}=0A-=0A 	r=
eturn pte;=0A }=0A =0A-- =0A1.8.4.rc3=0A=0A=0AFrom kas@linux.intel.com Thu =
Oct 10 21:18:33 2013=0AReturn-Path: <kas@linux.intel.com>=0AX-Original-To: =
kirill.shutemov@linux.intel.com=0ADelivered-To: kirill.shutemov@linux.intel=
=2Ecom=0AReceived: from linux.jf.intel.com [10.23.219.25]=0A	by blue with P=
OP3 (fetchmail-6.3.26)=0A	for <kas@localhost> (single-drop); Thu, 10 Oct 20=
13 21:18:33 +0300 (EEST)=0AReceived: from fmsmga001.fm.intel.com (fmsmga001=
=2Efm.intel.com [10.253.24.23])=0A	by linux.intel.com (Postfix) with ESMTP =
id 5E5886A4004=0A	for <kirill.shutemov@linux.intel.com>; Thu, 10 Oct 2013 1=
1:06:11 -0700 (PDT)=0AX-ExtLoop1: 1=0AX-IronPort-AV: E=3DSophos;i=3D"4.90,1=
073,1371106800"; =0A   d=3D"scan'208";a=3D"408987118"=0AReceived: from blue=
=2Efi.intel.com ([10.237.72.156])=0A  by fmsmga001.fm.intel.com with ESMTP;=
 10 Oct 2013 11:06:10 -0700=0AReceived: by blue.fi.intel.com (Postfix, from=
 userid 1000)=0A	id 9B0F7E00B2; Thu, 10 Oct 2013 21:06:03 +0300 (EEST)=0AFr=
om: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>=0ATo: Andrew Mor=
ton <akpm@linux-foundation.org>,=0A	Peter Zijlstra <peterz@infradead.org>,=
=0A	Ingo Molnar <mingo@redhat.com>=0ACc: linux-kernel@vger.kernel.org,=0A	l=
inux-mm@kvack.org,=0A	linux-arch@vger.kernel.org,=0A	"Kirill A. Shutemov" <=
kirill.shutemov@linux.intel.com>=0ASubject: [PATCH 34/34] mm: dynamically a=
llocate page->ptl if it cannot be embedded to struct page=0ADate: Thu, 10 O=
ct 2013 21:05:59 +0300=0AMessage-Id: <1381428359-14843-35-git-send-email-ki=
rill.shutemov@linux.intel.com>=0AX-Mailer: git-send-email 1.8.4.rc3=0AIn-Re=
ply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>=
=0AReferences: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.int=
el.com>=0AStatus: RO=0AContent-Length: 10384=0A=0AIf split page table lock =
is in use, we embed the lock into struct page=0Aof table's page. We have to=
 disable split lock, if spinlock_t is too big=0Abe to be embedded, like whe=
n DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC enabled.=0A=0AThis patch add support f=
or dynamic allocation of split page table lock=0Aif we can't embed it to st=
ruct page.=0A=0Apage->ptl is unsigned long now and we use it as spinlock_t =
if=0Asizeof(spinlock_t) <=3D sizeof(long), otherwise it's pointer to=0Aspin=
lock_t.=0A=0AThe spinlock_t allocated in pgtable_page_ctor() for PTE table =
and in=0Apgtable_pmd_page_ctor() for PMD table. All other helpers converted=
 to=0Asupport dynamically allocated page->ptl.=0A=0ASigned-off-by: Kirill A=
=2E Shutemov <kirill.shutemov@linux.intel.com>=0A---=0A Documentation/vm/sp=
lit_page_table_lock | 90 ++++++++++++++++++++++++++++++++++=0A arch/x86/xen=
/mmu.c                     |  2 +-=0A include/linux/mm.h                   =
  | 72 +++++++++++++++++++--------=0A include/linux/mm_types.h             =
  |  5 +-=0A mm/Kconfig                             |  2 -=0A mm/memory.c  =
                          | 19 +++++++=0A 6 files changed, 166 insertions(+=
), 24 deletions(-)=0A create mode 100644 Documentation/vm/split_page_table_=
lock=0A=0Adiff --git a/Documentation/vm/split_page_table_lock b/Documentati=
on/vm/split_page_table_lock=0Anew file mode 100644=0Aindex 0000000000..e2f6=
17b732=0A--- /dev/null=0A+++ b/Documentation/vm/split_page_table_lock=0A@@ =
-0,0 +1,90 @@=0A+Split page table lock=0A+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A+=0A+Originally, mm->page_table_lock spinl=
ock protected all page tables of the=0A+mm_struct. But this approach leads =
to poor page fault scalability of=0A+multi-threaded applications due high c=
ontention on the lock. To improve=0A+scalability, split page table lock was=
 introduced.=0A+=0A+With split page table lock we have separate per-table l=
ock to serialize=0A+access to the table. At the moment we use split lock fo=
r PTE and PMD=0A+tables. Access to higher level tables protected by mm->pag=
e_table_lock.=0A+=0A+There are helpers to lock/unlock a table and other acc=
essor functions:=0A+ - pte_offset_map_lock()=0A+	maps pte and takes PTE tab=
le lock, returns pointer to the taken=0A+	lock;=0A+ - pte_unmap_unlock()=0A=
+	unlocks and unmaps PTE table;=0A+ - pte_alloc_map_lock()=0A+	allocates PT=
E table if needed and take the lock, returns pointer=0A+	to taken lock or N=
ULL if allocation failed;=0A+ - pte_lockptr()=0A+	returns pointer to PTE ta=
ble lock;=0A+ - pmd_lock()=0A+	takes PMD table lock, returns pointer to tak=
en lock;=0A+ - pmd_lockptr()=0A+	returns pointer to PMD table lock;=0A+=0A+=
Split page table lock for PTE tables is enabled compile-time if=0A+CONFIG_S=
PLIT_PTLOCK_CPUS (usually 4) is less or equal to NR_CPUS.=0A+If split lock =
is disabled, all tables guaded by mm->page_table_lock.=0A+=0A+Split page ta=
ble lock for PMD tables is enabled, if it's enabled for PTE=0A+tables and t=
he architecture supports it (see below).=0A+=0A+Hugetlb and split page tabl=
e lock=0A+---------------------------------=0A+=0A+Hugetlb can support seve=
ral page sizes. We use split lock only for PMD=0A+level, but not for PUD.=
=0A+=0A+Hugetlb-specific helpers:=0A+ - huge_pte_lock()=0A+	takes pmd split=
 lock for PMD_SIZE page, mm->page_table_lock=0A+	otherwise;=0A+ - huge_pte_=
lockptr()=0A+	returns pointer to table lock;=0A+=0A+Support of split page t=
able lock by an architecture=0A+-------------------------------------------=
--------=0A+=0A+There's no need in special enabling of PTE split page table=
 lock:=0A+everything required is done by pgtable_page_ctor() and pgtable_pa=
ge_dtor(),=0A+which must be called on PTE table allocation / freeing.=0A+=
=0A+PMD split lock only makes sense if you have more than two page table=0A=
+levels.=0A+=0A+PMD split lock enabling requires pgtable_pmd_page_ctor() ca=
ll on PMD table=0A+allocation and pgtable_pmd_page_dtor() on freeing.=0A+=
=0A+Allocation usually happens in pmd_alloc_one(), freeing in pmd_free(), b=
ut=0A+make sure you cover all PMD table allocation / freeing paths: i.e X86=
_PAE=0A+preallocate few PMDs on pgd_alloc().=0A+=0A+With everything in plac=
e you can set CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK.=0A+=0A+NOTE: pgtable_pag=
e_ctor() and pgtable_pmd_page_ctor() can fail -- it must=0A+be handled prop=
erly.=0A+=0A+page->ptl=0A+---------=0A+=0A+page->ptl is used to access spli=
t page table lock, where 'page' is struct=0A+page of page containing the ta=
ble. It shares storage with page->private=0A+(and few other fields in union=
).=0A+=0A+To avoid increasing size of struct page and have best performance=
, we use a=0A+trick:=0A+ - if spinlock_t fits into long, we use page->ptr a=
s spinlock, so we=0A+   can avoid indirect access and save a cache line.=0A=
+ - if size of spinlock_t is bigger then size of long, we use page->ptl as=
=0A+   pointer to spinlock_t and allocate it dynamically. This allows to us=
e=0A+   split lock with enabled DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC, but cos=
ts=0A+   one more cache line for indirect access;=0A+=0A+The spinlock_t all=
ocated in pgtable_page_ctor() for PTE table and in=0A+pgtable_pmd_page_ctor=
() for PMD table.=0A+=0A+Please, never access page->ptl directly -- use app=
ropriate helper.=0Adiff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c=0Ai=
ndex 455c873ce0..49c962fe7e 100644=0A--- a/arch/x86/xen/mmu.c=0A+++ b/arch/=
x86/xen/mmu.c=0A@@ -797,7 +797,7 @@ static spinlock_t *xen_pte_lock(struct =
page *page, struct mm_struct *mm)=0A 	spinlock_t *ptl =3D NULL;=0A =0A #if =
USE_SPLIT_PTE_PTLOCKS=0A-	ptl =3D __pte_lockptr(page);=0A+	ptl =3D ptlock_p=
tr(page);=0A 	spin_lock_nest_lock(ptl, &mm->page_table_lock);=0A #endif=0A =
=0Adiff --git a/include/linux/mm.h b/include/linux/mm.h=0Aindex f6467032a9.=
=2E658e8b317f 100644=0A--- a/include/linux/mm.h=0A+++ b/include/linux/mm.h=
=0A@@ -1233,32 +1233,64 @@ static inline pmd_t *pmd_alloc(struct mm_struct =
*mm, pud_t *pud, unsigned long a=0A #endif /* CONFIG_MMU && !__ARCH_HAS_4LE=
VEL_HACK */=0A =0A #if USE_SPLIT_PTE_PTLOCKS=0A-/*=0A- * We tuck a spinlock=
 to guard each pagetable page into its struct page,=0A- * at page->private,=
 with BUILD_BUG_ON to make sure that this will not=0A- * overflow into the =
next struct page (as it might with DEBUG_SPINLOCK).=0A- * When freeing, res=
et page->mapping so free_pages_check won't complain.=0A- */=0A-#define __pt=
e_lockptr(page)	&((page)->ptl)=0A-#define pte_lock_init(_page)	do {					\=
=0A-	spin_lock_init(__pte_lockptr(_page));				\=0A-} while (0)=0A-#define p=
te_lock_deinit(page)	((page)->mapping =3D NULL)=0A-#define pte_lockptr(mm, =
pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})=0A+bool __ptlock_allo=
c(struct page *page);=0A+void __ptlock_free(struct page *page);=0A+static i=
nline bool ptlock_alloc(struct page *page)=0A+{=0A+	if (sizeof(spinlock_t) =
> sizeof(page->ptl))=0A+		return __ptlock_alloc(page);=0A+	return true;=0A+=
}=0A+static inline void ptlock_free(struct page *page)=0A+{=0A+	if (sizeof(=
spinlock_t) > sizeof(page->ptl))=0A+		__ptlock_free(page);=0A+}=0A+=0A+stat=
ic inline spinlock_t *ptlock_ptr(struct page *page)=0A+{=0A+	if (sizeof(spi=
nlock_t) > sizeof(page->ptl))=0A+		return (spinlock_t *) page->ptl;=0A+	els=
e=0A+		return (spinlock_t *) &page->ptl;=0A+}=0A+=0A+static inline spinlock=
_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)=0A+{=0A+	return ptlock_pt=
r(pmd_page(*pmd));=0A+}=0A+=0A+static inline bool ptlock_init(struct page *=
page)=0A+{=0A+	if (!ptlock_alloc(page))=0A+		return false;=0A+	spin_lock_in=
it(ptlock_ptr(page));=0A+	return true;=0A+}=0A+=0A+/* Reset page->mapping s=
o free_pages_check won't complain. */=0A+static inline void pte_lock_deinit=
(struct page *page)=0A+{=0A+	page->mapping =3D NULL;=0A+	ptlock_free(page);=
=0A+}=0A+=0A #else	/* !USE_SPLIT_PTE_PTLOCKS */=0A /*=0A  * We use mm->page=
_table_lock to guard all pagetable pages of the mm.=0A  */=0A-#define pte_l=
ock_init(page)	do {} while (0)=0A-#define pte_lock_deinit(page)	do {} while=
 (0)=0A-#define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;=
})=0A+static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pm=
d)=0A+{=0A+	return &mm->page_table_lock;=0A+}=0A+static inline bool ptlock_=
init(struct page *page) { return true; }=0A+static inline void pte_lock_dei=
nit(struct page *page) {}=0A #endif /* USE_SPLIT_PTE_PTLOCKS */=0A =0A stat=
ic inline bool pgtable_page_ctor(struct page *page)=0A {=0A-	pte_lock_init(=
page);=0A 	inc_zone_page_state(page, NR_PAGETABLE);=0A-	return true;=0A+	re=
turn ptlock_init(page);=0A }=0A =0A static inline void pgtable_page_dtor(st=
ruct page *page)=0A@@ -1299,16 +1331,15 @@ static inline void pgtable_page_=
dtor(struct page *page)=0A =0A static inline spinlock_t *pmd_lockptr(struct=
 mm_struct *mm, pmd_t *pmd)=0A {=0A-	return &virt_to_page(pmd)->ptl;=0A+	re=
turn ptlock_ptr(virt_to_page(pmd));=0A }=0A =0A static inline bool pgtable_=
pmd_page_ctor(struct page *page)=0A {=0A-	spin_lock_init(&page->ptl);=0A #i=
fdef CONFIG_TRANSPARENT_HUGEPAGE=0A 	page->pmd_huge_pte =3D NULL;=0A #endif=
=0A-	return true;=0A+	return ptlock_init(page);=0A }=0A =0A static inline v=
oid pgtable_pmd_page_dtor(struct page *page)=0A@@ -1316,6 +1347,7 @@ static=
 inline void pgtable_pmd_page_dtor(struct page *page)=0A #ifdef CONFIG_TRAN=
SPARENT_HUGEPAGE=0A 	VM_BUG_ON(page->pmd_huge_pte);=0A #endif=0A+	ptlock_fr=
ee(page);=0A }=0A =0A #define pmd_huge_pte(mm, pmd) (virt_to_page(pmd)->pmd=
_huge_pte)=0Adiff --git a/include/linux/mm_types.h b/include/linux/mm_types=
=2Eh=0Aindex bacc15f078..257ac12fac 100644=0A--- a/include/linux/mm_types.h=
=0A+++ b/include/linux/mm_types.h=0A@@ -147,7 +147,10 @@ struct page {=0A 	=
					 * system if PG_buddy is set.=0A 						 */=0A #if USE_SPLIT_PTE_PTLOCK=
S=0A-		spinlock_t ptl;=0A+		unsigned long ptl; /* It's spinlock_t if it fit=
s to long,=0A+				    * otherwise it's pointer to dynamicaly=0A+				    * a=
llocated spinlock_t.=0A+				    */=0A #endif=0A 		struct kmem_cache *slab_c=
ache;	/* SL[AU]B: Pointer to slab */=0A 		struct page *first_page;	/* Compo=
und tail pages */=0Adiff --git a/mm/Kconfig b/mm/Kconfig=0Aindex d19f7d380b=
=2E.9e8c8ae3b6 100644=0A--- a/mm/Kconfig=0A+++ b/mm/Kconfig=0A@@ -211,8 +21=
1,6 @@ config SPLIT_PTLOCK_CPUS=0A 	int=0A 	default "999999" if ARM && !CPU=
_CACHE_VIPT=0A 	default "999999" if PARISC && !PA20=0A-	default "999999" if=
 DEBUG_SPINLOCK || DEBUG_LOCK_ALLOC=0A-	default "999999" if !64BIT && GENER=
IC_LOCKBREAK=0A 	default "4"=0A =0A config ARCH_ENABLE_SPLIT_PMD_PTLOCK=0Ad=
iff --git a/mm/memory.c b/mm/memory.c=0Aindex 1200d6230c..7e11f745bc 100644=
=0A--- a/mm/memory.c=0A+++ b/mm/memory.c=0A@@ -4330,3 +4330,22 @@ void copy=
_user_huge_page(struct page *dst, struct page *src,=0A 	}=0A }=0A #endif /*=
 CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */=0A+=0A+#if USE_SPLIT_PT=
E_PTLOCKS=0A+bool __ptlock_alloc(struct page *page)=0A+{=0A+	spinlock_t *pt=
l;=0A+=0A+	ptl =3D kmalloc(sizeof(spinlock_t), GFP_KERNEL);=0A+	if (!ptl)=
=0A+		return false;=0A+	page->ptl =3D (unsigned long)ptl;=0A+	return true;=
=0A+}=0A+=0A+void __ptlock_free(struct page *page)=0A+{=0A+	if (sizeof(spin=
lock_t) > sizeof(page->ptl))=0A+		kfree((spinlock_t *)page->ptl);=0A+}=0A+#=
endif=0A-- =0A1.8.4.rc3=0A=0A=0A
--ZGiS0Q5IWpPtfppv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
