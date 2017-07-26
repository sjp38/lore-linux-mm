Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 936336B02B4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:20:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r63so63526405pfb.7
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:20:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q6si9946323pgn.509.2017.07.26.10.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 10:20:52 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6QHJH6M098875
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:20:51 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bxxum1r8u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:20:51 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 26 Jul 2017 18:20:48 +0100
Date: Wed, 26 Jul 2017 19:20:39 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [RFC PATCH 3/5] mm, memory_hotplug: allocate memmap from the
 added memory range for sparse-vmemmap
In-Reply-To: <20170726123040.GO2981@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
	<20170726083333.17754-4-mhocko@kernel.org>
	<20170726114539.GG3218@osiris>
	<20170726123040.GO2981@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20170726192039.48b81161@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, gerald.schaefer@de.ibm.com, Martin Schwidefsky <mschwide@de.ibm.com>

On Wed, 26 Jul 2017 14:30:41 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 26-07-17 13:45:39, Heiko Carstens wrote:
> [...]
> > In general I do like your idea, however if I understand your patches
> > correctly we might have an ordering problem on s390: it is not possible to
> > access hot-added memory on s390 before it is online (MEM_GOING_ONLINE
> > succeeded).
> 
> Could you point me to the code please? I cannot seem to find the
> notifier which implements that.

It is in drivers/s390/char/sclp_cmd.c: sclp_mem_notifier(). 

> 
> > On MEM_GOING_ONLINE we ask the hypervisor to back the potential available
> > hot-added memory region with physical pages. Accessing those ranges before
> > that will result in an exception.
> 
> Can we make the range which backs the memmap range available? E.g from
> s390 specific __vmemmap_populate path?

No, only the complete range of a storage increment can be made available.
The size of those increments may vary between z/VM and LPAR, but at least
with LPAR it will always be minimum 256 MB, IIRC.

> 
> > However with your approach the memory is still allocated when add_memory()
> > is being called, correct? That wouldn't be a change to the current
> > behaviour; except for the ordering problem outlined above.
> 
> Could you be more specific please? I do not change when the memmap is
> allocated.

I guess this is about the difference between s390 and others, wrt when
we call add_memory(). It is also in drivers/s390/char/sclp_cmd.c, early
during memory detection, as opposed to other archs, where I guess this
could be triggered by an ACPI event during runtime, at least for newly
added and to-be-onlined memory.

This probably means that any approach that tries to allocate memmap
memory during add_memory(), out of the "to-be-onlined but still offline"
memory, will be difficult for s390, because we call add_memory() only once
during memory detection for the complete range of (hypervisor) defined
online and offline memory. The offline parts are then made available in
the MEM_GOING_ONLINE notifier called from online_pages(). Only after
this point the memory would then be available to allocate a memmap in it.

Nevertheless, we have great interest in such a "allocate memmap from
the added memory range" solution. I guess we would need some way to
separate the memmap allocation from add_memory(), which sounds odd,
or provide some way to have add_memory() only allocate a memmap for
online memory, and a mechanism to add the memmaps for offline memory
blocks later when they are being set online.

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
