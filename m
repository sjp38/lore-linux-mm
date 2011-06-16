Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B2F446B0082
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 06:09:55 -0400 (EDT)
Date: Thu, 16 Jun 2011 12:09:37 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: [-git build bug, PATCH] Re: [BUGFIX][PATCH 2/5] memcg: fix
 init_page_cgroup nid with sparsemem
Message-ID: <20110616100937.GA12317@elte.hu>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
 <20110613120608.d5243bc9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110613120608.d5243bc9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>


* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Date: Mon, 13 Jun 2011 10:09:17 +0900
> Subject: [PATCH 2/5] [BUGFIX] memcg: fix init_page_cgroup nid with sparsemem

This fresh upstream commit commit:

  37573e8c7182: memcg: fix init_page_cgroup nid with sparsemem

is causing widespread build failures on latest -git, on x86:

  mm/page_cgroup.c:308:3: error: implicit declaration of function a??node_start_pfna?? [-Werror=implicit-function-declaration]
  mm/page_cgroup.c:309:3: error: implicit declaration of function a??node_end_pfna?? [-Werror=implicit-function-declaration]

On any config that has CONFIG_CGROUP_MEM_RES_CTLR=y enabled but 
CONFIG_NUMA disabled.

For now i've worked it around with the patch below, but the real 
solution would be to make the page_cgroup.c code not depend on NUMA.

Thanks,

	Ingo

diff --git a/init/Kconfig b/init/Kconfig
index 412c21b..1593be9 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -639,6 +639,7 @@ config RESOURCE_COUNTERS
 config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
 	depends on RESOURCE_COUNTERS
+	depends on NUMA
 	select MM_OWNER
 	help
 	  Provides a memory resource controller that manages both anonymous

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
