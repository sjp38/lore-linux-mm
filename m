Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D9F456B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 02:17:40 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h129-v6so4403702lfg.14
        for <linux-mm@kvack.org>; Tue, 01 May 2018 23:17:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q10-v6sor2340142lje.92.2018.05.01.23.17.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 May 2018 23:17:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180405202651.GB3666@bombadil.infradead.org>
References: <20180405162225.GA23411@jordon-HP-15-Notebook-PC>
 <20180405125322.2ef3abfc6159a72725095bd0@linux-foundation.org> <20180405202651.GB3666@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 2 May 2018 11:47:37 +0530
Message-ID: <CAFqt6zZzxvvm_mHroigBBQgrfCgjzPsH92LCR2Yy1foKft_=0w@mail.gmail.com>
Subject: Re: [PATCH] include: mm: Adding new inline function vmf_error
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>

Hi Andrew,

Any further comment on this patch ?
Around 10 drivers/file systems changes (vm_fault_t type changes)
depend on this patch.

On Fri, Apr 6, 2018 at 1:56 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Thu, Apr 05, 2018 at 12:53:22PM -0700, Andrew Morton wrote:
>> > +static inline vm_fault_t vmf_error(int err)
>> > +{
>> > +   vm_fault_t ret;
>> > +
>> > +   if (err == -ENOMEM)
>> > +           ret = VM_FAULT_OOM;
>> > +   else
>> > +           ret = VM_FAULT_SIGBUS;
>> > +
>> > +   return ret;
>> > +}
>> > +
>>
>> That's a bit verbose.  Why not simply
>>
>>       return (err == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
>
> That's a little skimpy for my taste (although Souptick's is more verbose
> than I like too) ... I suggested this:
>
>> > @@ -8983,9 +8984,9 @@ int btrfs_page_mkwrite(struct vm_fault *vmf)
>> >     }
>> >     if (ret) {
>> >             if (ret == -ENOMEM)
>> > -                   ret = VM_FAULT_OOM;
>> > +                   retval = VM_FAULT_OOM;
>> >             else /* -ENOSPC, -EIO, etc */
>> > -                   ret = VM_FAULT_SIGBUS;
>> > +                   retval = VM_FAULT_SIGBUS;
>> >             if (reserved)
>> >                     goto out;
>> >             goto out_noreserve;
>>
>> I'm seeing this pattern _a lot_ in filesystems.  It gets written in a
>> few different ways, but
>>
>>       ret = (err == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
>>
>> is really common.  I think we should do a helper function as part of
>> these cleanups ... maybe:
>>
>> static inline vm_fault_t vmf_error(int errno)
>> {
>>       if (err == -ENOMEM)
>>               return VM_FAULT_OOM;
>>       return VM_FAULT_SIGBUS;
>> }
>>
>> -             if (ret == -ENOMEM)
>> -                     ret = VM_FAULT_OOM;
>> -             else /* -ENOSPC, -EIO, etc */
>> -                     ret = VM_FAULT_SIGBUS;
>> +             ret = vmf_error(err);
>>
>> I know we've mostly been deleting these errno-to-vm_fault converters,
>> but those try to do too much -- they handle an errno of 0 (when there
>> are at least three ways to return success -- 0, NOPAGE and LOCKED),
>> and often they've encoded some other VM_FAULT code in a different
>> errno, eg the way block_page_mkwrite() uses -EFAULT.
>>
>> There are a few other error codes to handle under special conditions,
>> but the caller can handle them first.  eg I see block_page_mkwrite()
>> eventually looking like this:
>>
>>       err = __block_write_begin(page, 0, end, get_block);
>>       if (!err)
>>               err = block_commit_write(page, 0, end);
>>
>>       if (unlikely(err < 0))
>>               goto error;
>>       set_page_dirty(page);
>>       wait_for_stable_page(page);
>>       return 0;
>> error:
>>       if (err == -EAGAIN)
>>               ret = VM_FAULT_NOPAGE;
>>       else
>>               ret = vmf_error(err);
>> out_unlock:
>>       unlock_page(page);
>>       return ret;
>
