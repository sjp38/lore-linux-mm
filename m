Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8D2A6B0038
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 22:40:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g74so53287135ioi.4
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 19:40:26 -0700 (PDT)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id g72si13994136itb.122.2017.04.30.19.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 19:40:26 -0700 (PDT)
Received: by mail-io0-x22c.google.com with SMTP id r16so104650827ioi.2
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 19:40:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170501015403.GA16181@redhat.com>
References: <1743017574.4309811.1493400875692.JavaMail.zimbra@redhat.com>
 <CAPcyv4jCfMwthPwbE-iuvef1KkMYUtA=qAydgfJzH0_otXoAOg@mail.gmail.com>
 <1579714997.4315035.1493402406629.JavaMail.zimbra@redhat.com>
 <CAPcyv4hvBKG8t3e3QvUnmkaopeM8eTniz5JPVkrZ5Puu5eaViw@mail.gmail.com>
 <1295710462.4327805.1493406971970.JavaMail.zimbra@redhat.com>
 <CAPcyv4i+iPm=hBviOYABaroz_JJYVy8Qja8Ka=-_uAQNnGjpeg@mail.gmail.com>
 <20170428193305.GA3912@redhat.com> <20170429101726.cdczojcjjupb7myy@node.shutemov.name>
 <20170430231421.GA15163@redhat.com> <CAA9_cmekmRk3+MN0dTJap=dLgb+uLm9WEFEP+KDvg5uHbmhvCg@mail.gmail.com>
 <20170501015403.GA16181@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 30 Apr 2017 19:40:25 -0700
Message-ID: <CAPcyv4hnDDeAZDEH_8=1xZY99pTW+wh8V714jLEg5J-s2NW6rw@mail.gmail.com>
Subject: Re: [PATCH v2] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Sun, Apr 30, 2017 at 6:54 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Sun, Apr 30, 2017 at 06:42:02PM -0700, Dan Williams wrote:
>> On Sun, Apr 30, 2017 at 4:14 PM, Jerome Glisse <jglisse@redhat.com> wrote:
>> > On Sat, Apr 29, 2017 at 01:17:26PM +0300, Kirill A. Shutemov wrote:
>> >> On Fri, Apr 28, 2017 at 03:33:07PM -0400, Jerome Glisse wrote:
>> >> > On Fri, Apr 28, 2017 at 12:22:24PM -0700, Dan Williams wrote:
>> >> > > Are you sure about needing to hook the 2 -> 1 transition? Could we
>> >> > > change ZONE_DEVICE pages to not have an elevated reference count when
>> >> > > they are created so you can keep the HMM references out of the mm hot
>> >> > > path?
>> >> >
>> >> > 100% sure on that :) I need to callback into driver for 2->1 transition
>> >> > no way around that. If we change ZONE_DEVICE to not have an elevated
>> >> > reference count that you need to make a lot more change to mm so that
>> >> > ZONE_DEVICE is never use as fallback for memory allocation. Also need
>> >> > to make change to be sure that ZONE_DEVICE page never endup in one of
>> >> > the path that try to put them back on lru. There is a lot of place that
>> >> > would need to be updated and it would be highly intrusive and add a
>> >> > lot of special cases to other hot code path.
>> >>
>> >> Could you explain more on where the requirement comes from or point me to
>> >> where I can read about this.
>> >>
>> >
>> > HMM ZONE_DEVICE pages are use like other pages (anonymous or file back page)
>> > in _any_ vma. So i need to know when a page is freed ie either as result of
>> > unmap, exit or migration or anything that would free the memory. For zone
>> > device a page is free once its refcount reach 1 so i need to catch refcount
>> > transition from 2->1
>> >
>> > This is the only way i can inform the device that the page is now free. See
>> >
>> > https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v21&id=52da8fe1a088b87b5321319add79e43b8372ed7d
>> >
>> > There is _no_ way around that.
>>
>> Ok, but I need to point out that this not a ZONE_DEVICE requirement.
>> This is an HMM-specific need. So, this extra reference counting should
>> be clearly delineated as part of the MEMORY_DEVICE_PRIVATE use case.
>
> And it already is delimited, i think you even gave your review by on
> the patch.
>

I gave my reviewed-by to the patch that leveraged
{get,put}_zone_device_page(), but now those are gone and HMM needs a
new patch. I'm just saying these reference counts should not come back
as {get,put}_zone_device_page() because now they're HMM specific.

>> Can we hide the extra reference counting behind a static branch so
>> that the common case fast path doesn't get slower until a HMM device
>> shows up?
>
> Like i already did With likely()/unlikely() ? Or something else ?
>
> https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v21&id=e84778e9db0672e371eb6599dfcb812512118842

Something different:
http://lxr.free-electrons.com/source/Documentation/static-keys.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
