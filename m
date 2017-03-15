Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDD576B038C
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 03:53:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l37so1649642wrc.7
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 00:53:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 39si1577071wrc.33.2017.03.15.00.53.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 00:53:56 -0700 (PDT)
Date: Wed, 15 Mar 2017 08:53:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170315075351.GB32620@dhcp22.suse.cz>
References: <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
 <20170313115554.41d16b1f@nial.brq.redhat.com>
 <20170313122825.GO31518@dhcp22.suse.cz>
 <20170314142014.6ecbee57@nial.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170314142014.6ecbee57@nial.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz

On Tue 14-03-17 14:20:14, Igor Mammedov wrote:
> On Mon, 13 Mar 2017 13:28:25 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Mon 13-03-17 11:55:54, Igor Mammedov wrote:
> > > On Thu, 9 Mar 2017 13:54:00 +0100
> > > Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > > > The kernel is supposed to provide a proper API and that is sysfs
> > > > currently. I am not entirely happy about it either but pulling a lot of
> > > > code into the kernel is not the rigth thing to do. Especially when
> > > > different usecases require different treatment.  
> > >
> > > If it could be done from kernel side alone, it looks like a better way
> > > to me not to involve userspace at all. And for ACPI based x86/ARM it's
> > > possible to implement without adding a lot of kernel code.  
> > 
> > But this is not how we do the kernel development. We provide the API so
> > that userspace can implement the appropriate policy on top. We do not
> > add random knobs to implement the same thing in the kernel. Different
> > users might want to implement different onlining strategies and that is
> > hardly describable by a single global knob. Just look at the s390
> > example provided earlier. Please try to think out of your usecase scope.
>
> And could you think outside of legacy sysfs based onlining usecase scope?

Well, I always prefer a more generic solution which supports more
usecases and I am trying really hard to understand usecases you are
coming up with. So far I have heard that the current sysfs behavior is
broken (which is true!) and some very vague arguments about why we need
to online as quickly as possible to the point that userspace handling is
an absolute no go.

To be honest I still consider the later a non-issue. If the only thing
you care about is the memory footprint of the first phase then I believe
this is fixable. Memblock and section descriptors should be the only
necessary thing to allocate and that is not much.

As an aside, the more I think about the way the original authors
separated the physical hotadd from onlining the more I appreciate that
decision because the way how the memory can be online is definitely not
carved in stone and evolves with usecases. I believe nobody expected
that memory could be onlined as movable back then and I am pretty sure
new ways will emerge over time.
 
> I don't think that S390 comparing with x86 is correct as platforms
> and hardware implementations of memory hotplug are different with
> correspondingly different requirements, hence CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
> were introduced to allows platform specify behavior.

There are different usecases which are arch agnostic. E.g. decide the
movability based on some criterion (e.g. specific node, physical address
range and what not). Global auto onlining cannot handle those for obvious
reasons and a config option will not do achieve that for the same
reason.

> For x86/ARM(+ACPI) it's possible to implement hotplug in race free
> way inside kernel without userspace intervention, onlining memory
> using hardware vendor defined policy (ACPI SRAT/Memory device describe
> memory sufficiently to do it) so user won't have to do it manually,
> config option is a convenient way to enable new feature for platforms
> that could support it.

Sigh. Can you see the actual difference between the global kernel policy
and the policy coming from the specific hardware (ACPI etc...)? I am not
opposing auto onlining based on the ACPI attributes. But what we have
now is a policy _in_the_kernel_. This is almost always a bad idea and
I do not see any strong argument why it would be any different in this
particular case. Actually your current default in Fedora makes it harder
for anybody to use movable zones/nodes.

> It's good to maintain uniform API to userspace as far as API does
> the job, but being stuck to legacy way isn't good when
> there is a way (even though it's limited to limited set of platforms)
> to improve it by removing need for API, making overall less complex
> and race-less (more reliable) system.

then convince your virtualization platform to provide necessary data
for the memory auto onlining via ACPI etc...

> > > That's one more of a reason to keep CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
> > > so we could continue on improving kernel only auto-onlining
> > > and fixing current memory hot(un)plug issues without affecting
> > > other platforms/users that are no interested in it.  
> > 
> > I really do not see any reason to keep the config option. Setting up
> > this to enabled is _wrong_ thing to do in general purpose
> > (distribution) kernel and a kernel for the specific usecase can achieve
> > the same thing via boot command line.
>
> I have to disagree with you that setting policy 'not online by default'
> in kernel is more valid than opposite policy 'online by default'.
> It maybe works for your usecases but it doesn't mean that it suits
> needs of others.

Well, as described above there are good reasons to not hardwire any
policy into the kernel because things tend to evolve and come with many
surprising usecases original authors haven't anticipated at all.

On the other hand we have your auto_online policy which handles _one_
particular class of usecases which I believe could have been addressed
by enhancing the implementation of the current interface.  E.g. allocate
less memory in the initial phase, preemptive failing the first phase
when there is too much memory waiting for onlining or even help udev to
react faster by having preallocated workers to handle events. Instead, I
suspect, you have chosen the path of the least resistance/effort and now
we've ended up with a global policy with known limitations. I cannot say
I would be happy about that.

> As example RHEL distribution (x86) are shipped with memory
> autoonline enabled by default policy as it's what customers ask for.
> 
> And onlining memory as removable considered as a specific usecase,
> since arguably a number of users where physical memory removal is
> supported is less than a number of users where just hot add is
> supported, plus single virt usecase adds huge userbase to
> the later as it's easily available/accessible versus baremetal
> hotplug.

this might be the case now but might turn out to be a completely wrong
thing to do in few years when overhyped^Wcloud workloads won't be all
that interesting anymore.

> So default depends on target audience and distributions need
> a config option to pick default that suits its customers needs.

Well, I would hope that such a thing could be achieved by more flexible
means than the kernel config... E.g. pre-defined defaults that I can
install as a package rather than enforcing a particular policy to
everybody.

> If we don't provide reliably working memory hot-add solution
> customers will just move to OS that does (Windows or with your
> patch hyperv/xen based cloud instead of KVM/VMware.
>
> > > (PS: I don't care much about sysfs knob for setting auto-onlining,
> > > as kernel CLI override with memhp_default_state seems
> > > sufficient to me)  
> > 
> > That is good to hear! I would be OK with keeping the kernel command line
> > option until we resolve all the current issues with the hotplug.
>
> You RFC doesn't fix anything except of cleaning up config option,
> and even at that is does it inconsistently breaking both userspaces
>  - one that does expect auto-online
>     kernel update on Fedora will break memory hot-add
>     (on KVM/VMware hosts) since userspace doesn't ship any
>     scripts that would do it but will continue to work on
>     hyperv/xen hosts.

that is actually trivial to fix and provide a userspace fix while
the kernel still offers the functionality and remove the kernel
functionality later. Nobody talks about removing the whole thing at
once. API changes are not that simple at all.

>  - another that doesn't expect auto-online:
>     no change for KVM/VMware but suddenly hyperv/xen would
>     start auto-onlinig memory.

I would argue that removing a policy which covers only some usecases as
a fix but whatever. We obviously disagree here...

Anyway, I consider "never break the userspace" to be a hard rule and I
do not want to break any usecase of course. I thought this RFC would
help to trigger a constructive discussion with some reasonable outcome
where we would get rid of the cruft eventually. It seems this will not
be the case because getting an immediate half-solutions is preferred
much more than exhausting all the potential options these days.

I am sorry, but I have to say I really hate the way this all sneaked in
without a wider review, though. If this went through a proper review
process it would get a straight NAK, from me at least, I believe.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
