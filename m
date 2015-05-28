Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 034276B0032
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:38:40 -0400 (EDT)
Received: by lbcue7 with SMTP id ue7so34276552lbc.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:38:39 -0700 (PDT)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id bq3si2561746lbb.128.2015.05.28.11.38.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 11:38:37 -0700 (PDT)
Received: by lbbuc2 with SMTP id uc2so34304332lbb.2
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:38:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150528120015.GA26425@suse.de>
References: <CABPcSq+uMcDSBU1xt7oRqPXn-89ZpJmxK+C46M7rX7+Y7-x7iQ@mail.gmail.com>
	<20150528120015.GA26425@suse.de>
Date: Thu, 28 May 2015 11:38:36 -0700
Message-ID: <CABPcSq+5SR0vqs6fGOwKJ0AZMiLSDQ6Rsevi2wB4YgZPJ9iadg@mail.gmail.com>
Subject: Re: kernel bug(VM_BUG_ON_PAGE) with 3.18.13 in mm/migrate.c
From: Jovi Zhangwei <jovi@cloudflare.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com

Hi Mel,

On Thu, May 28, 2015 at 5:00 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, May 27, 2015 at 11:05:33AM -0700, Jovi Zhangwei wrote:
>> Hi,
>>
>> I got below kernel bug error in our 3.18.13 stable kernel.
>> "kernel BUG at mm/migrate.c:1661!"
>>
>> Source code:
>>
>> 1657    static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>> 1658   {
>> 1659            int page_lru;
>> 1660
>> 1661           VM_BUG_ON_PAGE(compound_order(page) &&
>> !PageTransHuge(page), page);
>>
>> It's easy to trigger the error by run tcpdump in our system.(not sure
>> it will easily be reproduced in another system)
>> "sudo tcpdump -i bond0.100 'tcp port 4242' -c 100000000000 -w 4242.pcap"
>>
>> Any comments for this bug would be great appreciated. thanks.
>>
>
> What sort of compound page is it? What sort of VMA is it in? hugetlbfs
> pages should never be tagged for NUMA migrate and never enter this
> path. Transparent huge pages are handled properly so I'm wondering
> exactly what type of compound page this is and what mapped it into
> userspace.
>
Thanks for your reply.

After reading net/packet/af_packet.c:alloc_one_pg_vec_page, I found
there indeed have compound page maped into userspace.

I sent a patch for this issue(you may received it), but not sure it's
right to fix,
feel free to update it or use your own patch.

Thanks.

--------------------------------------------------------------------------------------------

[PATCH] mm/migrate: Avoid migrate mmaped compound pages

Below kernel vm bug can be triggered by tcpdump which mmaped a lot of
pages with GFP_COMP flag.

[Mon May 25 05:29:33 2015] page:ffffea0015414000 count:66 mapcount:1
mapping:          (null) index:0x0
[Mon May 25 05:29:33 2015] flags: 0x20047580004000(head)
[Mon May 25 05:29:33 2015] page dumped because:
VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page))
[Mon May 25 05:29:33 2015] ------------[ cut here ]------------
[Mon May 25 05:29:33 2015] kernel BUG at mm/migrate.c:1661!
[Mon May 25 05:29:33 2015] invalid opcode: 0000 [#1] SMP

The fix is simply disallow migrate mmaped compound pages, return 0 instead of
report vm bug.

Signed-off-by: Jovi Zhangwei <jovi.zhangwei@gmail.com>
---
 mm/migrate.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index f53838f..839adef 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1606,7 +1606,8 @@ static int numamigrate_isolate_page(pg_data_t
*pgdat, struct page *page)
 {
  int page_lru;

- VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
+ if (compound_order(page) && !PageTransHuge(page))
+ return 0;

  /* Avoid migrating to a node that is nearly full */
  if (!migrate_balanced_pgdat(pgdat, 1UL << compound_order(page)))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
