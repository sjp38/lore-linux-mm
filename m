Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id C5805828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 12:32:40 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id e32so371225988qgf.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 09:32:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e67si2295740qkb.67.2016.01.13.09.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 09:32:39 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH v5 0/2] memory-hotplug: add automatic onlining policy for the newly added memory
Date: Wed, 13 Jan 2016 18:32:28 +0100
Message-Id: <1452706350-21158-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

Changes since v4:
Patch 1:
- Use memory_block_change_state() through walk_memory_range() instead of
  online_pages() to correctly handle possible failures [David Rientjes]
- Minor memory-hotplug.txt changes (keep the old title, explicitly word
  that we have a global policy here) [David Rientjes, Daniel Kiper]
Patch2:
- 'dom0' -> 'control domain', 'domU' -> 'target domain' in Kconfig
  [David Vrabel]
- always call add_memory_resource() with memhp_auto_online [David Vrabel]

Original description:

Currently, all newly added memory blocks remain in 'offline' state unless
someone onlines them, some linux distributions carry special udev rules
like:

SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"

to make this happen automatically. This is not a great solution for virtual
machines where memory hotplug is being used to address high memory pressure
situations as such onlining is slow and a userspace process doing this
(udev) has a chance of being killed by the OOM killer as it will probably
require to allocate some memory.

Introduce default policy for the newly added memory blocks in
/sys/devices/system/memory/auto_online_blocks file with two possible
values: "offline" which preserves the current behavior and "online" which
causes all newly added memory blocks to go online as soon as they're added.
The default is "offline".

Vitaly Kuznetsov (2):
  memory-hotplug: add automatic onlining policy for the newly added
    memory
  xen_balloon: support memory auto onlining policy

 Documentation/memory-hotplug.txt | 20 +++++++++++++++++---
 drivers/base/memory.c            | 34 +++++++++++++++++++++++++++++++++-
 drivers/xen/Kconfig              | 20 +++++++++++++-------
 drivers/xen/balloon.c            | 11 ++++++++++-
 include/linux/memory.h           |  3 +++
 include/linux/memory_hotplug.h   |  4 +++-
 mm/memory_hotplug.c              | 17 +++++++++++++++--
 7 files changed, 94 insertions(+), 15 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
