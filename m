Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 74FFA44084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 18:59:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u5so130607276pgq.14
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 15:59:40 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 31si3818025plg.595.2017.07.10.15.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 15:59:39 -0700 (PDT)
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
Message-ID: <f04a007d-fc34-fe3a-d366-1363248a609f@nvidia.com>
Date: Mon, 10 Jul 2017 15:59:37 -0700
MIME-Version: 1.0
In-Reply-To: <20170701005749.GA7232@redhat.com>
Content-Type: multipart/mixed;
	boundary="------------2D3AD0687E30103FA3C59CB4"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

--------------2D3AD0687E30103FA3C59CB4
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

On 6/30/17 5:57 PM, Jerome Glisse wrote:
...

Hi Jerome,

I am seeing a strange crash in our code that uses the hmm_device_new() 
helper. After the driver is repeatedly loaded/unloaded, hmm_device_new() 
suddenly returns NULL.

I have reproduced this with the dummy driver from the hmm-next branch:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000208

(gdb) bt
#0  hmm_devmem_add (ops=0xffffffffa003a140, device=0x0 
<irq_stack_union>, size=0x4000000) at mm/hmm.c:997
#1  0xffffffffa0038236 in dmirror_probe (pdev=<optimized out>) at 
drivers/char/hmm_dmirror.c:1106
#2  0xffffffff815acfcb in platform_drv_probe (_dev=0xffff88081368ca78) 
at drivers/base/platform.c:578
#3  0xffffffff815ab0a4 in really_probe (drv=<optimized out>, 
dev=<optimized out>) at drivers/base/dd.c:385
#4  driver_probe_device (drv=0xffffffffa003b028, dev=0xffff88081368ca78) 
at drivers/base/dd.c:529
#5  0xffffffff815ab1d4 in __driver_attach (dev=0xffff88081368ca78, 
data=0xffffffffa003b028) at drivers/base/dd.c:763
#6  0xffffffff815a911d in bus_for_each_dev (bus=<optimized out>, 
start=<optimized out>, data=0x4000000, fn=0x18 <irq_stack_union+24>) at 
drivers/base/bus.c:313
#7  0xffffffff815aa98e in driver_attach (drv=<optimized out>) at 
drivers/base/dd.c:782
#8  0xffffffff815aa585 in bus_add_driver (drv=0xffffffffa003b028) at 
drivers/base/bus.c:669
#9  0xffffffff815abc10 in driver_register (drv=0xffffffffa003b028) at 
drivers/base/driver.c:168
#10 0xffffffff815acf46 in __platform_driver_register (drv=<optimized 
out>, owner=<optimized out>) at drivers/base/platform.c:636


Can you please look into this?

Here's a command to reproduce, using the kload.sh script (taken from a 
sanity suite you provided earlier, attached):

$ while true; do sudo ./kload.sh; done

Thanks!

Evgeny Baskakov
NVIDIA

--------------2D3AD0687E30103FA3C59CB4
Content-Type: application/x-sh; name="kload.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="kload.sh"

#!/bin/sh
#
# Simple script to load/reload the HMM dummy driver and create appropriate
# device files.

sync
rmmod hmm_dmirror
modprobe hmm_dmirror || exit 1
rm -f .tmp_v_*

# device0
rm -f /dev/hmm_dmirror
major=$(awk "\$2==\"HMM_DMIRROR\" {print \$1}" /proc/devices)
echo hmm_dmirror major is $major
mknod /dev/hmm_dmirror c $major 0
chgrp ebaskakov /dev/hmm_dmirror
chmod 664 /dev/hmm_dmirror


--------------2D3AD0687E30103FA3C59CB4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
