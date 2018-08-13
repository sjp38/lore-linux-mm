Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 791896B0005
	for <linux-mm@kvack.org>; Sun, 12 Aug 2018 23:10:30 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w18-v6so10228881plp.3
        for <linux-mm@kvack.org>; Sun, 12 Aug 2018 20:10:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 19-v6sor3699372pgl.427.2018.08.12.20.10.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 12 Aug 2018 20:10:29 -0700 (PDT)
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Subject: [BUG] mm: truncate: a possible sleep-in-atomic-context bug in
 truncate_exceptional_pvec_entries()
Message-ID: <f863cf8d-615f-c622-812a-a6370efe757b@gmail.com>
Date: Mon, 13 Aug 2018 11:10:23 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jack@suse.cz, mgorman@techsingularity.net, ak@linux.intel.com, mawilcox@microsoft.com, viro@zeniv.linux.org.ukmawilcox@microsoft.com, ross.zwisler@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>

The kernel may sleep with holding a spinlock.

The function call paths (from bottom to top) in Linux-4.16 are:

[FUNC] schedule
fs/dax.c, 259: schedule in get_unlocked_mapping_entry
fs/dax.c, 450: get_unlocked_mapping_entry in __dax_invalidate_mapping_entry
fs/dax.c, 471: __dax_invalidate_mapping_entry in dax_delete_mapping_entry
mm/truncate.c, 97: dax_delete_mapping_entry in 
truncate_exceptional_pvec_entries
mm/truncate.c, 82: spin_lock_irq in truncate_exceptional_pvec_entries

I do not find a good way to fix, so I only report.
This is found by my static analysis tool (DSAC).


Thanks,
Jia-Ju Bai
