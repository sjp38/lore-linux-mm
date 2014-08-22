Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 827536B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 18:16:25 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so17578713pad.10
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 15:16:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dm3si42629412pdb.160.2014.08.22.15.16.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Aug 2014 15:16:24 -0700 (PDT)
Date: Fri, 22 Aug 2014 15:16:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] memory-hotplug: add sysfs zones_online_to attribute
Message-Id: <20140822151622.6786c1089548ea5ceb3732bf@linux-foundation.org>
In-Reply-To: <53F17230.5020409@huawei.com>
References: <1407902811-4873-1-git-send-email-zhenzhang.zhang@huawei.com>
	<53EAE534.8030303@huawei.com>
	<1408138647.26567.42.camel@misato.fc.hp.com>
	<53F17230.5020409@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, isimatu.yasuaki@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com, wangnan0@huawei.com, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Mon, 18 Aug 2014 11:25:36 +0800 Zhang Zhen <zhenzhang.zhang@huawei.com> wrote:

> On 2014/8/16 5:37, Toshi Kani wrote:
> > On Wed, 2014-08-13 at 12:10 +0800, Zhang Zhen wrote:
> >> Currently memory-hotplug has two limits:
> >> 1. If the memory block is in ZONE_NORMAL, you can change it to
> >> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
> >> 2. If the memory block is in ZONE_MOVABLE, you can change it to
> >> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
> >>
> >> With this patch, we can easy to know a memory block can be onlined to
> >> which zone, and don't need to know the above two limits.
> >>
> >> Updated the related Documentation.
> >>
> >> Change v1 -> v2:
> >> - optimize the implementation following Dave Hansen's suggestion
> >>
> >> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
> >> ---
> >>  Documentation/ABI/testing/sysfs-devices-memory |  8 ++++
> >>  Documentation/memory-hotplug.txt               |  4 +-
> >>  drivers/base/memory.c                          | 62 ++++++++++++++++++++++++++
> >>  include/linux/memory_hotplug.h                 |  1 +
> >>  mm/memory_hotplug.c                            |  2 +-
> >>  5 files changed, 75 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
> >> index 7405de2..2b2a1d7 100644
> >> --- a/Documentation/ABI/testing/sysfs-devices-memory
> >> +++ b/Documentation/ABI/testing/sysfs-devices-memory
> >> @@ -61,6 +61,14 @@ Users:		hotplug memory remove tools
> >>  		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils
> >>
> >>
> >> +What:           /sys/devices/system/memory/memoryX/zones_online_to
> > 
> > I think this name is a bit confusing.  How about "valid_online_types"?
> > 
> Thanks for your suggestion.
> 
> This patch has been added to -mm tree.
> If most people think so, i would like to modify the interface name.
> If not, let's leave it as it is.

Yes, the name could be better.  Do we actually need "online" in there? 
How about "valid_zones"?

Also, it's not really clear to me why we need this sysfs file at all. 
Do people really read sysfs files, make onlining decisions and manually
type in commands?  Or is this stuff all automated?  If the latter then
the script can take care of all this?  For example, attempt to online
the memory into the desired zone and report failure if that didn't
succeed?

IOW, please update the changelog to show

a) example output from
   /sys/devices/system/memory/memoryX/whatever-we-call-it and

b) example use-cases which help reviewers understand why this
   feature will be valuable to users.

Also, please do address the error which Yasuaki Ishimatsu identified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
