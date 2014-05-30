Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 601496B0037
	for <linux-mm@kvack.org>; Thu, 29 May 2014 22:57:09 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id wn1so1223440obc.41
        for <linux-mm@kvack.org>; Thu, 29 May 2014 19:57:09 -0700 (PDT)
Received: from mail-oa0-x244.google.com (mail-oa0-x244.google.com [2607:f8b0:4003:c02::244])
        by mx.google.com with ESMTPS id j1si4834513oev.102.2014.05.29.19.57.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 19:57:08 -0700 (PDT)
Received: by mail-oa0-f68.google.com with SMTP id i7so323752oag.11
        for <linux-mm@kvack.org>; Thu, 29 May 2014 19:57:08 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 30 May 2014 10:57:08 +0800
Message-ID: <CAGO-9moQrepikUk198XjgiE=hC2W6u_Wsup8yK=ooBfPNg1PfQ@mail.gmail.com>
Subject: Ask for help on the memory allocation for process shared mutex
 (resend with plain text)
From: yang ben <benyangfsl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear experts,

I came across a memory/mutex issue. Would you kindly shed some light on it?

I use pthread_mutex_xxx API to protect processes in user space. Since
it should be process shared, I allocated a shared memory to store
pthread_mutex_t structure.

The shared memory is allocated using vmalloc_user() and mapped using
remap_vmalloc_range() in driver. However, get_futex_key() will always
return -EFAULT, because page_head->mapping==0.

futex.c (Linux-3.10.31)
         if (!page_head->mapping) {
                 int shmem_swizzled = PageSwapCache(page_head);
                 unlock_page(page_head);
                 put_page(page_head);
                 if (shmem_swizzled)
                         goto again;
                 return -EFAULT;
         }

Is there special requirement on the memory to store mutex? What's the
correct way to allocate such memory in driver?
Thanks in advance!

Regards,
Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
