Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D42BC28092C
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 16:22:22 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id p78so63040703lfd.0
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 13:22:22 -0800 (PST)
Received: from mail.ispras.ru (mail.ispras.ru. [83.149.199.45])
        by mx.google.com with ESMTP id j185si2240667lfg.164.2017.03.10.13.22.21
        for <linux-mm@kvack.org>;
        Fri, 10 Mar 2017 13:22:21 -0800 (PST)
From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: z3fold: suspicious return with spinlock held
Date: Sat, 11 Mar 2017 00:22:12 +0300
Message-Id: <1489180932-13918-1-git-send-email-khoroshilov@ispras.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org

Hello!

z3fold_reclaim_page() contains the only return that may
leave the function with pool->lock spinlock held.

669 	spin_lock(&pool->lock);
670 	if (kref_put(&zhdr->refcount, release_z3fold_page)) {
671 		atomic64_dec(&pool->pages_nr);
672 		return 0;
673 	}

May be we need spin_unlock(&pool->lock); just before return?


Found by Linux Driver Verification project (linuxtesting.org).

--
Thank you,
Alexey Khoroshilov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
