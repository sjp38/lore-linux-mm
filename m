Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4084E6B0036
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 21:07:57 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so9616774pad.28
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 18:07:56 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id ax6si12661321pbd.19.2014.06.30.18.07.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 18:07:56 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so9549356pad.14
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 18:07:56 -0700 (PDT)
Date: Mon, 30 Jun 2014 18:06:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm/next] mm: memcontrol: rewrite charge API: fix
 shmem_unuse
In-Reply-To: <20140630173428.5ebeed18.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1406301805020.10594@eggly.anvils>
References: <alpine.LSU.2.11.1406301541420.4349@eggly.anvils> <20140630160212.46caf9c3d41445b61fece666@linux-foundation.org> <alpine.LSU.2.11.1406301658430.4898@eggly.anvils> <20140630173428.5ebeed18.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 30 Jun 2014, Andrew Morton wrote:
> On Mon, 30 Jun 2014 17:10:54 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> > On Mon, 30 Jun 2014, Andrew Morton wrote:
> > > On Mon, 30 Jun 2014 15:48:39 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> > > > -		return 0;
> > > > +		return -EAGAIN;
> > > 
> > > Maybe it's time to document the shmem_unuse_inode() return values.
> > 
> > Oh dear.  I had hoped they would look after themselves.  This one is a
> > private matter between shmem_unuse_inode and its one caller, just below.
> 
> Well, readers of shmem_unuse_inode() won't know that unless we tell them.

Add comments on the private use of -EAGAIN.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- 3.16-rc2-mm1+/mm/shmem.c	2014-06-30 15:05:50.736335600 -0700
+++ linux/mm/shmem.c	2014-06-30 18:00:02.820584009 -0700
@@ -611,7 +611,7 @@ static int shmem_unuse_inode(struct shme
 	radswap = swp_to_radix_entry(swap);
 	index = radix_tree_locate_item(&mapping->page_tree, radswap);
 	if (index == -1)
-		return -EAGAIN;
+		return -EAGAIN;	/* tell shmem_unuse we found nothing */
 
 	/*
 	 * Move _head_ to start search for next from here.
@@ -712,6 +712,7 @@ int shmem_unuse(swp_entry_t swap, struct
 		cond_resched();
 		if (error != -EAGAIN)
 			break;
+		/* found nothing in this: move on to search the next */
 	}
 	mutex_unlock(&shmem_swaplist_mutex);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
