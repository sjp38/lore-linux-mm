Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE486B0226
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:20:42 -0400 (EDT)
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocation
 APIs
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 13 May 2010 15:20:16 +0200
Message-ID: <1273756816.5605.3547.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Changli Gao <xiaosuo@gmail.com>
Cc: akpm@linux-foundation.org, Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, Roland Dreier <rolandd@cisco.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Divy Le Ray <divy@chelsio.com>, "James E.J. Bottomley" <James.Bottomley@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@sun.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, Eric Dumazet <eric.dumazet@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-05-13 at 17:51 +0800, Changli Gao wrote:
> +void *__kvmalloc(size_t size, gfp_t flags)
> +{
> +       void *ptr;
> +
> +       if (size < PAGE_SIZE)
> +               return kmalloc(size, GFP_KERNEL | flags);
> +       size =3D PAGE_ALIGN(size);
> +       if (is_power_of_2(size))
> +               ptr =3D (void *)__get_free_pages(GFP_KERNEL | flags |
> +                                              __GFP_NOWARN, get_order(si=
ze));
> +       else
> +               ptr =3D alloc_pages_exact(size, GFP_KERNEL | flags |
> +                                             __GFP_NOWARN);
> +       if (ptr !=3D NULL) {
> +               virt_to_head_page(ptr)->private =3D size;
> +               return ptr;
> +       }
> +
> +       ptr =3D vmalloc(size);
> +       if (ptr !=3D NULL && (flags & __GFP_ZERO))
> +               memset(ptr, 0, size);
> +
> +       return ptr;
> +}
> +EXPORT_SYMBOL(__kvmalloc);

So if I do kvmalloc(size, GFP_ATOMIC) I get GFP_KERNEL|GFP_ATOMIC, which
is not a recommended variation because one should not mix __GFP_WAIT and
__GFP_HIGH.

So I would simply drop the gfp argument to avoid confusion.

> +void __kvfree(void *ptr, bool inatomic)
> +{
> +       if (unlikely(ZERO_OR_NULL_PTR(ptr)))
> +               return;
> +       if (is_vmalloc_addr(ptr)) {
> +               if (inatomic) {
> +                       struct work_struct *work;
> +
> +                       work =3D ptr;
> +                       BUILD_BUG_ON(sizeof(struct work_struct) > PAGE_SI=
ZE);
> +                       INIT_WORK(work, kvfree_work);
> +                       schedule_work(work);
> +               } else {
> +                       vfree(ptr);
> +               }
> +       } else {
> +               struct page *page;
> +
> +               page =3D virt_to_head_page(ptr);
> +               if (PageSlab(page) || PageCompound(page))
> +                       kfree(ptr);
> +               else if (is_power_of_2(page->private))
> +                       free_pages((unsigned long)ptr,
> +                                  get_order(page->private));
> +               else
> +                       free_pages_exact(ptr, page->private);
> +       }
> +}
> +EXPORT_SYMBOL(__kvfree);=20

NAK, I really utterly dislike that inatomic argument. The alloc side
doesn't function in atomic context either. Please keep the thing
symmetric in that regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
