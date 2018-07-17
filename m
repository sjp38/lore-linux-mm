Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B95C6B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 05:00:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d5-v6so289980edq.3
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 02:00:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r11-v6si528645edp.9.2018.07.17.02.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 02:00:54 -0700 (PDT)
Date: Tue, 17 Jul 2018 11:00:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: Fix vma_is_anonymous() false-positives
Message-ID: <20180717090053.GE16803@dhcp22.suse.cz>
References: <20180710134821.84709-1-kirill.shutemov@linux.intel.com>
 <20180710134821.84709-2-kirill.shutemov@linux.intel.com>
 <20180710134858.3506f097104859b533c81bf3@linux-foundation.org>
 <20180716133028.GQ17280@dhcp22.suse.cz>
 <20180716140440.fd3sjw5xys5wozw7@black.fi.intel.com>
 <20180716142245.GT17280@dhcp22.suse.cz>
 <20180716144739.que5362bofty6ocp@kshutemo-mobl1>
 <20180716174042.GA17280@dhcp22.suse.cz>
 <20180716203846.roolhtesloabxr2g@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716203846.roolhtesloabxr2g@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon 16-07-18 23:38:46, Kirill A. Shutemov wrote:
> On Mon, Jul 16, 2018 at 07:40:42PM +0200, Michal Hocko wrote:
> > On Mon 16-07-18 17:47:39, Kirill A. Shutemov wrote:
> > > On Mon, Jul 16, 2018 at 04:22:45PM +0200, Michal Hocko wrote:
> > > > On Mon 16-07-18 17:04:41, Kirill A. Shutemov wrote:
> > > > > On Mon, Jul 16, 2018 at 01:30:28PM +0000, Michal Hocko wrote:
> > > > > > On Tue 10-07-18 13:48:58, Andrew Morton wrote:
> > > > > > > On Tue, 10 Jul 2018 16:48:20 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > > > > > 
> > > > > > > > vma_is_anonymous() relies on ->vm_ops being NULL to detect anonymous
> > > > > > > > VMA. This is unreliable as ->mmap may not set ->vm_ops.
> > > > > > > > 
> > > > > > > > False-positive vma_is_anonymous() may lead to crashes:
> > > > > > > > 
> > > > > > > > ...
> > > > > > > > 
> > > > > > > > This can be fixed by assigning anonymous VMAs own vm_ops and not relying
> > > > > > > > on it being NULL.
> > > > > > > > 
> > > > > > > > If ->mmap() failed to set ->vm_ops, mmap_region() will set it to
> > > > > > > > dummy_vm_ops. This way we will have non-NULL ->vm_ops for all VMAs.
> > > > > > > 
> > > > > > > Is there a smaller, simpler fix which we can use for backporting
> > > > > > > purposes and save the larger rework for development kernels?
> > > > > > 
> > > > > > Why cannot we simply keep anon vma with null vm_ops and set dummy_vm_ops
> > > > > > for all users who do not initialize it in their mmap callbacks?
> > > > > > Basically have a sanity check&fixup in call_mmap?
> > > > > 
> > > > > As I said, there's a corner case of MAP_PRIVATE of /dev/zero.
> > > > 
> > > > This is really creative. I really didn't think about that. I am
> > > > wondering whether this really has to be handled as a private anonymous
> > > > mapping implicitly. Why does vma_is_anonymous has to succeed for these
> > > > mappings? Why cannot we simply handle it as any other file backed
> > > > PRIVATE mapping?
> > > 
> > > Because it's established way to create anonymous mappings in Linux.
> > > And we cannot break the semantics.
> > 
> > How exactly would semantic break? You would still get zero pages on read
> > faults and anonymous pages on CoW. So basically the same thing as for
> > any other file backed MAP_PRIVATE mapping.
> 
> You are wrong about zero page.

Well, if we redirect ->fault to do_anonymous_page and

> And you won't get THP.

huge_fault to do_huge_pmd_anonymous_page then we should emulate the
standard anonymous mapping.

> And I'm sure there's more differences. Just grep for
> vma_is_anonymous().

I am sorry to push on this but if we have one odd case I would rather
handle it and have a simple _rule_ that every mmap provide _has_ to
provide vm_ops and have a trivial fix up at a single place rather than
patch a subtle placeholders you were proposing.

I will not insist of course but this looks less fragile to me.

-- 
Michal Hocko
SUSE Labs
