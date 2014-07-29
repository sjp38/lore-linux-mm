Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C9AA56B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 21:56:13 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so10800195pdj.22
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 18:56:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id nb9si9801075pdb.209.2014.07.28.18.56.12
        for <linux-mm@kvack.org>;
        Mon, 28 Jul 2014 18:56:12 -0700 (PDT)
From: "Zhang, Tianfei" <tianfei.zhang@intel.com>
Subject: RE: [PATCH v8 05/22] Add vm_replace_mixed()
Date: Tue, 29 Jul 2014 01:55:17 +0000
Message-ID: <BA6F50564D52C24884F9840E07E32DEC17D74A50@CDSMSX102.ccr.corp.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <b1052af08b49965fd0e6b87b6733b89294c8cc1e.1406058387.git.matthew.r.wilcox@intel.com>
 <20140723114540.GD10317@node.dhcp.inet.fi>
 <20140723135221.GA6754@linux.intel.com>
 <20140723142048.GA11963@node.dhcp.inet.fi>
 <20140723142745.GD6754@linux.intel.com>
 <20140723155500.GA12790@node.dhcp.inet.fi>
 <20140725194450.GJ6754@linux.intel.com>
 <20140728132558.GA967@node.dhcp.inet.fi>
In-Reply-To: <20140728132558.GA967@node.dhcp.inet.fi>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@linux.intel.com>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Kirill A. Shutemov
> Sent: Monday, July 28, 2014 9:26 PM
> To: Matthew Wilcox
> Cc: Wilcox, Matthew R; linux-fsdevel@vger.kernel.org; linux-mm@kvack.org;
> linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v8 05/22] Add vm_replace_mixed()
>=20
> On Fri, Jul 25, 2014 at 03:44:50PM -0400, Matthew Wilcox wrote:
> > On Wed, Jul 23, 2014 at 06:55:00PM +0300, Kirill A. Shutemov wrote:
> > > >         update_hiwater_rss(mm);
> > >
> > > No: you cannot end up with lower rss after replace, iiuc.
> >
> > Actually, you can ... when we replace a real page with a PFN, our rss
> > decreases.
>=20
> Okay.
>=20
> > > Do you mean you pointed to new file all the time? O_CREAT doesn't
> > > truncate file if it exists, iirc.
> >
> > It was pointing to a new file.  Still not sure why that one failed to
> > trigger the problem.  The slightly modified version attached triggered
> > the problem *just fine* :-)
> >
> > I've attached all the patches in my tree so far.  For the v9 patch
> > kit, I'll keep patch 3 as a separate patch, but roll patches 1, 2 and
> > 4 into other patches.
> >
> > I am seeing something odd though.  When I run double-map with
> > debugging printks inserted in strategic spots in the kernel, I see
> > four calls to do_dax_fault().  The first two, as expected, are the
> > loads from the two mapped addresses.  The third is via mkwrite, but
> > then the fourth time I get a regular page fault for write, and I don't
> understand why I get it.
> >
> > Any ideas?
>=20
> unmap_mapping_range() clears pte you've just set by vm_replace_mixed() on
> third fault.
>=20
> And locking looks wrong: it seems you need to hold i_mmap_mutex while
> replacing hole page with pfn. Your VM_BUG_ON() in zap_pte_single() trigge=
rs
> on my setup.
>=20
> > +static void zap_pte_single(struct vm_area_struct *vma, pte_t *pte,
> > +				unsigned long addr)
> > +{
> > +	struct mm_struct *mm =3D vma->vm_mm;
> > +	int force_flush =3D 0;
> > +	int rss[NR_MM_COUNTERS];
> > +
> > +
> 	VM_BUG_ON(!mutex_is_locked(&vma->vm_file->f_mapping->i_mmap_m
> utex));
>=20
> It's wrong place for VM_BUG_ON(): zap_pte_single() on anon mapping should
> work fine)

Hi Shutemov:
1. I am confuse that why insert_page() drop the PageAnon, insert_pfn() dono=
t drop PageAnon?

2.=20
remap_vmalloc_range() -> vm_insert_page()->insert_page() -> inc_mm_counter_=
fast(mm, MM_FILEPAGES);

so, in this scenario, this vmalloc page maybe not sure be a page cache, why=
 increase the MM_FILEPAGES ?


>=20
> > +
> > +	init_rss_vec(rss);
>=20
> Vector to commit single update to mm counters? What about inline counters
> update for rss =3D=3D NULL case?
>=20
> > +	update_hiwater_rss(mm);
> > +	flush_cache_page(vma, addr, pte_pfn(*pte));
> > +	zap_pte(NULL, vma, pte, addr, NULL, rss, &force_flush);
> > +	flush_tlb_page(vma, addr);
> > +	add_mm_rss_vec(mm, rss);
> > +}
> > +
>=20
> --
>  Kirill A. Shutemov
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in the body to
> majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
