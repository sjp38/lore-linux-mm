Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9116B0008
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 16:58:56 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n7-v6so151869pgv.9
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 13:58:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9-v6sor3225135pgj.323.2018.08.01.13.58.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 13:58:54 -0700 (PDT)
Date: Wed, 1 Aug 2018 23:58:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Linux 4.18-rc7
Message-ID: <20180801205848.6mgcfux4b63svj3n@kshutemo-mobl1>
References: <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
 <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils>
 <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1>
 <20180731174349.GA12944@agluck-desk>
 <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
 <alpine.LSU.2.11.1808011042090.14313@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1808011042090.14313@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Wed, Aug 01, 2018 at 11:31:52AM -0700, Hugh Dickins wrote:
> On Wed, 1 Aug 2018, Linus Torvalds wrote:
> > 
> > Anyway, the upshot of all this is that I think I know what the ia64
> > problem was, and John sent the patch for the ashmem case, and I'm
> > going to hold off reverting that vma_is_anonymous() false-positives
> > commit after all.
> 
> I'd better send deletion of zap_pmd_range()'s VM_BUG_ON_VMA(): below
> (but I've no proprietorial interest, if you prefer to do your own).

Agreed.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> John's patch is good, and originally I thought it was safe from that
> VM_BUG_ON_VMA(), because the /dev/ashmem fd exposed to the user is
> disconnected from the vm_file in the vma, and madvise(,,MADV_REMOVE)
> insists on VM_SHARED. But afterwards read John's earlier mail,
> drawing attention to the vfs_fallocate() in there: I may be wrong,
> and I don't know if Android has THP in the config anyway, but it looks
> to me like an unmap_mapping_range() from ashmem's vfs_fallocate()
> could hit precisely the VM_BUG_ON_VMA(), once it's vma_is_anonymous().
> 
> (I'm not familiar with ashmem, and I certainly don't understand the
> role of MAP_PRIVATE ashmem mappings - hole-punch's zap_pte_range()
> should end up leaving any anon pages in place; but the presence of
> the BUG is requiring us all to understand too much too quickly.)

Hugh, do you see any reason why ashmem shouldn't have vm_ops ==
shmem_vm_ops?

I don't understand ashmem, but I feel uncomfortable that we have this
sneaky way to create an anonymous VMA. It feels wrong to me.

-- 
 Kirill A. Shutemov
