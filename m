Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC3EE6B041D
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 17:49:02 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id g70so46649543lfh.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 14:49:02 -0800 (PST)
Received: from cloudserver094114.home.net.pl (cloudserver094114.home.net.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id w65si642160lff.122.2017.03.09.14.49.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 Mar 2017 14:49:01 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 1/2] mm: add private lock to serialize memory hotplug operations
Date: Thu, 09 Mar 2017 23:43:42 +0100
Message-ID: <9260906.bxXFooPL9U@aspire.rjw.lan>
In-Reply-To: <CAPcyv4gX-7BAZOEvi7UShZD0bo6JV1D7tiU5wQweauG0tx=Luw@mail.gmail.com>
References: <20170309130616.51286-1-heiko.carstens@de.ibm.com> <19605238.M7OFe3HAv5@aspire.rjw.lan> <CAPcyv4gX-7BAZOEvi7UShZD0bo6JV1D7tiU5wQweauG0tx=Luw@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Thursday, March 09, 2017 02:37:55 PM Dan Williams wrote:
> On Thu, Mar 9, 2017 at 2:22 PM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> > On Thursday, March 09, 2017 11:15:47 PM Rafael J. Wysocki wrote:
> >> On Thursday, March 09, 2017 10:10:31 AM Dan Williams wrote:
> >> > On Thu, Mar 9, 2017 at 5:39 AM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> [..]
> >> > I *think* we're ok in this case because unplugging the CPU package
> >> > that contains a persistent memory device will trigger
> >> > devm_memremap_pages() to call arch_remove_memory(). Removing a pmem
> >> > device can't fail. It may be held off while pages are pinned for DMA
> >> > memory, but it will eventually complete.
> >>
> >> What about the offlining, though?  Is it guaranteed that no memory from those
> >> ranges will go back online after the acpi_scan_try_to_offline() call in
> >> acpi_scan_hot_remove()?
> >
> > My point is that after the acpi_evaluate_ej0() in acpi_scan_hot_remove() the
> > hardware is physically gone, so if anything is still doing DMA to that memory at
> > that point, then the user is going to be unhappy.
> 
> Hmm, ACPI 6.1 does not have any text about what _EJ0 means for ACPI0012.

ACPI0012 is exceptional, but in general _EJ0 does not have to be present under
a particular device for it to be affected.  It can be under the device's parent, for
example, in which case the entire subtree under a device with _EJ0 goes away in
one go.  And that very well may mean disconnect at the physical level (voltage
goes away IOW).

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
