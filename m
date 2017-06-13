Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0D3B6B02C3
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 22:54:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b9so64495193pfl.0
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 19:54:04 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p25si345698pge.487.2017.06.12.19.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 19:54:03 -0700 (PDT)
Message-ID: <593F5452.2090109@intel.com>
Date: Tue, 13 Jun 2017 10:56:18 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com> <1497004901-30593-5-git-send-email-wei.w.wang@intel.com> <b92af473-f00e-b956-ea97-eb4626601789@intel.com> <20170612181354-mutt-send-email-mst@kernel.org> <9d0900f3-9df5-ac63-4069-2d796f2a5bc7@intel.com> <20170612194438-mutt-send-email-mst@kernel.org> <d0811862-6633-a43c-90a5-629fe9b6d150@intel.com>
In-Reply-To: <d0811862-6633-a43c-90a5-629fe9b6d150@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 06/13/2017 04:54 AM, Dave Hansen wrote:
> On 06/12/2017 01:34 PM, Michael S. Tsirkin wrote:
>> On Mon, Jun 12, 2017 at 09:42:36AM -0700, Dave Hansen wrote:
>>> On 06/12/2017 09:28 AM, Michael S. Tsirkin wrote:
>>>>> The hypervisor is going to throw away the contents of these pages,
>>>>> right?
>>>> It should be careful and only throw away contents that was there before
>>>> report_unused_page_block was invoked.  Hypervisor is responsible for not
>>>> corrupting guest memory.  But that's not something an mm patch should
>>>> worry about.
>>> That makes sense.  I'm struggling to imagine how the hypervisor makes
>>> use of this information, though.  Does it make the pages read-only
>>> before this, and then it knows if there has not been a write *and* it
>>> gets notified via this new mechanism that it can throw the page away?
>> Yes, and specifically, this is how it works for migration.  Normally you
>> start by migrating all of memory, then send updates incrementally if
>> pages have been modified.  This mechanism allows skipping some pages in
>> the 1st stage, if they get changed they will be migrated in the 2nd
>> stage.
> OK, so the migration starts and marks everything read-only.  All the
> pages now have read-only valuable data, or read-only worthless data in
> the case that the page is in the free lists.  In order for a page to
> become non-worthless, it has to have a write done to it, which the
> hypervisor obviously knows about.
>
> With this mechanism, the hypervisor knows it can discard pages which
> have not had a write since they were known to have worthless contents.
>
> Correct?
Right. By the way, ready-only is one of the dirty page logging
methods that a hypervisor uses to capture the pages that are
written by the VM.

>
> That also seems like pretty good information to include in the
> changelog.  Otherwise, folks are going to be left wondering what good
> the mechanism is.  It's pretty non-trivial to figure out. :)
If necessary, I think it's better to keep the introduction at high-level:

Examples of using this API by a hypervisor:
To live migrate a VM from one physical machine to another,
the hypervisor usually transfers all the VM's memory content.
An optimization here is to skip the transfer of memory that are not
in use by the VM, because the content of the unused memory is
worthless.
This API is the used to report the unused pages to the hypervisor.
The pages that have been reported to the hypervisor as unused
pages may be used by the VM after the report. The hypervisor
has a good mechanism (i.e. dirty page logging) to capture
the change. Therefore, if the new used pages are written into some
data, the hypervisor will still transfer them to the destination machine.

What do you guys think?

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
