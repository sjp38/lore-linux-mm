Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA5D76B0269
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:32:02 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u14so47526532lfd.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:32:02 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lr1si382357wjb.14.2016.09.15.07.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 07:31:47 -0700 (PDT)
Date: Thu, 15 Sep 2016 10:27:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm: memcontrol: consolidate cgroup socket tracking
Message-ID: <20160915142733.GA25519@cmpxchg.org>
References: <20160914194846.11153-3-hannes@cmpxchg.org>
 <201609151357.bgs2EcXM%fengguang.wu@intel.com>
 <20160914151714.f6d1b2a57da0619bf9e2372c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914151714.f6d1b2a57da0619bf9e2372c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Sep 14, 2016 at 03:17:14PM -0700, Andrew Morton wrote:
> On Thu, 15 Sep 2016 13:34:24 +0800 kbuild test robot <lkp@intel.com> wrote:
> 
> > Hi Johannes,
> > 
> > [auto build test ERROR on net/master]
> > [also build test ERROR on v4.8-rc6 next-20160914]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > [Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
> > [Check https://git-scm.com/docs/git-format-patch for more information]
> > 
> > url:    https://github.com/0day-ci/linux/commits/Johannes-Weiner/mm-memcontrol-make-per-cpu-charge-cache-IRQ-safe-for-socket-accounting/20160915-035634
> > config: m68k-sun3_defconfig (attached as .config)
> > compiler: m68k-linux-gcc (GCC) 4.9.0
> > reproduce:
> >         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=m68k 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    net/built-in.o: In function `sk_alloc':
> > >> (.text+0x4076): undefined reference to `mem_cgroup_sk_alloc'
> >    net/built-in.o: In function `__sk_destruct':
> > >> sock.c:(.text+0x457e): undefined reference to `mem_cgroup_sk_free'
> >    net/built-in.o: In function `sk_clone_lock':
> >    (.text+0x4f1c): undefined reference to `mem_cgroup_sk_alloc'
> 
> This?

Thanks for fixing it up, Andrew.

I think it'd be nicer to declare the dummy functions for !CONFIG_MEMCG;
it also doesn't look like a hotpath that would necessitate the jump
label in that place. Dave, any preference either way?

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ca11b3e6dd65..61d20c17f3b7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -773,13 +773,13 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 struct sock;
-void mem_cgroup_sk_alloc(struct sock *sk);
-void mem_cgroup_sk_free(struct sock *sk);
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 #ifdef CONFIG_MEMCG
 extern struct static_key_false memcg_sockets_enabled_key;
 #define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
+void mem_cgroup_sk_alloc(struct sock *sk);
+void mem_cgroup_sk_free(struct sock *sk);
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && memcg->tcpmem_pressure)
@@ -792,6 +792,8 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 }
 #else
 #define mem_cgroup_sockets_enabled 0
+static inline void mem_cgroup_sk_alloc(struct sock *sk) { };
+static inline void mem_cgroup_sk_free(struct sock *sk) { };
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 	return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
