Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A583D6B0008
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 09:30:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r9-v6so11576328edh.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 06:30:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p34-v6si8228522edp.402.2018.07.16.06.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 06:30:32 -0700 (PDT)
Date: Mon, 16 Jul 2018 15:30:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: Fix vma_is_anonymous() false-positives
Message-ID: <20180716133028.GQ17280@dhcp22.suse.cz>
References: <20180710134821.84709-1-kirill.shutemov@linux.intel.com>
 <20180710134821.84709-2-kirill.shutemov@linux.intel.com>
 <20180710134858.3506f097104859b533c81bf3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710134858.3506f097104859b533c81bf3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue 10-07-18 13:48:58, Andrew Morton wrote:
> On Tue, 10 Jul 2018 16:48:20 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > vma_is_anonymous() relies on ->vm_ops being NULL to detect anonymous
> > VMA. This is unreliable as ->mmap may not set ->vm_ops.
> > 
> > False-positive vma_is_anonymous() may lead to crashes:
> > 
> > ...
> > 
> > This can be fixed by assigning anonymous VMAs own vm_ops and not relying
> > on it being NULL.
> > 
> > If ->mmap() failed to set ->vm_ops, mmap_region() will set it to
> > dummy_vm_ops. This way we will have non-NULL ->vm_ops for all VMAs.
> 
> Is there a smaller, simpler fix which we can use for backporting
> purposes and save the larger rework for development kernels?

Why cannot we simply keep anon vma with null vm_ops and set dummy_vm_ops
for all users who do not initialize it in their mmap callbacks?
Basically have a sanity check&fixup in call_mmap?
-- 
Michal Hocko
SUSE Labs
