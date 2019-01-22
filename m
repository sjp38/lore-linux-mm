Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D4A418E0004
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 03:06:41 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z10so8982536edz.15
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 00:06:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 40si1559537edz.189.2019.01.22.00.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 00:06:40 -0800 (PST)
From: Juergen Gross <jgross@suse.com>
Subject: [PATCH 0/2] x86: respect memory size limits
Date: Tue, 22 Jan 2019 09:06:26 +0100
Message-Id: <20190122080628.7238-1-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, x86@kernel.org, linux-mm@kvack.org
Cc: boris.ostrovsky@oracle.com, sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, Juergen Gross <jgross@suse.com>

On a customer system running Xen a boot problem was observed due to
the kernel not respecting the memory size limit imposed by the Xen
hypervisor.

During analysis I found the same problem should be able to occur on
bare metal in case the memory would be limited via the "mem=" boot
parameter.

The system this problem has been observed on has tons of memory
added via PCI. So while in the E820 map the not to be used memory has
been wiped out the additional PCI memory is detected during ACPI scan
and it is added via __add_memory().

This small series tries to repair the issue by testing the imposed
memory limit during the memory hotplug process and refusing to add it
in case the limit is being violated.

I've chosen to refuse adding the complete memory chunk in case the
limit is reached instead of adding only some of the memory, as I
thought this would result in less problems (e.g. avoiding to add
only parts of a 128MB memory bar which might be difficult to remove
later).


Juergen Gross (2):
  x86: respect memory size limiting via mem= parameter
  x86/xen: dont add memory above max allowed allocation

 arch/x86/kernel/e820.c         | 5 +++++
 arch/x86/xen/setup.c           | 5 +++++
 include/linux/memory_hotplug.h | 2 ++
 mm/memory_hotplug.c            | 6 ++++++
 4 files changed, 18 insertions(+)

-- 
2.16.4
