Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09D576B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 14:07:30 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id h9so2453623qtc.2
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 11:07:30 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x42si6089168qtb.7.2017.11.03.11.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 11:07:29 -0700 (PDT)
Subject: Re: [PATCH 2/6] shmem: rename functions that are memfd-related
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
 <20171031184052.25253-3-marcandre.lureau@redhat.com>
 <c884ed14-cb4e-fa04-e5be-5a732e64f988@oracle.com>
 <847029229.35880816.1509724946936.JavaMail.zimbra@redhat.com>
 <633d88c8-cdf4-27ad-3c8c-cce9a356b74b@oracle.com>
 <1658986317.35884697.1509726973081.JavaMail.zimbra@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <3e736356-634b-2d06-2d75-4427a93e8195@oracle.com>
Date: Fri, 3 Nov 2017 11:07:20 -0700
MIME-Version: 1.0
In-Reply-To: <1658986317.35884697.1509726973081.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 11/03/2017 09:36 AM, Marc-AndrA(C) Lureau wrote:
> Hi
> 
> ----- Original Message -----
>> On 11/03/2017 09:02 AM, Marc-AndrA(C) Lureau wrote:
>>> Hi
>>>
>>> ----- Original Message -----
>>>> On 10/31/2017 11:40 AM, Marc-AndrA(C) Lureau wrote:
>>>>> Those functions are called for memfd files, backed by shmem or
>>>>> hugetlb (the next patches will handle hugetlb).
>>>>>
>>>>> Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
>>>>> ---
>>>>>  fs/fcntl.c               |  2 +-
>>>>>  include/linux/shmem_fs.h |  4 ++--
>>>>>  mm/shmem.c               | 10 +++++-----
>>>>>  3 files changed, 8 insertions(+), 8 deletions(-)
>>>>>
>>>>> diff --git a/fs/fcntl.c b/fs/fcntl.c
>>>>> index 448a1119f0be..752c23743616 100644
>>>>> --- a/fs/fcntl.c
>>>>> +++ b/fs/fcntl.c
>>>>> @@ -417,7 +417,7 @@ static long do_fcntl(int fd, unsigned int cmd,
>>>>> unsigned
>>>>> long arg,
>>>>>  		break;
>>>>>  	case F_ADD_SEALS:
>>>>>  	case F_GET_SEALS:
>>>>> -		err = shmem_fcntl(filp, cmd, arg);
>>>>> +		err = memfd_fcntl(filp, cmd, arg);
>>>>>  		break;
>>>>>  	case F_GET_RW_HINT:
>>>>>  	case F_SET_RW_HINT:
>>>>> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
>>>>> index 557d0c3b6eca..0dac8c0f4aa4 100644
>>>>> --- a/include/linux/shmem_fs.h
>>>>> +++ b/include/linux/shmem_fs.h
>>>>> @@ -109,11 +109,11 @@ extern void shmem_uncharge(struct inode *inode,
>>>>> long
>>>>> pages);
>>>>>  
>>>>>  #ifdef CONFIG_TMPFS
>>>>>  
>>>>> -extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned
>>>>> long
>>>>> arg);
>>>>> +extern long memfd_fcntl(struct file *file, unsigned int cmd, unsigned
>>>>> long
>>>>> arg);
>>>>>  
>>>>>  #else
>>>>>  
>>>>> -static inline long shmem_fcntl(struct file *f, unsigned int c, unsigned
>>>>> long a)
>>>>> +static inline long memfd_fcntl(struct file *f, unsigned int c, unsigned
>>>>> long a)
>>>>>  {
>>>>>  	return -EINVAL;
>>>>>  }
>>>>
>>>> Do we want memfd_fcntl() to work for hugetlbfs if CONFIG_TMPFS is not
>>>> defined?  I admit that having CONFIG_HUGETLBFS defined without
>>>> CONFIG_TMPFS
>>>> is unlikely, but I think possible.  Based on the above #ifdef/#else, I
>>>> think hugetlbfs seals will not work if CONFIG_TMPFS is not defined.
>>>
>>> Good point, memfd_create() will not exists either.
>>>
>>> I think this is a separate concern, and preexisting from this patch series
>>> though.
>>
>> Ah yes.  I should have addressed this when adding hugetlbfs memfd_create
>> support.
>>
>> Of course, one 'simple' way to address this would be to make CONFIG_HUGETLBFS
>> depend on CONFIG_TMPFS.  Not sure what people think about this?
>>
> 
> I can't say much about that. But compiling the hugetlb seal support while TPMFS/memfd is disabled should not break anything. You won't be able to add seals, that's it.
> 

Correct.  But, if someone did create such a config AND wanted hugetlbfs
seal support they would be out of luck.  I really can't imagine systems
where tmpfs would be disabled and hugetlbfs would be enabled and users
would want hugetlbfs file sealing.  That is why I threw out the possibility
of making hugetlbfs depend on tmpfs.

> I suppose memfd could be splitted off TPMFS, and depend on either HUGETLBFS || TPMFS?

Yes, that would be the ideal solution.  I just hate to go through the code
churn for a config combination that may never be used.  However, this really
would be the right thing to do.

> 
>>> Ack the function renaming part?
>>
>> Yes, the remaining code looks fine to me.
> 
> Should I add your Review-by: for this patch then?

Yes

-- 
Mike Kravetz

> 
>>
>> --
>> Mike Kravetz
>>
>>>
>>>> --
>>>> Mike Kravetz
>>>>
>>>>> diff --git a/mm/shmem.c b/mm/shmem.c
>>>>> index 37260c5e12fa..b7811979611f 100644
>>>>> --- a/mm/shmem.c
>>>>> +++ b/mm/shmem.c
>>>>> @@ -2722,7 +2722,7 @@ static int shmem_wait_for_pins(struct address_space
>>>>> *mapping)
>>>>>  		     F_SEAL_GROW | \
>>>>>  		     F_SEAL_WRITE)
>>>>>  
>>>>> -static int shmem_add_seals(struct file *file, unsigned int seals)
>>>>> +static int memfd_add_seals(struct file *file, unsigned int seals)
>>>>>  {
>>>>>  	struct inode *inode = file_inode(file);
>>>>>  	struct shmem_inode_info *info = SHMEM_I(inode);
>>>>> @@ -2792,7 +2792,7 @@ static int shmem_add_seals(struct file *file,
>>>>> unsigned int seals)
>>>>>  	return error;
>>>>>  }
>>>>>  
>>>>> -static int shmem_get_seals(struct file *file)
>>>>> +static int memfd_get_seals(struct file *file)
>>>>>  {
>>>>>  	if (file->f_op != &shmem_file_operations)
>>>>>  		return -EINVAL;
>>>>> @@ -2800,7 +2800,7 @@ static int shmem_get_seals(struct file *file)
>>>>>  	return SHMEM_I(file_inode(file))->seals;
>>>>>  }
>>>>>  
>>>>> -long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
>>>>> +long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
>>>>>  {
>>>>>  	long error;
>>>>>  
>>>>> @@ -2810,10 +2810,10 @@ long shmem_fcntl(struct file *file, unsigned int
>>>>> cmd, unsigned long arg)
>>>>>  		if (arg > UINT_MAX)
>>>>>  			return -EINVAL;
>>>>>  
>>>>> -		error = shmem_add_seals(file, arg);
>>>>> +		error = memfd_add_seals(file, arg);
>>>>>  		break;
>>>>>  	case F_GET_SEALS:
>>>>> -		error = shmem_get_seals(file);
>>>>> +		error = memfd_get_seals(file);
>>>>>  		break;
>>>>>  	default:
>>>>>  		error = -EINVAL;
>>>>>
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
