Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 90D2F28073B
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:20:08 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v195so31952937qka.1
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:20:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b57si9936031qte.154.2017.05.19.14.20.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 14:20:07 -0700 (PDT)
Subject: Re: [RFC PATCH v2 13/17] cgroup: Allow fine-grained controllers
 control in cgroup v2
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-14-git-send-email-longman@redhat.com>
 <20170519205550.GD15279@wtj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <6fe07727-e611-bfcd-8382-593a51bb4888@redhat.com>
Date: Fri, 19 May 2017 17:20:01 -0400
MIME-Version: 1.0
In-Reply-To: <20170519205550.GD15279@wtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/19/2017 04:55 PM, Tejun Heo wrote:
> Hello, Waiman.
>
> On Mon, May 15, 2017 at 09:34:12AM -0400, Waiman Long wrote:
>> For cgroup v1, different controllers can be binded to different cgroup=

>> hierarchies optimized for their own use cases. That is not currently
>> the case for cgroup v2 where combining all these controllers into
>> the same hierarchy will probably require more levels than is needed
>> by each individual controller.
>>
>> By not enabling a controller in a cgroup and its descendants, we can
>> effectively trim the hierarchy as seen by a controller from the leafs
>> up. However, there is currently no way to compress the hierarchy in
>> the intermediate levels.
>>
>> This patch implements a fine-grained mechanism to allow a controller t=
o
>> skip some intermediate levels in a hierarchy and effectively flatten
>> the hierarchy as seen by that controller.
>>
>> Controllers can now be directly enabled or disabled in a cgroup
>> by writing to the "cgroup.controllers" file.  The special prefix
>> '#' with the controller name is used to set that controller in
>> pass-through mode.  In that mode, the controller is disabled for that
>> cgroup but it allows its children to have that controller enabled or
>> in pass-through mode again.
>>
>> With this change, each controller can now have a unique view of their
>> virtual process hierarchy that can be quite different from other
>> controllers.  We now have the freedom and flexibility to create the
>> right hierarchy for each controller to suit their own needs without
>> performance loss when compared with cgroup v1.
> I can see the appeal but this needs at least more refinements.
>
> This breaks the invariant that in a cgroup its resource control knobs
> control distribution of resources from its parent.  IOW, the resource
> control knobs of a cgroup always belong to the parent.  This is also
> reflected in how delegation is done.  The delegatee assumes ownership
> of the cgroup itself and the ability to manage sub-cgroups but doesn't
> get the ownership of the resource control knobs as otherwise the
> parent would lose control over how it distributes its resources.

One twist that I am thinking is to have a controller enabled by the
parent in subtree_control, but then allow the child to either disable it
or set it in pass-through mode by writing to controllers file. IOW, a
child cannot enable a controller without parent's permission. Once a
child has permission, it can do whatever it wants. A parent cannot force
a child to have a controller enabled.

> Another aspect is that most controllers aren't that sensitive to
> nesting several levels.  Expensive operations can be and already are
> aggregated and the performance overhead of several levels of nesting
> barely shows up.  Skipping levels can be an interesting optimization
> approach and we can definitely support from the core side; however,
> it'd be a lot nicer if we could do that optimization transparently
> (e.g. CPU can skip multi level queueing if there usually is only one
> item at some levels).

The trend that I am seeing is that the total number of controllers is
going to grow over time. New controllers may be sensitive to the level
of nesting like the cpu controller. I am also thinking about how systemd
is using the cgroup filesystem for task classification purpose without
any controller attached to it. With this scheme, we can accommodate all
the different needs without using different cgroup filesystems.

> Hmm... that said, if we can fix the delegation issue in a not-too-ugly
> way, why not?  I wonder whether we can still keep the resource control
> knobs attached to the parent and skip in the middle.  Topology-wise,
> that'd make more sense too.

Let me know how you think about my proposal above.

Cheers,
Longma

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
