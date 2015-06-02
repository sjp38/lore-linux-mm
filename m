Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC4A6B006E
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 03:19:48 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so59765801wib.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 00:19:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hq3si22887650wib.22.2015.06.02.00.19.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 00:19:46 -0700 (PDT)
Date: Tue, 2 Jun 2015 08:19:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kernel bug(VM_BUG_ON_PAGE) with 3.18.13 in mm/migrate.c
Message-ID: <20150602071941.GB26425@suse.de>
References: <CABPcSq+uMcDSBU1xt7oRqPXn-89ZpJmxK+C46M7rX7+Y7-x7iQ@mail.gmail.com>
 <20150528120015.GA26425@suse.de>
 <CABPcSq+5SR0vqs6fGOwKJ0AZMiLSDQ6Rsevi2wB4YgZPJ9iadg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CABPcSq+5SR0vqs6fGOwKJ0AZMiLSDQ6Rsevi2wB4YgZPJ9iadg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jovi Zhangwei <jovi@cloudflare.com>
Cc: linux-kernel@vger.kernel.org, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com

On Thu, May 28, 2015 at 11:38:36AM -0700, Jovi Zhangwei wrote:
> Hi Mel,
> 
> On Thu, May 28, 2015 at 5:00 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Wed, May 27, 2015 at 11:05:33AM -0700, Jovi Zhangwei wrote:
> >> Hi,
> >>
> >> I got below kernel bug error in our 3.18.13 stable kernel.
> >> "kernel BUG at mm/migrate.c:1661!"
> >>
> >> Source code:
> >>
> >> 1657    static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
> >> 1658   {
> >> 1659            int page_lru;
> >> 1660
> >> 1661           VM_BUG_ON_PAGE(compound_order(page) &&
> >> !PageTransHuge(page), page);
> >>
> >> It's easy to trigger the error by run tcpdump in our system.(not sure
> >> it will easily be reproduced in another system)
> >> "sudo tcpdump -i bond0.100 'tcp port 4242' -c 100000000000 -w 4242.pcap"
> >>
> >> Any comments for this bug would be great appreciated. thanks.
> >>
> >
> > What sort of compound page is it? What sort of VMA is it in? hugetlbfs
> > pages should never be tagged for NUMA migrate and never enter this
> > path. Transparent huge pages are handled properly so I'm wondering
> > exactly what type of compound page this is and what mapped it into
> > userspace.
> >
> Thanks for your reply.
> 
> After reading net/packet/af_packet.c:alloc_one_pg_vec_page, I found
> there indeed have compound page maped into userspace.
> 

Ok, it's clear now. Thanks very much.

> I sent a patch for this issue(you may received it), but not sure it's
> right to fix,
> feel free to update it or use your own patch.
> 

It avoids the problem but it's not the best fix because a lot of useless
overhead has been incurred for a page that can never be migrated. Can you
try the following instead please?

---8<---

sched, numa: Do not hint for NUMA balancing on VM_MIXEDMAP mappings

Jovi Zhangwei reported the following problem

  Below kernel vm bug can be triggered by tcpdump which mmaped a lot of pages
  with GFP_COMP flag.

  [Mon May 25 05:29:33 2015] page:ffffea0015414000 count:66 mapcount:1 mapping:          (null) index:0x0
  [Mon May 25 05:29:33 2015] flags: 0x20047580004000(head)
  [Mon May 25 05:29:33 2015] page dumped because: VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page))
  [Mon May 25 05:29:33 2015] ------------[ cut here ]------------
  [Mon May 25 05:29:33 2015] kernel BUG at mm/migrate.c:1661!
  [Mon May 25 05:29:33 2015] invalid opcode: 0000 [#1] SMP

Compound pages cannot be migrated and it was not expected that such pages
be marked for NUMA balancing. This did not take into account that drivers
such as net/packet/af_packet.c may insert compound pages into userspace
with vm_insert_page. This patch tells the NUMA balancing protection scanner
to skip all VM_MIXEDMAP mappings which avoids the possibility that compound
pages are marked for migration.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reported-by: Jovi Zhangwei <jovi@cloudflare.com>
---
 kernel/sched/fair.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 241213be507c..486d00c408b0 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2166,7 +2166,7 @@ void task_numa_work(struct callback_head *work)
 	}
 	for (; vma; vma = vma->vm_next) {
 		if (!vma_migratable(vma) || !vma_policy_mof(vma) ||
-			is_vm_hugetlb_page(vma)) {
+			is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_MIXEDMAP)) {
 			continue;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
