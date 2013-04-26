Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A23156B0032
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 13:19:25 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id 16so3789411obc.9
        for <linux-mm@kvack.org>; Fri, 26 Apr 2013 10:19:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130424153810.GA25958@quack.suse.cz>
References: <20130424153810.GA25958@quack.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 26 Apr 2013 13:19:04 -0400
Message-ID: <CAHGf_=rRomz4r8c5nJ8edX29bpwxA4T4bFOq3rW2FgOuVSkLFw@mail.gmail.com>
Subject: Re: Infiniband use of get_user_pages()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

>   when checking users of get_user_pages() (I'm doing some cleanups in that
> area to fix filesystem's issues with mmap_sem locking) I've noticed that
> infiniband drivers add number of pages obtained from get_user_pages() to
> mm->pinned_vm counter. Although this makes some sence, it doesn't match
> with any other user of get_user_pages() (e.g. direct IO) so has infiniband
> some special reason why it does so?

I'm also puzzled because mm->pinned_vm_counter is only used from /proc. Who
and how to use this accounting?


>   Also that seems to be the only real reason why mmap_sem has to be grabbed
> in exclusive mode, am I right?

I think so. get_user_pages() doesn't need write lock.


>   Another suspicious thing (at least in drivers/infiniband/core/umem.c:
> ib_umem_get()) is that arguments of get_user_pages() are like:
>                 ret = get_user_pages(current, current->mm, cur_base,
>                                      min_t(unsigned long, npages,
>                                            PAGE_SIZE / sizeof (struct page *)),
>                                      1, !umem->writable, page_list, vma_list);
> So we always have write argument set to 1 and force argument is set to
> !umem->writable. Is that really intentional? My naive guess would be that
> arguments should be switched... Although even in that case I fail to see
> why 'force' argument should be set. Can someone please explain?

If I understand correctly, IB and DirectIO have different set sequence.

DirectIO
 1. write to buf
 2. write(buf). i.e. get_user_pages_fast(write=0)

Infiniband
 1. reg_mr. i.e. get_user_pages(write=1)
 2. write to buf

I mean, if direct-io is passed zero page, it is user mistake. but user
process which uses infiniband set up mr before writing IO buffer,
IIUC.

In this case, I think user process which uses infiniband need to dereg
mr before fork(). but it is another story.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
