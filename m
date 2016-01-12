Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id C71E3828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 11:56:26 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id 6so354678990qgy.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 08:56:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a197si43991412qkb.6.2016.01.12.08.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 08:56:25 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH v4 0/2] memory-hotplug: add automatic onlining policy for the newly added memory
Date: Tue, 12 Jan 2016 17:56:15 +0100
Message-Id: <1452617777-10598-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

Changes since v3:
- Add support for the policy to Xen balloon driver [Daniel Kiper, David Vrabel]
- I found an issue with PATCH v3: when memory auto onlining was requested we
  do nothing to memblocks states so in sysfs they stay 'offline' (while in
  reality they're online). Modify register_new_memory() (and its only caller,
  __add_section()) to create memblocks in the proper state.

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

 Documentation/memory-hotplug.txt | 19 +++++++++++++++----
 drivers/base/memory.c            | 40 ++++++++++++++++++++++++++++++++++++----
 drivers/xen/Kconfig              | 20 +++++++++++++-------
 drivers/xen/balloon.c            | 30 +++++++++++++++++++-----------
 include/linux/memory.h           |  3 ++-
 include/linux/memory_hotplug.h   |  4 +++-
 mm/memory_hotplug.c              | 18 +++++++++++++++---
 7 files changed, 103 insertions(+), 31 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
