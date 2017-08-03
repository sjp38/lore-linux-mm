Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7AB6B062D
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 19:11:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g28so3719303wrg.3
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 16:11:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i72si2129001wmc.121.2017.08.03.16.11.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 16:11:48 -0700 (PDT)
Date: Thu, 3 Aug 2017 16:11:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix list corruptions on shmem shrinklist
Message-Id: <20170803161146.4316d105e533a363a5597e64@linux-foundation.org>
In-Reply-To: <20170803054630.18775-1-xiyou.wangcong@gmail.com>
References: <20170803054630.18775-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Wed,  2 Aug 2017 22:46:30 -0700 Cong Wang <xiyou.wangcong@gmail.com> wrote:

> We saw many list corruption warnings on shmem shrinklist:
> 
> ...
> 
> The problem is that shmem_unused_huge_shrink() moves entries
> from the global sbinfo->shrinklist to its local lists and then
> releases the spinlock. However, a parallel shmem_setattr()
> could access one of these entries directly and add it back to
> the global shrinklist if it is removed, with the spinlock held.
> 
> The logic itself looks solid since an entry could be either
> in a local list or the global list, otherwise it is removed
> from one of them by list_del_init(). So probably the race
> condition is that, one CPU is in the middle of INIT_LIST_HEAD()

Where is this INIT_LIST_HEAD()?

> but the other CPU calls list_empty() which returns true
> too early then the following list_add_tail() sees a corrupted
> entry.
> 
> list_empty_careful() is designed to fix this situation.
> 

I'm not sure I'm understanding this.  AFAICT all the list operations to
which you refer are synchronized under spin_lock(&sbinfo->shrinklist_lock)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
