Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 600506B025E
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 04:41:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 101so62484968qtb.0
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 01:41:56 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id g202si9944760wmg.75.2016.08.14.01.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Aug 2016 01:41:54 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so5656929wme.0
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 01:41:53 -0700 (PDT)
Date: Sun, 14 Aug 2016 10:41:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160814084151.GA9248@dhcp22.suse.cz>
References: <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
 <20160813001500.yvmv67cram3bp7ug@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160813001500.yvmv67cram3bp7ug@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Sat 13-08-16 03:15:00, Michael S. Tsirkin wrote:
> On Fri, Aug 12, 2016 at 03:21:41PM +0200, Oleg Nesterov wrote:
> > Whats really interesting is that I still fail to understand do we really
> > need this hack, iiuc you are not sure too, and Michael didn't bother to
> > explain why a bogus zero from anon memory is worse than other problems
> > caused by SIGKKILL from oom-kill.c.
> 
> vhost thread will die, but vcpu thread is going on.  If it's memory is
> corrupted because vhost read 0 and uses that as an array index, it can
> do things like corrupt the disk, so it can't be restarted.
> 
> But I really wish we didn't need this special-casing.  Can't PTEs be
> made invalid on oom instead of pointing them at the zero page?

Well ptes are just made !present and the subsequent #PF will allocate
a fresh new page which will be a zero page as the original content is
gone already. But I am not really sure what you mean by an invalid
pte. You are in a kernel thread context, aka unkillable context. How
would you handle SIGBUS or whatever other signal as a result of the
invalid access?

> And then
> won't memory accesses trigger pagefaults instead of returning 0?

See above. Zero page is just result of the lost memory content. We
cannot both reclaim and keep the original content.

> That
> would make regular copy_from_user machinery do the right thing,
> making vhost stop running as appropriate.

I must be missing something here but how would you make the kernel
thread context find out the invalid access. You would have to perform
signal handling routine after every single memory access and I fail how
this is any different from a special copy_from_user_mm.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
