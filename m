Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 996B48E004D
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 23:48:33 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k66so12287968qkf.1
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:48:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x46si4975321qth.369.2018.12.10.20.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 20:48:32 -0800 (PST)
Date: Tue, 11 Dec 2018 12:48:25 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH] mm: thp: fix soft dirty for migration when split
Message-ID: <20181211044825.GA3260@xz-x1>
References: <20181206084604.17167-1-peterx@redhat.com>
 <20181207033407.GB10726@xz-x1>
 <CALYGNiMjWDL6XaOFgfrM1WR6_GnmxfLBXwJ=YYGVNfEKNX0MfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALYGNiMjWDL6XaOFgfrM1WR6_GnmxfLBXwJ=YYGVNfEKNX0MfQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, dave.jiang@intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, jrdr.linux@gmail.com, =?utf-8?B?0JrQvtC90YHRgtCw0L3RgtC40L0g0KXQu9C10LHQvdC40LrQvtCy?= <khlebnikov@yandex-team.ru>, linux-mm@kvack.org

On Mon, Dec 10, 2018 at 07:50:52PM +0300, Konstantin Khlebnikov wrote:
> On Fri, Dec 7, 2018 at 6:34 AM Peter Xu <peterx@redhat.com> wrote:
> >
> > On Thu, Dec 06, 2018 at 04:46:04PM +0800, Peter Xu wrote:
> > > When splitting a huge migrating PMD, we'll transfer the soft dirty bit
> > > from the huge page to the small pages.  However we're possibly using a
> > > wrong data since when fetching the bit we're using pmd_soft_dirty()
> > > upon a migration entry.  Fix it up.
> >
> > Note that if my understanding is correct about the problem then if
> > without the patch there is chance to lose some of the dirty bits in
> > the migrating pmd pages (on x86_64 we're fetching bit 11 which is part
> > of swap offset instead of bit 2) and it could potentially corrupt the
> > memory of an userspace program which depends on the dirty bit.
> 
> It seems this code is broken in case of pmd_migraion:
> 
> old_pmd = pmdp_invalidate(vma, haddr, pmd);
> 
> #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> pmd_migration = is_pmd_migration_entry(old_pmd);
> if (pmd_migration) {
> swp_entry_t entry;
> 
> entry = pmd_to_swp_entry(old_pmd);
> page = pfn_to_page(swp_offset(entry));
> } else
> #endif
> page = pmd_page(old_pmd);
> VM_BUG_ON_PAGE(!page_count(page), page);
> page_ref_add(page, HPAGE_PMD_NR - 1);
> if (pmd_dirty(old_pmd))
> SetPageDirty(page);
> write = pmd_write(old_pmd);
> young = pmd_young(old_pmd);
> soft_dirty = pmd_soft_dirty(old_pmd);
> 
> Not just soft_dirt - all bits (dirty, write, young) have diffrent encoding
> or not present at all for migration entry.

Hi, Konstantin,

Actually I noticed it but I thought it didn't hurt since both
write/young flags are not used at all when applying to the small pages
when pmd_migration==true.  But indeed there's at least an unexpected
side effect of an extra call to SetPageDirty() that I missed.

I'll repost soon.  Thanks!

-- 
Peter Xu
