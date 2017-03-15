Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED696B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 12:37:34 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v127so17184493qkb.5
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:37:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l65si1792199qkf.193.2017.03.15.09.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 09:37:33 -0700 (PDT)
Date: Wed, 15 Mar 2017 17:37:29 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: ZONE_NORMAL vs. ZONE_MOVABLE
Message-ID: <20170315163729.GR27056@redhat.com>
References: <20170315091347.GA32626@dhcp22.suse.cz>
 <87shmedddm.fsf@vitty.brq.redhat.com>
 <20170315122914.GG32620@dhcp22.suse.cz>
 <87k27qd7m2.fsf@vitty.brq.redhat.com>
 <20170315131139.GK32620@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315131139.GK32620@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Andi Kleen <ak@linux.intel.com>

On Wed, Mar 15, 2017 at 02:11:40PM +0100, Michal Hocko wrote:
> OK, I see now. I am afraid there is quite a lot of code which expects
> that zones do not overlap. We can have holes in zones but not different
> zones interleaving. Probably something which could be addressed but far
> from trivial IMHO.
> 
> All that being said, I do not want to discourage you from experiments in
> those areas. Just be prepared all those are far from trivial and
> something for a long project ;)

This constraint was known for quite some time, so when I talked about
this very constraint with Mel at least year LSF/MM he suggested sticky
pageblocks would be superior to the current movable zone.

So instead of having a Movable zone, we could use the pageblocks but
make it sticky-movable so they're only going to accept __GFP_MOVABLE
allocations into them. It would be still a quite large change indeed
but it looks simpler and with fewer drawbacks than trying to make the
zone overlap.

Currently when you online memory as movable you're patching down the
movable zone not just onlining the memory and that complexity you've
to deal with, would go away with sticky movable pageblocks.

One other option could be to boot like with _DEFAULT_ONLINE=n and of
course without udev rule. Then after booting with the base memory run
one of the two echo below:

    $ cat /sys/devices/system/memory/removable_hotplug_default
    [disabled] online online_movable
    $ echo online > /sys/devices/system/memory/removable_hotplug_default
    $ echo online_movable > /sys/devices/system/memory/removable_hotplug_default

Then the "echo online/online_movable" would activate the in-kernel
hotplug mechanism that is faster and more reliable than udev and it
won't risk to run into the movable zone shift "constraint". After the
"echo" the kernel would behave like if it booted with _DEFAULT_ONLINE=y.

If you still want to do it by hand and leave it disabled or even
trying to fix udev movable shift constraints, sticky pageblocks and
lack of synchronicity (and deal with the resulting slower
performance compared to in-kernel onlining), you could.

The in-kernel onlining would use the exact same code of
_DEFAULT_ONLINE=y, but it would be configured with a file like
/etc/sysctl.conf. And then to switch it to the _movable model you
would just need to edit the file like you've to edit the udev rule
(the one that if you edit it with online_movable currently breaks).

>From usability prospective it would be like udev, but without all
drawbacks of doing the onlining in userland.

Checking if the memory should become movable or not depending on
acpi_has_method(handle, "_EJ0") isn't flexible enough I think, on bare
metal especially we couldn't change the ACPI like we can do with the
hypervisor, but the admin has still to decide freely if he wants to
risk early OOM and movable zone imbalance or if he prefers not being
able to hotunplug the memory ever again. So it would need to become a
grub boot option which is probably less friendly than editing
sysctl.conf or something like that (especially given grub-mkconfig
output..).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
