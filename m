Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6926B00DD
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 03:37:25 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id eu11so14119834pac.9
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 00:37:25 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id o8si17516169pds.34.2014.11.04.00.37.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 00:37:24 -0800 (PST)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8F9C43EE0B6
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:37:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 9C8A5AC048D
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:37:21 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C8321DB8041
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:37:21 +0900 (JST)
Message-ID: <54589017.9060604@jp.fujitsu.com>
Date: Tue, 4 Nov 2014 17:36:39 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct
 page
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2014/11/02 12:15), Johannes Weiner wrote:
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
>     text    data     bss     dec     hex     filename
> 8828345 1725264  983040 11536649 b00909  vmlinux.old
> 8827425 1725264  966656 11519345 afc571  vmlinux.new
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>   include/linux/memcontrol.h  |   6 +-
>   include/linux/mm_types.h    |   5 +
>   include/linux/mmzone.h      |  12 --
>   include/linux/page_cgroup.h |  53 --------
>   init/main.c                 |   7 -
>   mm/memcontrol.c             | 124 +++++------------
>   mm/page_alloc.c             |   2 -
>   mm/page_cgroup.c            | 319 --------------------------------------------
>   8 files changed, 41 insertions(+), 487 deletions(-)
> 

Great! 
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, init/Kconfig comments shouldn't be updated ?
(I'm sorry if it has been updated since your latest fix.)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
