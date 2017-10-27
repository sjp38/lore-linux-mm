Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDB106B026B
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:31:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q127so3607607wmd.1
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 10:31:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d30sor4636372edd.36.2017.10.27.10.31.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Oct 2017 10:31:57 -0700 (PDT)
Date: Fri, 27 Oct 2017 20:31:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
Message-ID: <20171027173154.a5msarm2qzlee3od@node.shutemov.name>
References: <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
 <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
 <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
 <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
 <20171023165717.qx5qluryshz62zv5@dhcp22.suse.cz>
 <b138bcf8-0a66-a988-4040-520d767da266@gmx.de>
 <20171023180232.luayzqacnkepnm57@dhcp22.suse.cz>
 <0c934e18-5436-792f-2b2c-ebca3ae2d786@gmx.de>
 <b27c7b12-beb3-abdd-fde1-3d48fa73ea81@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b27c7b12-beb3-abdd-fde1-3d48fa73ea81@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Oct 27, 2017 at 04:29:16PM +0200, Vlastimil Babka wrote:
> On 10/24/2017 09:41 AM, C.Wehrmeyer wrote:
> > On 2017-10-23 20:02, Michal Hocko wrote:
> >> On Mon 23-10-17 19:52:27, C.Wehrmeyer wrote:
> >> [...]
> >>>> or you can mmap a larger block and
> >>>> munmap the initial unaligned part.
> >>>
> >>> And how is that supposed to be transparent? When I hear "transparent" I
> >>> think of a mechanism which I can put under a system so that it benefits from
> >>> it, while the system does not notice or at least does not need to be aware
> >>> of it. The system also does not need to be changed for it.
> >>
> >> How do you expect to get a huge page when the mapping itself is not
> >> properly aligned?
> > 
> > There are four ways that I can think of from the top of my head, but 
> > only one of them would be actually transparent.
> > 
> > 1. Provide a flag to mmap, which might be something different from 
> > MAP_HUGETLB. After all your question revolved merely around properly 
> > aligned pages - we don't want to *force* the kernel to reserve 
> > hugepages, we just want it to provide the proper alignment in this case. 
> > That wouldn't be very transparent, but it would be the easiest route to 
> > go (and mmap already kind-of supports such a thing).
> 
> Maybe just have mmap() detect that the requested size is a multiple of
> huge page size, and then align it automatically? I.e. a heuristic that
> should work in 99% of the cases?

Just don't bother.

Anon mapping for appliaction that would really benefit THP would grow
naturally: kernel will allocation new mapping next to the old one and
merge them. Doing fancy things here may hurt performance due to going
number of VMAs.

And we already do right thing for file mapping (tmpfs/shmem):
->get_unmapped_area would provide the right spot for the file, given the
size of mapping and ->vm_pgoff.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
