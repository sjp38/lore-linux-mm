Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC0C8E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 21:27:06 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 186-v6so8588750pgc.12
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 18:27:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p14-v6sor171965plq.116.2018.09.24.18.27.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 18:27:05 -0700 (PDT)
Message-ID: <1537838811.10753.2.camel@gmail.com>
Subject: Re: [PATCH RFCv2 3/6] mm/memory_hotplug: fix online/offline_pages
 called w.o. mem_hotplug_lock
From: Rashmica Gupta <rashmica.g@gmail.com>
Date: Tue, 25 Sep 2018 11:26:51 +1000
In-Reply-To: <5f80ca56-9f34-4e6e-bc83-8f8b3c888163@redhat.com>
References: <20180821104418.12710-1-david@redhat.com>
	 <20180821104418.12710-4-david@redhat.com>
	 <70372ef5-e332-6c07-f08c-50f8808bde6d@gmail.com>
	 <5f80ca56-9f34-4e6e-bc83-8f8b3c888163@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J.
 Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Michael Neuling <mikey@neuling.org>, Balbir Singh <bsingharora@gmail.com>, Kate Stewart <kstewart@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>

On Mon, 2018-09-17 at 09:32 +0200, David Hildenbrand wrote:
> Am 03.09.18 um 02:36 schrieb Rashmica:
> > Hi David,
> > 
> > 
> > On 21/08/18 20:44, David Hildenbrand wrote:
> > 
> > > There seem to be some problems as result of 30467e0b3be ("mm,
> > > hotplug:
> > > fix concurrent memory hot-add deadlock"), which tried to fix a
> > > possible
> > > lock inversion reported and discussed in [1] due to the two locks
> > > 	a) device_lock()
> > > 	b) mem_hotplug_lock
> > > 
> > > While add_memory() first takes b), followed by a) during
> > > bus_probe_device(), onlining of memory from user space first took
> > > b),
> > > followed by a), exposing a possible deadlock.
> > 
> > Do you mean "onlining of memory from user space first took a),
> > followed by b)"? 
> 
> Very right, thanks.
> 
> > 
> > > In [1], and it was decided to not make use of
> > > device_hotplug_lock, but
> > > rather to enforce a locking order.
> > > 
> > > The problems I spotted related to this:
> > > 
> > > 1. Memory block device attributes: While .state first calls
> > >    mem_hotplug_begin() and the calls device_online() - which
> > > takes
> > >    device_lock() - .online does no longer call
> > > mem_hotplug_begin(), so
> > >    effectively calls online_pages() without mem_hotplug_lock.
> > > 
> > > 2. device_online() should be called under device_hotplug_lock,
> > > however
> > >    onlining memory during add_memory() does not take care of
> > > that.
> > > 
> > > In addition, I think there is also something wrong about the
> > > locking in
> > > 
> > > 3. arch/powerpc/platforms/powernv/memtrace.c calls
> > > offline_pages()
> > >    without locks. This was introduced after 30467e0b3be. And
> > > skimming over
> > >    the code, I assume it could need some more care in regards to
> > > locking
> > >    (e.g. device_online() called without device_hotplug_lock - but
> > > I'll
> > >    not touch that for now).
> > 
> > Can you mention that you fixed this in later patches?
> 
> Sure!
> 
> > 
> > 
> > The series looks good to me. Feel free to add my reviewed-by:
> > 
> > Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
> > 
> 
> Thanks, r-b only for this patch or all of the series?

Sorry, I somehow missed this. To all of the series.
> 
