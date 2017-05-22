Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22162831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 10:35:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y106so12009589wrb.14
        for <linux-mm@kvack.org>; Mon, 22 May 2017 07:35:12 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id 90si14287247wrg.43.2017.05.22.07.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 07:35:10 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id d127so33613953wmf.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 07:35:10 -0700 (PDT)
Date: Mon, 22 May 2017 17:29:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: pgds getting out of sync after memory hot remove
Message-ID: <20170522142917.pxvev563djdmm2ia@node.shutemov.name>
References: <1495216887-3175-1-git-send-email-jglisse@redhat.com>
 <20170522131215.wrnklp4dtemntixz@node.shutemov.name>
 <20170522141150.GA3813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170522141150.GA3813@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>

On Mon, May 22, 2017 at 10:11:51AM -0400, Jerome Glisse wrote:
> On Mon, May 22, 2017 at 04:12:15PM +0300, Kirill A. Shutemov wrote:
> > On Fri, May 19, 2017 at 02:01:26PM -0400, Jerome Glisse wrote:
> > > After memory hot remove it seems we do not synchronize pgds for kernel
> > > virtual memory range (on vmemmap_free()). This seems bogus to me as it
> > > means we are left with stall entry for process with mm != mm_init
> > > 
> > > Yet i am puzzle by the fact that i am only now hitting this issue. It
> > > never was an issue with 4.12 or before ie HMM never triggered following
> > > BUG_ON inside sync_global_pgds():
> > > 
> > > if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
> > >    BUG_ON(p4d_page_vaddr(*p4d) != p4d_page_vaddr(*p4d_ref));
> > > 
> > > 
> > > It seems that Kirill 5 level page table changes play a role in this
> > > behavior change. I could not bisect because HMM is painfull to rebase
> > > for each bisection step so that is just my best guess.
> > > 
> > > 
> > > Am i missing something here ? Am i wrong in assuming that should sync
> > > pgd on vmemmap_free() ? If so anyone have a good guess on why i am now
> > > seeing the above BUG_ON ?
> > 
> > What would we gain by syncing pgd on free? Stale pgds are fine as long as
> > they are not referenced (use-after-free case). Syncing is addtional work.
> 
> Well then how do i avoid the BUG_ON above ? Because the init_mm pgd is
> clear but none of the stall entry in any other mm. So if i unplug memory
> and replug memory at exact same address it tries to allocate new p4d/pud
> for struct page area and then when sync_global_pgds() is call it goes
> over the list of pgd and BUG_ON() :
> 
> if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
>     BUG_ON(p4d_page_vaddr(*p4d) != p4d_page_vaddr(*p4d_ref));
> 
> 
> So to me either above check need to go and we should overwritte pgd no
> matter what or we should restore previous behavior. I don't mind either
> one.

I would prefer to drop the BUG_ON.

Ingo?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
