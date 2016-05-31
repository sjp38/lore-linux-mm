Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 54D936B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 17:01:18 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id k63so382019936qgf.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 14:01:18 -0700 (PDT)
Received: from mail-yw0-x22c.google.com (mail-yw0-x22c.google.com. [2607:f8b0:4002:c05::22c])
        by mx.google.com with ESMTPS id z195si12485278ywg.122.2016.05.31.14.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 14:01:17 -0700 (PDT)
Received: by mail-yw0-x22c.google.com with SMTP id c127so201788278ywb.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 14:01:17 -0700 (PDT)
Date: Tue, 31 May 2016 17:01:16 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/swap: lru drain on memory reclaim workqueue
Message-ID: <20160531210116.GA14868@mtj.duckdns.org>
References: <1464727815-13073-1-git-send-email-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464727815-13073-1-git-send-email-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, May 31, 2016 at 02:50:15PM -0600, Keith Busch wrote:
> +	system_mem_wq = alloc_workqueue("events_mem_unbound", WQ_UNBOUND | WQ_MEM_RECLAIM,

So, WQ_MEM_RECLAIM on a shared workqueue doesn't make much sense.
That flag guarantees single concurrency level to the workqueue.  How
would multiple users of a shared workqueue coordinate around that?
What prevents one events_mem_unbound user from depending on, say,
draining lru?  If lru draining requires a rescuer to guarantee forward
progress under memory pressure, that rescuer worker must be dedicated
for that purpose and can't be shared.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
