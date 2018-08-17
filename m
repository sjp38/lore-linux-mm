Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C691A6B0770
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 05:03:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w185-v6so6595298oig.19
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 02:03:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16-v6sor861278oij.170.2018.08.17.02.03.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Aug 2018 02:03:21 -0700 (PDT)
MIME-Version: 1.0
References: <20180817075901.4608-1-david@redhat.com> <20180817075901.4608-2-david@redhat.com>
 <20180817084146.GB14725@kroah.com> <5a5d73e9-e4aa-ffed-a2e3-8aef64e61923@redhat.com>
In-Reply-To: <5a5d73e9-e4aa-ffed-a2e3-8aef64e61923@redhat.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Fri, 17 Aug 2018 11:03:09 +0200
Message-ID: <CAJZ5v0gkYV8o2Eq+EcGT=OP1tQGPGVVe3n9VGD6z7KAVVqhv9w@mail.gmail.com>
Subject: Re: [PATCH RFC 1/2] drivers/base: export lock_device_hotplug/unlock_device_hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, devel@linuxdriverproject.org, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, osalvador@suse.de, Vitaly Kuznetsov <vkuznets@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, David Rientjes <rientjes@google.com>

On Fri, Aug 17, 2018 at 10:56 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 17.08.2018 10:41, Greg Kroah-Hartman wrote:
> > On Fri, Aug 17, 2018 at 09:59:00AM +0200, David Hildenbrand wrote:
> >> From: Vitaly Kuznetsov <vkuznets@redhat.com>
> >>
> >> Well require to call add_memory()/add_memory_resource() with
> >> device_hotplug_lock held, to avoid a lock inversion. Allow external modules
> >> (e.g. hv_balloon) that make use of add_memory()/add_memory_resource() to
> >> lock device hotplug.
> >>
> >> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> >> [modify patch description]
> >> Signed-off-by: David Hildenbrand <david@redhat.com>
> >> ---
> >>  drivers/base/core.c | 2 ++
> >>  1 file changed, 2 insertions(+)
> >>
> >> diff --git a/drivers/base/core.c b/drivers/base/core.c
> >> index 04bbcd779e11..9010b9e942b5 100644
> >> --- a/drivers/base/core.c
> >> +++ b/drivers/base/core.c
> >> @@ -700,11 +700,13 @@ void lock_device_hotplug(void)
> >>  {
> >>      mutex_lock(&device_hotplug_lock);
> >>  }
> >> +EXPORT_SYMBOL_GPL(lock_device_hotplug);
> >>
> >>  void unlock_device_hotplug(void)
> >>  {
> >>      mutex_unlock(&device_hotplug_lock);
> >>  }
> >> +EXPORT_SYMBOL_GPL(unlock_device_hotplug);
> >
> > If these are going to be "global" symbols, let's properly name them.
> > device_hotplug_lock/unlock would be better.  But I am _really_ nervous
> > about letting stuff outside of the driver core mess with this, as people
> > better know what they are doing.
>
> The only "problem" is that we have kernel modules (for paravirtualized
> devices) that call add_memory(). This is Hyper-V right now, but we might
> have other ones in the future. Without them we would not have to export
> it. We might also get kernel modules that want to call remove_memory() -
> which will require the device_hotplug_lock as of now.
>
> What we could do is
>
> a) add_memory() -> _add_memory() and don't export it
> b) add_memory() takes the device_hotplug_lock and calls _add_memory() .
> We export that one.
> c) Use add_memory() in external modules only
>
> Similar wrapper would be needed e.g. for remove_memory() later on.

That would be safer IMO, as it would prevent developers from using
add_memory() without the lock, say.

If the lock is always going to be required for add_memory(), make it
hard (or event impossible) to use the latter without it.
