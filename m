Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3DB6B0005
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 16:44:27 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id s1so4832319qkc.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 13:44:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g124si19589879qke.278.2016.06.14.13.44.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 13:44:26 -0700 (PDT)
Date: Tue, 14 Jun 2016 22:44:20 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/10 -v4] Handle oom bypass more gracefully
Message-ID: <20160614204420.GA2315@redhat.com>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <20160613112348.GC6518@dhcp22.suse.cz>
 <20160613141324.GK6518@dhcp22.suse.cz>
 <20160614201740.GA617@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160614201740.GA617@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 06/14, Oleg Nesterov wrote:
>
> So to me this additional patch looks fine,

forgot to mention, but I think it needs another change in task_will_free_mem(),
it should ignore kthreads (should not fail if we see a kthread which shares
task->mm).

And the comment you added on top of use_mm() looks misleading in any case.

"Do not use copy_from_user from this context" looks simply wrong, why else
do you need use_mm() if you are not going to do get/put_user?

"because the address space might got reclaimed behind the back by the oom_reaper"
doesn't look right too, copy_from_user() can also fail or read ZERO_PAGE() if mm
owner does munmap/madvise.

> but probably I missed something?

Yes...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
