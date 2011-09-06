Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9AD6B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 07:34:51 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so6527481bkb.14
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 04:34:47 -0700 (PDT)
Date: Tue, 6 Sep 2011 13:36:06 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Memory unplug question
Message-ID: <20110906113606.GA6121@dhcp-192-168-178-175.profitbricks.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I am trying to get memory-unplug to work on a kvm host/guest scenario.
This is for an x86_64 kvm Linux guest running 3.1.0 kernel. The host is running a
modified qemu-kvm and seabios to support memory hotplug (see
https://patchwork.kernel.org/patch/1057612/ for details)

I have managed to hotplug memory in 128MB chunks, above the 4GB limit.
E.g. adding a 128MB memory range at 4GB physical offset results in the following
dmesg output in the guest:

[   42.028288] Hotplug Mem Device 
[   42.028580] init_memory_mapping: 0000000100000000-0000000108000000
[   42.028633]  0100000000 - 0108000000 page 2M

And the memory device can be onlined and normally used.
On memory unplug, I always get the followings failure 

[   71.907689] memory offlining 100000 to 108000 failed
[   71.908438] ACPI:memory_hp:Disable memory device

(I have not onlined the memory device in the OS when trying the unplug)

Specifically the callpath is:
acpi_memory_disable_device()
    remove_memory()
        offline_pages()
            check_pages_isolated() returns a negative value.

Is this expected behaviour? Can the pluggable memory pages be moved to a different
memory zone so that they can be later isolated? I 've seen mention of
ZONE_MOVABLE or a retry parameter in old memory-unplug patchsets.

thanks for any suggestions,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
