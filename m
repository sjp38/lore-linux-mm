Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7C8AE6B024C
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 08:24:16 -0400 (EDT)
Date: Fri, 14 Sep 2012 14:24:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3] memcg: clean up networking headers file inclusion
Message-ID: <20120914122413.GO28039@dhcp22.suse.cz>
References: <20120914112118.GG28039@dhcp22.suse.cz>
 <50531339.1000805@parallels.com>
 <20120914113400.GI28039@dhcp22.suse.cz>
 <50531696.1080708@parallels.com>
 <20120914120849.GL28039@dhcp22.suse.cz>
 <5052E766.9070304@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5052E766.9070304@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>, Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sachin Kamat <sachin.kamat@linaro.org>

On Fri 14-09-12 12:14:30, Glauber Costa wrote:
> On 09/14/2012 04:08 PM, Michal Hocko wrote:
> > On Fri 14-09-12 15:35:50, Glauber Costa wrote:
> > [...]
> >> So, *right now* this code is used only for inet code, so I won't oppose
> >> your patch on this basis. I'll reuse it for kmem, but I am happy to just
> >> rebase it.
> > 
> > Hmm, I guess I was too strict after all. memcg_init_kmem doesn't need
> > CONFIG_INET gueard as both mem_cgroup_sockets_{init,destroy} are defined
> > empty for !CONFIG_INET. All other functions guarded in INET&&KMEM combo
> > seem to be networking specific.
> > Updated patch bellow:
> > ---
> > From 4dca5e135b4dcc08464bbd70761d094f99ed83b1 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Tue, 11 Sep 2012 10:38:42 +0200
> > Subject: [PATCH] memcg: clean up networking headers file inclusion
> > 
> > Memory controller doesn't need anything from the networking stack unless
> > CONFIG_MEMCG_KMEM is selected.
> > Now we are including net/sock.h and net/tcp_memcontrol.h unconditionally
> > which is not necessary. Moreover struct mem_cgroup contains tcp_mem
> > even if CONFIG_MEMCG_KMEM and CONFIG_INET are not selected which is not
> > necessary.
> > While we are at it, let's clean up KMEM sock code ifdefs to require both
> > CONFIG_KMEM and CONFIG_INET as it doesn't make much sense to compile
> > this code if there is no possible user for it.
> > 
> > Tested with
> > - CONFIG_INET && CONFIG_MEMCG_KMEM
> > - !CONFIG_INET && CONFIG_MEMCG_KMEM
> > - CONFIG_INET && !CONFIG_MEMCG_KMEM
> > - !CONFIG_INET && !CONFIG_MEMCG_KMEM
> > 
> > Changes since V2:
> > - memcg_init_kmem and kmem_cgroup_destroy don't need CONFIG_INET
> > 
> > Changes since V1:
> > - depend on both CONFIG_INET and CONFIG_MEMCG_KMEM for both
> >   mem_cgroup->tcp_mem and the sock specific code
> > 
> > Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Seems safe now. Since the config matrix can get tricky, and we have no
> pressing time issues with this, I would advise to give it a day in
> Fengguang's magic system before merging it. Just put it in a temp branch
> in korg and let it do the job.

OK done. It is cleanups/memcg-sock-include.

Fengguang, do you think we can (ab)use your build test coverity to test
git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git cleanups/memcg-sock-include

Thanks a lot!

I will repost both patches later (and hopefully I will not forget about
other people on the CC list list like now...)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
