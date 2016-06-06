Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEA916B0253
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 09:26:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 4so10414727wmz.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:26:55 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v3si18587351wmd.69.2016.06.06.06.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 06:26:54 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n184so16501026wmn.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:26:54 -0700 (PDT)
Date: Mon, 6 Jun 2016 15:26:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 10/10] mm, oom: hide mm which is shared with kthread
 or global init
Message-ID: <20160606132650.GI11895@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <1464945404-30157-11-git-send-email-mhocko@kernel.org>
 <201606040016.BFG17115.OFMLSJFOtHQOFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606040016.BFG17115.OFMLSJFOtHQOFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Sat 04-06-16 00:16:32, Tetsuo Handa wrote:
[...]
> Leaving current thread from out_of_memory() without clearing TIF_MEMDIE might
> cause OOM lockup, for there is no guarantee that current thread will not wait
> for locks in unkillable state after current memory allocation request completes
> (e.g. getname() followed by mutex_lock() shown at
> http://lkml.kernel.org/r/201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp ).

OK, so what do you think about the following. I am not entirely happy to
duplicate MMF_OOM_REAPED flags into other code paths but I guess we can
clean this up later.
---
