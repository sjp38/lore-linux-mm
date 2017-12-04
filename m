Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB316B025F
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 12:50:51 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id r137so8291228ywg.4
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 09:50:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d5si3408446vkg.202.2017.12.04.09.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 09:50:50 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vB4HoYgu084937
	for <linux-mm@kvack.org>; Mon, 4 Dec 2017 12:50:49 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2en8w88mtj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Dec 2017 12:50:48 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 4 Dec 2017 10:50:47 -0700
Date: Mon, 4 Dec 2017 11:50:41 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/5] mm: memory_hotplug: Add memory hotremove probe
 device
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
 <5A17F5DF.2040108@huawei.com>
 <20171124104401.GD18120@samekh>
 <5A180DF1.8060009@huawei.com>
 <20171124142948.GA1966@samekh>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20171124142948.GA1966@samekh>
Message-Id: <20171204175040.2vgc6ccdcr5m77hm@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: zhong jiang <zhongjiang@huawei.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, realean2@ie.ibm.com

On Fri, Nov 24, 2017 at 02:29:48PM +0000, Andrea Reale wrote:
>But, at least in my understanding, the implementation is not as
>straightfoward as it looks. If I declare a memory node in the fdt, then,
>at boot, the kernel will expect that memory to actually be there to be
>used: this is not true if I want to plug my dimms only later at runtime.
>So I think that declaring the hotpluggable memory in an fdt memory
>node might not feasible without changes.

On the power arch, we do this today using "linux,usable-memory".

memory@10000000000 {
  device_type = "memory";
  reg = <0x100 0x0 0x0 0x80000000>;
  linux,usable-memory = <0x100 0x0 0x0 0x40000000>;
  :
}

The reg range defines the node, but at at boot, memblocks are only 
created for the linux,usable-memory range. The rest can be hotplugged 
later. YMMV, because this depends on your arch's implementation of 
memory_add_physaddr_to_nid().

>One idea could be to add a new property to memory nodes, to specify 
>what memory is potentially hotplugguable.

Somewhat related, there is already a "hotpluggable" property.

memory@10040000000 {
  device_type = "memory";
  reg = <0x100 0x40000000 0x0 0x40000000>;
  hotpluggable;
  :
}

This is subtly different from the earlier example. This memory IS 
present at boot. The hotpluggable property ensures that it resides in 
ZONE_MOVABLE so it can potentially be removed.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
