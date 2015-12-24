Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id DA54982F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 06:07:02 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id uo6so42639890pac.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 03:07:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id va5si8280620pac.165.2015.12.24.03.07.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Dec 2015 03:07:01 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
	<CAOxpaSV38vy2ywCqQZggfydWsSfAOVo-q8cn7OcuN86ch=4mEA@mail.gmail.com>
	<20151224094758.GA22760@dhcp22.suse.cz>
In-Reply-To: <20151224094758.GA22760@dhcp22.suse.cz>
Message-Id: <201512242006.CGJ81784.SVMHOOQtLFFFOJ@I-love.SAKURA.ne.jp>
Date: Thu, 24 Dec 2015 20:06:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, zwisler@gmail.com
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ross.zwisler@linux.intel.com

Michal Hocko wrote:
> This is VM_BUG_ON_PAGE(page_mapped(page), page), right? Could you attach
> the full kernel log? It all smells like a race when OOM reaper tears
> down the mapping and there is a truncate still in progress. But hitting
> the BUG_ON just because of that doesn't make much sense to me. OOM
> reaper is essentially MADV_DONTNEED. I have to think about this some
> more, though, but I am in a holiday mode until early next year so please
> bear with me.

I don't know whether the OOM killer was invoked just before this
VM_BUG_ON_PAGE().

> Is this somehow DAX related?

4.4.0-rc6-next-20151223_new_fsync_v6+ suggests that this kernel
has "[PATCH v6 0/7] DAX fsync/msync support" applied. But I think
http://marc.info/?l=linux-mm&m=145068666428057 should be applied
when retesting. (20151223 does not have this fix.)

[  235.768779]  [<ffffffff811feba4>] ? unmap_mapping_range+0x64/0x130
[  235.769385]  [<ffffffff811febb4>] ? unmap_mapping_range+0x74/0x130
[  235.770010]  [<ffffffff810f5c3f>] ? up_write+0x1f/0x40
[  235.770501]  [<ffffffff811febb4>] ? unmap_mapping_range+0x74/0x130

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
