Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE18F6B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 12:03:39 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id f191so64072883qka.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:03:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z64si7349757qkg.169.2017.03.02.09.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 09:03:24 -0800 (PST)
Date: Thu, 2 Mar 2017 18:03:15 +0100
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170302180315.78975d4b@nial.brq.redhat.com>
In-Reply-To: <20170302142816.GK1404@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
	<1488462828-174523-1-git-send-email-imammedo@redhat.com>
	<20170302142816.GK1404@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y.
 Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org

On Thu, 2 Mar 2017 15:28:16 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 02-03-17 14:53:48, Igor Mammedov wrote:
> [...]
> > When trying to support memory unplug on guest side in RHEL7,
> > experience shows otherwise. Simplistic udev rule which onlines
> > added block doesn't work in case one wants to online it as movable.
> > 
> > Hotplugged blocks in current kernel should be onlined in reverse
> > order to online blocks as movable depending on adjacent blocks zone.  
> 
> Could you be more specific please? Setting online_movable from the udev
> rule should just work regardless of the ordering or the state of other
> memblocks. If that doesn't work I would call it a bug.
It's rather an implementation constrain than a bug
for details and workaround patch see
 [1] https://bugzilla.redhat.com/show_bug.cgi?id=1314306#c7
patch attached there is limited by another memory hotplug
issue, which is NORMAL/MOVABLE zone balance, if kernel runs
on configuration where the most of memory is hot-removable
kernel might experience lack of memory in zone NORMAL.

> 
> > Which means simple udev rule isn't usable since it gets event from
> > the first to the last hotplugged block order. So now we would have
> > to write a daemon that would
> >  - watch for all blocks in hotplugged memory appear (how would it know)
> >  - online them in right order (order might also be different depending
> >    on kernel version)
> >    -- it becomes even more complicated in NUMA case when there are
> >       multiple zones and kernel would have to provide user-space
> >       with information about zone maps
> > 
> > In short current experience shows that userspace approach
> >  - doesn't solve issues that Vitaly has been fixing (i.e. onlining
> >    fast and/or under memory pressure) when udev (or something else
> >    might be killed)  
> 
> yeah and that is why the patch does the onlining from the kernel.
onlining in this patch is limited to hyperv and patch breaks
auto-online on x86 kvm/vmware/baremetal as they reuse the same
hotplug path.

> > > Can you imagine any situation when somebody actually might want to have
> > > this knob enabled? From what I understand it doesn't seem to be the
> > > case.  
> > For x86:
> >  * this config option is enabled by default in recent Fedora,  
> 
> How do you want to support usecases which really want to online memory
> as movable? Do you expect those users to disable the option because
> unless I am missing something the in kernel auto onlining only supporst
> regular onlining.
current auto onlining config option does what it's been designed for,
i.e. it onlines hotplugged memory.
It's possible for non average Fedora user to override default
(commit 86dd995d6) if she/he needs non default behavior
(i.e. user knows how to online manually and/or can write
a daemon that would handle all of nuances of kernel in use).

For the rest when Fedora is used in cloud and user increases memory
via management interface of whatever cloud she/he uses, it just works.

So it's choice of distribution to pick its own default that makes
majority of user-base happy and this patch removes it without taking
that in consideration.

How to online memory is different issue not related to this patch,
current default onlining as ZONE_NORMAL works well for scaling
up VMs.

Memory unplug is rather new and it doesn't work reliably so far,
moving onlining to user-space won't really help. Further work
is need to be done so that it would work reliably.

Now about the question of onlining removable memory as movable,
x86 kernel is able to get info, if hotadded memory is removable,
from ACPI subsystem and online it as movable one without any
intervention from user-space where it's hard to do so,
as patch[1] shows.
Problem is still researched and when we figure out how to fix
hot-remove issues we might enable auto-onlining by default for x86.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
