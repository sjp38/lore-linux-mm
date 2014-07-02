Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E91ED6B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 18:37:56 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id b13so1404335wgh.26
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 15:37:56 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id q6si21615205wix.37.2014.07.02.15.37.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 15:37:56 -0700 (PDT)
Date: Wed, 2 Jul 2014 18:37:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH mmotm/next] mm: memcontrol: rewrite charge API: fix
 shmem_unuse
Message-ID: <20140702223750.GA910@cmpxchg.org>
References: <alpine.LSU.2.11.1406301541420.4349@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1406301541420.4349@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 30, 2014 at 03:48:39PM -0700, Hugh Dickins wrote:
> Under shmem swapping and swapoff load, I sometimes hit the
> VM_BUG_ON_PAGE(!page->mapping) in mem_cgroup_commit_charge() at
> mm/memcontrol.c:6502!  Each time it has been a call from shmem_unuse().
> 
> Yes, there are some cases (most commonly when the page being unswapped
> is in a file being unlinked and evicted at that time) when the charge
> should not be committed.  In the old scheme, the page got uncharged
> again on release; but in the new scheme, it hits that BUG beforehand.
> 
> It's a useful BUG, so adapt shmem_unuse() to allow for it.  Which needs
> more info from shmem_unuse_inode(): so abuse -EAGAIN internally to
> replace the previous !found state (-ENOENT would be a more natural
> code, but that's exactly what you get when the swap has been evicted).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks, Hugh!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
