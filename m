Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA716B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 03:22:34 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f21so201985674pgi.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 00:22:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q17si18317837pgh.300.2017.03.06.00.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 00:22:33 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v26844a0012725
	for <linux-mm@kvack.org>; Mon, 6 Mar 2017 03:22:32 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28yu2jj060-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Mar 2017 03:22:31 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 6 Mar 2017 08:22:28 -0000
Date: Mon, 6 Mar 2017 09:22:21 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm, add_memory_resource: hold device_hotplug lock over
 mem_hotplug_{begin, done}
References: <alpine.LFD.2.20.1702261231580.3067@schleppi.fritz.box>
 <20170227162031.GA27937@dhcp22.suse.cz>
 <20170228115729.GB13872@osiris>
 <20170301125105.GA5208@osiris>
 <CAPcyv4ghK3GWUD0qBNigfQvPM6qUWLMwmfgT5THcDcjuYrjSSQ@mail.gmail.com>
 <20170301170429.GB5208@osiris>
 <CAPcyv4iUzC_rN4mg5c5ShLAoFxam7Jiek4q8dDaHTi44cxB=Aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iUzC_rN4mg5c5ShLAoFxam7Jiek4q8dDaHTi44cxB=Aw@mail.gmail.com>
Message-Id: <20170306082221.GA4572@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>

Hello Dan,

> > If you look at commit 5e33bc4165f3 ("driver core / ACPI: Avoid device hot
> > remove locking issues") then lock_device_hotplug_sysfs() was introduced to
> > avoid a different subtle deadlock, but it also sleeps uninterruptible, but
> > not for more than 5ms ;)
> >
> > However I'm not sure if the device hotplug lock should also be used to fix
> > an unrelated bug that was introduced with the get_online_mems() /
> > put_online_mems() interface. Should it?
> 
> No, I don't think it should.
> 
> I like your proposed direction of creating a new lock internal to
> mem_hotplug_begin() to protect active_writer, and stop relying on
> lock_device_hotplug to serve this purpose.
> 
> > If so, we need to sprinkle around a couple of lock_device_hotplug() calls
> > near mem_hotplug_begin() calls, like Sebastian already started, and give it
> > additional semantics (protecting mem_hotplug.active_writer), and hope it
> > doesn't lead to deadlocks anywhere.
> 
> I'll put your proposed patch through some testing.

On s390 it _seems_ to work. Did it pass your testing too?
If so I would send a patch with proper patch description for inclusion.

Thanks,
Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
