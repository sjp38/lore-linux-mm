Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 821B46B0092
	for <linux-mm@kvack.org>; Wed, 27 May 2015 13:10:21 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so21514293pdb.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 10:10:21 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lw5si26815670pab.204.2015.05.27.10.10.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 10:10:19 -0700 (PDT)
Date: Wed, 27 May 2015 13:09:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 11/51] memcg: implement mem_cgroup_css_from_page()
Message-ID: <20150527170955.GA25324@cmpxchg.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-12-git-send-email-tj@kernel.org>
 <20150527161344.GO7099@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150527161344.GO7099@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed, May 27, 2015 at 12:13:44PM -0400, Tejun Heo wrote:
> From 26bab580abfc441c841c1983469b8b86f5a8ef5c Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj@kernel.org>
> Date: Wed, 27 May 2015 12:08:29 -0400
> 
> Implement mem_cgroup_css_from_page() which returns the
> cgroup_subsys_state of the memcg associated with a given page.  This
> will be used by cgroup writeback support.
> 
> This function assumes that page->mem_cgroup association doesn't change
> until the page is released, which is true on the default hierarchy as
> long as mem_cgroup_migrate() is not used.  As the only user of
> mem_cgroup_migrate() is FUSE which won't support cgroup writeback for
> the time being, this works for now, and mem_cgroup_migrate() will soon
> be updated so that the invariant actually holds.

Regular page migration uses mem_cgroup_migrate() as well, but it's not
a problem as it ensures that the old page doesn't have any outstanding
references at that point.

It's only replace_page_cache_page() that calls mem_cgroup_migrate() on
a live page breaking mem_cgroup_css_from_page().

So the page looks fine, I'd just update the culprit function in the
changelog and kerneldoc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
