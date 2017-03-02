Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7736B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:53:55 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n127so100560458qkf.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:53:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u5si6955630qkh.311.2017.03.02.05.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 05:53:54 -0800 (PST)
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Date: Thu,  2 Mar 2017 14:53:48 +0100
Message-Id: <1488462828-174523-1-git-send-email-imammedo@redhat.com>
In-Reply-To: <20170227154304.GK26504@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org

On Mon 27-02-17 16:43:04, Michal Hocko wrote:
> On Mon 27-02-17 12:25:10, Heiko Carstens wrote:
> > On Mon, Feb 27, 2017 at 11:02:09AM +0100, Vitaly Kuznetsov wrote:  
> > > A couple of other thoughts:
> > > 1) Having all newly added memory online ASAP is probably what people
> > > want for all virtual machines.  
> > 
> > This is not true for s390. On s390 we have "standby" memory that a guest
> > sees and potentially may use if it sets it online. Every guest that sets
> > memory offline contributes to the hypervisor's standby memory pool, while
> > onlining standby memory takes memory away from the standby pool.
> > 
> > The use-case is that a system administrator in advance knows the maximum
> > size a guest will ever have and also defines how much memory should be used
> > at boot time. The difference is standby memory.
> > 
> > Auto-onlining of standby memory is the last thing we want.
I don't know much about anything other than x86 so all comments
below are from that point of view,
archetectures that don't need auto online can keep current default

> > > Unfortunately, we have additional complexity with memory zones
> > > (ZONE_NORMAL, ZONE_MOVABLE) and in some cases manual intervention is
> > > required. Especially, when further unplug is expected.  
> > 
> > This also is a reason why auto-onlining doesn't seem be the best way.  

When trying to support memory unplug on guest side in RHEL7,
experience shows otherwise. Simplistic udev rule which onlines
added block doesn't work in case one wants to online it as movable.

Hotplugged blocks in current kernel should be onlined in reverse
order to online blocks as movable depending on adjacent blocks zone.
Which means simple udev rule isn't usable since it gets event from
the first to the last hotplugged block order. So now we would have
to write a daemon that would
 - watch for all blocks in hotplugged memory appear (how would it know)
 - online them in right order (order might also be different depending
   on kernel version)
   -- it becomes even more complicated in NUMA case when there are
      multiple zones and kernel would have to provide user-space
      with information about zone maps

In short current experience shows that userspace approach
 - doesn't solve issues that Vitaly has been fixing (i.e. onlining
   fast and/or under memory pressure) when udev (or something else
   might be killed)
 - doesn't reduce overall system complexity, it only gets worse
   as user-space handler needs to know a lot about kernel internals
   and implementation details/kernel versions to work properly

It's might be not easy but doing onlining in kernel on the other hand is:
 - faster
 - more reliable (can't be killed under memory pressure)
 - kernel has access to all info needed for onlining and how it
   internals work to implement auto-online correctly
 - since there is no need to mantain ABI for user-space
   (zones layout/ordering/maybe something else), kernel is
   free change internal implemetation without breaking userspace
   (currently hotplug+unplug doesn't work reliably and we might
    need something more flexible than zones)
    That's direction of research in progress, i.e. making kernel
    implementation better instead of putting responsibility on
    user-space to deal with kernel shortcomings.

> Can you imagine any situation when somebody actually might want to have
> this knob enabled? From what I understand it doesn't seem to be the
> case.
For x86:
 * this config option is enabled by default in recent Fedora,
 * RHEL6 ships similar downstream patches to do the same thing for years
 * RHEL7 has udev rule (because there wasn't kernel side solution at fork time)
   that auto-onlines it unconditionally, Vitaly might backport it later
   when he has time.
Not linux kernel but still auto online policy is used by Windows
both on baremetal and guest configurations.

That's somewhat shows that current defaults upstream on x86
might be not what end-users wish for.

When auto_online_blocks were introduced, Vitaly has been
conservative and left current upstream defaults where they were
lest it would break someone else setup but allowing downstreams
set their own auto-online policy, eventually we might switch it
upstream too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
