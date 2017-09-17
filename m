Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6983B6B0038
	for <linux-mm@kvack.org>; Sat, 16 Sep 2017 23:44:16 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q7so11789819ioi.3
        for <linux-mm@kvack.org>; Sat, 16 Sep 2017 20:44:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d22sor1675111ioj.81.2017.09.16.20.44.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Sep 2017 20:44:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170815122701.GF27505@quack2.suse.cz>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150277753660.23945.11500026891611444016.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170815122701.GF27505@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 16 Sep 2017 20:44:14 -0700
Message-ID: <CAA9_cmc0vejxCsc1NWp5b4C0CSsO5xetF3t6LCoCuEYB6yPiwQ@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] mm: introduce MAP_VALIDATE a mechanism for adding
 new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Tue, Aug 15, 2017 at 5:27 AM, Jan Kara <jack@suse.cz> wrote:
> On Mon 14-08-17 23:12:16, Dan Williams wrote:
>> The mmap syscall suffers from the ABI anti-pattern of not validating
>> unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
>> mechanism to define new behavior that is known to fail on older kernels
>> without the feature. Use the fact that specifying MAP_SHARED and
>> MAP_PRIVATE at the same time is invalid as a cute hack to allow a new
>> set of validated flags to be introduced.
>>
>> This also introduces the ->fmmap() file operation that is ->mmap() plus
>> flags. Each ->fmmap() implementation must fail requests when a locally
>> unsupported flag is specified.
> ...
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 1104e5df39ef..bbe755d0caee 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -1674,6 +1674,7 @@ struct file_operations {
>>       long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
>>       long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
>>       int (*mmap) (struct file *, struct vm_area_struct *);
>> +     int (*fmmap) (struct file *, struct vm_area_struct *, unsigned long);
>>       int (*open) (struct inode *, struct file *);
>>       int (*flush) (struct file *, fl_owner_t id);
>>       int (*release) (struct inode *, struct file *);
>> @@ -1748,6 +1749,12 @@ static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
>>       return file->f_op->mmap(file, vma);
>>  }
>>
>> +static inline int call_fmmap(struct file *file, struct vm_area_struct *vma,
>> +             unsigned long flags)
>> +{
>> +     return file->f_op->fmmap(file, vma, flags);
>> +}
>> +
>
> Hum, I dislike a new file op for this when the only problem with ->mmap is
> that it misses 'flags' argument. I understand there are lots of ->mmap
> implementations out there and modifying prototype of them all is painful
> but is it so bad? Coccinelle patch for this should be rather easy...

So it wasn't all that easy, and Linus declined to take it. I think we
should add a new ->mmap_validate() file operation and save the
tree-wide cleanup until later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
