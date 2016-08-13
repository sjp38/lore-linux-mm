Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57D9A6B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 20:15:07 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i184so4059505ywb.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 17:15:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o10si6315257qtb.120.2016.08.12.17.15.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 17:15:06 -0700 (PDT)
Date: Sat, 13 Aug 2016 03:15:00 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160813001500.yvmv67cram3bp7ug@redhat.com>
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
Cc: Michal Hocko <mhocko@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Fri, Aug 12, 2016 at 03:21:41PM +0200, Oleg Nesterov wrote:
> Whats really interesting is that I still fail to understand do we really
> need this hack, iiuc you are not sure too, and Michael didn't bother to
> explain why a bogus zero from anon memory is worse than other problems
> caused by SIGKKILL from oom-kill.c.

vhost thread will die, but vcpu thread is going on.  If it's memory is
corrupted because vhost read 0 and uses that as an array index, it can
do things like corrupt the disk, so it can't be restarted.

But I really wish we didn't need this special-casing.  Can't PTEs be
made invalid on oom instead of pointing them at the zero page? And then
won't memory accesses trigger pagefaults instead of returning 0? That
would make regular copy_from_user machinery do the right thing,
making vhost stop running as appropriate.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
