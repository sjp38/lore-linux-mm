Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE926B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 07:55:02 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so3208677pad.8
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 04:55:02 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bm3si11554929pad.232.2014.07.15.04.55.01
        for <linux-mm@kvack.org>;
        Tue, 15 Jul 2014 04:55:01 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CALYGNiM3tQUCvSPxPbum5jkhNOPeKpAVL=x3ggFmZH-QaqULcA@mail.gmail.com>
References: <748020aaaf5c5c2924a16232313e0175.squirrel@webmail.tu-dortmund.de>
 <alpine.LSU.2.11.1407141209160.17242@eggly.anvils>
 <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
 <20140715105547.C4832E00A3@blue.fi.intel.com>
 <CALYGNiM3tQUCvSPxPbum5jkhNOPeKpAVL=x3ggFmZH-QaqULcA@mail.gmail.com>
Subject: Re: PROBLEM: repeated remap_file_pages on tmpfs triggers bug on
 process exit
Content-Transfer-Encoding: 7bit
Message-Id: <20140715115456.32886E00A3@blue.fi.intel.com>
Date: Tue, 15 Jul 2014 14:54:56 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Korb <ingo.korb@tu-dortmund.de>, Ning Qu <quning@google.com>, Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Konstantin Khlebnikov wrote:
> On Tue, Jul 15, 2014 at 2:55 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > Konstantin Khlebnikov wrote:
> >> It seems boundng logic in do_fault_around is wrong:
> >>
> >> start_addr = max(address & fault_around_mask(), vma->vm_start);
> >> off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
> >> pte -= off;
> >> pgoff -= off;
> >>
> >> Ok, off  <= 511, but it might be bigger than pte offset in pte table.
> >
> > I don't see how it possible: fault_around_mask() cannot be more than 0x1ff000
> > (x86-64, fault_around_bytes == 2M). It means start_addr will be aligned to 2M
> > boundary in this case which is start of the page table pte belong to.
> >
> > Do I miss something?
> 
> Nope, you're right. This fixes kernel crash but not the original problem.
> 
> Problem is caused by calling do_fault_around for _non-linear_ faiult.
> In this case pgoff is shifted and might become negative during calculation.
> I'll send another patch.

I've got to the same conclusion. My patch is below.
