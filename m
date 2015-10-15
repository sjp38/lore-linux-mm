Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0B22F6B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 03:05:13 -0400 (EDT)
Received: by oihr205 with SMTP id r205so41153147oih.3
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 00:05:12 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id dh7si6701288oec.16.2015.10.15.00.04.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 15 Oct 2015 00:05:12 -0700 (PDT)
Message-ID: <561F4EEA.60203@huawei.com>
Date: Thu, 15 Oct 2015 14:59:54 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: some problems about kasan
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, adech.fo@gmail.com, ryabinin.a.a@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, qiuxishi@huawei.com, guohanjun@huawei.com, zhangdianfang@huawei.com

1a?? I feel confused about one of the cases when  testing the cases  kasan can solve . the function come from the kernel in the /lib/test_kasan.c.

  static noinline void __init kmalloc_uaf2(void)
{
	char *ptr1, *ptr2;
	size_t size = 43;

	pr_info("use-after-free after another kmalloc\n");
	ptr1 = kmalloc(size, GFP_KERNEL);
	if (!ptr1) {
		pr_err("Allocation failed\n");
		return;
	}

	kfree(ptr1);
	ptr2 = kmalloc(size, GFP_KERNEL);
	if (!ptr2) {
		pr_err("Allocation failed\n");
		return;
	}

	ptr1[40] = 'x';
	kfree(ptr2);
}

In the above function, the point ptr1 are probably  the same as the ptr2 . so the error not certain to occur.

2a??Is the stack local variable out of bound access set by the GCC  ? I don't see any operate in the kernel

3a??I want to know that the global variable size include redzone is allocated by the module_alloc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
