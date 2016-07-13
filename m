Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E87306B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:49:03 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f7so68256658qkc.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 22:49:03 -0700 (PDT)
Received: from smtp.polymtl.ca (smtp.polymtl.ca. [132.207.4.11])
        by mx.google.com with ESMTPS id 54si1808259qtw.17.2016.07.12.22.49.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 22:49:03 -0700 (PDT)
Received: from [192.168.2.140] (bas7-montreal19-2925249519.dsl.bell.ca [174.91.195.239])
	by smtp.polymtl.ca (8.14.3/8.14.3) with ESMTP id u6D5mv0C014862
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:49:02 -0400
From: Houssem Daoud <houssem.daoud@polymtl.ca>
Subject: Unexpected growth of the LRU inactive list
Message-ID: <d8e2130c-5a1c-bd6c-0f79-6b17bb6da645@polymtl.ca>
Date: Wed, 13 Jul 2016 01:48:57 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I was testing the filesystem performance of my system using the 
following script:

#!/bin/bash
while true;
do
dd if=/dev/zero of=output.dat  bs=100M count=1
done

I noticed that after some time, all the physical memory is consumed by 
the LRU inactive list and only 120 MB are left to the system.
/proc/meminfo shows the following information:
MemTotal: 4021820 Kb
MemFree: 121912 Kb
Active: 1304396 Kb
Inactive: 2377124 Kb

The evolution of memory utilization over time is available in this link: 
http://secretaire.dorsal.polymtl.ca/~hdaoud/ext4_journal_meminfo.png

With the help of a kernel tracer, I found that most of the pages in the 
inactive list are created by the ext4 journal during a truncate operation.
The call stack of the allocation is:
[
__alloc_pages_nodemask
alloc_pages_current
__page_cache_alloc
find_or_create_page
__getblk
jbd2_journal_get_descriptor_buffer
jbd2_journal_commit_transaction
kjournald2
kthread
]

I can't find an explanation why the LRU is growing while we are just 
writing to the same file again and again. I know that the philosophy of 
memory management in Linux is to use the available memory as much as 
possible, but what is the need of keeping truncated pages in the LRU if 
we know that they are not even accessible ?

Thanks !

ps: My system is running kernel 4.3 with ext4 filesystem (journal mode)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
