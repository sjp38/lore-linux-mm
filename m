Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 45F8C9003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 07:59:04 -0400 (EDT)
Received: by lbbpo10 with SMTP id po10so30462761lbb.3
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 04:59:03 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id ci12si4295063lad.24.2015.07.02.04.59.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jul 2015 04:59:02 -0700 (PDT)
Received: by lbcpe5 with SMTP id pe5so30439037lbc.2
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 04:59:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABYiri9W5qM3PRyNua3pNO+eP=nz--TbYzTQ0Z8WseKTygz8HA@mail.gmail.com>
References: <CABYiri9MEbEnZikqTU3d=w6rxtsgumH2gJ++Qzi1yZKGn6it+Q@mail.gmail.com>
 <20150224001228.GA11456@amt.cnet> <CABYiri_U7oB==4-cxegjVQJ_dX62d0tX=D0cUAPTpV_xjCukEw@mail.gmail.com>
 <alpine.LSU.2.11.1503281705040.13543@eggly.anvils> <CABYiri9W5qM3PRyNua3pNO+eP=nz--TbYzTQ0Z8WseKTygz8HA@mail.gmail.com>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Thu, 2 Jul 2015 14:58:41 +0300
Message-ID: <CABYiri8zwGibcRndsBc7D8F21PwzKKoDhuLhEtnfzVw_rYdR7w@mail.gmail.com>
Subject: Re: copy_huge_page: unable to handle kernel NULL pointer dereference
 at 0000000000000008
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, Luis Henriques <luis.henriques@canonical.com>, Marcelo Tosatti <mtosatti@redhat.com>, stable@vger.kernel.org, linux-mm@kvack.org, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, wanpeng.li@linux.intel.com, jipan yang <jipan.yang@gmail.com>

>> But you are very appositely mistaken: copy_huge_page() used to make
>> the same mistake, and Dave Hansen fixed it back in v3.13, but the fix
>> never went to the stable trees.
>>
>> commit 30b0a105d9f7141e4cbf72ae5511832457d89788
>> Author: Dave Hansen <dave.hansen@linux.intel.com>
>> Date:   Thu Nov 21 14:31:58 2013 -0800
>>
>>     mm: thp: give transparent hugepage code a separate copy_page
>>
>>     Right now, the migration code in migrate_page_copy() uses copy_huge_page()
>>     for hugetlbfs and thp pages:
>>
>>            if (PageHuge(page) || PageTransHuge(page))
>>                     copy_huge_page(newpage, page);
>>
>>     So, yay for code reuse.  But:
>>
>>       void copy_huge_page(struct page *dst, struct page *src)
>>       {
>>             struct hstate *h = page_hstate(src);
>>
>>     and a non-hugetlbfs page has no page_hstate().  This works 99% of the
>>     time because page_hstate() determines the hstate from the page order
>>     alone.  Since the page order of a THP page matches the default hugetlbfs
>>     page order, it works.
>>
>>     But, if you change the default huge page size on the boot command-line
>>     (say default_hugepagesz=1G), then we might not even *have* a 2MB hstate
>>     so page_hstate() returns null and copy_huge_page() oopses pretty fast
>>     since copy_huge_page() dereferences the hstate:
>>
>>       void copy_huge_page(struct page *dst, struct page *src)
>>       {
>>             struct hstate *h = page_hstate(src);
>>             if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
>>       ...
>>
>>     Mel noticed that the migration code is really the only user of these
>>     functions.  This moves all the copy code over to migrate.c and makes
>>     copy_huge_page() work for THP by checking for it explicitly.
>>
>>     I believe the bug was introduced in commit b32967ff101a ("mm: numa: Add
>>     THP migration for the NUMA working set scanning fault case")
>>
>>     [akpm@linux-foundation.org: fix coding-style and comment text, per Naoya Horiguchi]
>>     Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>>     Acked-by: Mel Gorman <mgorman@suse.de>
>>     Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>     Cc: Hillf Danton <dhillf@gmail.com>
>>     Cc: Andrea Arcangeli <aarcange@redhat.com>
>>     Tested-by: Dave Jiang <dave.jiang@intel.com>
>>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>>
>
> Thanks, the issue is fixed on 3.10 with trivial patch modification.

Ping? 3.10 still misses that..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
