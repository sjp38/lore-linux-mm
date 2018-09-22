Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34EDF8E0001
	for <linux-mm@kvack.org>; Sat, 22 Sep 2018 09:39:49 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p52-v6so619026qtf.9
        for <linux-mm@kvack.org>; Sat, 22 Sep 2018 06:39:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o11-v6sor4195869qkg.16.2018.09.22.06.39.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 22 Sep 2018 06:39:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFqt6zYtptZNeXbJwcJemb5O8rKjcB9=FpfiH60wK9v6vd0A2A@mail.gmail.com>
References: <20180920202316.GA6038@jordon-HP-15-Notebook-PC>
 <CANiq72kQA45ekbSruh-zTsc9B-9EOxZna=cOgOcM7--owxrWsA@mail.gmail.com> <CAFqt6zYtptZNeXbJwcJemb5O8rKjcB9=FpfiH60wK9v6vd0A2A@mail.gmail.com>
From: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Date: Sat, 22 Sep 2018 15:39:26 +0200
Message-ID: <CANiq72=rtoq6269pn0KgznAkoqhF+UmRB2kd9K2vVmFt=SwiZg@mail.gmail.com>
Subject: Re: [PATCH] auxdisplay/cfag12864bfb.c: Replace vm_insert_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Sep 21, 2018 at 1:07 PM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> On Fri, Sep 21, 2018 at 2:56 AM Miguel Ojeda
> <miguel.ojeda.sandonis@gmail.com> wrote:
>>
>> A link to the discussion/plan would be nice. The commit 1c8f422059ae5
>> ("mm: change return type to vm_fault_t") explains a bit, but has a
>> broken link :( Googling for the stuff returns many of the patches, but
>> not the actual discussion...
>
> This might be helpful.
> https://marc.info/?l=linux-mm&m=152054772413234&w=4

Thank you, although that does not explain why the changes are
happening, only that you are introducing the new API so that you can
start converting users (which is the normal way of doing it, no?).
What I meant is the discussion that led to commit 1c8f422059ae5 itself
(which has a link inside, but is broken).

>> I am out of the loop on these mm changes, so please indulge me, but:
>>
>>   * Why is there no documentation on vmf_insert_page() while
>> vm_insert_page() had it? (specially since it seems you want to remove
>> vm_insert_page()).
>
> The plan is to convert vm_insert_{page,pfn,mixed} to
> vmf_insert_{page,pfn,mixed}. As a good intermediate
> steps inline wrapper vmf_insert_{pfn,page,mixed} are
> introduced. After all the drivers converted, we will convert
> vm_insert_page to vmf_insert_page and remove the inline
> wrapper and update the document at the same time.

Yeah, that is what 1c8f422059ae5 ("mm: change return type to
vm_fault_t") seems to say at the end (thanks for clarifying).

Still, that does not explain why the documentation was not added at
the same time as soon the new API is introduced. I don't see how it
matters that they are wrappers.

Actually, I think the wrappers should have been the final functions
already in memory.c, their declarations in mm.h, etc. That way you
would minimize the code changes later on: you would be only removing
dead code, rather than changing code again. Even if you forward the
calls for the moment, it would have been a much smaller change later
on.

>
>>
>>   * Shouldn't we have a simple remap_page() or remap_kernel_page() to
>> fit this use case and avoid that dance? (another driver in auxdisplay
>> will require the same change, and I guess others in the kernel as
>> well).
>
>
> There are few drivers similar like auxdisplay where straight forward
> conversion from vm_insert_page to vmf_insert_page is not possible.
>
> So I mapped the kernel memory to user vma using remap_pfn_range
> and remove vm_insert_page in this driver.
>
> Other way, is to replace vm_insert_page with vmf_insert_page() and
> then convert VM_FAULT_CODE back to errno. But as part of vm_fault_t
> migration we have already removed/cleanup most the errno to VM_FAULT_CODE
> mapping from drivers. So I prefer not to take this option.
>
> Third, we can introduce a similar API like vm_insert_page say,
> vm_insert_kmem_page() and use it for same scenarios like this.

Yep, I think that is the best, unless there are only a couple of users
and you think nobody should be using it in the future.

Cheers,
Miguel
