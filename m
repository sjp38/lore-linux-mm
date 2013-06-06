Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 54A076B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 18:42:45 -0400 (EDT)
Date: Thu, 6 Jun 2013 17:42:39 -0500
From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH -V7 09/18] powerpc: Switch 16GB and 16MB explicit
 hugepages to a different page table format
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1367177859-7893-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367177859-7893-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> (from
	aneesh.kumar@linux.vnet.ibm.com on Sun Apr 28 14:37:30 2013)
Message-ID: <1370558559.32518.4@snotra>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; delsp=Yes; format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On 04/28/2013 02:37:30 PM, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> We will be switching PMD_SHIFT to 24 bits to facilitate THP =20
> impmenetation.
> With PMD_SHIFT set to 24, we now have 16MB huge pages allocated at =20
> PGD level.
> That means with 32 bit process we cannot allocate normal pages at
> all, because we cover the entire address space with one pgd entry. =20
> Fix this
> by switching to a new page table format for hugepages. With the new =20
> page table
> format for 16GB and 16MB hugepages we won't allocate hugepage =20
> directory. Instead
> we encode the PTE information directly at the directory level. This =20
> forces 16MB
> hugepage at PMD level. This will also make the page take walk much =20
> simpler later
> when we add the THP support.
>=20
> With the new table format we have 4 cases for pgds and pmds:
> (1) invalid (all zeroes)
> (2) pointer to next table, as normal; bottom 6 bits =3D=3D 0
> (3) leaf pte for huge page, bottom two bits !=3D 00
> (4) hugepd pointer, bottom two bits =3D=3D 00, next 4 bits indicate size =
=20
> of table
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/page.h    |   2 +
>  arch/powerpc/include/asm/pgtable.h |   2 +
>  arch/powerpc/mm/gup.c              |  18 +++-
>  arch/powerpc/mm/hugetlbpage.c      | 176 =20
> +++++++++++++++++++++++++++++++------
>  4 files changed, 168 insertions(+), 30 deletions(-)

After this patch, on 64-bit book3e (e5500, and thus 4K pages), I see =20
messages like this after exiting a program that uses hugepages =20
(specifically, qemu):

/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc221516.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc221516.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc2214d6.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc2214d6.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc221916.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc221916.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc2218d6.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc2218d6.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc221496.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc221496.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc221856.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc221856.
/home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd =20
40000001fc221816.

-Scott=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
