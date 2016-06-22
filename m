Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38A886B025E
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 11:05:43 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id ot10so37953196obb.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:05:43 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v127si604681oia.69.2016.06.22.08.05.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 08:05:40 -0700 (PDT)
Message-ID: <576AA934.4090504@huawei.com>
Date: Wed, 22 Jun 2016 23:05:24 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: A question about the patch(commit :c777e2a8b654 powerpc/mm: Fix Multi
 hit ERAT cause by recent THP update)
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aneesh.kumar@linux.vnet.ibm.com
Cc: Linux Memory Management List <linux-mm@kvack.org>

Hi  Aneesh

                CPU0                            CPU1
    shrink_page_list()
      add_to_swap()
        split_huge_page_to_list()
          __split_huge_pmd_locked()
            pmdp_huge_clear_flush_notify()
        // pmd_none() == true
                                        exit_mmap()
                                          unmap_vmas()
                                            zap_pmd_range()
                                              // no action on pmd since pmd_none() == true
        pmd_populate()


the mm should be the last user  when CPU1 process is exiting,  CPU0 must be a own mm .
two different process  should not be influenced each other.  in a words , they should not
have race.

I want to know if I missing the point.

Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
