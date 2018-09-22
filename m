Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E83038E0025
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 20:01:09 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id h1-v6so2062943pld.21
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 17:01:09 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id 3-v6si27222134plx.173.2018.09.21.17.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 17:01:07 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [Question] Why do clear VM_ACCOUNT before do_munmap() in mremap()
Message-ID: <80280fc6-3916-d6e0-7fb0-c5cbc7013221@linux.alibaba.com>
Date: Fri, 21 Sep 2018 17:00:52 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi folks,


When reading the mremap() code, I found the below code fragmentation:


 A A A A A A A  /* Conceal VM_ACCOUNT so old reservation is not undone */
 A A A A A A A  if (vm_flags & VM_ACCOUNT) {
 A A A A A A A A A A A A A A A  vma->vm_flags &= ~VM_ACCOUNT;
 A A A A A A A A A A A A A A A  excess = vma->vm_end - vma->vm_start - old_len;
 A A A A A A A A A A A A A A A  if (old_addr > vma->vm_start &&
 A A A A A A A A A A A A A A A A A A A  old_addr + old_len < vma->vm_end)
 A A A A A A A A A A A A A A A A A A A A A A A  split = 1;
 A A A A A A A  }

 A A A A A A A  ...

 A A A A A A A  do_munmap(mm, old_addr, old_len, uf_unmap)

 A A A A A A A  ...

 A A A A A A A  /* Restore VM_ACCOUNT if one or two pieces of vma left */
 A A A A A A A  if (excess) {
 A A A A A A A A A A A A A A A  vma->vm_flags |= VM_ACCOUNT;
 A A A A A A A A A A A A A A A  if (split)
 A A A A A A A A A A A A A A A A A A A A A A A  vma->vm_next->vm_flags |= VM_ACCOUNT;
 A A A A A A A  }


I don't get why it conceals VM_ACCOUNT, then restores it. This change is 
pre git period, so there is not commit log about why this is needed. Any 
hint is appreciated.


Thanks,

Yang
