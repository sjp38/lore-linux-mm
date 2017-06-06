Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 09BE76B0279
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 09:43:21 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b65so18828822lfh.8
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 06:43:20 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id n16si5501961lje.79.2017.06.06.06.43.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 06:43:19 -0700 (PDT)
Message-ID: <5936B098.6020807@huawei.com>
Date: Tue, 6 Jun 2017 21:39:36 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: double call identical release when there is a race hitting
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

Hi

when I review the code, I find the following scenario will lead to a race ,
but I am not sure whether the real issue will hit or not.

cpu1                                                                      cpu2
exit_mmap                                               mmu_notifier_unregister
   __mmu_notifier_release                                 srcu_read_lock
            srcu_read_lock
            mm->ops->release(mn, mm)                 mm->ops->release(mn,mm)
           srcu_read_unlock                                         srcu_read_unlock


obviously,  the specified mm will call identical release function when
the related condition satisfy.  is it right?

Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
