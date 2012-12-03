Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id D58F66B002B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 10:16:03 -0500 (EST)
Date: Mon, 3 Dec 2012 16:16:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121203151601.GA17093@dhcp22.suse.cz>
References: <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126132149.GD17860@dhcp22.suse.cz>
 <20121130032918.59B3F780@pobox.sk>
 <20121130124506.GH29317@dhcp22.suse.cz>
 <20121130144427.51A09169@pobox.sk>
 <20121130144431.GI29317@dhcp22.suse.cz>
 <20121130160811.6BB25BDD@pobox.sk>
 <20121130153942.GL29317@dhcp22.suse.cz>
 <20121130165937.F9564EBE@pobox.sk>
 <20121130161923.GN29317@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121130161923.GN29317@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 30-11-12 17:19:23, Michal Hocko wrote:
[...]
> The important question is why you see VM_FAULT_OOM and whether memcg
> charging failure can trigger that. I don not see how this could happen
> right now because __GFP_NORETRY is not used for user pages (except for
> THP which disable memcg OOM already), file backed page faults (aka
> __do_fault) use mem_cgroup_newpage_charge which doesn't disable OOM.
> This is a real head scratcher.

The following should print the traces when we hand over ENOMEM to the
caller. It should catch all charge paths (migration is not covered but
that one is not important here). If we don't see any traces from here
and there is still global OOM striking then there must be something else
to trigger this.
Could you test this with the patch which aims at fixing your deadlock,
please? I realise that this is a production environment but I do not see
anything relevant in the code.
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c8425b1..9e5b56b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2397,6 +2397,7 @@ done:
 	return 0;
 nomem:
 	*ptr = NULL;
+	__WARN();
 	return -ENOMEM;
 bypass:
 	*ptr = NULL;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
