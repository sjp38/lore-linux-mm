Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C773F6B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 08:44:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g90so8033579wrd.14
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:44:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t66si3187598wma.78.2017.10.30.05.44.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 05:44:00 -0700 (PDT)
Date: Mon, 30 Oct 2017 13:43:58 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20171030124358.GF23278@quack2.suse.cz>
References: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: jack@suse.cz, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 28-10-17 02:22:18, Yang Shi wrote:
> If some process generates events into a huge or unlimit event queue, but no
> listener read them, they may consume significant amount of memory silently
> until oom happens or some memory pressure issue is raised.
> It'd better to account those slab caches in memcg so that we can get heads
> up before the problematic process consume too much memory silently.
> 
> But, the accounting might be heuristic if the producer is in the different
> memcg from listener if the listener doesn't read the events. Due to the
> current design of kmemcg, who does the allocation, who gets the accounting.
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> ---
> v1 --> v2:
> * Updated commit log per Amir's suggestion

I'm sorry but I don't think this solution is acceptable. I understand that
in some cases (and you likely run one of these) the result may *happen* to
be the desired one but in other cases, you might be charging wrong memcg
and so misbehaving process in memcg A can effectively cause a DoS attack on
a process in memcg B.

If you have a setup in which notification events can consume considerable
amount of resources, you are doing something wrong I think. Standard event
queue length is limited, overall events are bounded to consume less than 1
MB. If you have unbounded queue, the process has to be CAP_SYS_ADMIN and
presumably it has good reasons for requesting unbounded queue and it should
know what it is doing.

So maybe we could come up with some better way to control amount of
resources consumed by notification events but for that we lack more
information about your use case. And I maintain that the solution should
account events to the consumer, not the producer...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
