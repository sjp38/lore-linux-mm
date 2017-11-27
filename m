Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFD56B0261
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:14:58 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id o29so21670882qto.12
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 09:14:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d31si14487305qkh.314.2017.11.27.09.14.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 09:14:56 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vARHBs9E057807
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:14:55 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2egm4r0u2a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:14:53 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Mon, 27 Nov 2017 17:14:50 -0000
Date: Mon, 27 Nov 2017 17:14:43 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/5] mm: memory_hotplug: Add memory hotremove probe
 device
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
 <198063b0-fcc9-7beb-7476-86ed5f04734c@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <198063b0-fcc9-7beb-7476-86ed5f04734c@arm.com>
Message-Id: <20171127171441.GB12687@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, realean2@ie.ibm.com, mhocko@suse.com, m.bielski@virtualopensystems.com, scott.branden@broadcom.com, catalin.marinas@arm.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arunks@qti.qualcomm.com, qiuxishi@huawei.com

Hi Robin,

On Mon 27 Nov 2017, 15:33, Robin Murphy wrote:
> On 23/11/17 11:14, Andrea Reale wrote:
> >Adding a "remove" sysfs handle that can be used to trigger
> >memory hotremove manually, exactly simmetrically with
> >what happens with the "probe" device for hot-add.
> >
> >This is usueful for architecture that do not rely on
> >ACPI for memory hot-remove.
> 
> Is there a real-world use-case for this, or is it mostly just a handy
> development feature?
> 
as I was saying in a response to your previous message, in our use
case remove events are triggered by software. Besides our use case,
yes, it is mostly just a handy develeopment feature AFAICT.

> >Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> >Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
> >---
> >  drivers/base/memory.c | 34 +++++++++++++++++++++++++++++++++-
> >  1 file changed, 33 insertions(+), 1 deletion(-)
> >
> >diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> >index 1d60b58..8ccb67c 100644
> >--- a/drivers/base/memory.c
> >+++ b/drivers/base/memory.c
> >@@ -530,7 +530,36 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
> >  }
> >  static DEVICE_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
> >-#endif
> >+
> >+#ifdef CONFIG_MEMORY_HOTREMOVE
> >+static ssize_t
> >+memory_remove_store(struct device *dev,
> >+		struct device_attribute *attr, const char *buf, size_t count)
> >+{
> >+	u64 phys_addr;
> >+	int nid, ret;
> >+	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;
> >+
> >+	ret = kstrtoull(buf, 0, &phys_addr);
> >+	if (ret)
> >+		return ret;
> >+
> >+	if (phys_addr & ((pages_per_block << PAGE_SHIFT) - 1))
> >+		return -EINVAL;
> >+
> >+	nid = memory_add_physaddr_to_nid(phys_addr);
> 
> This call looks a bit odd, since you're not doing a memory add. In fact, any
> memory being removed should already be fully known-about, so AFAICS it
> should be simple to get everything you need to know (including potentially
> the online status as mentioned earlier), through 'normal' methods, e.g.
> page_to_nid() or similar.

Makes sense. Suggestion noted, thanks.

> Robin.
> 
> >+	ret = lock_device_hotplug_sysfs();
> >+	if (ret)
> >+		return ret;
> >+
> >+	remove_memory(nid, phys_addr,
> >+			 MIN_MEMORY_BLOCK_SIZE * sections_per_block);
> >+	unlock_device_hotplug();
> >+	return count;
> >+}
> >+static DEVICE_ATTR(remove, S_IWUSR, NULL, memory_remove_store);
> >+#endif /* CONFIG_MEMORY_HOTREMOVE */
> >+#endif /* CONFIG_ARCH_MEMORY_PROBE */
> >  #ifdef CONFIG_MEMORY_FAILURE
> >  /*
> >@@ -790,6 +819,9 @@ bool is_memblock_offlined(struct memory_block *mem)
> >  static struct attribute *memory_root_attrs[] = {
> >  #ifdef CONFIG_ARCH_MEMORY_PROBE
> >  	&dev_attr_probe.attr,
> >+#ifdef CONFIG_MEMORY_HOTREMOVE
> >+	&dev_attr_remove.attr,
> >+#endif
> >  #endif
> >  #ifdef CONFIG_MEMORY_FAILURE
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
