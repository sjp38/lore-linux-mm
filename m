Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1C0D66B0092
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 16:24:10 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so688161pad.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 13:24:09 -0700 (PDT)
Date: Fri, 19 Oct 2012 13:24:05 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121019202405.GR13370@google.com>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-5-git-send-email-mhocko@suse.cz>
 <20121018224148.GR13370@google.com>
 <20121019133244.GE799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121019133244.GE799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

Hello, Michal.

On Fri, Oct 19, 2012 at 03:32:45PM +0200, Michal Hocko wrote:
> On Thu 18-10-12 15:41:48, Tejun Heo wrote:
> > Hello, Michal.
> > 
> > On Wed, Oct 17, 2012 at 03:30:46PM +0200, Michal Hocko wrote:
> > > Now that mem_cgroup_pre_destroy callback doesn't fail finally we can
> > > safely move on and forbit all the callbacks to fail. The last missing
> > > piece is moving cgroup_call_pre_destroy after cgroup_clear_css_refs so
> > > that css_tryget fails so no new charges for the memcg can happen.
> > > The callbacks are also called from within cgroup_lock to guarantee that
> > > no new tasks show up. We could theoretically call them outside of the
> > > lock but then we have to move after CGRP_REMOVED flag is set.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > So, the plan is to do something like the following once memcg is
> > ready.
> > 
> >   http://thread.gmane.org/gmane.linux.kernel.containers/22559/focus=75251
> > 
> > Note that the patch is broken in a couple places but it does show the
> > general direction.  I'd prefer if patch #3 simply makes pre_destroy()
> > return 0 and drop __DEPRECATED_clear_css_refs from mem_cgroup_subsys.
> 
> We can still fail inn #3 without this patch becasuse there are is no
> guarantee that a new task is attached to the group. And I wanted to keep
> memcg and generic cgroup parts separated.

Yes, but all other controllers are broken that way too and the worst
thing which will hapen is triggering WARN_ON_ONCE().  Let's note the
failure in the commit and remove DEPREDATED_clear_css_refs in the
previous patch.  Then, I can pull from you, clean up pre_destroy mess
and then you can pull back for further cleanups.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
