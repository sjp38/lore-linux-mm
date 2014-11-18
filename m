Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2096B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 18:44:20 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so5001705pdj.35
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:44:20 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id uc9si38537pac.130.2014.11.18.15.44.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 15:44:19 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
Date: Tue, 18 Nov 2014 23:41:08 +0000
Message-ID: <20141118234145.GA4116@hori1.linux.bs1.fc.nec.co.jp>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
 <20141118084337.GA16714@hori1.linux.bs1.fc.nec.co.jp>
 <20141118095811.GA21774@node.dhcp.inet.fi>
In-Reply-To: <20141118095811.GA21774@node.dhcp.inet.fi>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0ACED6FBA3CFB049B5DB2D7AC4EB0B4F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Nov 18, 2014 at 11:58:11AM +0200, Kirill A. Shutemov wrote:
> On Tue, Nov 18, 2014 at 08:43:00AM +0000, Naoya Horiguchi wrote:
> > > @@ -1837,6 +1839,9 @@ static void __split_huge_page_refcount(struct p=
age *page,
> > >  	atomic_sub(tail_count, &page->_count);
> > >  	BUG_ON(atomic_read(&page->_count) <=3D 0);
> > > =20
> > > +	page->_mapcount =3D *compound_mapcount_ptr(page);
> >=20
> > Is atomic_set() necessary?
>=20
> Do you mean
> 	atomic_set(&page->_mapcount, atomic_read(compound_mapcount_ptr(page)));
> ?
>=20
> I don't see why we would need this. Simple assignment should work just
> fine. Or we have archs which will break?

Sorry, I was wrong, please ignore this comment.

> > > @@ -6632,10 +6637,12 @@ static void dump_page_flags(unsigned long fla=
gs)
> > >  void dump_page_badflags(struct page *page, const char *reason,
> > >  		unsigned long badflags)
> > >  {
> > > -	printk(KERN_ALERT
> > > -	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
> > > +	pr_alert("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
> > >  		page, atomic_read(&page->_count), page_mapcount(page),
> > >  		page->mapping, page->index);
> > > +	if (PageCompound(page))
> >=20
> > > +		printk(" compound_mapcount: %d", compound_mapcount(page));
> > > +	printk("\n");
> >=20
> > These two printk() should be pr_alert(), too?
>=20
> No. It will split the line into several messages in dmesg.

This splitting is fine. I meant that these printk()s are for one series
of message, so setting the same log level looks reasonable to me.

> > > @@ -986,9 +986,30 @@ void page_add_anon_rmap(struct page *page,
> > >  void do_page_add_anon_rmap(struct page *page,
> > >  	struct vm_area_struct *vma, unsigned long address, int flags)
> > >  {
> > > -	int first =3D atomic_inc_and_test(&page->_mapcount);
> > > +	bool compound =3D flags & RMAP_COMPOUND;
> > > +	bool first;
> > > +
> > > +	VM_BUG_ON_PAGE(!PageLocked(compound_head(page)), page);
> > > +
> > > +	if (PageTransCompound(page)) {
> > > +		struct page *head_page =3D compound_head(page);
> > > +
> > > +		if (compound) {
> > > +			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > > +			first =3D atomic_inc_and_test(compound_mapcount_ptr(page));
> >=20
> > Is compound_mapcount_ptr() well-defined for tail pages?
>=20
> The page is head page, otherwise VM_BUG_ON on the line above would trigge=
r.

Ah, OK.

Thanks,
Naoya Horiguchi

> > > @@ -1032,10 +1052,19 @@ void page_add_new_anon_rmap(struct page *page=
,
> > > =20
> > >  	VM_BUG_ON(address < vma->vm_start || address >=3D vma->vm_end);
> > >  	SetPageSwapBacked(page);
> > > -	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) =
*/
> > >  	if (compound) {
> > > +		atomic_t *compound_mapcount;
> > > +
> > >  		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > > +		compound_mapcount =3D (atomic_t *)&page[1].mapping;
> >=20
> > You can use compound_mapcount_ptr() here.
>=20
> Right, thanks.
>=20
> --=20
>  Kirill A. Shutemov
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
