Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 7C8646B0033
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 18:47:49 -0400 (EDT)
Date: Tue, 3 Sep 2013 18:47:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RESEND] mm/vmscan : use vmcan_swappiness( ) basing on
 MEMCG config to elimiate unnecessary runtime cost
Message-ID: <20130903224731.GC1412@cmpxchg.org>
References: <20130826133658.GA357@larmbr-lcx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130826133658.GA357@larmbr-lcx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: larmbr <nasa4836@gmail.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, linux-kernel@vger.kernel.org

On Mon, Aug 26, 2013 at 09:36:58PM +0800, larmbr wrote:
> Currently, we get the vm_swappiness via vmscan_swappiness(), which
> calls global_reclaim() to check if this is a global reclaim. 
> 
> Besides, the current implementation of global_reclaim() always returns 
> true for the !CONFIG_MEGCG case, and judges the other case by checking 
> whether scan_control->target_mem_cgroup is null or not.
> 
> Thus, we could just use two versions of vmscan_swappiness() based on 
> MEMCG Kconfig , to eliminate the unnecessary run-time cost for 
> the !CONFIG_MEMCG at all, and to squash all memcg-related checking
> into the CONFIG_MEMCG version.

The compiler can easily detect that global_reclaim() always returns
true for !CONFIG_MEMCG during compile time and not even generate a
branch for this.

> 2 files changed, 12 insertions(+), 3 deletions(-)

You're adding more code for now gain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
