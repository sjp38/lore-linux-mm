Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 920736B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 08:58:00 -0500 (EST)
Date: Tue, 27 Dec 2011 14:57:52 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] Makefiles: Disable unused-variable warning (was: Re: [PATCH
 1/6] memcg: fix unused variable warning)
Message-ID: <20111227135752.GK5344@tiehlicka.suse.cz>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Marek <mmarek@suse.cz>, linux-kbuild@vger.kernel.org

On Sat 24-12-11 05:00:14, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> 
> mm/memcontrol.c: In function a??memcg_check_eventsa??:
> mm/memcontrol.c:784:22: warning: unused variable a??do_numainfoa?? [-Wunused-variable]
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>  mm/memcontrol.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d643bd6..a5e92bd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -781,14 +781,15 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>  	/* threshold event is triggered in finer grain than soft limit */
>  	if (unlikely(mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_THRESH))) {
> -		bool do_softlimit, do_numainfo;
> +		bool do_softlimit;
>  
> -		do_softlimit = mem_cgroup_event_ratelimit(memcg,
> -						MEM_CGROUP_TARGET_SOFTLIMIT);
>  #if MAX_NUMNODES > 1
> +		bool do_numainfo;
>  		do_numainfo = mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_NUMAINFO);
>  #endif
> +		do_softlimit = mem_cgroup_event_ratelimit(memcg,
> +						MEM_CGROUP_TARGET_SOFTLIMIT);

I don't like this very much. Maybe we should get rid of both do_* and
do it with flags? But maybe it is not worth the additional code at
all...

Anyway, I am wondering why unused-but-set-variable is disabled while
unused-variable is enabled. Shouldn't we just disable it as well rather
than workaround this in the code? The warning is just pure noise in this
case.
What about something like:
---
