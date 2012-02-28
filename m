Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 3C1636B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 21:55:42 -0500 (EST)
Message-ID: <4F4C4215.5020108@utoronto.ca>
Date: Mon, 27 Feb 2012 21:55:17 -0500
From: Steven Truelove <steven.truelove@utoronto.ca>
MIME-Version: 1.0
Subject: Re: [PATCH] HUGETLBFS: Align memory request to multiple of huge page
 size to avoid underallocating.
References: <1330351768-14874-1-git-send-email-steven.truelove@utoronto.ca> <20120227154217.0a0d5a06.akpm@linux-foundation.org>
In-Reply-To: <20120227154217.0a0d5a06.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: wli@holomorphy.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 27/02/2012 6:42 PM, Andrew Morton wrote:
> On Mon, 27 Feb 2012 09:09:28 -0500
> Steven Truelove<steven.truelove@utoronto.ca>  wrote:
>
>> When calling shmget with SHM_HUGETLB, shmget aligns the request size to PAGE_SIZE, but this is not sufficient.  Modified hugetlb_file_setup to align requests to the huge page size.
>>
>> Signed-off-by: Steven Truelove<steven.truelove@utoronto.ca>
>> ---
>>   fs/hugetlbfs/inode.c |    9 ++++++---
>>   1 files changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 1e85a7a..6c23f09 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -938,6 +938,8 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
>>   	struct path path;
>>   	struct dentry *root;
>>   	struct qstr quick_string;
>> +	struct hstate *hstate;
>> +	int num_pages;
>>
>>   	*user = NULL;
>>   	if (!hugetlbfs_vfsmount)
>> @@ -967,10 +969,11 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
>>   	if (!inode)
>>   		goto out_dentry;
>>
>> +	hstate = hstate_inode(inode);
>> +	num_pages = (size + huge_page_size(hstate) - 1)>>
>> +			huge_page_shift(hstate);
>>   	error = -ENOMEM;
>> -	if (hugetlb_reserve_pages(inode, 0,
>> -			size>>  huge_page_shift(hstate_inode(inode)), NULL,
>> -			acctflag))
>> +	if (hugetlb_reserve_pages(inode, 0, num_pages, NULL, acctflag))
>>   		goto out_inode;
>>
>>   	d_instantiate(path.dentry, inode);
> A few things...
>
> - sys_mmap_pgoff() does the rounding up prior to calling
>    hugetlb_file_setup().  ipc/shm.c:newseg() does not.
>
>    We should be consistent here: do it in the caller or the callee,
>    not both (or neither!).  I guess doing it in the callee would be
>    best.
>
> - The above code could/should have used ALIGN().  Or round_up(): the
>    difference presently escapes me, even though it was so obvious that
>    we left all these things undocumented.
>
> - What's the point in aligning the length if we don't also look at
>    the start address?  If that isn't a multiple of huge_page_size(), we
>    will need an additional page.
>

Since mmap has an address to check and shmget does not, if the address 
is going to be checked it will need to be in the caller.  If you like, I 
will leave the size check in hugetlb_file_setup() and remove the size 
check from mmap_pgoff, but replace it with a check of the address.  That 
will centralize the common check (size of buffer), and let mmap_pgoff 
check the part that is unique to it.  Patch shortly.

Steven Truelove

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
