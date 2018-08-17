Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBD546B07A3
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 06:06:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q21-v6so3431944pff.21
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 03:06:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j193-v6si1619695pge.617.2018.08.17.03.06.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 03:06:07 -0700 (PDT)
Date: Fri, 17 Aug 2018 12:06:04 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH RFC 1/2] drivers/base: export
 lock_device_hotplug/unlock_device_hotplug
Message-ID: <20180817100604.GA18164@kroah.com>
References: <20180817075901.4608-1-david@redhat.com>
 <20180817075901.4608-2-david@redhat.com>
 <20180817084146.GB14725@kroah.com>
 <5a5d73e9-e4aa-ffed-a2e3-8aef64e61923@redhat.com>
 <CAJZ5v0gkYV8o2Eq+EcGT=OP1tQGPGVVe3n9VGD6z7KAVVqhv9w@mail.gmail.com>
 <42df9062-f647-3ad6-5a07-be2b99531119@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42df9062-f647-3ad6-5a07-be2b99531119@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, linux-s390@vger.kernel.org, sthemmin@microsoft.com, Pavel Tatashin <pasha.tatashin@oracle.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, Len Brown <lenb@kernel.org>, haiyangz@microsoft.com, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, osalvador@suse.de, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, devel@linuxdriverproject.org, Vitaly Kuznetsov <vkuznets@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Fri, Aug 17, 2018 at 11:41:24AM +0200, David Hildenbrand wrote:
> On 17.08.2018 11:03, Rafael J. Wysocki wrote:
> > On Fri, Aug 17, 2018 at 10:56 AM David Hildenbrand <david@redhat.com> wrote:
> >>
> >> On 17.08.2018 10:41, Greg Kroah-Hartman wrote:
> >>> On Fri, Aug 17, 2018 at 09:59:00AM +0200, David Hildenbrand wrote:
> >>>> From: Vitaly Kuznetsov <vkuznets@redhat.com>
> >>>>
> >>>> Well require to call add_memory()/add_memory_resource() with
> >>>> device_hotplug_lock held, to avoid a lock inversion. Allow external modules
> >>>> (e.g. hv_balloon) that make use of add_memory()/add_memory_resource() to
> >>>> lock device hotplug.
> >>>>
> >>>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> >>>> [modify patch description]
> >>>> Signed-off-by: David Hildenbrand <david@redhat.com>
> >>>> ---
> >>>>  drivers/base/core.c | 2 ++
> >>>>  1 file changed, 2 insertions(+)
> >>>>
> >>>> diff --git a/drivers/base/core.c b/drivers/base/core.c
> >>>> index 04bbcd779e11..9010b9e942b5 100644
> >>>> --- a/drivers/base/core.c
> >>>> +++ b/drivers/base/core.c
> >>>> @@ -700,11 +700,13 @@ void lock_device_hotplug(void)
> >>>>  {
> >>>>      mutex_lock(&device_hotplug_lock);
> >>>>  }
> >>>> +EXPORT_SYMBOL_GPL(lock_device_hotplug);
> >>>>
> >>>>  void unlock_device_hotplug(void)
> >>>>  {
> >>>>      mutex_unlock(&device_hotplug_lock);
> >>>>  }
> >>>> +EXPORT_SYMBOL_GPL(unlock_device_hotplug);
> >>>
> >>> If these are going to be "global" symbols, let's properly name them.
> >>> device_hotplug_lock/unlock would be better.  But I am _really_ nervous
> >>> about letting stuff outside of the driver core mess with this, as people
> >>> better know what they are doing.
> >>
> >> The only "problem" is that we have kernel modules (for paravirtualized
> >> devices) that call add_memory(). This is Hyper-V right now, but we might
> >> have other ones in the future. Without them we would not have to export
> >> it. We might also get kernel modules that want to call remove_memory() -
> >> which will require the device_hotplug_lock as of now.
> >>
> >> What we could do is
> >>
> >> a) add_memory() -> _add_memory() and don't export it
> >> b) add_memory() takes the device_hotplug_lock and calls _add_memory() .
> >> We export that one.
> >> c) Use add_memory() in external modules only
> >>
> >> Similar wrapper would be needed e.g. for remove_memory() later on.
> > 
> > That would be safer IMO, as it would prevent developers from using
> > add_memory() without the lock, say.
> > 
> > If the lock is always going to be required for add_memory(), make it
> > hard (or event impossible) to use the latter without it.
> > 
> 
> If there are no objections, I'll go into that direction. But I'll wait
> for more comments regarding the general concept first.

It is the middle of the merge window, and maintainers are really busy
right now.  I doubt you will get many review comments just yet...
