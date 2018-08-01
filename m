Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08DC76B0003
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 17:55:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v9-v6so84908pfn.6
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 14:55:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cb3-v6sor17815plb.115.2018.08.01.14.55.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 14:55:31 -0700 (PDT)
Date: Wed, 1 Aug 2018 14:55:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Linux 4.18-rc7
In-Reply-To: <20180801205848.6mgcfux4b63svj3n@kshutemo-mobl1>
Message-ID: <alpine.LSU.2.11.1808011424540.1087@eggly.anvils>
References: <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com> <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com> <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com> <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1> <20180731174349.GA12944@agluck-desk>
 <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com> <alpine.LSU.2.11.1808011042090.14313@eggly.anvils> <20180801205848.6mgcfux4b63svj3n@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Wed, 1 Aug 2018, Kirill A. Shutemov wrote:
> On Wed, Aug 01, 2018 at 11:31:52AM -0700, Hugh Dickins wrote:
> > On Wed, 1 Aug 2018, Linus Torvalds wrote:
> > > 
> > > Anyway, the upshot of all this is that I think I know what the ia64
> > > problem was, and John sent the patch for the ashmem case, and I'm
> > > going to hold off reverting that vma_is_anonymous() false-positives
> > > commit after all.
> > 
> > I'd better send deletion of zap_pmd_range()'s VM_BUG_ON_VMA(): below
> > (but I've no proprietorial interest, if you prefer to do your own).
> 
> Agreed.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks.

> 
> > John's patch is good, and originally I thought it was safe from that
> > VM_BUG_ON_VMA(), because the /dev/ashmem fd exposed to the user is
> > disconnected from the vm_file in the vma, and madvise(,,MADV_REMOVE)
> > insists on VM_SHARED. But afterwards read John's earlier mail,
> > drawing attention to the vfs_fallocate() in there: I may be wrong,
> > and I don't know if Android has THP in the config anyway, but it looks
> > to me like an unmap_mapping_range() from ashmem's vfs_fallocate()
> > could hit precisely the VM_BUG_ON_VMA(), once it's vma_is_anonymous().
> > 
> > (I'm not familiar with ashmem, and I certainly don't understand the
> > role of MAP_PRIVATE ashmem mappings - hole-punch's zap_pte_range()
> > should end up leaving any anon pages in place; but the presence of
> > the BUG is requiring us all to understand too much too quickly.)
> 
> Hugh, do you see any reason why ashmem shouldn't have vm_ops ==
> shmem_vm_ops?

I cannot immediately think of an absolute reason why not, but I'm
not giving it much thought; and that might turn it into a stranger
beast than it already is.

> 
> I don't understand ashmem, but I feel uncomfortable that we have this
> sneaky way to create an anonymous VMA. It feels wrong to me.

I agree it's odd, but in this respect it's no odder than /dev/zero:
that has exactly the same pattern of shmem_zero_setup() for VM_SHARED,
else vma_set_anonymous(): which made me comfortable with John's patch,
restoring the way it worked before.

Admittedly, the subsequent vfs_fallocate() might generate surprises;
and the business of doing a shmem_file_setup() first, and then undoing
it with a shmem_zero_setup(), looks weird - from John's old XXX comment,
I think it was a quick hack to piece together some functionality they
needed in a hurry, which never got revisited (they wanted a name for
the area? maybe memfd would be good for that now).

But if what's in there is working now, I do not want to mess with it:
I'd be adding bugs faster than removing them.

Hugh
