Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 96B4A6B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 21:39:27 -0400 (EDT)
Received: by lagv1 with SMTP id v1so79209670lag.3
        for <linux-mm@kvack.org>; Sat, 30 May 2015 18:39:27 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id l5si8611315lbt.73.2015.05.30.18.39.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 18:39:25 -0700 (PDT)
Received: by laat2 with SMTP id t2so79171942laa.1
        for <linux-mm@kvack.org>; Sat, 30 May 2015 18:39:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABPcSq+5SR0vqs6fGOwKJ0AZMiLSDQ6Rsevi2wB4YgZPJ9iadg@mail.gmail.com>
References: <CABPcSq+uMcDSBU1xt7oRqPXn-89ZpJmxK+C46M7rX7+Y7-x7iQ@mail.gmail.com>
	<20150528120015.GA26425@suse.de>
	<CABPcSq+5SR0vqs6fGOwKJ0AZMiLSDQ6Rsevi2wB4YgZPJ9iadg@mail.gmail.com>
Date: Sat, 30 May 2015 18:39:24 -0700
Message-ID: <CABPcSq+Y6Mfe7AODKhgcvtMTmj+rYmzqzXbksmzq2S2pWizhAw@mail.gmail.com>
Subject: Re: kernel bug(VM_BUG_ON_PAGE) with 3.18.13 in mm/migrate.c
From: Jovi Zhangwei <jovi@cloudflare.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com

On Thu, May 28, 2015 at 11:38 AM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
> Hi Mel,
>
> On Thu, May 28, 2015 at 5:00 AM, Mel Gorman <mgorman@suse.de> wrote:
>> On Wed, May 27, 2015 at 11:05:33AM -0700, Jovi Zhangwei wrote:
>>> Hi,
>>>
>>> I got below kernel bug error in our 3.18.13 stable kernel.
>>> "kernel BUG at mm/migrate.c:1661!"
>>>
>>> Source code:
>>>
>>> 1657    static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>>> 1658   {
>>> 1659            int page_lru;
>>> 1660
>>> 1661           VM_BUG_ON_PAGE(compound_order(page) &&
>>> !PageTransHuge(page), page);
>>>
>>> It's easy to trigger the error by run tcpdump in our system.(not sure
>>> it will easily be reproduced in another system)
>>> "sudo tcpdump -i bond0.100 'tcp port 4242' -c 100000000000 -w 4242.pcap"
>>>
>>> Any comments for this bug would be great appreciated. thanks.
>>>
>>
>> What sort of compound page is it? What sort of VMA is it in? hugetlbfs
>> pages should never be tagged for NUMA migrate and never enter this
>> path. Transparent huge pages are handled properly so I'm wondering
>> exactly what type of compound page this is and what mapped it into
>> userspace.
>>
> Thanks for your reply.
>
> After reading net/packet/af_packet.c:alloc_one_pg_vec_page, I found
> there indeed have compound page maped into userspace.
>
> I sent a patch for this issue(you may received it), but not sure it's
> right to fix,
> feel free to update it or use your own patch.
>
ping?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
