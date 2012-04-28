Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 0B9AC6B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 17:31:56 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so2810041pbc.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 14:31:56 -0700 (PDT)
Date: Sat, 28 Apr 2012 14:31:51 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH 8/9 v2] cgroup: avoid creating new cgroup under a
 cgroup being destroyed
Message-ID: <20120428213151.GA4586@mtj.dyndns.org>
References: <4F9A327A.6050409@jp.fujitsu.com>
 <4F9A36DE.30301@jp.fujitsu.com>
 <20120427204035.GN26595@google.com>
 <CABEgKgrJ68wU-L17zwN4_htX948TNFnLVgts=hFeY7QG3etwCA@mail.gmail.com>
 <20120428020003.GA26573@mtj.dyndns.org>
 <CABEgKgpPXPu3L6oS6+2+dZmcPS=t-ZR7PnCvm0mo8UFeXPHDog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CABEgKgpPXPu3L6oS6+2+dZmcPS=t-ZR7PnCvm0mo8UFeXPHDog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

Hello, KAME.

On Sat, Apr 28, 2012 at 06:31:38PM +0900, Hiroyuki Kamezawa wrote:
> > So, IMHO, just making pre_destroy() clean up its own charges and
> > always returning 0 is enough.  There's no need to fix up old
> > non-critical race condition at this point in the patch stream.  cgroup
> > rmdir simplification will make them disappear anyway.
>
> So, hmm, ok. I'll drop patch 7 & 8. memcg may return -EBUSY in very very
> race case but users will not see it in the most case.
> I'll fix limit, move-charge and use_hierarchy problem first.

IIUC, memcg can just return 0 when child creation races against
pre_destroy().  cgroup will retry if child exists after pre_destroy()
completion.  If child comes and goes before cgroup checks its
existence, some charges may be lost but that race already exists and
it will be gone once the retry logic is removed.  Also, returning
-errno will trigger WARN_ON() w/o the legacy behavior flag.

Thank you very much.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
