Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0946B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 12:41:19 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b184so2387166oii.1
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 09:41:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v126sor445029oie.152.2017.09.28.09.41.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 09:41:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x49poaaaimr.fsf@segfault.boston.devel.redhat.com>
References: <150655617774.700.5326522538400299973.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150655619012.700.15161500295945223238.stgit@dwillia2-desk3.amr.corp.intel.com>
 <x49poaaaimr.fsf@segfault.boston.devel.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 28 Sep 2017 09:41:17 -0700
Message-ID: <CAPcyv4hn=N=j57JNiidWhgwMh_zBWjfrZCKqf2xg2oDNjk-rTw@mail.gmail.com>
Subject: Re: [PATCH 2/3] dax: stop using VM_MIXEDMAP for dax
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Thu, Sep 28, 2017 at 9:32 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Dan Williams <dan.j.williams@intel.com> writes:
>
>> Now that we always have pages for DAX we can stop setting VM_MIXEDMAP.
>> This does require some small fixups for the pte insert routines that dax
>> utilizes.
>
> It used to be that userspace would look to see if it had a 'mm' entry in
> /proc/pid/smaps to determine whether or not it got a direct mapping.
> Later, that same userspace (nvml) just uniformly declared dax not
> available from any Linux file system, since msync was required.  And, I
> guess DAX has always been marked experimental, so the interface can be
> changed.
>
> All this is to say I guess it's fine to change this.

Yes, it was always broken / dangerous to look for 'mm' as a pseudo-dax flag.

>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 680506faceae..d682f60670ff 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -1111,7 +1111,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>>        * We later require that vma->vm_flags == vm_flags,
>>        * so this tests vma->vm_flags & VM_SPECIAL, too.
>>        */
>> -     if (vm_flags & VM_SPECIAL)
>> +     if ((vm_flags & VM_SPECIAL))
>>               return NULL;
>
> That looks superfluous.

Whoops, yeah. That was a case where I converted it to add a
vma_is_dax() check and then decided we don't need that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
