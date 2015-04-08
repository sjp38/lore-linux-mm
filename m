Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 411226B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 10:05:06 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so116677694pdb.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 07:05:06 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j2si16754722pdp.128.2015.04.08.07.05.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 07:05:05 -0700 (PDT)
Date: Wed, 8 Apr 2015 17:04:46 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [next:master 9613/10050] mm/cma_debug.c:45 cma_used_get() warn:
 should 'used << cma->order_per_bit' be a 64 bit type?
Message-ID: <20150408140446.GR16501@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, Stefan Strogin <stefan.strogin@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Dan Carpenter <dan.carpenter@oracle.com>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   a897436e0e233e84b664bb7f33c4e0d4d3e3bdad
commit: 8b0c0ea86849b55091281d146d62bbd9cda87556 [9613/10050] mm-cma-add-functions-to-get-region-pages-counters-fix-2

mm/cma_debug.c:45 cma_used_get() warn: should 'used << cma->order_per_bit' be a 64 bit type?
mm/cma_debug.c:67 cma_maxchunk_get() warn: should 'maxchunk << cma->order_per_bit' be a 64 bit type?

git remote add next git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
git remote update next
git checkout 8b0c0ea86849b55091281d146d62bbd9cda87556
vim +45 mm/cma_debug.c

8b0c0ea8 Stefan Strogin 2015-04-08  39  	unsigned long used;
c8e6dfcb Dmitry Safonov 2015-04-08  40  
8b0c0ea8 Stefan Strogin 2015-04-08  41  	mutex_lock(&cma->lock);
8b0c0ea8 Stefan Strogin 2015-04-08  42  	/* pages counter is smaller than sizeof(int) */
8b0c0ea8 Stefan Strogin 2015-04-08  43  	used = bitmap_weight(cma->bitmap, (int)cma->count);
8b0c0ea8 Stefan Strogin 2015-04-08  44  	mutex_unlock(&cma->lock);
8b0c0ea8 Stefan Strogin 2015-04-08 @45  	*val = used << cma->order_per_bit;
c8e6dfcb Dmitry Safonov 2015-04-08  46  
c8e6dfcb Dmitry Safonov 2015-04-08  47  	return 0;
c8e6dfcb Dmitry Safonov 2015-04-08  48  }
c8e6dfcb Dmitry Safonov 2015-04-08  49  
c8e6dfcb Dmitry Safonov 2015-04-08  50  DEFINE_SIMPLE_ATTRIBUTE(cma_used_fops, cma_used_get, NULL, "%llu\n");
c8e6dfcb Dmitry Safonov 2015-04-08  51  
c8e6dfcb Dmitry Safonov 2015-04-08  52  static int cma_maxchunk_get(void *data, u64 *val)
c8e6dfcb Dmitry Safonov 2015-04-08  53  {
c8e6dfcb Dmitry Safonov 2015-04-08  54  	struct cma *cma = data;
8b0c0ea8 Stefan Strogin 2015-04-08  55  	unsigned long maxchunk = 0;
8b0c0ea8 Stefan Strogin 2015-04-08  56  	unsigned long start, end = 0;
c8e6dfcb Dmitry Safonov 2015-04-08  57  
8b0c0ea8 Stefan Strogin 2015-04-08  58  	mutex_lock(&cma->lock);
8b0c0ea8 Stefan Strogin 2015-04-08  59  	for (;;) {
8b0c0ea8 Stefan Strogin 2015-04-08  60  		start = find_next_zero_bit(cma->bitmap, cma->count, end);
8b0c0ea8 Stefan Strogin 2015-04-08  61  		if (start >= cma->count)
8b0c0ea8 Stefan Strogin 2015-04-08  62  			break;
8b0c0ea8 Stefan Strogin 2015-04-08  63  		end = find_next_bit(cma->bitmap, cma->count, start);
8b0c0ea8 Stefan Strogin 2015-04-08  64  		maxchunk = max(end - start, maxchunk);
8b0c0ea8 Stefan Strogin 2015-04-08  65  	}
8b0c0ea8 Stefan Strogin 2015-04-08  66  	mutex_unlock(&cma->lock);
8b0c0ea8 Stefan Strogin 2015-04-08 @67  	*val = maxchunk << cma->order_per_bit;
c8e6dfcb Dmitry Safonov 2015-04-08  68  
c8e6dfcb Dmitry Safonov 2015-04-08  69  	return 0;
c8e6dfcb Dmitry Safonov 2015-04-08  70  }

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
