Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 46B4C6B5819
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 07:36:58 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id v79so4332119pfd.20
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 04:36:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor6917054plr.70.2018.11.30.04.36.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 04:36:56 -0800 (PST)
Date: Fri, 30 Nov 2018 15:36:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm: page_mapped: don't assume compound page is huge
 or THP
Message-ID: <20181130123651.5qrdrw3i5ergbuzl@kshutemo-mobl1>
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
 <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
 <20181130121851.GI6923@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130121851.GI6923@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, lersek@redhat.com, alex.williamson@redhat.com, aarcange@redhat.com, rientjes@google.com, mgorman@techsingularity.net, linux-kernel@vger.kernel.org

On Fri, Nov 30, 2018 at 01:18:51PM +0100, Michal Hocko wrote:
> On Fri 30-11-18 13:06:57, Jan Stancek wrote:
> > LTP proc01 testcase has been observed to rarely trigger crashes
> > on arm64:
> >     page_mapped+0x78/0xb4
> >     stable_page_flags+0x27c/0x338
> >     kpageflags_read+0xfc/0x164
> >     proc_reg_read+0x7c/0xb8
> >     __vfs_read+0x58/0x178
> >     vfs_read+0x90/0x14c
> >     SyS_read+0x60/0xc0
> > 
> > Issue is that page_mapped() assumes that if compound page is not
> > huge, then it must be THP. But if this is 'normal' compound page
> > (COMPOUND_PAGE_DTOR), then following loop can keep running
> > (for HPAGE_PMD_NR iterations) until it tries to read from memory
> > that isn't mapped and triggers a panic:
> >         for (i = 0; i < hpage_nr_pages(page); i++) {
> >                 if (atomic_read(&page[i]._mapcount) >= 0)
> >                         return true;
> > 	}
> > 
> > I could replicate this on x86 (v4.20-rc4-98-g60b548237fed) only
> > with a custom kernel module [1] which:
> > - allocates compound page (PAGEC) of order 1
> > - allocates 2 normal pages (COPY), which are initialized to 0xff
> >   (to satisfy _mapcount >= 0)
> > - 2 PAGEC page structs are copied to address of first COPY page
> > - second page of COPY is marked as not present
> > - call to page_mapped(COPY) now triggers fault on access to 2nd
> >   COPY page at offset 0x30 (_mapcount)
> > 
> > [1] https://github.com/jstancek/reproducers/blob/master/kernel/page_mapped_crash/repro.c
> > 
> > Fix the loop to iterate for "1 << compound_order" pages.
> 
> This is much less magic than the previous version. It is still not clear
> to me how is mapping higher order pages to page tables other than THP
> though. So a more detailed information about the source would bre really
> welcome. Once we know that we can add a Fixes tag and also mark the
> patch for stable because that sounds like a stable material.

IIRC, sound subsystem can producuce custom mapped compound pages.

The bug dates back to e1534ae95004.

> > Debugged-by: Laszlo Ersek <lersek@redhat.com>
> > Suggested-by: "Kirill A. Shutemov" <kirill@shutemov.name>
> > Signed-off-by: Jan Stancek <jstancek@redhat.com>
> 
> The patch looks sensible to me
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
