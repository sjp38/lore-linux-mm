Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E9A4E6B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 11:45:00 -0500 (EST)
Date: Tue, 24 Jan 2012 17:44:49 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4] memcg: remove PCG_CACHE page_cgroup flag
Message-ID: <20120124164449.GH1660@cmpxchg.org>
References: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
 <20120120122658.1b14b512.kamezawa.hiroyu@jp.fujitsu.com>
 <20120120084545.GC9655@tiehlicka.suse.cz>
 <20120124121636.115f1cf0.kamezawa.hiroyu@jp.fujitsu.com>
 <20120124111644.GE1660@cmpxchg.org>
 <20120124145411.GF1660@cmpxchg.org>
 <20120124160140.GH26289@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120124160140.GH26289@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Tue, Jan 24, 2012 at 05:01:40PM +0100, Michal Hocko wrote:
> On Tue 24-01-12 15:54:11, Johannes Weiner wrote:
> > Hold on, I think this patch is still not complete: end_migration()
> > directly uses __mem_cgroup_uncharge_common() with the FORCE charge
> > type.  This will uncharge all migrated anon pages as cache, when it
> > should decide based on PageAnon(used), which is the page where
> > ->mapping is intact after migration.
> 
> You are right, I've missed that one as well. Anyway
> MEM_CGROUP_CHARGE_TYPE_FORCE is used only in mem_cgroup_end_migration
> these days and it got out of sync with its documentation (used by
> force_empty) quite some time ago (f817ed48). What about something like
> the following on top of the previous patch?
> --- 
> Should be foldet into the previous patch with the updated changelog:
> 
> Mapping of the unused page is not touched during migration (see

used one, not unused.  unused->mapping is globbered during migration.

> page_remove_rmap) so we can rely on it and push the correct charge type
> down to __mem_cgroup_uncharge_common from end_migration. The force flag
> was misleading anyway.

Kinda.  It had the effect of skipping the needless page_mapped() /
PageCgroupMigration() check, we know the unused page is no longer
mapped and cleared the migration flag just a few lines up.  But doing
the checks is no biggie and it's not worth adding another flag just to
skip them.  But I guess this should be mentioned in the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
