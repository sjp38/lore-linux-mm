Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3D06B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 10:42:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so1972947wme.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:42:01 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id s7si2693827wme.118.2016.08.12.07.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 07:41:59 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i138so3233330wmf.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:41:59 -0700 (PDT)
Date: Fri, 12 Aug 2016 16:41:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160812144157.GL3639@dhcp22.suse.cz>
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
> On 08/12, Michal Hocko wrote:
[...]
> There is a more interesting case when another 3rd thread can trigger
> a fault and populate this page before __get_user_mm() calls _get_user().
> But even in this case I think we are fine.

All the threads should be killed/exiting so they shouldn't access that
memory. My assumption is that the exit path doesn't touch that memory.
If any of threads was in the middle of the page fault or g-u-p while
writing to that address then it should be OK because it would be just
a matter of SIGKILL timing.  I might be wrong here and in that case
__get_user_mm wouldn't be sufficient of course.

> Whats really interesting is that I still fail to understand do we really
> need this hack, iiuc you are not sure too, and Michael didn't bother to
> explain why a bogus zero from anon memory is worse than other problems
> caused by SIGKKILL from oom-kill.c.

Yes, I admit that I am not familiar with the vhost memory usage model so
I can only speculate. But the mere fact that the mm is bound to a device
fd which can be passed over to a different process makes me worried.
This means that the mm is basically isolated from the original process
until the last fd is closed which is under control of the process which
holds it. The mm can still be access during that time from the vhost
worker. And I guess this is exactly where the problem lies.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
