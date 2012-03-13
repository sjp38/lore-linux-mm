Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D3A136B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 09:20:23 -0400 (EDT)
Received: by eeke53 with SMTP id e53so234726eek.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 06:20:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 13 Mar 2012 21:20:21 +0800
Message-ID: <CAJd=RBAHYi-BOXBO+u0u9-C=35Lu=ow=L77w2WSsndUBxVKf9w@mail.gmail.com>
Subject: Re: [PATCH -V3 3/8] hugetlb: add charge/uncharge calls for HugeTLB alloc/free
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, Mar 13, 2012 at 3:07 PM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> This adds necessary charge/uncharge calls in the HugeTLB code
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> =C2=A0mm/hugetlb.c =C2=A0 =C2=A0| =C2=A0 21 ++++++++++++++++++++-
> =C2=A0mm/memcontrol.c | =C2=A0 =C2=A05 +++++
> =C2=A02 files changed, 25 insertions(+), 1 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index fe7aefd..b7152d1 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -21,6 +21,8 @@
> =C2=A0#include <linux/rmap.h>
> =C2=A0#include <linux/swap.h>
> =C2=A0#include <linux/swapops.h>
> +#include <linux/memcontrol.h>
> +#include <linux/page_cgroup.h>
>
> =C2=A0#include <asm/page.h>
> =C2=A0#include <asm/pgtable.h>
> @@ -542,6 +544,9 @@ static void free_huge_page(struct page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(page_mapcount(page));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&page->lru);
>
> + =C2=A0 =C2=A0 =C2=A0 if (mapping)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_hugetlb_unc=
harge_page(h - hstates,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0pages_per_huge_page(h), page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&hugetlb_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (h->surplus_huge_pages_node[nid] && huge_pa=
ge_order(h) < MAX_ORDER) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0update_and_free_pa=
ge(h, page);
> @@ -1019,12 +1024,15 @@ static void vma_commit_reservation(struct hstate =
*h,
> =C2=A0static struct page *alloc_huge_page(struct vm_area_struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long addr, int=
 avoid_reserve)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 int ret, idx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct hstate *h =3D hstate_vma(vma);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_space *mapping =3D vma->vm_file=
->f_mapping;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct inode *inode =3D mapping->host;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0long chg;
>
> + =C2=A0 =C2=A0 =C2=A0 idx =3D h - hstates;

Better if hstate index is computed with a tiny inline helper?
Other than that,

Acked-by: Hillf Danton <dhillf@gmail.com>

> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Processes that did not create the mapping w=
ill have no reserves and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * will not have accounted against quota. Chec=
k that the quota can be
> @@ -1039,6 +1047,12 @@ static struct page *alloc_huge_page(struct vm_area=
_struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (hugetlb_get_qu=
ota(inode->i_mapping, chg))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return ERR_PTR(-VM_FAULT_SIGBUS);
>
> + =C2=A0 =C2=A0 =C2=A0 ret =3D mem_cgroup_hugetlb_charge_page(idx, pages_=
per_huge_page(h),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0&memcg);
> + =C2=A0 =C2=A0 =C2=A0 if (ret) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hugetlb_put_quota(inod=
e->i_mapping, chg);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ERR_PTR(-VM_FAU=
LT_SIGBUS);
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&hugetlb_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D dequeue_huge_page_vma(h, vma, addr, a=
void_reserve);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&hugetlb_lock);
> @@ -1046,6 +1060,9 @@ static struct page *alloc_huge_page(struct vm_area_=
struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D alloc_bud=
dy_huge_page(h, NUMA_NO_NODE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mem_cgroup_hugetlb_uncharge_memcg(idx,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pages_per_huge_page(h),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memcg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0hugetlb_put_quota(inode->i_mapping, chg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return ERR_PTR(-VM_FAULT_SIGBUS);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -1054,7 +1071,9 @@ static struct page *alloc_huge_page(struct vm_area_=
struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0set_page_private(page, (unsigned long) mapping=
);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0vma_commit_reservation(h, vma, addr);
> -
> + =C2=A0 =C2=A0 =C2=A0 /* update page cgroup details */
> + =C2=A0 =C2=A0 =C2=A0 mem_cgroup_hugetlb_commit_charge(idx, pages_per_hu=
ge_page(h),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memcg,=
 page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return page;
> =C2=A0}
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8cac77b..f4aa11c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2901,6 +2901,11 @@ __mem_cgroup_uncharge_common(struct page *page, en=
um charge_type ctype)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageSwapCache(page))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* HugeTLB page uncharge happen in the HugeTL=
B compound page destructor
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (PageHuge(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageTransHuge(page)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_pages <<=3D com=
pound_order(page);
> --
> 1.7.9
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
