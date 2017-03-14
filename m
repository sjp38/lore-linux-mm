Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2846B0038
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:20:23 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f191so242398089qka.7
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 06:20:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b47si2996101qtc.27.2017.03.14.06.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 06:20:21 -0700 (PDT)
Date: Tue, 14 Mar 2017 14:20:14 +0100
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170314142014.6ecbee57@nial.brq.redhat.com>
In-Reply-To: <20170313122825.GO31518@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
	<1488462828-174523-1-git-send-email-imammedo@redhat.com>
	<20170302142816.GK1404@dhcp22.suse.cz>
	<20170302180315.78975d4b@nial.brq.redhat.com>
	<20170303082723.GB31499@dhcp22.suse.cz>
	<20170303183422.6358ee8f@nial.brq.redhat.com>
	<20170306145417.GG27953@dhcp22.suse.cz>
	<20170307134004.58343e14@nial.brq.redhat.com>
	<20170309125400.GI11592@dhcp22.suse.cz>
	<20170313115554.41d16b1f@nial.brq.redhat.com>
	<20170313122825.GO31518@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y.
 Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz

On Mon, 13 Mar 2017 13:28:25 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 13-03-17 11:55:54, Igor Mammedov wrote:
> > On Thu, 9 Mar 2017 13:54:00 +0100
> > Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > [...]  
> > > > It's major regression if you remove auto online in kernels that
> > > > run on top of x86 kvm/vmware hypervisors, making API cleanups
> > > > while breaking useful functionality doesn't make sense.
> > > > 
> > > > I would ACK config option removal if auto online keeps working
> > > > for all x86 hypervisors (hyperv/xen isn't the only who needs it)
> > > > and keep kernel CLI option to override default.
> > > > 
> > > > That doesn't mean that others will agree with flipping default,
> > > > that's why config option has been added.
> > > > 
> > > > Now to sum up what's been discussed on this thread, there were 2
> > > > different issues discussed:
> > > >   1) memory hotplug: remove in kernel auto online for all
> > > >                      except of hyperv/xen
> > > > 
> > > >        - suggested RFC is not acceptable from virt point of view
> > > >          as it regresses guests on top of x86 kvm/vmware which
> > > >          both use ACPI based memory hotplug.
> > > > 
> > > >        - udev/userspace solution doesn't work in practice as it's
> > > >          too slow and unreliable when system is under load which
> > > >          is quite common in virt usecase. That's why auto online
> > > >          has been introduced in the first place.    
> > > 
> > > Please try to be more specific why "too slow" is a problem. Also how
> > > much slower are we talking about?  
> >
> > In virt case on host with lots VMs, userspace handler
> > processing could be scheduled late enough to trigger a race
> > between (guest memory going away/OOM handler) and memory
> > coming online.  
> 
> Either you are mixing two things together or this doesn't really make
> much sense. So is this a balloning based on memory hotplug (aka active
> memory hotadd initiated between guest and host automatically) or a guest
> asking for additional memory by other means (pay more for memory etc.)?
> Because if this is an administrative operation then I seriously question
> this reasoning.
It doesn't have to be user initiated action,
have you heard about pay as you go phone plans, same thing use case
applies to cloud environments where typically hotplug user initiated
action on baremetal could be easily automated to hotplug on demand.


> [...]
> > > >        - currently if one wants to use online_movable,
> > > >          one has to either
> > > >            * disable auto online in kernel OR    
> > > 
> > > which might not just work because an unmovable allocation could have
> > > made the memblock pinned.  
> >
> > With memhp_default_state=offline on kernel CLI there won't be any
> > unmovable allocation as hotplugged memory won't be onlined and
> > user can online it manually. So it works for non default usecase
> > of playing with memory hot-unplug.  
> 
> I was talking about the case when the auto_online was true, of course,
> e.g. depending on the config option which you've said is enabled in
> Fedora kernels.
>
> [...] 
> > > >          I'm in favor of implementing that in kernel as it keeps
> > > >          kernel internals inside kernel and doesn't need
> > > >          kernel API to be involved (memory blocks in sysfs,
> > > >          online_kernel, online_movable)
> > > >          There would be no need in userspace which would have to
> > > >          deal with kernel zoo and maintain that as well.    
> > > 
> > > The kernel is supposed to provide a proper API and that is sysfs
> > > currently. I am not entirely happy about it either but pulling a lot of
> > > code into the kernel is not the rigth thing to do. Especially when
> > > different usecases require different treatment.  
> >
> > If it could be done from kernel side alone, it looks like a better way
> > to me not to involve userspace at all. And for ACPI based x86/ARM it's
> > possible to implement without adding a lot of kernel code.  
> 
> But this is not how we do the kernel development. We provide the API so
> that userspace can implement the appropriate policy on top. We do not
> add random knobs to implement the same thing in the kernel. Different
> users might want to implement different onlining strategies and that is
> hardly describable by a single global knob. Just look at the s390
> example provided earlier. Please try to think out of your usecase scope.
And could you think outside of legacy sysfs based onlining usecase scope?

I don't think that S390 comparing with x86 is correct as platforms
and hardware implementations of memory hotplug are different with
correspondingly different requirements, hence CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
were introduced to allows platform specify behavior.

For x86/ARM(+ACPI) it's possible to implement hotplug in race free
way inside kernel without userspace intervention, onlining memory
using hardware vendor defined policy (ACPI SRAT/Memory device describe
memory sufficiently to do it) so user won't have to do it manually,
config option is a convenient way to enable new feature for platforms
that could support it.

It's good to maintain uniform API to userspace as far as API does
the job, but being stuck to legacy way isn't good when
there is a way (even though it's limited to limited set of platforms)
to improve it by removing need for API, making overall less complex
and race-less (more reliable) system.

> > That's one more of a reason to keep CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
> > so we could continue on improving kernel only auto-onlining
> > and fixing current memory hot(un)plug issues without affecting
> > other platforms/users that are no interested in it.  
> 
> I really do not see any reason to keep the config option. Setting up
> this to enabled is _wrong_ thing to do in general purpose
> (distribution) kernel and a kernel for the specific usecase can achieve
> the same thing via boot command line.
I have to disagree with you that setting policy 'not online by default'
in kernel is more valid than opposite policy 'online by default'.
It maybe works for your usecases but it doesn't mean that it suits
needs of others.

As example RHEL distribution (x86) are shipped with memory
autoonline enabled by default policy as it's what customers ask for.

And onlining memory as removable considered as a specific usecase,
since arguably a number of users where physical memory removal is
supported is less than a number of users where just hot add is
supported, plus single virt usecase adds huge userbase to
the later as it's easily available/accessible versus baremetal
hotplug.

So default depends on target audience and distributions need
a config option to pick default that suits its customers needs.
If we don't provide reliably working memory hot-add solution
customers will just move to OS that does (Windows or with your
patch hyperv/xen based cloud instead of KVM/VMware.

> > (PS: I don't care much about sysfs knob for setting auto-onlining,
> > as kernel CLI override with memhp_default_state seems
> > sufficient to me)  
> 
> That is good to hear! I would be OK with keeping the kernel command line
> option until we resolve all the current issues with the hotplug.
You RFC doesn't fix anything except of cleaning up config option,
and even at that is does it inconsistently breaking both userspaces
 - one that does expect auto-online
    kernel update on Fedora will break memory hot-add
    (on KVM/VMware hosts) since userspace doesn't ship any
    scripts that would do it but will continue to work on
    hyperv/xen hosts.
 - another that doesn't expect auto-online:
    no change for KVM/VMware but suddenly hyperv/xen would
    start auto-onlinig memory.
So users would have broken VMs until regression is noticed
and would have to manually fix userspace that they use to
accommodate 'improved' kernel.

This RFC under guise of clean up is removing default choice
from distributions and actually crippling linux guests on top
of KVM/VMware hosts while favoring xen/hyperv hosts.
IMHO it doesn't make any sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
