Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9236B0268
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 12:57:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v105so6667867wrc.11
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 09:57:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si3681678wmi.194.2017.10.23.09.57.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 09:57:18 -0700 (PDT)
Date: Mon, 23 Oct 2017 18:57:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
Message-ID: <20171023165717.qx5qluryshz62zv5@dhcp22.suse.cz>
References: <93684e4b-9e60-ef3a-ba62-5719fdf7cff9@gmx.de>
 <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
 <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
 <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
 <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
 <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 23-10-17 18:46:59, C.Wehrmeyer wrote:
> On 23-10-17 18:13, Michal Hocko wrote:
> > On Mon 23-10-17 16:00:13, C.Wehrmeyer wrote:
> > > And just to be very sure I've added:
> > > 
> > > if (madvise(buf1,ALLOC_SIZE_1,MADV_HUGEPAGE)) {
> > >          errno_tmp = errno;
> > >          fprintf(stderr,"madvise: %u\n",errno_tmp);
> > >          goto out;
> > > }
> > > 
> > > /*Make sure the mapping is actually used*/
> > > memset(buf1,'!',ALLOC_SIZE_1);
> > 
> > Is the buffer aligned to 2MB?
> 
> When I omit MAP_HUGETLB for the flags that mmap receives - no.
> 
> #define ALLOC_SIZE_1 (2 * 1024 * 1024)
> [...]
> buf1 = mmap (
>         NULL,
>         ALLOC_SIZE_1,
>         prot, /*PROT_READ | PROT_WRITE*/
>         flags /*MAP_PRIVATE | MAP_ANONYMOUS*/,
>         -1,
>         0
> );
> 
> In such a case buf1 usually contains addresses which are aligned to 4 KiBs,
> such as 0x7f07d76e9000. 2-MiB-aligned addresses, such as 0x7f89f5e00000, are
> only produced with MAP_HUGETLB - which, if I understood the documentation
> correctly, is not the point of THPs as they are supposed to be transparent.

yes. You can use posix_memalign or you can mmap a larger block and
munmap the initial unaligned part.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
