Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC7E0C43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:38:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 929DB2070D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:38:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n6Z1RgYD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 929DB2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2262D6B0008; Tue,  2 Apr 2019 03:38:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AD9D6B000C; Tue,  2 Apr 2019 03:38:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 050066B000D; Tue,  2 Apr 2019 03:38:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4B326B0008
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 03:38:39 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n23so10148514ioj.10
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 00:38:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wjuKuxU39VVQSUlss5RXuAiigbOxlt7hhRGciMvlm20=;
        b=nRSDML/zmx8uNhGND8fzZaljZATuXPHwpHc+jGCZOgVf/bOZXCT4OOzMqB9WN/7vJa
         dmoY24Q8Ml0IIW5v6LcpUiIhBTLAnpxiIq8yKAKFGiZs0zJzaZrk3RyfK1BTzunHyGmw
         0Xers0YwLd4K6nPCbPVpDDTY2XsLzglLoIM/zhNv8xeSsWzHGn/qTbncu0TnjuodGfpX
         F8Jt0TYQyc8QPKc9BKHUSm+peCz2CRFv2h/k+C6Uv5RK++Sc3OYu4etBB/u6XOxYgWNi
         zM3iSOmTuZOIrqnRgr3ZBoSGKdLjCgpJmJ1ZUThKP7IFc5gyCyiS4Ys8Nj7yOgY87Hj9
         ZOuA==
X-Gm-Message-State: APjAAAV4JL9SUgrYQtscNVRM7Kx3ZV+kWyzigb+sD+Yqpc74c0o6ZR/s
	1/CwtmNe8velmrev5cxgtndQnMQ1K6G0UTON+TT4j0ry669LWdVNzA/u9pHZTVv6AhCD6R4xk6m
	B3/K839RmWle1C8vZgtdoTgOxxc/WguFSstQiDdaoTjL6cDqrY5UPgVM0i9Vyq9BAkg==
X-Received: by 2002:a24:5f52:: with SMTP id r79mr3032034itb.125.1554190719585;
        Tue, 02 Apr 2019 00:38:39 -0700 (PDT)
X-Received: by 2002:a24:5f52:: with SMTP id r79mr3031995itb.125.1554190718726;
        Tue, 02 Apr 2019 00:38:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554190718; cv=none;
        d=google.com; s=arc-20160816;
        b=LCw0zAVmjWQiFU5PqbZzkMVDjhkac4EksXMlIgNYf7gRxo6CDFFEvGtJKkLN0i+jJS
         Np3T8SOKxcMQXNICTpSKe93MnTidhmapnRNJCNwJI5YV1jm+GThI2pXhU3xhyhPtiDlg
         885IdEDHKEPu66wdzK3jt2bOJsvBtVaVc3vxDjM6NtGv7W8BZqkSto4K92GrvwXcq+LZ
         kCqV0JodjR6Qo81wA3u13Iv/SeRcYR/Ijm88rbyzOdttXgWPHhyNZJtKKJzamhyRlA84
         PL2jyCuoxwKGklTlPKaYoFXO6lShslSpw2MfeXsN3eghJbqTuu/R2RC5QSnqhnHN6Iz4
         y87w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wjuKuxU39VVQSUlss5RXuAiigbOxlt7hhRGciMvlm20=;
        b=eUqATKW1LL4pUHFEnx8gD5ax+984eXbaTfkyQYiALH9g48xepuI6ApnHGXGmGPkygD
         E8NMKS4j0TohR3f22dYlX0mX0C0+rNQhwuWOlkj7XQewS/19WY/NLWmkRisM1nJSMd8v
         SnIJ6TZ+/rjJyU+R0AzymSkFogT2pmVmOlLHi/vvHn27BrIRy2XCoQrBzIqWDKHNl23j
         uWW59jXfmHa3/z8lIGXj8nEcPIzVxVv+ACLET7MteSJ6MqfLec+nITgiNhqDt4xWPn49
         DfP7tcpJ0GkSoFl8/EwsKCfWJ9nDne8ozA4fXH8o1UYjyvwTWfvsbBoSE20P3DNp/Ahl
         jawA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n6Z1RgYD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v20sor7168340iom.126.2019.04.02.00.38.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 00:38:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n6Z1RgYD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wjuKuxU39VVQSUlss5RXuAiigbOxlt7hhRGciMvlm20=;
        b=n6Z1RgYDDHH19WL5m/zsj5OpMwbr3WDj60Wr7k3VnUxh2jjK6OzwA0J0omLOKY9oeS
         MvNMGSuH4GcGHdD9YTDz7aoJpvXFm6ebfwYgPrT7h0uuhBRhA2Y6DH5nWLiZ6yuPZAB8
         XvJT5Mg423x+lgi+MzrROTmT1Sv19zIyOBLaK+zlzbq7wN3ZQgnzy54+YQlO9WYHYKx8
         F3Vt6ktR66+74zHz9TPcOwZYCmIAk7S+CaowSmnLxcpmI/8QyAvMVCQWAvT2mVNVc5O1
         BpU1BL4IRoKBl/fhXTpWld8xHVncgAIjBlXTAKTdClOcYzqX1J3y/I6Z7nd3shIfpE+k
         tp2Q==
X-Google-Smtp-Source: APXvYqwAMblZgQx5eoeC+RjrJfmmZmj5hHvZftSP0oEVrIDbBx6mxFIeVqHZq0EJRPjw/YzD1jdTQISTvzJfj0M1V/w=
X-Received: by 2002:a5d:8c98:: with SMTP id g24mr1206297ion.35.1554190718386;
 Tue, 02 Apr 2019 00:38:38 -0700 (PDT)
MIME-Version: 1.0
References: <1554185720-26404-1-git-send-email-laoar.shao@gmail.com> <20190402072351.GN28293@dhcp22.suse.cz>
In-Reply-To: <20190402072351.GN28293@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 2 Apr 2019 15:38:02 +0800
Message-ID: <CALOAHbASRo1xdkG62K3sAAYbApD5yTt6GEnCAZo1ZSop=ORj6w@mail.gmail.com>
Subject: Re: [PATCH] mm: add vm event for page cache miss
To: Michal Hocko <mhocko@suse.com>
Cc: willy@infradead.org, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 3:23 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Tue 02-04-19 14:15:20, Yafang Shao wrote:
> > We found that some latency spike was caused by page cache miss on our
> > database server.
> > So we decide to measure the page cache miss.
> > Currently the kernel is lack of this facility for measuring it.
>
> What are you going to use this information for?
>

With this counter, we can monitor pgcachemiss per second and this can
give us some informaton that
whether the database performance issue is releated with pgcachemiss.
For example, if this value increase suddently, it always cause latency spike.

What's more, I also want to measure how long this page cache miss may cause,
but this seems more complex to implement.


> > This patch introduces a new vm counter PGCACHEMISS for this purpose.
> > This counter will be incremented in bellow scenario,
> > - page cache miss in generic file read routine
> > - read access page cache miss in mmap
> > - read access page cache miss in swapin
> >
> > NB, readahead routine is not counted because it won't stall the
> > application directly.
>
> Doesn't this partially open the side channel we have closed for mincore
> just recently?
>

Seems I missed this dicussion.
Could you pls. give a reference to it?

Thanks
Yafang

> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > ---
> >  include/linux/pagemap.h       | 7 +++++++
> >  include/linux/vm_event_item.h | 1 +
> >  mm/filemap.c                  | 2 ++
> >  mm/memory.c                   | 1 +
> >  mm/shmem.c                    | 9 +++++----
> >  mm/vmstat.c                   | 1 +
> >  6 files changed, 17 insertions(+), 4 deletions(-)
> >
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index f939e00..8355b51 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -233,6 +233,13 @@ pgoff_t page_cache_next_miss(struct address_space *mapping,
> >  pgoff_t page_cache_prev_miss(struct address_space *mapping,
> >                            pgoff_t index, unsigned long max_scan);
> >
> > +static inline void page_cache_read_miss(struct vm_fault *vmf)
> > +{
> > +     if (!vmf || (vmf->flags & (FAULT_FLAG_USER | FAULT_FLAG_WRITE)) ==
> > +         FAULT_FLAG_USER)
> > +             count_vm_event(PGCACHEMISS);
> > +}
> > +
> >  #define FGP_ACCESSED         0x00000001
> >  #define FGP_LOCK             0x00000002
> >  #define FGP_CREAT            0x00000004
> > diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> > index 47a3441..d589f05 100644
> > --- a/include/linux/vm_event_item.h
> > +++ b/include/linux/vm_event_item.h
> > @@ -29,6 +29,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> >               PGFREE, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE,
> >               PGFAULT, PGMAJFAULT,
> >               PGLAZYFREED,
> > +             PGCACHEMISS,
> >               PGREFILL,
> >               PGSTEAL_KSWAPD,
> >               PGSTEAL_DIRECT,
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 4157f85..fc12c2d 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2256,6 +2256,7 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
> >               goto out;
> >
> >  no_cached_page:
> > +             page_cache_read_miss(NULL);
> >               /*
> >                * Ok, it wasn't cached, so we need to create a new
> >                * page..
> > @@ -2556,6 +2557,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
> >               fpin = do_async_mmap_readahead(vmf, page);
> >       } else if (!page) {
> >               /* No page in the page cache at all */
> > +             page_cache_read_miss(vmf);
> >               count_vm_event(PGMAJFAULT);
> >               count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
> >               ret = VM_FAULT_MAJOR;
> > diff --git a/mm/memory.c b/mm/memory.c
> > index bd157f2..63bcd41 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2754,6 +2754,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
> >               ret = VM_FAULT_MAJOR;
> >               count_vm_event(PGMAJFAULT);
> >               count_memcg_event_mm(vma->vm_mm, PGMAJFAULT);
> > +             page_cache_read_miss(vmf);
> >       } else if (PageHWPoison(page)) {
> >               /*
> >                * hwpoisoned dirty swapcache pages are kept for killing
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index 3a4b74c..47e33a4 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -127,7 +127,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
> >  static int shmem_swapin_page(struct inode *inode, pgoff_t index,
> >                            struct page **pagep, enum sgp_type sgp,
> >                            gfp_t gfp, struct vm_area_struct *vma,
> > -                          vm_fault_t *fault_type);
> > +                          struct vm_fault *vmf, vm_fault_t *fault_type);
> >  static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
> >               struct page **pagep, enum sgp_type sgp,
> >               gfp_t gfp, struct vm_area_struct *vma,
> > @@ -1159,7 +1159,7 @@ static int shmem_unuse_swap_entries(struct inode *inode, struct pagevec pvec,
> >               error = shmem_swapin_page(inode, indices[i],
> >                                         &page, SGP_CACHE,
> >                                         mapping_gfp_mask(mapping),
> > -                                       NULL, NULL);
> > +                                       NULL, NULL, NULL);
> >               if (error == 0) {
> >                       unlock_page(page);
> >                       put_page(page);
> > @@ -1614,7 +1614,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
> >  static int shmem_swapin_page(struct inode *inode, pgoff_t index,
> >                            struct page **pagep, enum sgp_type sgp,
> >                            gfp_t gfp, struct vm_area_struct *vma,
> > -                          vm_fault_t *fault_type)
> > +                          struct vm_fault *vmf, vm_fault_t *fault_type)
> >  {
> >       struct address_space *mapping = inode->i_mapping;
> >       struct shmem_inode_info *info = SHMEM_I(inode);
> > @@ -1636,6 +1636,7 @@ static int shmem_swapin_page(struct inode *inode, pgoff_t index,
> >                       *fault_type |= VM_FAULT_MAJOR;
> >                       count_vm_event(PGMAJFAULT);
> >                       count_memcg_event_mm(charge_mm, PGMAJFAULT);
> > +                     page_cache_read_miss(vmf);
> >               }
> >               /* Here we actually start the io */
> >               page = shmem_swapin(swap, gfp, info, index);
> > @@ -1758,7 +1759,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
> >       page = find_lock_entry(mapping, index);
> >       if (xa_is_value(page)) {
> >               error = shmem_swapin_page(inode, index, &page,
> > -                                       sgp, gfp, vma, fault_type);
> > +                                       sgp, gfp, vma, vmf, fault_type);
> >               if (error == -EEXIST)
> >                       goto repeat;
> >
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 36b56f8..c49ecba 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -1188,6 +1188,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
> >       "pgfault",
> >       "pgmajfault",
> >       "pglazyfreed",
> > +     "pgcachemiss",
> >
> >       "pgrefill",
> >       "pgsteal_kswapd",
> > --
> > 1.8.3.1
> >
>
> --
> Michal Hocko
> SUSE Labs

