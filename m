Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id C8B636B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 06:25:01 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Mar 2012 15:54:58 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2EAMcMo250092
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 15:52:38 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2EFrCqJ020247
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 02:53:13 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 3/8] hugetlb: add charge/uncharge calls for HugeTLB alloc/free
In-Reply-To: <CAJd=RBAHYi-BOXBO+u0u9-C=35Lu=ow=L77w2WSsndUBxVKf9w@mail.gmail.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <CAJd=RBAHYi-BOXBO+u0u9-C=35Lu=ow=L77w2WSsndUBxVKf9w@mail.gmail.com>
Date: Wed, 14 Mar 2012 15:52:28 +0530
Message-ID: <87wr6n8ot7.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 21:20:21 +0800, Hillf Danton <dhillf@gmail.com> wrote:
> On Tue, Mar 13, 2012 at 3:07 PM, Aneesh Kumar K.V
> <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >
> > This adds necessary charge/uncharge calls in the HugeTLB code
> >
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > ---
> > =C2=A0mm/hugetlb.c =C2=A0 =C2=A0| =C2=A0 21 ++++++++++++++++++++-
> > =C2=A0mm/memcontrol.c | =C2=A0 =C2=A05 +++++
> > =C2=A02 files changed, 25 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index fe7aefd..b7152d1 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -21,6 +21,8 @@
> > =C2=A0#include <linux/rmap.h>
> > =C2=A0#include <linux/swap.h>
> > =C2=A0#include <linux/swapops.h>
> > +#include <linux/memcontrol.h>
> > +#include <linux/page_cgroup.h>
> >
> > =C2=A0#include <asm/page.h>
> > =C2=A0#include <asm/pgtable.h>
> > @@ -542,6 +544,9 @@ static void free_huge_page(struct page *page)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(page_mapcount(page));
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&page->lru);
> >
> > + =C2=A0 =C2=A0 =C2=A0 if (mapping)
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_hugetlb_u=
ncharge_page(h - hstates,
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0pages_per_huge_page(h), page);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&hugetlb_lock);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (h->surplus_huge_pages_node[nid] && huge_=
page_order(h) < MAX_ORDER) {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0update_and_free_=
page(h, page);
> > @@ -1019,12 +1024,15 @@ static void vma_commit_reservation(struct hstat=
e *h,
> > =C2=A0static struct page *alloc_huge_page(struct vm_area_struct *vma,
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long addr, =
int avoid_reserve)
> > =C2=A0{
> > + =C2=A0 =C2=A0 =C2=A0 int ret, idx;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct hstate *h =3D hstate_vma(vma);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
> > + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D NULL;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_space *mapping =3D vma->vm_fi=
le->f_mapping;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct inode *inode =3D mapping->host;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0long chg;
> >
> > + =C2=A0 =C2=A0 =C2=A0 idx =3D h - hstates;
>=20
> Better if hstate index is computed with a tiny inline helper?
> Other than that,

Will update in the next iteration.

>=20
> Acked-by: Hillf Danton <dhillf@gmail.com>
>=20

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
