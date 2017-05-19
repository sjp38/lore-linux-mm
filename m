Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EBBF28071E
	for <linux-mm@kvack.org>; Fri, 19 May 2017 16:55:58 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id f96so31592055qki.14
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:55:58 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id s1si9747417qkf.304.2017.05.19.13.55.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 13:55:57 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id j13so11162116qta.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:55:57 -0700 (PDT)
Date: Fri, 19 May 2017 16:55:50 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 13/17] cgroup: Allow fine-grained controllers
 control in cgroup v2
Message-ID: <20170519205550.GD15279@wtj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-14-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494855256-12558-14-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

On Mon, May 15, 2017 at 09:34:12AM -0400, Waiman Long wrote:
> For cgroup v1, different controllers can be binded to different cgroup
> hierarchies optimized for their own use cases. That is not currently
> the case for cgroup v2 where combining all these controllers into
> the same hierarchy will probably require more levels than is needed
> by each individual controller.
> 
> By not enabling a controller in a cgroup and its descendants, we can
> effectively trim the hierarchy as seen by a controller from the leafs
> up. However, there is currently no way to compress the hierarchy in
> the intermediate levels.
> 
> This patch implements a fine-grained mechanism to allow a controller to
> skip some intermediate levels in a hierarchy and effectively flatten
> the hierarchy as seen by that controller.
> 
> Controllers can now be directly enabled or disabled in a cgroup
> by writing to the "cgroup.controllers" file.  The special prefix
> '#' with the controller name is used to set that controller in
> pass-through mode.  In that mode, the controller is disabled for that
> cgroup but it allows its children to have that controller enabled or
> in pass-through mode again.
> 
> With this change, each controller can now have a unique view of their
> virtual process hierarchy that can be quite different from other
> controllers.  We now have the freedom and flexibility to create the
> right hierarchy for each controller to suit their own needs without
> performance loss when compared with cgroup v1.

I can see the appeal but this needs at least more refinements.

This breaks the invariant that in a cgroup its resource control knobs
control distribution of resources from its parent.  IOW, the resource
control knobs of a cgroup always belong to the parent.  This is also
reflected in how delegation is done.  The delegatee assumes ownership
of the cgroup itself and the ability to manage sub-cgroups but doesn't
get the ownership of the resource control knobs as otherwise the
parent would lose control over how it distributes its resources.

Another aspect is that most controllers aren't that sensitive to
nesting several levels.  Expensive operations can be and already are
aggregated and the performance overhead of several levels of nesting
barely shows up.  Skipping levels can be an interesting optimization
approach and we can definitely support from the core side; however,
it'd be a lot nicer if we could do that optimization transparently
(e.g. CPU can skip multi level queueing if there usually is only one
item at some levels).

Hmm... that said, if we can fix the delegation issue in a not-too-ugly
way, why not?  I wonder whether we can still keep the resource control
knobs attached to the parent and skip in the middle.  Topology-wise,
that'd make more sense too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
