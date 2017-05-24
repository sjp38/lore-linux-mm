Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0AB6B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:49:50 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v195so74898149qka.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:49:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p5si153879qki.291.2017.05.24.10.49.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 10:49:49 -0700 (PDT)
Subject: Re: [RFC PATCH v2 13/17] cgroup: Allow fine-grained controllers
 control in cgroup v2
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-14-git-send-email-longman@redhat.com>
 <20170519205550.GD15279@wtj.duckdns.org>
 <6fe07727-e611-bfcd-8382-593a51bb4888@redhat.com>
 <20170524173144.GI24798@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <29bc746d-f89b-3385-fd5c-314bcd22f9f7@redhat.com>
Date: Wed, 24 May 2017 13:49:46 -0400
MIME-Version: 1.0
In-Reply-To: <20170524173144.GI24798@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/24/2017 01:31 PM, Tejun Heo wrote:
> Hello, Waiman.
>
> On Fri, May 19, 2017 at 05:20:01PM -0400, Waiman Long wrote:
>>> This breaks the invariant that in a cgroup its resource control knobs=

>>> control distribution of resources from its parent.  IOW, the resource=

>>> control knobs of a cgroup always belong to the parent.  This is also
>>> reflected in how delegation is done.  The delegatee assumes ownership=

>>> of the cgroup itself and the ability to manage sub-cgroups but doesn'=
t
>>> get the ownership of the resource control knobs as otherwise the
>>> parent would lose control over how it distributes its resources.
>> One twist that I am thinking is to have a controller enabled by the
>> parent in subtree_control, but then allow the child to either disable =
it
>> or set it in pass-through mode by writing to controllers file. IOW, a
>> child cannot enable a controller without parent's permission. Once a
>> child has permission, it can do whatever it wants. A parent cannot for=
ce
>> a child to have a controller enabled.
> Heh, I think I need more details to follow your proposal.  Anyways,
> what we need to guarantee is that a descendant is never allowed to
> pull in more resources than its ancestors want it to.

What I am saying is as follows:
    / A
P - B
   \ C

# echo +memory > P/cgroups.subtree_control
# echo -memory > P/A/cgroup.controllers
# echo "#memory" > P/B/cgroup.controllers

The parent grants the memory controller to its children - A, B and C.
Child A has the memory controller explicitly disabled. Child B has the
memory controller in pass-through mode, while child C has the memory
controller enabled by default. "echo +memory > cgroup.controllers" is
not allowed. There are 2 possible choices with regard to the '-' or '#'
prefixes. We can allow them before the grant from the parent or only
after that. In the former case, the state remains dormant until after
the grant from the parent.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
