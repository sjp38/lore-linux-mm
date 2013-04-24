Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id CA1CC6B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 04:21:57 -0400 (EDT)
Message-ID: <517795E2.6070404@huawei.com>
Date: Wed, 24 Apr 2013 16:20:50 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
References: <bug-56881-27@https.bugzilla.kernel.org/> <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org> <1366755995-no3omuhl-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1366755995-no3omuhl-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com

On 2013/4/24 6:26, Naoya Horiguchi wrote:

> On Tue, Apr 23, 2013 at 01:25:22PM -0700, Andrew Morton wrote:
>>
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Sat, 20 Apr 2013 03:00:30 +0000 (UTC) bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=56881
>>>
>>>            Summary: MAP_HUGETLB mmap fails for certain sizes
>>>            Product: Memory Management
>>>            Version: 2.5
>>>     Kernel Version: 3.5.0-27
>>
>> Thanks.
>>
>> It's a post-3.4 regression, testcase included.  Does someone want to
>> take a look, please?
> 
> Let me try it.
> 
>   static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>   {                                                                            
>           struct inode *inode = file->f_path.dentry->d_inode;
>           loff_t len, vma_len;                               
>           int ret;                                           
>           struct hstate *h = hstate_file(file);              
>           ...                                                                               
>           if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))              
>                   return -EINVAL;                                              
> 
> This code checks only whether a given hugetlb vma covers (1 << order)
> pages, not whether it's exactly hugepage aligned.
> Before 2b37c35e6552 "fs/hugetlbfs/inode.c: fix pgoff alignment
> checking on 32-bit", it was
> 
>   if (vma->vm_pgoff & ~(huge_page_mask(h) >> PAGE_SHIFT))
> 
> , but this made no sense because ~(huge_page_mask(h) >> PAGE_SHIFT) is
> 0xff for 2M hugepage.
> I think the reported problem is not a bug because the behavior before
> this change was wrong or not as expected.
> 
> If we want to make sure that a given address range fits hugepage size,
> something like below can be useful.
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 78bde32..a98304b 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -113,11 +113,11 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>  	vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND | VM_DONTDUMP;
>  	vma->vm_ops = &hugetlb_vm_ops;
>  
> -	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
> -		return -EINVAL;
> -
>  	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
>  
> +	if (vma->len & ~huge_page_mask(h))
> +		return -EINVAL;
> +
>  	mutex_lock(&inode->i_mutex);
>  	file_accessed(file);
>  
> 
> Thanks,
> Naoya Horiguchi
> 

Hi Naoya,

I think the -EINVAL is returned from hugetlb_get_unmapped_area(),
for the two testcases:
1) $ ./mmappu $((5 * 2 * 1024 * 1024 - 4096))	//len1 = 0x9ff000
2) $ ./mmappu $((5 * 2 * 1024 * 1024 - 4095))	//len2 = 0x9ff001

In do_mmap_pgoff(), after "len = PAGE_ALIGN(len);", len1 = 0x9ff000,
len2 = 0xa00000, so len2 will pass "if (len & ~huge_page_mask(h))" check in
hugetlb_get_unmapped_area(), and len1 will return -EINVAL. As follow:

do_mmap_pgoff()
{
	...
	/* Careful about overflows.. */
	len = PAGE_ALIGN(len);
	...
	get_unmapped_area()
		-->hugetlb_get_unmapped_area()
		   {
			...
			if (len & ~huge_page_mask(h))
				return -EINVAL;
			...
		   }
}

do we need to align len to hugepage size if it's hugetlbfs mmap? something like below:

---
 mm/mmap.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 0db0de1..bd42be24 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1188,7 +1188,10 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		addr = round_hint_to_min(addr);
 
 	/* Careful about overflows.. */
-	len = PAGE_ALIGN(len);
+	if (file && is_file_hugepages(file))
+		len = ALIGN(len, huge_page_size(hstate_file(file)));
+	else
+		len = PAGE_ALIGN(len);
 	if (!len)
 		return -ENOMEM;
 
-- 

Thanks,
Jianguo Wu

>>>           Platform: All
>>>         OS/Version: Linux
>>>               Tree: Mainline
>>>             Status: NEW
>>>           Severity: high
>>>           Priority: P1
>>>          Component: Other
>>>         AssignedTo: akpm@linux-foundation.org
>>>         ReportedBy: iceman_dvd@yahoo.com
>>>         Regression: No
>>>
>>>
>>> This is on an Ubuntu 12.10 desktop, but the same issue has been found on 12.04
>>> with 3.5.0 kernel.
>>> See the sample program. An allocation with MAP_HUGETLB consistently fails with
>>> certain sizes, while it succeeds with others.
>>> The allocation sizes are well below the number of free huge pages.
>>>
>>> $ uname -a Linux davide-lnx2 3.5.0-27-generic #46-Ubuntu SMP Mon Mar 25
>>> 19:58:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
>>>
>>>
>>> # echo 100 > /proc/sys/vm/nr_hugepages
>>>
>>> # cat /proc/meminfo
>>> ...
>>> AnonHugePages:         0 kB
>>> HugePages_Total:     100
>>> HugePages_Free:      100
>>> HugePages_Rsvd:        0
>>> HugePages_Surp:        0
>>> Hugepagesize:       2048 kB
>>>
>>>
>>> $ ./mmappu $((5 * 2 * 1024 * 1024 - 4096))
>>> size=10481664    0x9ff000
>>> hugepage mmap: Invalid argument
>>>
>>>
>>> $ ./mmappu $((5 * 2 * 1024 * 1024 - 4095))
>>> size=10481665    0x9ff001
>>> OK!
>>>
>>>
>>> It seems the trigger point is a normal page size.
>>> The same binary works flawlessly in previous kernels.
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
