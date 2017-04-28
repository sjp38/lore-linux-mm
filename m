Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A385B6B02F3
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 15:22:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id o22so35509802iod.6
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 12:22:26 -0700 (PDT)
Received: from mail-it0-x22e.google.com (mail-it0-x22e.google.com. [2607:f8b0:4001:c0b::22e])
        by mx.google.com with ESMTPS id h2si7910286iti.64.2017.04.28.12.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 12:22:25 -0700 (PDT)
Received: by mail-it0-x22e.google.com with SMTP id 70so47659792ita.0
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 12:22:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1295710462.4327805.1493406971970.JavaMail.zimbra@redhat.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com> <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
 <1743017574.4309811.1493400875692.JavaMail.zimbra@redhat.com>
 <CAPcyv4jCfMwthPwbE-iuvef1KkMYUtA=qAydgfJzH0_otXoAOg@mail.gmail.com>
 <1579714997.4315035.1493402406629.JavaMail.zimbra@redhat.com>
 <CAPcyv4hvBKG8t3e3QvUnmkaopeM8eTniz5JPVkrZ5Puu5eaViw@mail.gmail.com> <1295710462.4327805.1493406971970.JavaMail.zimbra@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Apr 2017 12:22:24 -0700
Message-ID: <CAPcyv4i+iPm=hBviOYABaroz_JJYVy8Qja8Ka=-_uAQNnGjpeg@mail.gmail.com>
Subject: Re: [PATCH v2] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Fri, Apr 28, 2017 at 12:16 PM, Jerome Glisse <jglisse@redhat.com> wrote:
>> On Fri, Apr 28, 2017 at 11:00 AM, Jerome Glisse <jglisse@redhat.com> wrote:
>> >> On Fri, Apr 28, 2017 at 10:34 AM, Jerome Glisse <jglisse@redhat.com>
>> >> wrote:
>> >> >> Kirill points out that the calls to {get,put}_dev_pagemap() can be
>> >> >> removed from the mm fast path if we take a single get_dev_pagemap()
>> >> >> reference to signify that the page is alive and use the final put of
>> >> >> the
>> >> >> page to drop that reference.
>> >> >>
>> >> >> This does require some care to make sure that any waits for the
>> >> >> percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
>> >> >> since it now maintains its own elevated reference.
>> >> >
>> >> > This is NAK from HMM point of view as i need those call. So if you
>> >> > remove
>> >> > them now i will need to add them back as part of HMM.
>> >>
>> >> I thought you only need them at page free time? You can still hook
>> >> __put_page().
>> >
>> > No, i need a hook when page refcount reach 1, not 0. That being said
>> > i don't care about put_dev_pagemap(page->pgmap); so that part of the
>> > patch is fine from HMM point of view but i definitly need to hook my-
>> > self in the general put_page() function.
>> >
>> > So i will have to undo part of this patch for HMM (put_page() will
>> > need to handle ZONE_DEVICE page differently).
>>
>> Ok, I'd rather this go in now since it fixes the existing use case,
>> and unblocks the get_user_pages_fast() conversion to generic code.
>> That also gives Kirill and -mm folks a chance to review what HMM wants
>> to do on top of the page_ref infrastructure.  The
>> {get,put}_zone_device_page interface went in in 4.5 right before
>> page_ref went in during 4.6, so it was just an oversight that
>> {get,put}_zone_device_page were not removed earlier.
>>
>
> I don't mind this going in, i am hopping people won't ignore HMM patchset
> once i repost after 4.12 merge window. Note that there is absolutely no way
> around me hooking up inside put_page(). The only other way to do it would
> be to modify virtualy all places that call that function to handle ZONE_DEVICE
> case.

Are you sure about needing to hook the 2 -> 1 transition? Could we
change ZONE_DEVICE pages to not have an elevated reference count when
they are created so you can keep the HMM references out of the mm hot
path?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
