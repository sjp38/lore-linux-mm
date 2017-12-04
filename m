Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3CC6B0291
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 07:44:31 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id u124so11269760qkd.18
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 04:44:31 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z124si273319qkb.357.2017.12.04.04.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 04:44:30 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vB4ChtnT129229
	for <linux-mm@kvack.org>; Mon, 4 Dec 2017 07:44:29 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2en4h6xkar-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Dec 2017 07:44:29 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Mon, 4 Dec 2017 12:44:25 -0000
Date: Mon, 4 Dec 2017 12:44:19 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/5] mm: memory_hotplug: Add memory hotremove probe
 device
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
 <20171130144905.ntpovhy66gekj6e6@dhcp22.suse.cz>
 <20171204115129.GD6373@samekh>
 <20171204123355.4tam7pfv34zmwzyu@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171204123355.4tam7pfv34zmwzyu@dhcp22.suse.cz>
Message-Id: <20171204124419.GB10599@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, realean2@ie.ibm.com

On Mon  4 Dec 2017, 13:33, Michal Hocko wrote:
> On Mon 04-12-17 11:51:29, Andrea Reale wrote:
> > On Thu 30 Nov 2017, 15:49, Michal Hocko wrote:
> > > On Thu 23-11-17 11:14:52, Andrea Reale wrote:
> > > > Adding a "remove" sysfs handle that can be used to trigger
> > > > memory hotremove manually, exactly simmetrically with
> > > > what happens with the "probe" device for hot-add.
> > > > 
> > > > This is usueful for architecture that do not rely on
> > > > ACPI for memory hot-remove.
> > > 
> > > As already said elsewhere, this really has to check the online status of
> > > the range and fail some is still online.
> > > 
> > 
> > This is actually still done in remove_memory() (patch 2/5) with
> > walk_memory_range. We just return an error rather than BUGing().
> > 
> > Or are you referring to something else?
> 
> But you are not returning that error to the caller, are you?
> 
> [...]

Oh, I see your point. Yes, indeed we should have returned it. Thanks for
catching the issue.

> > > > +	nid = memory_add_physaddr_to_nid(phys_addr);
> > > > +	ret = lock_device_hotplug_sysfs();
> > > > +	if (ret)
> > > > +		return ret;
> > > > +
> > > > +	remove_memory(nid, phys_addr,
> > > > +			 MIN_MEMORY_BLOCK_SIZE * sections_per_block);
> > > > +	unlock_device_hotplug();
> > > > +	return count;

Thanks,
Andrea
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
