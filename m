Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0E36B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 12:04:55 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x17so61617836pgi.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 09:04:55 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c22si5112637pli.5.2017.03.01.09.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 09:04:54 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v21H4pG7138536
	for <linux-mm@kvack.org>; Wed, 1 Mar 2017 12:04:53 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28wxrb4nv1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Mar 2017 12:04:53 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 1 Mar 2017 17:04:49 -0000
Date: Wed, 1 Mar 2017 18:04:29 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm, add_memory_resource: hold device_hotplug lock over
 mem_hotplug_{begin, done}
References: <alpine.LFD.2.20.1702261231580.3067@schleppi.fritz.box>
 <20170227162031.GA27937@dhcp22.suse.cz>
 <20170228115729.GB13872@osiris>
 <20170301125105.GA5208@osiris>
 <CAPcyv4ghK3GWUD0qBNigfQvPM6qUWLMwmfgT5THcDcjuYrjSSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ghK3GWUD0qBNigfQvPM6qUWLMwmfgT5THcDcjuYrjSSQ@mail.gmail.com>
Message-Id: <20170301170429.GB5208@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>

On Wed, Mar 01, 2017 at 07:52:18AM -0800, Dan Williams wrote:
> On Wed, Mar 1, 2017 at 4:51 AM, Heiko Carstens
> <heiko.carstens@de.ibm.com> wrote:
> > Since it is anything but obvious why Dan wrote in changelog of b5d24fda9c3d
> > ("mm, devm_memremap_pages: hold device_hotplug lock over
> > mem_hotplug_{begin, done}") that write accesses to
> > mem_hotplug.active_writer are coordinated via lock_device_hotplug() I'd
> > rather propose a new private memory_add_remove_lock which has similar
> > semantics like the cpu_add_remove_lock for cpu hotplug (see patch below).
> >
> > However instead of sprinkling locking/unlocking of that new lock around all
> > calls of mem_hotplug_begin() and mem_hotplug_end() simply include locking
> > and unlocking into these two functions.
> >
> > This still allows get_online_mems() and put_online_mems() to work, while at
> > the same time preventing mem_hotplug.active_writer corruption.
> >
> > Any opinions?
> 
> Sorry, yes, I didn't make it clear that I derived that locking
> requirement from store_mem_state() and its usage of
> lock_device_hotplug_sysfs().
> 
> That routine is trying very hard not trip the soft-lockup detector. It
> seems like that wants to be an interruptible wait.

If you look at commit 5e33bc4165f3 ("driver core / ACPI: Avoid device hot
remove locking issues") then lock_device_hotplug_sysfs() was introduced to
avoid a different subtle deadlock, but it also sleeps uninterruptible, but
not for more than 5ms ;)

However I'm not sure if the device hotplug lock should also be used to fix
an unrelated bug that was introduced with the get_online_mems() /
put_online_mems() interface. Should it?

If so, we need to sprinkle around a couple of lock_device_hotplug() calls
near mem_hotplug_begin() calls, like Sebastian already started, and give it
additional semantics (protecting mem_hotplug.active_writer), and hope it
doesn't lead to deadlocks anywhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
