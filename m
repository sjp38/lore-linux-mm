Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A92F6B054A
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 10:42:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h126so5952611wmf.10
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 07:42:55 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id j19si4197584edh.128.2017.08.04.07.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 07:42:53 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id d40so5923850wma.3
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 07:42:53 -0700 (PDT)
Date: Fri, 4 Aug 2017 17:42:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: fix list corruptions on shmem shrinklist
Message-ID: <20170804144251.zpkfjm2eybevqo7t@node.shutemov.name>
References: <20170803054630.18775-1-xiyou.wangcong@gmail.com>
 <20170803161146.4316d105e533a363a5597e64@linux-foundation.org>
 <CA+55aFyPq+vVyFJ9GGm8FxH-MYAzLA+Q86Gmz44aDopQxrsC9g@mail.gmail.com>
 <20170803165307.172e2e1100b0170f6055894a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170803165307.172e2e1100b0170f6055894a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "# .39.x" <stable@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Aug 03, 2017 at 04:53:07PM -0700, Andrew Morton wrote:
> On Thu, 3 Aug 2017 16:25:46 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > On Thu, Aug 3, 2017 at 4:11 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > Where is this INIT_LIST_HEAD()?
> > 
> > I think it's this one:
> > 
> >         list_del_init(&info->shrinklist);
> > 
> > in shmem_unused_huge_shrink().
> 
> OK.
> 
> > > I'm not sure I'm understanding this.  AFAICT all the list operations to
> > > which you refer are synchronized under spin_lock(&sbinfo->shrinklist_lock)?
> > 
> > No, notice how shmem_unused_huge_shrink() does the
> > 
> >         list_move(&info->shrinklist, &to_remove);
> > 
> > and
> > 
> >         list_move(&info->shrinklist, &list);
> > 
> > to move to (two different) private lists under the shrinklist_lock,
> > but once it is on that private "list/to_remove" list, it is then
> > accessed outside the locked region.
> 
> So the code is using sbinfo->shrinklist_lock to protect
> sbinfo->shrinklist AND to protect all the per-inode info->shrinklist's.
> Except it didn't get the coverage complete.
> 
> Presumably it's too expensive to extend sbinfo->shrinklist_lock
> coverage in shmem_unused_huge_shrink() (or is it?  - this is huge
> pages).  An alternative would be to add a new
> shmem_inode_info.shrinklist_lock whose mandate is to protect
> shmem_inode_info.shrinklist.
> 
> > Honestly, I don't love this situation, or the patch, but I think the
> > patch is likely the right thing to do.
> 
> Well, we could view the premature droppage of sbinfo->shrinklist_lock
> in shmem_unused_huge_shrink() to be a performance optimization and put
> some big fat comments in there explaining what's going on.  But it's
> tricky and it's not known that such an optimization is warranted.

The reason we need to drop shrinklist_lock is that we need to perform
sleeping operations for both of the lists:

 - 'to_remove' was added to get iput() running outside spin lock.
    See 253fd0f02040 ("shmem: fix sleeping from atomic context")

 - on handling 'list' we need to take lock_page() and also call iput().

 The fix looks fine to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
