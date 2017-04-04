Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FDFC6B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 09:23:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g7so28541682wrd.16
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 06:23:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u203si8657027wmg.14.2017.04.04.06.23.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 06:23:52 -0700 (PDT)
Date: Tue, 4 Apr 2017 15:23:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: oom: Bogus "sysrq: OOM request ignored because killer is
 disabled" message
Message-ID: <20170404132349.GM15132@dhcp22.suse.cz>
References: <201704021252.GIF21549.QFFOFOMVJtHSLO@I-love.SAKURA.ne.jp>
 <20170403083800.GF24661@dhcp22.suse.cz>
 <20170403091153.GH24661@dhcp22.suse.cz>
 <20170403101041.GC29639@esperanza>
 <20170403102029.GJ24661@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403102029.GJ24661@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org

On Mon 03-04-17 12:20:29, Michal Hocko wrote:
> On Mon 03-04-17 13:10:41, Vladimir Davydov wrote:
> > On Mon, Apr 03, 2017 at 11:11:53AM +0200, Michal Hocko wrote:
> > > [Fixup Vladimir email address]
> > > 
> > > On Mon 03-04-17 10:38:00, Michal Hocko wrote:
[...]
> > > > The real reason is that there are no eligible tasks for the OOM killer
> > > > to select but since 7c5f64f84483bd13 ("mm: oom: deduplicate victim
> > > > selection code for memcg and global oom") the semantic of out_of_memory
> > > > has changed without updating moom_callback.
> > > > 
> > > > This patch updates moom_callback to tell that no task was eligible
> > > > which is the case for both oom killer disabled and no eligible tasks.
> > > > In order to help distinguish first case from the second add printk to
> > > > both oom_killer_{enable,disable}. This information is useful on its own
> > > > because it might help debugging potential memory allocation failures.
> > 
> > I think this makes sense although personally I find the "No task
> > eligible" message in case OOM killer is disabled manually a bit
> > confusing: the thing is in order to find out why an OOM request
> > failed you'll have to scan the full log, which might be unavailable.
> > May be, we'd better just make out_of_memory() return true in case
> > is_sysrq_oom() is true and no task was found, as it used to be.
> 
> Well, the thing is that the oom killer is disabled only during the PM
> suspend and I do not expect we would grow new users. And it is quite
> unlikely to invoke sysrq during that time. The OOM killer is disabled is
> unlikely to be too far in the past in that case. It is also a matter of
> fact that no tasks are eligible during that time period so the message
> is not misleading. I have considered is_sysrq_oom approach but I would
> rather not add yet another exception for that path, we have quite some
> of them already. Especially when the only point of that exception would
> be to control a log message.

Does this reasoning make sense to you? Can I post the patch to Andrew or
you sill see strong reasons to tweak out_of_memory?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
