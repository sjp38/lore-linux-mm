Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C1C026B0103
	for <linux-mm@kvack.org>; Wed, 27 May 2015 08:59:35 -0400 (EDT)
Received: by wgv5 with SMTP id 5so8812185wgv.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 05:59:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o4si23800815wiv.40.2015.05.27.05.59.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 05:59:34 -0700 (PDT)
Date: Wed, 27 May 2015 08:58:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 11/51] memcg: implement mem_cgroup_css_from_page()
Message-ID: <20150527125842.GA19856@cmpxchg.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-12-git-send-email-tj@kernel.org>
 <20150522232831.GB6485@cmpxchg.org>
 <20150524212440.GD7099@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150524212440.GD7099@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Sun, May 24, 2015 at 05:24:40PM -0400, Tejun Heo wrote:
> Hello,
> 
> On Fri, May 22, 2015 at 07:28:31PM -0400, Johannes Weiner wrote:
> > replace_page_cache() can clear page->mem_cgroup even when the page
> > still has references, so unfortunately you must hold the page lock
> > when calling this function.
> > 
> > I haven't checked how you use this - chances are you always have the
> > page locked anyways - but it probably needs a comment.
> 
> Hmmm... as replace_page_cache_page() is used only by fuse and fuse's
> bdi doesn't go through the usual writeback accounting which is
> necessary for cgroup writeback support anyway, so I don't think this
> presents an actual problem.  I'll add a warning in
> replace_page_cache_page() which triggers when it's used on a bdi which
> has cgroup writeback enabled and add comments explaining what's going
> on.

Okay, so that's no problem then as long as it's documented.

In the long term, it would probably still be a good idea to restore
the invariant that page->mem_cgroup never changes on live pages.  For
the old interface that ship has sailed as live pages can move around
different cgroups; in unified hierarchy, however, we currently only
move charges when migrating pages between page frames.  That can be
switched to duplicating the charge instead and leaving the old page
alone until the final put - which is expected to occur soon after.

Accounting the same page twice for a short period during migration
should be an acceptable trade-off when considering how much simpler it
makes the synchronization rules.  We only have to make sure to clearly
mark interfaces and functions that are only safe for use with unified
hierarchy code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
