Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 6C9D66B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 08:36:57 -0500 (EST)
Date: Wed, 25 Jan 2012 14:36:45 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v5] memcg: remove PCG_CACHE page_cgroup flag
Message-ID: <20120125133645.GC7694@cmpxchg.org>
References: <20120120084545.GC9655@tiehlicka.suse.cz>
 <20120124121636.115f1cf0.kamezawa.hiroyu@jp.fujitsu.com>
 <20120124111644.GE1660@cmpxchg.org>
 <20120124145411.GF1660@cmpxchg.org>
 <20120124160140.GH26289@tiehlicka.suse.cz>
 <20120124164449.GH1660@cmpxchg.org>
 <20120124172308.GI26289@tiehlicka.suse.cz>
 <20120124180842.GA18372@tiehlicka.suse.cz>
 <20120125090025.6d24cd0f.kamezawa.hiroyu@jp.fujitsu.com>
 <20120125144100.4fcfcb82.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120125144100.4fcfcb82.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed, Jan 25, 2012 at 02:41:00PM +0900, KAMEZAWA Hiroyuki wrote:
> Subject: [PATCH v5] memcg: remove PCG_CACHE
> 
> We record 'the page is cache' by PCG_CACHE bit to page_cgroup.
> Here, "CACHE" means anonymous user pages (and SwapCache). This
> doesn't include shmem.
> 
> Consdering callers, at charge/uncharge, the caller should know
> what  the page is and we don't need to record it by using 1bit
> per page.
> 
> This patch removes PCG_CACHE bit and make callers of
> mem_cgroup_charge_statistics() to specify what the page is.
> 
> About page migration:
> Mapping of the used page is not touched during migration (see
> page_remove_rmap) so we can rely on it and push the correct charge type
> down to __mem_cgroup_uncharge_common from end_migration for unused page.
> The force flag was misleading was abused for skipping the needless
> page_mapped() / PageCgroupMigration() check, as we know the unused page
> is no longer mapped and cleared the migration flag just a few lines
> up.  But doing the checks is no biggie and it's not worth adding another
> flag just to skip them.
> 
> Changelog since v4
>  - fixed a bug at page migration by Michal Hokko.
> 
> Changelog since v3
>  - renamed a variable 'rss' to 'anon'
> 
> Changelog since v2
>  - removed 'not_rss', added 'anon'
>  - changed a meaning of arguments to mem_cgroup_charge_statisitcs()
>  - removed a patch to mem_cgroup_uncharge_cache
>  - simplified comment.
> 
> Changelog since RFC.
>  - rebased onto memcg-devel
>  - rename 'file' to 'not_rss'
>  - some cleanup and added comment.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
