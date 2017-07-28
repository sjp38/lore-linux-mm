Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 520C86B055D
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 11:16:13 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id h36so162640958uad.12
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 08:16:13 -0700 (PDT)
Received: from mail-ua0-x22f.google.com (mail-ua0-x22f.google.com. [2607:f8b0:400c:c08::22f])
        by mx.google.com with ESMTPS id x40si2741014uax.347.2017.07.28.08.16.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 08:16:12 -0700 (PDT)
Received: by mail-ua0-x22f.google.com with SMTP id q25so147075848uah.1
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 08:16:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0a7cd2a8-45ff-11d1-ddb5-036ce36af163@redhat.com>
References: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com> <0a7cd2a8-45ff-11d1-ddb5-036ce36af163@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Jul 2017 08:16:11 -0700
Message-ID: <CAPcyv4iYdEAv7wqun5L1C-gT7fMDpO+M918or-bg5XiWLnM3=w@mail.gmail.com>
Subject: Re: [RFC] virtio-mem: paravirtualized memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: KVM <kvm@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@redhat.com>

On Fri, Jul 28, 2017 at 4:09 AM, David Hildenbrand <david@redhat.com> wrote:
> Btw, I am thinking about the following addition to the concept:
>
> 1. Add a type to each virtio-mem device.
>
> This describes the type of the memory region we expose to the guest.
> Initially, we could have RAM and RAM_HUGE. The latter one would be
> interesting, because the guest would know that this memory is based on
> huge pages in case we would ever want to expose different RAM types to a
> guest (the guest could conclude that this memory might be faster and
> would also best be used with huge pages in the guest). But we could also
> simply start only with RAM.

I think it's up to the hypervisor to manage whether the guest is
getting huge pages or not and the guest need not know. As for
communicating differentiated memory media performance we have the ACPI
HMAT (Heterogeneous Memory Attributes Table) for that.

> 2. Adding also a guest -> host command queue.
>
> That can be used to request/notify the host about something. As written
> in the original proposal, for ordinary RAM this could be used to request
> more/less memory out of the guest.

I would hope that where possible we minimize paravirtualized
interfaces and just use standardized interfaces. In the case of memory
hotplug, ACPI already defines that interface.

> This might come in handy for other memory regions we just want to expose
> to the guest via a paravirtualized interface. The resize features
> (adding/removing memory) might not apply to these, but we can simply
> restrict that to certain types.
>
> E.g. if we want to expose PMEM memory region to a guest using a
> paravirtualized interface (or anything else that can be mapped into
> guest memory in the form of memory regions), we could use this. The
> guest->host control queue can be used for tasks that typically cannot be
> done if moddeling something like this using ordinary ACPI DIMMs
> (flushing etc).
>
> CCing a couple of people that just thought about something like this in
> the concept of fake DAX.

I'm not convinced that there is a use case for paravirtualized PMEM
commands beyond this "fake-DAX" use case. Everything would seem to
have a path through the standard ACPI platform communication
mechanisms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
