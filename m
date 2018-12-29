Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2128E0001
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 01:38:22 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id d20so20699725iom.0
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 22:38:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p140sor33220668itp.36.2018.12.28.22.38.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 22:38:21 -0800 (PST)
MIME-Version: 1.0
References: <000000000000b57d19057e1b383d@google.com> <20181228130938.c9e42c213cdcc35a93dd0dac@linux-foundation.org>
 <20181228235106.okk3oastsnpxusxs@kshutemo-mobl1>
In-Reply-To: <20181228235106.okk3oastsnpxusxs@kshutemo-mobl1>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 29 Dec 2018 07:38:08 +0100
Message-ID: <CACT4Y+Ynm+LPupT0OM=E8AdF0bQDKc-arPy3M=V1D5V0tCmZ=g@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in filemap_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, josef@toxicpanda.com, Souptick Joarder <jrdr.linux@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>

On Sat, Dec 29, 2018 at 12:51 AM Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> On Fri, Dec 28, 2018 at 01:09:38PM -0800, Andrew Morton wrote:
> > On Fri, 28 Dec 2018 12:51:04 -0800 syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com> wrote:
> >
> > > Hello,
> > >
> > > syzbot found the following crash on:
> >
> > uh-oh.  Josef, could you please take a look?
> >
> > :     page = find_get_page(mapping, offset);
> > :     if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
> > :             /*
> > :              * We found the page, so try async readahead before
> > :              * waiting for the lock.
> > :              */
> > :             fpin = do_async_mmap_readahead(vmf, page);
> > :     } else if (!page) {
> > :             /* No page in the page cache at all */
> > :             fpin = do_sync_mmap_readahead(vmf);
> > :             count_vm_event(PGMAJFAULT);
> > :             count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
> >
> > vmf->vma has been freed at this point.
> >
> > :             ret = VM_FAULT_MAJOR;
> > : retry_find:
> > :             page = pagecache_get_page(mapping, offset,
> > :                                       FGP_CREAT|FGP_FOR_MMAP,
> > :                                       vmf->gfp_mask);
> > :             if (!page) {
> > :                     if (fpin)
> > :                             goto out_retry;
> > :                     return vmf_error(-ENOMEM);
> > :             }
> > :     }
> >
>
> Here's a fixup for "filemap: drop the mmap_sem for all blocking operations".

If you are going to squash this, please add:

Tested-by: syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com


> do_sync_mmap_readahead() drops mmap_sem now, so by the time of
> dereferencing vmf->vma for count_memcg_event_mm() the VMA can be gone.
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 00a9315f45d4..65c85c47bdb1 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2554,10 +2554,10 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>                 fpin = do_async_mmap_readahead(vmf, page);
>         } else if (!page) {
>                 /* No page in the page cache at all */
> -               fpin = do_sync_mmap_readahead(vmf);
>                 count_vm_event(PGMAJFAULT);
>                 count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
>                 ret = VM_FAULT_MAJOR;
> +               fpin = do_sync_mmap_readahead(vmf);
>  retry_find:
>                 page = pagecache_get_page(mapping, offset,
>                                           FGP_CREAT|FGP_FOR_MMAP,
> --
>  Kirill A. Shutemov
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/20181228235106.okk3oastsnpxusxs%40kshutemo-mobl1.
> For more options, visit https://groups.google.com/d/optout.
