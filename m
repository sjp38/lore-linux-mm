Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 404706B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 07:34:50 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so17166705wiv.1
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 04:34:49 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0085.outbound.protection.outlook.com. [157.55.234.85])
        by mx.google.com with ESMTPS id dw9si13636064wib.9.2014.12.01.04.34.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Dec 2014 04:34:49 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: RE: [PATCH 1/5] mm: Refactor do_wp_page, extract the reuse case
Date: Mon, 1 Dec 2014 12:34:30 +0000
Message-ID: <297b07d8c87a4077a7140d39a68c1eb0@AM3PR05MB0935.eurprd05.prod.outlook.com>
References: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
 <1417435485-24629-2-git-send-email-raindel@mellanox.com>
 <20141201123038.GA13856@node.dhcp.inet.fi>
In-Reply-To: <20141201123038.GA13856@node.dhcp.inet.fi>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mgorman@suse.de" <mgorman@suse.de>, "riel@redhat.com" <riel@redhat.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "matthew.r.wilcox@intel.com" <matthew.r.wilcox@intel.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Haggai Eran <haggaie@mellanox.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "pfeiner@google.com" <pfeiner@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Sagi
 Grimberg <sagig@mellanox.com>, "walken@google.com" <walken@google.com>



> -----Original Message-----
> From: Kirill A. Shutemov [mailto:kirill@shutemov.name]
> Sent: Monday, December 01, 2014 2:31 PM
> To: Shachar Raindel
> Cc: linux-mm@kvack.org; kirill.shutemov@linux.intel.com;
> mgorman@suse.de; riel@redhat.com; ak@linux.intel.com;
> matthew.r.wilcox@intel.com; dave.hansen@linux.intel.com; n-
> horiguchi@ah.jp.nec.com; akpm@linux-foundation.org; torvalds@linux-
> foundation.org; Haggai Eran; aarcange@redhat.com; pfeiner@google.com;
> hannes@cmpxchg.org; Sagi Grimberg; walken@google.com
> Subject: Re: [PATCH 1/5] mm: Refactor do_wp_page, extract the reuse case
>=20
> On Mon, Dec 01, 2014 at 02:04:41PM +0200, Shachar Raindel wrote:
> > When do_wp_page is ending, in several cases it needs to reuse the
> > existing page. This is achieved by making the page table writable,
> > and possibly updating the page-cache state.
> >
> > Currently, this logic was "called" by using a goto jump. This makes
> > following the control flow of the function harder. It is also
> > against the coding style guidelines for using goto.
> >
> > As the code can easily be refactored into a specialized function,
> > refactor it out and simplify the code flow in do_wp_page.
> >
> > Signed-off-by: Shachar Raindel <raindel@mellanox.com>
> > ---
> >  mm/memory.c | 136 ++++++++++++++++++++++++++++++++++-----------------
> ---------
> >  1 file changed, 78 insertions(+), 58 deletions(-)
> >
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 3e50383..61334e9 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2020,6 +2020,75 @@ static int do_page_mkwrite(struct
> vm_area_struct *vma, struct page *page,
> >  }
> >
> >  /*
> > + * Handle write page faults for pages that can be reused in the
> current vma
> > + *
> > + * This can happen either due to the mapping being with the VM_SHARED
> flag,
> > + * or due to us being the last reference standing to the page. In
> either
> > + * case, all we need to do here is to mark the page as writable and
> update
> > + * any related book-keeping.
> > + */
> > +static int wp_page_reuse(struct mm_struct *mm, struct vm_area_struct
> *vma,
> > +			 unsigned long address, pte_t *page_table,
> > +			 spinlock_t *ptl, pte_t orig_pte,
> > +			 struct page *recycled_page, int dirty_page,
>=20
> recycled_page? what's wrong with old_page?
>=20

You are reusing the page in this function, so I was feeling that naming it
"old" is less indicative than "recycled". However, if you prefer "old", I
am happy with it.

> Otherwise:
>=20
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>=20

Thanks :)

--Shachar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
