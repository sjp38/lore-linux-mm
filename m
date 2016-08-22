Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E124D6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 09:03:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so61286302wmz.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:03:14 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id r125si16119038wmr.63.2016.08.22.06.03.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 06:03:13 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id o80so142835636wme.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:03:13 -0700 (PDT)
Date: Mon, 22 Aug 2016 15:03:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160822130311.GL13596@dhcp22.suse.cz>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812132140.GA776@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>

On Fri 12-08-16 15:21:41, Oleg Nesterov wrote:
[...]
> Whats really interesting is that I still fail to understand do we really
> need this hack, iiuc you are not sure too, and Michael didn't bother to
> explain why a bogus zero from anon memory is worse than other problems
> caused by SIGKKILL from oom-kill.c.

OK, so I've extended the changelog to clarify this some more, hopefully.
"
vhost driver relies on copy_from_user/get_user from a kernel thread.
This makes it impossible to reap the memory of an oom victim which
shares the mm with the vhost kernel thread because it could see a zero
page unexpectedly and theoretically make an incorrect decision visible
outside of the killed task context. To quote Michael S. Tsirkin:
: Getting an error from __get_user and friends is handled gracefully.
: Getting zero instead of a real value will cause userspace
: memory corruption.

The vhost kernel thread is bound to an open fd of the vhost device which
is not tight to the mm owner life cycle in theory. The fd can be 
inherited or passed over to another process which means that we really
have to be careful about unexpected memory corruption because unlike for
normal oom victims the result will be visible outside of the oom victim
context.

Make sure that each place which can read from userspace is annotated
properly and it uses copy_from_user_mm, __get_user_mm resp.
copy_from_iter_mm. Each will get the target mm as an argument and it
performs a pessimistic check to rule out that the oom_reaper could
possibly unmap the particular page. __oom_reap_task then just needs to
mark the mm as unstable before it unmaps any page.

An alternative approach would require to hook into the page fault path
and trigger EFAULT path from there but I do not like to add any code
to all users while there is a single use_mm() consumer which suffers 
from this problem. 

This is a preparatory patch without any functional changes because
the oom reaper doesn't touch mm shared with kthreads yet.
"

Does it help? Are there any other concerns or I can repost the series
and ask Andrew to pick it for mmotm tree?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
