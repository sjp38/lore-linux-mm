Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 667526B0038
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 21:45:43 -0400 (EDT)
Received: by obbda8 with SMTP id da8so2560578obb.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 18:45:43 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n199si329043oig.12.2015.10.19.18.45.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 18:45:42 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm/hugetlb: Setup hugetlb_falloc during fallocate
 hole punch
References: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
 <1445033310-13155-3-git-send-email-mike.kravetz@oracle.com>
 <20151019161642.68e787103cacb613d372b5c4@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56259BD0.7060307@oracle.com>
Date: Mon, 19 Oct 2015 18:41:36 -0700
MIME-Version: 1.0
In-Reply-To: <20151019161642.68e787103cacb613d372b5c4@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>

On 10/19/2015 04:16 PM, Andrew Morton wrote:
> On Fri, 16 Oct 2015 15:08:29 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> When performing a fallocate hole punch, set up a hugetlb_falloc struct
>> and make i_private point to it.  i_private will point to this struct for
>> the duration of the operation.  At the end of the operation, wake up
>> anyone who faulted on the hole and is on the waitq.
>>
>> ...
>>
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -507,7 +507,9 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
>>  {
>>  	struct hstate *h = hstate_inode(inode);
>>  	loff_t hpage_size = huge_page_size(h);
>> +	unsigned long hpage_shift = huge_page_shift(h);
>>  	loff_t hole_start, hole_end;
>> +	struct hugetlb_falloc hugetlb_falloc;
>>  
>>  	/*
>>  	 * For hole punch round up the beginning offset of the hole and
>> @@ -518,8 +520,23 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
>>  
>>  	if (hole_end > hole_start) {
>>  		struct address_space *mapping = inode->i_mapping;
>> +		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(hugetlb_falloc_waitq);
>> +
>> +		/*
>> +		 * Page faults on the area to be hole punched must be
>> +		 * stopped during the operation.  Initialize struct and
>> +		 * have inode->i_private point to it.
>> +		 */
>> +		hugetlb_falloc.waitq = &hugetlb_falloc_waitq;
>> +		hugetlb_falloc.start = hole_start >> hpage_shift;
>> +		hugetlb_falloc.end = hole_end >> hpage_shift;
> 
> This is a bit neater:
> 
> --- a/fs/hugetlbfs/inode.c~mm-hugetlb-setup-hugetlb_falloc-during-fallocate-hole-punch-fix
> +++ a/fs/hugetlbfs/inode.c
> @@ -509,7 +509,6 @@ static long hugetlbfs_punch_hole(struct
>  	loff_t hpage_size = huge_page_size(h);
>  	unsigned long hpage_shift = huge_page_shift(h);
>  	loff_t hole_start, hole_end;
> -	struct hugetlb_falloc hugetlb_falloc;
>  
>  	/*
>  	 * For hole punch round up the beginning offset of the hole and
> @@ -521,15 +520,16 @@ static long hugetlbfs_punch_hole(struct
>  	if (hole_end > hole_start) {
>  		struct address_space *mapping = inode->i_mapping;
>  		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(hugetlb_falloc_waitq);
> -
>  		/*
> -		 * Page faults on the area to be hole punched must be
> -		 * stopped during the operation.  Initialize struct and
> -		 * have inode->i_private point to it.
> +		 * Page faults on the area to be hole punched must be stopped
> +		 * during the operation.  Initialize struct and have
> +		 * inode->i_private point to it.
>  		 */
> -		hugetlb_falloc.waitq = &hugetlb_falloc_waitq;
> -		hugetlb_falloc.start = hole_start >> hpage_shift;
> -		hugetlb_falloc.end = hole_end >> hpage_shift;
> +		struct hugetlb_falloc hugetlb_falloc = {
> +			.waitq = &hugetlb_falloc_waitq,
> +			.start = hole_start >> hpage_shift,
> +			.end = hole_end >> hpage_shift
> +		};
>  
>  		mutex_lock(&inode->i_mutex);
>  
> 

Thanks!

>>  		mutex_lock(&inode->i_mutex);
>> +
>> +		spin_lock(&inode->i_lock);
>> +		inode->i_private = &hugetlb_falloc;
>> +		spin_unlock(&inode->i_lock);
> 
> Locking around a single atomic assignment is a bit peculiar.  I can
> kinda see that it kinda protects the logic in hugetlb_fault(), but I
> would like to hear (in comment form) your description of how this logic
> works?

To be honest, this code/scheme was copied from shmem as it addresses
the same situation there.  I did not notice how strange this looks until
you pointed it out.  At first glance, the locking does appear to be
unnecessary.  The fault code initially checks this value outside the
lock.  However, the fault code (on another CPU) will take the lock
and access values within the structure.  Without the locking or some other
type of memory barrier here, there is no guarantee that the structure
will be initialized before setting i_private.  So, the faulting code
could see invalid values in the structure.

Hugh, is that accurate?  You provided the shmem code.

-- 
Mike Kravetz

>>  		i_mmap_lock_write(mapping);
>>  		if (!RB_EMPTY_ROOT(&mapping->i_mmap))
>>  			hugetlb_vmdelete_list(&mapping->i_mmap,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
