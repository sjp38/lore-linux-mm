Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF2996B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 18:17:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so57564186pfb.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 15:17:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z89si3943041pff.2.2016.09.14.15.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 15:17:17 -0700 (PDT)
Date: Wed, 14 Sep 2016 15:17:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: memcontrol: consolidate cgroup socket tracking
Message-Id: <20160914151714.f6d1b2a57da0619bf9e2372c@linux-foundation.org>
In-Reply-To: <201609151357.bgs2EcXM%fengguang.wu@intel.com>
References: <20160914194846.11153-3-hannes@cmpxchg.org>
	<201609151357.bgs2EcXM%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org, Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, 15 Sep 2016 13:34:24 +0800 kbuild test robot <lkp@intel.com> wrote:

> Hi Johannes,
> 
> [auto build test ERROR on net/master]
> [also build test ERROR on v4.8-rc6 next-20160914]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> [Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
> [Check https://git-scm.com/docs/git-format-patch for more information]
> 
> url:    https://github.com/0day-ci/linux/commits/Johannes-Weiner/mm-memcontrol-make-per-cpu-charge-cache-IRQ-safe-for-socket-accounting/20160915-035634
> config: m68k-sun3_defconfig (attached as .config)
> compiler: m68k-linux-gcc (GCC) 4.9.0
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=m68k 
> 
> All errors (new ones prefixed by >>):
> 
>    net/built-in.o: In function `sk_alloc':
> >> (.text+0x4076): undefined reference to `mem_cgroup_sk_alloc'
>    net/built-in.o: In function `__sk_destruct':
> >> sock.c:(.text+0x457e): undefined reference to `mem_cgroup_sk_free'
>    net/built-in.o: In function `sk_clone_lock':
>    (.text+0x4f1c): undefined reference to `mem_cgroup_sk_alloc'

This?

--- a/mm/memcontrol.c~mm-memcontrol-consolidate-cgroup-socket-tracking-fix
+++ a/mm/memcontrol.c
@@ -5655,9 +5655,6 @@ void mem_cgroup_sk_alloc(struct sock *sk
 {
 	struct mem_cgroup *memcg;
 
-	if (!mem_cgroup_sockets_enabled)
-		return;
-
 	/*
 	 * Socket cloning can throw us here with sk_memcg already
 	 * filled. It won't however, necessarily happen from
--- a/net/core/sock.c~mm-memcontrol-consolidate-cgroup-socket-tracking-fix
+++ a/net/core/sock.c
@@ -1385,7 +1385,8 @@ static void sk_prot_free(struct proto *p
 	slab = prot->slab;
 
 	cgroup_sk_free(&sk->sk_cgrp_data);
-	mem_cgroup_sk_free(sk);
+	if (mem_cgroup_sockets_enabled)
+		mem_cgroup_sk_free(sk);
 	security_sk_free(sk);
 	if (slab != NULL)
 		kmem_cache_free(slab, sk);
@@ -1422,7 +1423,8 @@ struct sock *sk_alloc(struct net *net, i
 		sock_net_set(sk, net);
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
-		mem_cgroup_sk_alloc(sk);
+		if (mem_cgroup_sockets_enabled)
+			mem_cgroup_sk_alloc(sk);
 		cgroup_sk_alloc(&sk->sk_cgrp_data);
 		sock_update_classid(&sk->sk_cgrp_data);
 		sock_update_netprioidx(&sk->sk_cgrp_data);
@@ -1569,7 +1571,8 @@ struct sock *sk_clone_lock(const struct
 		newsk->sk_incoming_cpu = raw_smp_processor_id();
 		atomic64_set(&newsk->sk_cookie, 0);
 
-		mem_cgroup_sk_alloc(newsk);
+		if (mem_cgroup_sockets_enabled)
+			mem_cgroup_sk_alloc(newsk);
 		cgroup_sk_alloc(&newsk->sk_cgrp_data);
 
 		/*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
