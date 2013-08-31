Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 68BAB6B0032
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 20:28:42 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 3/3] PM / hibernate / memory hotplug: Rework mutual exclusion
Date: Sat, 31 Aug 2013 02:39:28 +0200
Message-ID: <1984629.rbRksDyNff@vostro.rjw.lan>
In-Reply-To: <1377908599.10300.901.camel@misato.fc.hp.com>
References: <9589253.Co8jZpnWdd@vostro.rjw.lan> <1562298.ZjRvhqQzT7@vostro.rjw.lan> <1377908599.10300.901.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org

On Friday, August 30, 2013 06:23:19 PM Toshi Kani wrote:
> On Thu, 2013-08-29 at 23:18 +0200, Rafael J. Wysocki wrote:
> > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > 
> > Since all of the memory hotplug operations have to be carried out
> > under device_hotplug_lock, they won't need to acquire pm_mutex if
> > device_hotplug_lock is held around hibernation.
> > 
> > For this reason, make the hibernation code acquire
> > device_hotplug_lock after freezing user space processes and
> > release it before thawing them.  At the same tim drop the
> > lock_system_sleep() and unlock_system_sleep() calls from
> > lock_memory_hotplug() and unlock_memory_hotplug(), respectively.
> > 
> > Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > ---
> >  kernel/power/hibernate.c |    4 ++++
> >  kernel/power/user.c      |    2 ++
> >  mm/memory_hotplug.c      |    4 ----
> >  3 files changed, 6 insertions(+), 4 deletions(-)
> > 
> > Index: linux-pm/kernel/power/hibernate.c
> > ===================================================================
> > --- linux-pm.orig/kernel/power/hibernate.c
> > +++ linux-pm/kernel/power/hibernate.c
> > @@ -652,6 +652,7 @@ int hibernate(void)
> >  	if (error)
> >  		goto Exit;
> >  
> > +	lock_device_hotplug();
> 
> Since hibernate() can be called from sysfs, do you think the tool may
> see this as a circular dependency with p_active again?  This shouldn't
> be a problem in practice, though.

/sys/power/state isn't a device attribute even and is never removed, so it
would be very sad and disappointing if lockdep reported that as a circular
dependency.  The deadlock is surely not possible here anyway.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
