Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF356B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:31:48 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id 130so56836623ybl.7
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:31:48 -0700 (PDT)
Received: from mail-yb0-x22a.google.com (mail-yb0-x22a.google.com. [2607:f8b0:4002:c09::22a])
        by mx.google.com with ESMTPS id l139si7920708ywb.302.2017.05.24.10.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 10:31:46 -0700 (PDT)
Received: by mail-yb0-x22a.google.com with SMTP id p143so47183169yba.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:31:46 -0700 (PDT)
Date: Wed, 24 May 2017 13:31:44 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 13/17] cgroup: Allow fine-grained controllers
 control in cgroup v2
Message-ID: <20170524173144.GI24798@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-14-git-send-email-longman@redhat.com>
 <20170519205550.GD15279@wtj.duckdns.org>
 <6fe07727-e611-bfcd-8382-593a51bb4888@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6fe07727-e611-bfcd-8382-593a51bb4888@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

On Fri, May 19, 2017 at 05:20:01PM -0400, Waiman Long wrote:
> > This breaks the invariant that in a cgroup its resource control knobs
> > control distribution of resources from its parent.  IOW, the resource
> > control knobs of a cgroup always belong to the parent.  This is also
> > reflected in how delegation is done.  The delegatee assumes ownership
> > of the cgroup itself and the ability to manage sub-cgroups but doesn't
> > get the ownership of the resource control knobs as otherwise the
> > parent would lose control over how it distributes its resources.
> 
> One twist that I am thinking is to have a controller enabled by the
> parent in subtree_control, but then allow the child to either disable it
> or set it in pass-through mode by writing to controllers file. IOW, a
> child cannot enable a controller without parent's permission. Once a
> child has permission, it can do whatever it wants. A parent cannot force
> a child to have a controller enabled.

Heh, I think I need more details to follow your proposal.  Anyways,
what we need to guarantee is that a descendant is never allowed to
pull in more resources than its ancestors want it to.

> > Another aspect is that most controllers aren't that sensitive to
> > nesting several levels.  Expensive operations can be and already are
> > aggregated and the performance overhead of several levels of nesting
> > barely shows up.  Skipping levels can be an interesting optimization
> > approach and we can definitely support from the core side; however,
> > it'd be a lot nicer if we could do that optimization transparently
> > (e.g. CPU can skip multi level queueing if there usually is only one
> > item at some levels).
> 
> The trend that I am seeing is that the total number of controllers is
> going to grow over time. New controllers may be sensitive to the level
> of nesting like the cpu controller. I am also thinking about how systemd
> is using the cgroup filesystem for task classification purpose without
> any controller attached to it. With this scheme, we can accommodate all
> the different needs without using different cgroup filesystems.

I'm not sure about that.  It's true that cgroup hierarchy is being
used more but there are only so many hard / complex resources that we
deal with - cpu, memory and io.  Beyond those, other uses are usually
about identifying membership (perf, net) or propagating and
restricting attributes (cpuset).  pids can be considered an exception
but we have it only because pids can globally run out a lot sooner
than can be controlled through memory.  Even then, it's trivial.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
