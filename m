Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f53.google.com (mail-vn0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 270E96B006C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 18:15:58 -0400 (EDT)
Received: by vnbg129 with SMTP id g129so3018038vnb.9
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:15:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ci5si3340892vdb.76.2015.06.11.15.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 15:15:57 -0700 (PDT)
Message-ID: <557A089A.3090202@redhat.com>
Date: Thu, 11 Jun 2015 18:15:54 -0400
From: Prarit Bhargava <prarit@redhat.com>
MIME-Version: 1.0
Subject: Re: linux 4.1-rc7 deadlock
References: <5576D3E7.40302@fedoraproject.org> <5576F3DA.7000106@monom.org> <CAKSJeFLb523beVQHqWhCtaBOECfeYrwWdojb5M8wqQWMfwJ72A@mail.gmail.com> <alpine.LSU.2.11.1506111246170.6716@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1506111246170.6716@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Morten Stevens <mstevens@fedoraproject.org>, Daniel Wagner <wagi@monom.org>, Dave Chinner <david@fromorbit.com>, Eric Paris <eparis@redhat.com>, Eric Sandeen <esandeen@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 06/11/2015 04:06 PM, Hugh Dickins wrote:
> On Tue, 9 Jun 2015, Morten Stevens wrote:
>> 2015-06-09 16:10 GMT+02:00 Daniel Wagner <wagi@monom.org>:
>>> On 06/09/2015 01:54 PM, Morten Stevens wrote:
>>>> [   28.193327]  Possible unsafe locking scenario:
>>>>
>>>> [   28.194297]        CPU0                    CPU1
>>>> [   28.194774]        ----                    ----
>>>> [   28.195254]   lock(&mm->mmap_sem);
>>>> [   28.195709]                                lock(&xfs_dir_ilock_class);
>>>> [   28.196174]                                lock(&mm->mmap_sem);
>>>> [   28.196654]   lock(&isec->lock);
>>>> [   28.197108]
>>>
>>> [...]
>>>
>>>> Any ideas?
>>>
>>> I think you hit the same problem many have already reported:
>>>
>>> https://lkml.org/lkml/2015/3/30/594
>>
>> Yes, that sounds very likely. But that was about 1 month ago, so I
>> thought that it has been fixed in the last weeks?
> 
> It's not likely to get fixed without Cc'ing the right people.
> 
> This appears to be the same as Prarit reported to linux-mm on
> 2014/09/10.  Dave Chinner thinks it's a shmem bug, I disagree,
> but I am hopeful that it can be easily fixed at the shmem end.
> 
> Here's the patch I suggested nine months ago: but got no feedback,
> so it remains Not-Yet-Signed-off-by.  Please, if you find this works
> (and does not just delay the lockdep conflict until a little later),
> do let me know, then I can add some Tested-bys and send it to Linus.
> 
> mm: shmem_zero_setup skip security check and lockdep conflict with XFS
> 
> It appears that, at some point last year, XFS made directory handling
> changes which bring it into lockdep conflict with shmem_zero_setup():
> it is surprising that mmap() can clone an inode while holding mmap_sem,
> but that has been so for many years.
> 
> Since those few lockdep traces that I've seen all implicated selinux,
> I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
> v3.13's commit c7277090927a ("security: shmem: implement kernel private
> shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
> the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
> 
> This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
> (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
> which cloned inode in mmap(), but if so, I cannot locate them now.
> 
> Reported-by: Prarit Bhargava <prarit@redhat.com>
> Reported-by: Daniel Wagner <wagi@monom.org>
> Reported-by: Morten Stevens <mstevens@fedoraproject.org>
> Not-Yet-Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/shmem.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 4.1-rc7/mm/shmem.c	2015-04-26 19:16:31.352191298 -0700
> +++ linux/mm/shmem.c	2015-06-11 11:08:21.042745594 -0700
> @@ -3401,7 +3401,7 @@ int shmem_zero_setup(struct vm_area_stru
>  	struct file *file;
>  	loff_t size = vma->vm_end - vma->vm_start;
>  
> -	file = shmem_file_setup("dev/zero", size, vma->vm_flags);
> +	file = __shmem_file_setup("dev/zero", size, vma->vm_flags, S_PRIVATE);

Perhaps,

	file = shmem_kernel_file_setup("dev/zero", size, vma->vm_flags) ?

Tested-by: Prarit Bhargava <prarit@redhat.com>

P.

>  	if (IS_ERR(file))
>  		return PTR_ERR(file);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
