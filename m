Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6646B0311
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 15:33:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p187so15594871qkd.11
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 12:33:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c49si7262891qtd.145.2017.04.28.12.33.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 12:33:11 -0700 (PDT)
Date: Fri, 28 Apr 2017 15:33:07 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
Message-ID: <20170428193305.GA3912@redhat.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com>
 <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
 <1743017574.4309811.1493400875692.JavaMail.zimbra@redhat.com>
 <CAPcyv4jCfMwthPwbE-iuvef1KkMYUtA=qAydgfJzH0_otXoAOg@mail.gmail.com>
 <1579714997.4315035.1493402406629.JavaMail.zimbra@redhat.com>
 <CAPcyv4hvBKG8t3e3QvUnmkaopeM8eTniz5JPVkrZ5Puu5eaViw@mail.gmail.com>
 <1295710462.4327805.1493406971970.JavaMail.zimbra@redhat.com>
 <CAPcyv4i+iPm=hBviOYABaroz_JJYVy8Qja8Ka=-_uAQNnGjpeg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4i+iPm=hBviOYABaroz_JJYVy8Qja8Ka=-_uAQNnGjpeg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Fri, Apr 28, 2017 at 12:22:24PM -0700, Dan Williams wrote:
> On Fri, Apr 28, 2017 at 12:16 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> >> On Fri, Apr 28, 2017 at 11:00 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> >> >> On Fri, Apr 28, 2017 at 10:34 AM, Jerome Glisse <jglisse@redhat.com>
> >> >> wrote:
> >> >> >> Kirill points out that the calls to {get,put}_dev_pagemap() can be
> >> >> >> removed from the mm fast path if we take a single get_dev_pagemap()
> >> >> >> reference to signify that the page is alive and use the final put of
> >> >> >> the
> >> >> >> page to drop that reference.
> >> >> >>
> >> >> >> This does require some care to make sure that any waits for the
> >> >> >> percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
> >> >> >> since it now maintains its own elevated reference.
> >> >> >
> >> >> > This is NAK from HMM point of view as i need those call. So if you
> >> >> > remove
> >> >> > them now i will need to add them back as part of HMM.
> >> >>
> >> >> I thought you only need them at page free time? You can still hook
> >> >> __put_page().
> >> >
> >> > No, i need a hook when page refcount reach 1, not 0. That being said
> >> > i don't care about put_dev_pagemap(page->pgmap); so that part of the
> >> > patch is fine from HMM point of view but i definitly need to hook my-
> >> > self in the general put_page() function.
> >> >
> >> > So i will have to undo part of this patch for HMM (put_page() will
> >> > need to handle ZONE_DEVICE page differently).
> >>
> >> Ok, I'd rather this go in now since it fixes the existing use case,
> >> and unblocks the get_user_pages_fast() conversion to generic code.
> >> That also gives Kirill and -mm folks a chance to review what HMM wants
> >> to do on top of the page_ref infrastructure.  The
> >> {get,put}_zone_device_page interface went in in 4.5 right before
> >> page_ref went in during 4.6, so it was just an oversight that
> >> {get,put}_zone_device_page were not removed earlier.
> >>
> >
> > I don't mind this going in, i am hopping people won't ignore HMM patchset
> > once i repost after 4.12 merge window. Note that there is absolutely no way
> > around me hooking up inside put_page(). The only other way to do it would
> > be to modify virtualy all places that call that function to handle ZONE_DEVICE
> > case.
> 
> Are you sure about needing to hook the 2 -> 1 transition? Could we
> change ZONE_DEVICE pages to not have an elevated reference count when
> they are created so you can keep the HMM references out of the mm hot
> path?

100% sure on that :) I need to callback into driver for 2->1 transition
no way around that. If we change ZONE_DEVICE to not have an elevated
reference count that you need to make a lot more change to mm so that
ZONE_DEVICE is never use as fallback for memory allocation. Also need
to make change to be sure that ZONE_DEVICE page never endup in one of
the path that try to put them back on lru. There is a lot of place that
would need to be updated and it would be highly intrusive and add a
lot of special cases to other hot code path.

Maybe i over estimate the amount of work but from top of my head it is
far from being trivial.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
