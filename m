Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id D43C06B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 07:40:35 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id q8so2541451lbi.28
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 04:40:34 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si2942580laq.40.2014.01.30.04.40.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jan 2014 04:40:33 -0800 (PST)
Message-ID: <52EA483F.50105@parallels.com>
Date: Thu, 30 Jan 2014 16:40:31 +0400
From: Maxim Patlasov <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] balancing dirty pages - how to keep growing dirty
 memory in reasonable limits
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "fuse-devel@lists.sourceforge.net" <fuse-devel@lists.sourceforge.net>, linux-mm@kvack.org

Hi,

A recent patch from Linus limiting global_dirtyable_memory to 1GB (see 
"Disabling in-memory write cache for x86-64 in Linux" thread) drew 
attention to a long-standing problem: on a node with a huge amount of 
RAM installed, the global dirty threshold is high, and existing 
behaviour of balance_dirty_pages() skips throttling until the global 
limit is reached. So, by the time balance_dirty_pages() starts 
throttling, you can easily end up in a huge amount of dirty pages backed 
up by some (e.g. slow USB) device.

A lot of ideas were proposed, but no conclusion was made. In particular, 
one of suggested approaches is to develop per-BDI time-based limits and 
to enable them for all: don't allow dirty cache of BDI to grow over 5s 
of measured writeback speed. The approach looks pretty straightforward, 
but in practice it may be tricky to implement: you cannot discover how 
fast a device is until you load it heavily enough, and conversely, you 
must go far beyond current per-BDI limit to load the device heavily. And 
other approaches have other caveats as usual.

I'm interested in attending upcoming LSF/MM to discuss the topic above 
as well as two other unrelated ones:

* future improvements of FUSE. Having "write-back cache policy" 
patch-set almost adopted and patches for synchronous close(2) and 
umount(2) in queue, I'd like to keep my efforts in sync with other FUSE 
developers.

* reboot-less kernel updates. Since memory reset can be avoided by 
booting the new kernel using Kexec, and almost any application can be 
checkpointed and then restored by CRIU, the downtime can be diminished 
significantly by keeping userspace processes' working set in memory 
while the system gets updated. Questions to discuss are how to prevent 
the kernel from using some memory regions on boot, what interface can be 
reused/introduced for managing the regions and how they can be 
re-installed back into processes' address space on restore.

Thanks,
Maxim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
