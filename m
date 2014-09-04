Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B33D16B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 22:31:52 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so12541634pdb.27
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 19:31:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ey4si373662pab.231.2014.09.03.19.31.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Sep 2014 19:31:48 -0700 (PDT)
Date: Wed, 3 Sep 2014 19:30:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
Message-Id: <20140903193058.2bc891a7.akpm@linux-foundation.org>
In-Reply-To: <5407C989.50605@oracle.com>
References: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
	<20140903161000.f383fa4c1a4086de054cb6a0@linux-foundation.org>
	<5407C989.50605@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: david@fromorbit.com, xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 04 Sep 2014 10:08:09 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:

> On 09/04/2014 07:10 AM, Andrew Morton wrote:
> > On Wed,  3 Sep 2014 13:54:54 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:
> > 
> >> commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O during memory allocation")
> >> introduces PF_MEMALLOC_NOIO flag to avoid doing I/O inside memory allocation, __GFP_IO is cleared
> >> when this flag is set, but __GFP_FS implies __GFP_IO, it should also be cleared. Or it may still
> >> run into I/O, like in superblock shrinker.
> > 
> > Is there an actual bug which inspired this fix?  If so, please describe
> > it.
> > 
> Yes, an ocfs2 deadlock bug is related to this, there is a workqueue in
> ocfs2 who is for building tcp connections and processing ocfs2 message.
> Like when an new node is up in ocfs2 cluster, the workqueue will try to
> build the connections to it, since there are some common code in
> networking like sock_alloc() using GFP_KERNEL to allocate memory, direct
> reclaim will be triggered and call into superblock shrinker if available
> memory is not enough even set PF_MEMALLOC_NOIO for the workqueue. To
> shrink the inode cache, ocfs2 needs release cluster lock and this
> depends on workqueue to do it, so cause the deadlock. Not sure whether
> there are similar issue for other cluster fs, like nfs, it is possible
> rpciod hung like the ocfs2 workqueue?

All this info should be in the changelog.

> 
> > I don't think it's accurate to say that __GFP_FS implies __GFP_IO. 
> > Where did that info come from?
> __GFP_FS allowed callback into fs during memory allocation, and fs may
> do io whatever __GFP_IO is set?

__GFP_FS and __GFP_IO are (or were) for communicating to vmscan: don't
enter the fs for writepage, don't write back swapcache.

I guess those concepts have grown over time without a ton of thought
going into it.  Yes, I suppose that if a filesystem's writepage is
called (for example) it expects that it will be able to perform
writeback and it won't check (or even be passed) the __GFP_IO setting.

So I guess we could say that !__GFP_FS && GFP_IO is not implemented and
shouldn't occur.

That being said, it still seems quite bad to disable VFS cache
shrinking for PF_MEMALLOC_NOIO allocation attempts.

> > 
> > And the superblock shrinker is a good example of why this shouldn't be
> > the case.  The main thing that code does is to reclaim clean fs objects
> > without performing IO.  AFAICT the proposed patch will significantly
> > weaken PF_MEMALLOC_NOIO allocation attempts by needlessly preventing
> > the kernel from reclaiming such objects?
> Even fs didn't do io in superblock shrinker, it is possible for a fs
> process who is not convenient to set GFP_NOFS holding some fs lock and
> call back fs again?
> 
> PF_MEMALLOC_NOIO is only set for some special processes. I think it
> won't affect much.

Maybe not now.  But once we add hacks like this, people say "goody" and
go and use them rather than exerting the effort to sort out their
deadlocks properly :( There will be more PF_MEMALLOC_NOIO users in
2019.

Dunno, I'd like to hear David's thoughts but perhaps it would be better
to find some way to continue to permit PF_MEMALLOC_NOIO to shrink VFS
caches for most filesystems and find some fs-specific fix for ocfs2. 
That would mean testing PF_MEMALLOC_NOIO directly I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
