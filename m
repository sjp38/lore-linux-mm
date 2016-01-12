Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id D45B44403DB
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 04:34:04 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id py5so54563243obc.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 01:34:04 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id mz3si31907760obb.100.2016.01.12.01.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 01:34:04 -0800 (PST)
Date: Tue, 12 Jan 2016 12:33:56 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: balloon: fix page list locking
Message-ID: <20160112093356.GC29804@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: linux-mm@kvack.org

Hello Michael S. Tsirkin,

The patch 0b5ffdb4f7c6: "balloon: fix page list locking" from Jan 1,
2016, leads to the following static checker warning:

	mm/balloon_compaction.c:116 balloon_page_dequeue()
	error: double unlock 'spin_lock:&b_dev_info->pages_lock'

mm/balloon_compaction.c
   101                          spin_lock_irqsave(&b_dev_info->pages_lock, flags);
   102                          balloon_page_delete(page);
   103                          __count_vm_event(BALLOON_DEFLATE);
   104                          spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Unlock.

   105                          unlock_page(page);
   106                          put_page(page);
   107                          dequeued_page = true;
   108                          break;
   109                  }
   110                  put_page(page);
   111                  spin_lock_irqsave(&b_dev_info->pages_lock, flags);
   112          }
   113  
   114          /* re-add remaining entries */
   115          list_splice(&processed, &b_dev_info->pages);
   116          spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Second unlock.

   117  
   118          if (!dequeued_page) {

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
