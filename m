Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 7BA246B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 11:38:13 -0400 (EDT)
Date: Wed, 24 Apr 2013 17:38:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Infiniband use of get_user_pages()
Message-ID: <20130424153810.GA25958@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org, linux-mm@kvack.org

  Hello,

  when checking users of get_user_pages() (I'm doing some cleanups in that
area to fix filesystem's issues with mmap_sem locking) I've noticed that
infiniband drivers add number of pages obtained from get_user_pages() to
mm->pinned_vm counter. Although this makes some sence, it doesn't match
with any other user of get_user_pages() (e.g. direct IO) so has infiniband
some special reason why it does so?

  Also that seems to be the only real reason why mmap_sem has to be grabbed
in exclusive mode, am I right?

  Another suspicious thing (at least in drivers/infiniband/core/umem.c:
ib_umem_get()) is that arguments of get_user_pages() are like:
                ret = get_user_pages(current, current->mm, cur_base,
                                     min_t(unsigned long, npages,
                                           PAGE_SIZE / sizeof (struct page *)),
                                     1, !umem->writable, page_list, vma_list);
So we always have write argument set to 1 and force argument is set to
!umem->writable. Is that really intentional? My naive guess would be that
arguments should be switched... Although even in that case I fail to see
why 'force' argument should be set. Can someone please explain?

  Finally (and here I may show my ignorance ;), I'd like to ask whether
there's any reason why ib_umem_get() checks for is_vm_hugetlb_page() and
not just whether a page is a huge page?


								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
