Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6980F6B4A96
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 03:51:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h40-v6so1893939edb.2
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 00:51:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m26-v6si2911049edq.379.2018.08.29.00.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 00:51:32 -0700 (PDT)
Date: Wed, 29 Aug 2018 09:51:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
Message-ID: <20180829075129.GU10223@dhcp22.suse.cz>
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535476780-5773-3-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On Tue 28-08-18 13:19:40, Waiman Long wrote:
> For negative dentries that are accessed once and never used again, they
> should be removed first before other dentries when shrinker is running.
> This is done by putting negative dentries at the head of the LRU list
> instead at the tail.
> 
> A new DCACHE_NEW_NEGATIVE flag is now added to a negative dentry when it
> is initially created. When such a dentry is added to the LRU, it will be
> added to the head so that it will be the first to go when a shrinker is
> running if it is never accessed again (DCACHE_REFERENCED bit not set).
> The flag is cleared after the LRU list addition.

Placing object to the head of the LRU list can be really tricky as Dave
pointed out. I am not familiar with the dentry cache reclaim so my
comparison below might not apply. Let me try anyway.

Negative dentries sound very similar to MADV_FREE pages from the reclaim
POV. They are primary candidate for reclaim, yet you want to preserve
aging to other easily reclaimable objects (including other MADV_FREE
pages). What we do for those pages is to move them from the anonymous
LRU list to the inactive file LRU list. Now you obviously do not have
anon/file LRUs but something similar to active/inactive LRU lists might
be a reasonably good match. Have easily reclaimable dentries on the
inactive list including negative dentries. If negative entries are
heavily used then they can promote to the active list because there is
no reason to reclaim them soon.

Just my 2c
-- 
Michal Hocko
SUSE Labs
