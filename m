Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED59D6B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 11:09:17 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id q4so22712858qkh.4
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:09:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i7si5904736qkf.334.2017.02.24.08.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 08:09:17 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
References: <20170223150920.GB29056@dhcp22.suse.cz>
	<877f4gzz4d.fsf@vitty.brq.redhat.com>
	<20170223161241.GG29056@dhcp22.suse.cz>
	<8737f4zwx5.fsf@vitty.brq.redhat.com>
	<20170223174106.GB13822@dhcp22.suse.cz>
	<87tw7kydto.fsf@vitty.brq.redhat.com>
	<20170224133714.GH19161@dhcp22.suse.cz>
	<87efyny90q.fsf@vitty.brq.redhat.com>
	<20170224144147.GJ19161@dhcp22.suse.cz>
	<87a89by6hd.fsf@vitty.brq.redhat.com>
	<20170224153227.GL19161@dhcp22.suse.cz>
Date: Fri, 24 Feb 2017 17:09:13 +0100
In-Reply-To: <20170224153227.GL19161@dhcp22.suse.cz> (Michal Hocko's message
	of "Fri, 24 Feb 2017 16:32:27 +0100")
Message-ID: <8760jzy3iu.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com, kys@microsoft.com

Michal Hocko <mhocko@kernel.org> writes:

> On Fri 24-02-17 16:05:18, Vitaly Kuznetsov wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>> > On Fri 24-02-17 15:10:29, Vitaly Kuznetsov wrote:
> [...]
>> >> Just did a quick (and probably dirty) test, increasing guest memory from
>> >> 4G to 8G (32 x 128mb blocks) require 68Mb of memory, so it's roughly 2Mb
>> >> per block. It's really easy to trigger OOM for small guests.
>> >
>> > So we need ~1.5% of the added memory. That doesn't sound like something
>> > to trigger OOM killer too easily. Assuming that increase is not way too
>> > large. Going from 256M (your earlier example) to 8G looks will eat half
>> > the memory which is still quite far away from the OOM.
>> 
>> And if the kernel itself takes 128Mb of ram (which is not something
>> extraordinary with many CPUs) we have zero left. Go to something bigger
>> than 8G and you die.
>
> Again, if you have 128M and jump to 8G then your memory balancing is
> most probably broken.
>

I don't understand what balancing you're talking about. I have a small
guest and I want to add more memory to it and the result is ... OOM. Not
something I expected.

>> > I would call such
>> > an increase a bad memory balancing, though, to be honest. A more
>> > reasonable memory balancing would go and double the available memory
>> > IMHO. Anway, I still think that hotplug is a terrible way to do memory
>> > ballooning.
>> 
>> That's what we have in *all* modern hypervisors. And I don't see why
>> it's bad.
>
> Go and re-read the original thread. Dave has given many good arguments.
>

Are we discussing taking away the memory hotplug feature from all
hypervisors here?

>> > Just make them all online the memory explicitly. I really do not see why
>> > this should be decided by poor user. Put it differently, when should I
>> > disable auto online when using hyperV or other of the mentioned
>> > technologies? CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE should simply die and
>> > I would even be for killing the whole memhp_auto_online thing along the
>> > way. This simply doesn't make any sense to me.
>> 
>> ACPI, for example, is shared between KVM/Qemu, Vmware and real
>> hardware. I can understand why bare metall guys might not want to have
>> auto-online by default (though, major linux distros ship the stupid
>> 'offline' -> 'online' udev rule and nobody complains) -- they're doing
>> some physical action - going to a server room, openning the box,
>> plugging in memory, going back to their place but with VMs it's not like
>> that. What's gonna be the default for ACPI then?
>> 
>> I don't understand why CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is
>
> Because this is something a user has to think about and doesn't have a
> reasonable way to decide. Our config space is also way too large!

Config space is for distros, not users.

>
>> disturbing and why do we need to take this choice away from distros. I
>> don't understand what we're gaining by replacing it with
>> per-memory-add-technology defaults.
>
> Because those technologies know that they want to have the memory online
> as soon as possible. Jeez, just look at the hv code. It waits for the
> userspace to online memory before going further. Why would it ever want
> to have the tunable in "offline" state? This just doesn't make any
> sense. Look at how things get simplified if we get rid of this clutter

While this will most probably work for me I still disagree with the
concept of 'one size fits all' here and the default 'false' for ACPI,
we're taking away the feature from KVM/Vmware folks so they'll again
come up with the udev rule which has known issues.

[snip].

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
