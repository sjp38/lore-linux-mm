Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 26DE86B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:00:19 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so73078369pac.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 18:00:18 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id tb8si17044714pab.225.2015.10.21.18.00.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 18:00:18 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so70098804pad.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 18:00:18 -0700 (PDT)
Date: Wed, 21 Oct 2015 17:59:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
In-Reply-To: <20151022000648.GD23631@bbox>
Message-ID: <alpine.LSU.2.11.1510211744380.5219@eggly.anvils>
References: <20151021052836.GB6024@bbox> <20151021110723.GC10597@node.shutemov.name> <20151022000648.GD23631@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, 22 Oct 2015, Minchan Kim wrote:
> 
> I added the code to check it and queued it again but I had another oops
> in this time but symptom is related to anon_vma, too.
> (kernel is based on recent mmotm + unconditional mkdirty for bug fix)
> It seems page_get_anon_vma returns NULL since the page was not page_mapped
> at that time but second check of page_mapped right before try_to_unmap seems
> to be true.
> 
> Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> page:ffffea0001cfbfc0 count:3 mapcount:1 mapping:ffff88007f1b5f51 index:0x600000aff
> flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
> page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)

That's interesting, that's one I added in my page migration series.
Let me think on it, but it could well relate to the one you got before.

> page->mem_cgroup:ffff88007f3dcc00
> ------------[ cut here ]------------
> kernel BUG at mm/migrate.c:889!
> invalid opcode: 0000 [#1] SMP 
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 11 PID: 59 Comm: khugepaged Not tainted 4.3.0-rc6-next-20151021-THP-ref-madv_free+ #1557

Hmm, it might be me to blame, or it might be Kirill, don't know yet.

Oh, hold on, I think Andrew has just posted a new mmotm, and it includes
an update to Kirill's migrate_pages-try-to-split-pages-on-queueing.patch:
I haven't digested yet, but it might turn out to be relevant.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
