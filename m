Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 954B56B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 20:54:53 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w10so2932546oie.1
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:54:53 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id f66si729356oia.381.2017.08.31.17.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 17:54:52 -0700 (PDT)
Received: by mail-oi0-x232.google.com with SMTP id n18so6980929oig.2
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:54:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170831100201.GC21443@lst.de>
References: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150413450036.5923.13851061508172314879.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170831100201.GC21443@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 31 Aug 2017 17:54:51 -0700
Message-ID: <CAPcyv4hEoLUjxv7jT8e_7hZYtkf6ZoT6qJiv2HP1simuFitXgg@mail.gmail.com>
Subject: Re: [PATCH 1/2] vfs: add flags parameter to ->mmap() in 'struct file_operations'
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, David Airlie <airlied@linux.ie>, Linux API <linux-api@vger.kernel.org>, Takashi Iwai <tiwai@suse.com>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Julia Lawall <julia.lawall@lip6.fr>, Andy Lutomirski <luto@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Thu, Aug 31, 2017 at 3:02 AM, Christoph Hellwig <hch@lst.de> wrote:
>> -static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma)
>> +static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma,
>> +                      unsigned long map_flags)
>>  {
>>       struct file *lower_file = ecryptfs_file_to_lower(file);
>>       /*
>> @@ -179,7 +180,7 @@ static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma)
>>        */
>>       if (!lower_file->f_op->mmap)
>>               return -ENODEV;
>> -     return generic_file_mmap(file, vma);
>> +     return generic_file_mmap(file, vma, 0);
>
> Shouldn't ecryptfs pass on the flags?  Same for coda_file_mmap and
> shm_mmap.

Yes, I'll get those fixed up.

>
>> -static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
>> +static inline int call_mmap(struct file *file, struct vm_area_struct *vma,
>> +                         unsigned long flags)
>>  {
>> -     return file->f_op->mmap(file, vma);
>> +     return file->f_op->mmap(file, vma, flags);
>>  }
>
> It would be great to kill this pointless wrapper while we're at it.

Will do.

Thanks for taking a look!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
