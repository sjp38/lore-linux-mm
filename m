Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91A1F6B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:04:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f9-v6so24133033pfn.22
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:04:40 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d128-v6si2773432pfc.211.2018.07.16.07.04.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 07:04:38 -0700 (PDT)
Date: Mon, 16 Jul 2018 17:04:41 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 1/2] mm: Fix vma_is_anonymous() false-positives
Message-ID: <20180716140440.fd3sjw5xys5wozw7@black.fi.intel.com>
References: <20180710134821.84709-1-kirill.shutemov@linux.intel.com>
 <20180710134821.84709-2-kirill.shutemov@linux.intel.com>
 <20180710134858.3506f097104859b533c81bf3@linux-foundation.org>
 <20180716133028.GQ17280@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716133028.GQ17280@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, Jul 16, 2018 at 01:30:28PM +0000, Michal Hocko wrote:
> On Tue 10-07-18 13:48:58, Andrew Morton wrote:
> > On Tue, 10 Jul 2018 16:48:20 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > vma_is_anonymous() relies on ->vm_ops being NULL to detect anonymous
> > > VMA. This is unreliable as ->mmap may not set ->vm_ops.
> > > 
> > > False-positive vma_is_anonymous() may lead to crashes:
> > > 
> > > ...
> > > 
> > > This can be fixed by assigning anonymous VMAs own vm_ops and not relying
> > > on it being NULL.
> > > 
> > > If ->mmap() failed to set ->vm_ops, mmap_region() will set it to
> > > dummy_vm_ops. This way we will have non-NULL ->vm_ops for all VMAs.
> > 
> > Is there a smaller, simpler fix which we can use for backporting
> > purposes and save the larger rework for development kernels?
> 
> Why cannot we simply keep anon vma with null vm_ops and set dummy_vm_ops
> for all users who do not initialize it in their mmap callbacks?
> Basically have a sanity check&fixup in call_mmap?

As I said, there's a corner case of MAP_PRIVATE of /dev/zero. It has to
produce anonymous VMA, but in map_region() we cannot distinguish it from
broken ->mmap handler.

See my attempt

	6dc296e7df4c ("mm: make sure all file VMAs have ->vm_ops set")

and it's revert

	 28c553d0aa0a ("revert "mm: make sure all file VMAs have ->vm_ops set"")

-- 
 Kirill A. Shutemov
