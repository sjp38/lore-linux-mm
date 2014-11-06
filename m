Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id A12956B00B8
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 13:55:59 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so2441965wib.11
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 10:55:59 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id e2si10837382wjp.168.2014.11.06.10.55.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 10:55:58 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id ex7so2431114wid.16
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 10:55:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
Date: Thu, 6 Nov 2014 22:55:58 +0400
Message-ID: <CALYGNiO85ts2J_c8fiYHGDe5gEhb4QMB_HAsST3opdwumUptFg@mail.gmail.com>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct page
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, Nov 2, 2014 at 6:15 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Memory cgroups used to have 5 per-page pointers.  To allow users to
> disable that amount of overhead during runtime, those pointers were
> allocated in a separate array, with a translation layer between them
> and struct page.
>
> There is now only one page pointer remaining: the memcg pointer, that
> indicates which cgroup the page is associated with when charged.  The
> complexity of runtime allocation and the runtime translation overhead
> is no longer justified to save that *potential* 0.19% of memory.  With
> CONFIG_SLUB, page->mem_cgroup actually sits in the doubleword padding
> after the page->private member and doesn't even increase struct page,
> and then this patch actually saves space.  Remaining users that care
> can still compile their kernels without CONFIG_MEMCG.
>
>    text    data     bss     dec     hex     filename
> 8828345 1725264  983040 11536649 b00909  vmlinux.old
> 8827425 1725264  966656 11519345 afc571  vmlinux.new
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Great! Never thought I'd see this. =)

Acked-by: Konstantin Khlebnikov <koct9i@gmail.com>


> ---
>  include/linux/memcontrol.h  |   6 +-
>  include/linux/mm_types.h    |   5 +
>  include/linux/mmzone.h      |  12 --
>  include/linux/page_cgroup.h |  53 --------
>  init/main.c                 |   7 -
>  mm/memcontrol.c             | 124 +++++------------
>  mm/page_alloc.c             |   2 -
>  mm/page_cgroup.c            | 319 --------------------------------------------
>  8 files changed, 41 insertions(+), 487 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d4575a1d6e99..dafba59b31b4 100644



> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
