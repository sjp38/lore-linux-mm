Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id E94EB6B0070
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:28:21 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id z107so1641381qgd.11
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:28:21 -0800 (PST)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com. [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id 61si4967479qgx.12.2015.01.22.07.28.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 07:28:21 -0800 (PST)
Received: by mail-qc0-f178.google.com with SMTP id b13so1710871qcw.9
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:28:21 -0800 (PST)
Date: Thu, 22 Jan 2015 10:28:17 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
Message-ID: <20150122152817.GD4507@htj.dyndns.org>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <54BCFDCF.9090603@arm.com>
 <20150121163955.GM4549@arm.com>
 <20150122134550.GA13876@phnom.home.cmpxchg.org>
 <20150122143454.GA4507@htj.dyndns.org>
 <20150122151943.GA27368@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150122151943.GA27368@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Will Deacon <will.deacon@arm.com>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Vladimir Davydov <vdavydov@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Thu, Jan 22, 2015 at 10:19:43AM -0500, Johannes Weiner wrote:
> From 3d7ae5aeb16ce6118d8bff17194e791339a1f06c Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 22 Jan 2015 08:16:31 -0500
> Subject: [patch] kernel: cgroup: prevent mount hang due to memory controller
>  lifetime
> 
> Since b2052564e66d ("mm: memcontrol: continue cache reclaim from
> offlined groups"), re-mounting the memory controller after using it is
> very likely to hang.
> 
> The cgroup core assumes that any remaining references after deleting a
> cgroup are temporary in nature, and synchroneously waits for them, but
> the above-mentioned commit has left-over page cache pin its css until
> it is reclaimed naturally.  That being said, swap entries and charged
> kernel memory have been doing the same indefinite pinning forever, the
> bug is just more likely to trigger with left-over page cache.
> 
> Reparenting kernel memory is highly impractical, which leaves changing
> the cgroup assumptions to reflect this: once a controller has been
> mounted and used, it has internal state that is independent from mount
> and cgroup lifetime.  It can be unmounted and remounted, but it can't
> be reconfigured during subsequent mounts.
> 
> Don't offline the controller root as long as there are any children,
> dead or alive.  A remount will no longer wait for these old references
> to drain, it will simply mount the persistent controller state again.
> 
> Reported-by: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
> Reported-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Applied to cgroup/for-3.19-fixes.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
