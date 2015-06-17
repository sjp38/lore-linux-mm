Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id E83316B0072
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 14:25:04 -0400 (EDT)
Received: by ykfl8 with SMTP id l8so47109944ykf.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 11:25:04 -0700 (PDT)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com. [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id j189si1862451ywe.171.2015.06.17.11.25.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 11:25:04 -0700 (PDT)
Received: by ykar6 with SMTP id r6so46998625yka.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 11:25:03 -0700 (PDT)
Date: Wed, 17 Jun 2015 14:25:00 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 06/51] memcg: add mem_cgroup_root_css
Message-ID: <20150617182500.GI22637@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-7-git-send-email-tj@kernel.org>
 <20150617145642.GI25056@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150617145642.GI25056@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hey, Michal.

On Wed, Jun 17, 2015 at 04:56:42PM +0200, Michal Hocko wrote:
> On Fri 22-05-15 17:13:20, Tejun Heo wrote:
> > Add global mem_cgroup_root_css which points to the root memcg css.
> 
> Is there any reason to using css rather than mem_cgroup other than the
> structure is not visible outside of memcontrol.c? Because I have a
> patchset which exports it. It is not merged yet so a move to mem_cgroup
> could be done later. I am just interested whether there is a stronger
> reason.

It doesn't really matter either way but I think it makes a bit more
sense to use css as the common type when external code interacts with
cgroup controllers.  e.g. cgroup writeback interacts with both memcg
and blkcg and in most cases it doesn't know or care about their
internal states.  Most of what it wants is tracking them and doing
some common css operations (refcnting, printing and so on) on them.

> > This will be used by cgroup writeback support.  If memcg is disabled,
> > it's defined as ERR_PTR(-EINVAL).
> 
> Hmm. Why EINVAL? I can see only mm/backing-dev.c (in
> review-cgroup-writeback-switch-20150528 branch) which uses it and that
> shouldn't even try to compile if !CONFIG_MEMCG no? Otherwise we would
> simply blow up.

Hmm... the code maybe has changed inbetween but there was something
which depended on the root css being defined when
!CONFIG_CGROUP_WRITEBACK or maybe it was on blkcg_root_css and memcg
side was added for consistency.  An ERR_PTR value is non-zero, which
is an invariant which is often depended upon, while guaranteeing oops
when deref'd.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
