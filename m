Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B59A6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 08:58:41 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 32so16829119qtv.5
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 05:58:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q1si1881854qtd.284.2017.07.20.05.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 05:58:40 -0700 (PDT)
Date: Thu, 20 Jul 2017 14:58:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm, something wrong in page_lock_anon_vma_read()?
Message-ID: <20170720125835.GC29716@redhat.com>
References: <alpine.LSU.2.11.1705191935220.11750@eggly.anvils>
 <591FB173.4020409@huawei.com>
 <a94c202d-7d9f-0a62-3049-9f825a1db50d@suse.cz>
 <5923FF31.5020801@huawei.com>
 <aea91199-2b40-85fd-8c93-2d807ed726bd@suse.cz>
 <593954BD.9060703@huawei.com>
 <e8dacd42-e5c5-998b-5f9a-a34dbfb986f1@suse.cz>
 <596DEA07.5000009@huawei.com>
 <24bd80c6-1bb7-c8b8-2acf-b91e5e10dbb1@suse.cz>
 <596F2D65.8020902@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <596F2D65.8020902@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, zhong jiang <zhongjiang@huawei.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 19, 2017 at 05:59:01PM +0800, Xishi Qiu wrote:
> I find two patches from upstream.
> 887843961c4b4681ee993c36d4997bf4b4aa8253

Do you use the remap_file_pages syscall? Such syscall has been dropped
upstream so very few apps should possibly try to use it on 64bit
archs.

It would also require a get_user_pages(write=1, force=1) on a nonlinear
VM_SHARED mapped without PROT_WRITE and such action should happen
before remap_file_pages is called to overwrite the page that got poked
by gdb.

Which sounds an extremely unusual setup for a production
environment. Said that you're clearly running docker containers so who
knows what is running inside them (and the point where you notice the
stale anon-vma and the container that crashes isn't necessarily the
same container that runs the fremap readonly gdb poking workload).

I'll look into integrating the above fix regardless.

I'll also send you privately the fix backported to the specific
enterprise kernel you're using, adding a WARN_ON as well that will
tell us if such a fix ever makes a difference. The alternative is that
you place a perf probe or systemtap hook in remap_file_pages to know
if it ever runs, but the WARN_ON I'll add is even better proof. If you
get the WARN_ON in the logs, we'll be 100% sure thing the patch fixed
your issue and we don't have to keep looking for other issues of the
same kind.

> a9c8e4beeeb64c22b84c803747487857fe424b68
> 
> I can't find any relations to the panic from the first one, and the second

Actually I do. Vlastimil theory that a pte got marked none is sound
but if zap_pte in a fremap fails to drop the anon page that was under
memory migration/compaction the exact same thing will happen. Either
ways an anon page isn't freed as it should have been: the vma will be
dropped, the anon-vma too, but the page will be left hanging around as
anonymous in the lrus with page->mapping pointing to a stale anon_vma
and the rss counters will go off by one too.

> one seems triggered from xen, but we use kvm.

Correct, the second one isn't needed with KVM.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
