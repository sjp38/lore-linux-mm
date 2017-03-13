Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABBC86B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 06:56:02 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a189so236650877qkc.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 03:56:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r3si128646qkb.46.2017.03.13.03.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 03:56:01 -0700 (PDT)
Date: Mon, 13 Mar 2017 11:55:54 +0100
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170313115554.41d16b1f@nial.brq.redhat.com>
In-Reply-To: <20170309125400.GI11592@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
	<1488462828-174523-1-git-send-email-imammedo@redhat.com>
	<20170302142816.GK1404@dhcp22.suse.cz>
	<20170302180315.78975d4b@nial.brq.redhat.com>
	<20170303082723.GB31499@dhcp22.suse.cz>
	<20170303183422.6358ee8f@nial.brq.redhat.com>
	<20170306145417.GG27953@dhcp22.suse.cz>
	<20170307134004.58343e14@nial.brq.redhat.com>
	<20170309125400.GI11592@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y.
 Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz

On Thu, 9 Mar 2017 13:54:00 +0100
Michal Hocko <mhocko@kernel.org> wrote:

[...]
> > It's major regression if you remove auto online in kernels that
> > run on top of x86 kvm/vmware hypervisors, making API cleanups
> > while breaking useful functionality doesn't make sense.
> > 
> > I would ACK config option removal if auto online keeps working
> > for all x86 hypervisors (hyperv/xen isn't the only who needs it)
> > and keep kernel CLI option to override default.
> > 
> > That doesn't mean that others will agree with flipping default,
> > that's why config option has been added.
> > 
> > Now to sum up what's been discussed on this thread, there were 2
> > different issues discussed:
> >   1) memory hotplug: remove in kernel auto online for all
> >                      except of hyperv/xen
> > 
> >        - suggested RFC is not acceptable from virt point of view
> >          as it regresses guests on top of x86 kvm/vmware which
> >          both use ACPI based memory hotplug.
> > 
> >        - udev/userspace solution doesn't work in practice as it's
> >          too slow and unreliable when system is under load which
> >          is quite common in virt usecase. That's why auto online
> >          has been introduced in the first place.  
> 
> Please try to be more specific why "too slow" is a problem. Also how
> much slower are we talking about?
In virt case on host with lots VMs, userspace handler
processing could be scheduled late enough to trigger a race
between (guest memory going away/OOM handler) and memory
coming online.

>  
> >   2) memory unplug: online memory as movable
> > 
> >        - doesn't work currently with udev rule due to kernel
> >          issues https://bugzilla.redhat.com/show_bug.cgi?id=1314306#c7  
> 
> These should be fixed
>  
> >        - could be fixed both for in kernel auto online and udev
> >          with following patch:
> >          https://bugzilla.redhat.com/attachment.cgi?id=1146332
> >          but fixing it this way exposes zone disbalance issues,
> >          which are not present in current kernel as blocks are
> >          onlined in Zone Normal. So this is area to work and
> >          improve on.
> > 
> >        - currently if one wants to use online_movable,
> >          one has to either
> >            * disable auto online in kernel OR  
> 
> which might not just work because an unmovable allocation could have
> made the memblock pinned.
With memhp_default_state=offline on kernel CLI there won't be any
unmovable allocation as hotplugged memory won't be onlined and
user can online it manually. So it works for non default usecase
of playing with memory hot-unplug.
 
> >            * remove udev rule that distro ships
> >          AND write custom daemon that will be able to online
> >          block in right zone/order. So currently whole
> >          online_movable thing isn't working by default
> >          regardless of who onlines memory.  
> 
> my epxperience with onlining full nodes as movable shows this works just
> fine (with all the limitations of the movable zones but that is a
> separate thing). I haven't played with configurations where movable
> zones are sharing the node with other zones.
I don't have access to a such baremetal configuration to play
with anymore.


> >          I'm in favor of implementing that in kernel as it keeps
> >          kernel internals inside kernel and doesn't need
> >          kernel API to be involved (memory blocks in sysfs,
> >          online_kernel, online_movable)
> >          There would be no need in userspace which would have to
> >          deal with kernel zoo and maintain that as well.  
> 
> The kernel is supposed to provide a proper API and that is sysfs
> currently. I am not entirely happy about it either but pulling a lot of
> code into the kernel is not the rigth thing to do. Especially when
> different usecases require different treatment.
If it could be done from kernel side alone, it looks like a better way
to me not to involve userspace at all. And for ACPI based x86/ARM it's
possible to implement without adding a lot of kernel code.
That's one more of a reason to keep CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
so we could continue on improving kernel only auto-onlining
and fixing current memory hot(un)plug issues without affecting
other platforms/users that are no interested in it.
(PS: I don't care much about sysfs knob for setting auto-onlining,
as kernel CLI override with memhp_default_state seems
sufficient to me)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
