Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36F9A8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 14:33:33 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id i12so33895166ita.3
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 11:33:33 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x65si3204389itf.28.2019.01.02.11.33.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 11:33:31 -0800 (PST)
Subject: Re: [PATCH v5 8/9] xen/gntdev.c: Convert to use vm_insert_range
References: <20181224132751.GA22184@jordon-HP-15-Notebook-PC>
 <CAFqt6za2_BOZaynNV2iVkLCjadzyR_bOJog=R6j43dDCDwgFzw@mail.gmail.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <39041074-01d6-e28e-93e1-4c5d708c2157@oracle.com>
Date: Wed, 2 Jan 2019 14:32:54 -0500
MIME-Version: 1.0
In-Reply-To: <CAFqt6za2_BOZaynNV2iVkLCjadzyR_bOJog=R6j43dDCDwgFzw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Juergen Gross <jgross@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On 1/2/19 1:58 PM, Souptick Joarder wrote:
> On Mon, Dec 24, 2018 at 6:53 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>> Convert to use vm_insert_range() to map range of kernel
>> memory to user vma.
>>
>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>> Reviewed-by: Matthew Wilcox <willy@infradead.org>
>> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
>> ---
>>  drivers/xen/gntdev.c | 11 ++++-------
>>  1 file changed, 4 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
>> index b0b02a5..430d4cb 100644
>> --- a/drivers/xen/gntdev.c
>> +++ b/drivers/xen/gntdev.c
>> @@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>>         int index = vma->vm_pgoff;
>>         int count = vma_pages(vma);
>>         struct gntdev_grant_map *map;
>> -       int i, err = -EINVAL;
>> +       int err = -EINVAL;
>>
>>         if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
>>                 return -EINVAL;
>> @@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>>                 goto out_put_map;
>>
>>         if (!use_ptemod) {
>> -               for (i = 0; i < count; i++) {
>> -                       err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
>> -                               map->pages[i]);
>> -                       if (err)
>> -                               goto out_put_map;
>> -               }
> Looking into the original code, the loop should run from i =0 to *i <
> map->count*.
> There is no error check for *count > map->count* and we might end up
> overrun the map->pages[i] boundary.

I don't think we can have map->count != count (see
gntdev_find_map_index()). But for clarity I agree using map->count might
be better.


>
> While converting this code with suggested vm_insert_range(), this can be fixed.

And count can be dropped altogether.


Thanks.
-boris


>
>
>> +               err = vm_insert_range(vma, vma->vm_start, map->pages, count);
>> +               if (err)
>> +                       goto out_put_map;
>>         } else {
>>  #ifdef CONFIG_X86
>>                 /*
>> --
>> 1.9.1
>>
