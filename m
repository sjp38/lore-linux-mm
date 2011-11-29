Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB716B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 02:58:47 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AB5863EE0AE
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 16:58:42 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FD5745DE68
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 16:58:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 748EC45DE4D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 16:58:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 673AF1DB8041
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 16:58:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FBD81DB802C
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 16:58:42 +0900 (JST)
Date: Tue, 29 Nov 2011 16:57:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [V4 PATCH 1/2] tmpfs: add fallocate support
Message-Id: <20111129165720.6034bf5c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4ED4888E.9040402@redhat.com>
References: <1322544793-2676-1-git-send-email-amwang@redhat.com>
	<20111129150210.ad266dd7.kamezawa.hiroyu@jp.fujitsu.com>
	<4ED4888E.9040402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 29 Nov 2011 15:23:58 +0800
Cong Wang <amwang@redhat.com> wrote:

> 于 2011年11月29日 14:02, KAMEZAWA Hiroyuki 写道:
> >
> > You can't know whether the 'page' is allocated by alloc_page() in fallocate()
> > or just found as exiting one.
> > Then, yourwill corrupt existing pages in error path.
> > Is it allowed ?
> >
> 
> According to the comment,
> 
> /*
>   * shmem_getpage_gfp - find page in cache, or get from swap, or allocate
>   *
>   * If we allocate a new one we do not mark it dirty. That's up to the
>   * vm. If we swap it in we mark it dirty since we also free the swap
>   * entry since a page cannot live in both the swap and page cache
>   */
> 
> so we can know if the page is newly allocated by checking page dirty bit.
> Or am I missing something?
> 

If swap-in doesn't happen and  a page is found...

==
       page = find_lock_page(mapping, index); <=============== you find a page
       if (radix_tree_exceptional_entry(page)) {
                swap = radix_to_swp_entry(page);
                page = NULL;
        }

        if (sgp != SGP_WRITE &&
            ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
                error = -EINVAL;
                goto failed;
        }

        if (page || (sgp == SGP_READ && !swap.val)) {
                /*
                 * Once we can get the page lock, it must be uptodate:
                 * if there were an error in reading back from swap,
                 * the page would not be inserted into the filecache.
                 */
                BUG_ON(page && !PageUptodate(page));
                *pagep = page; <========================= return here.
                return 0;
        }
==
Page will not be marked as dirty.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
