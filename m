Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63B6C6B0253
	for <linux-mm@kvack.org>; Sat, 23 Jul 2016 03:32:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p64so280176187pfb.0
        for <linux-mm@kvack.org>; Sat, 23 Jul 2016 00:32:46 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id m63si19090886pfb.137.2016.07.23.00.32.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Jul 2016 00:32:45 -0700 (PDT)
Message-ID: <57931C48.4050002@huawei.com>
Date: Sat, 23 Jul 2016 15:27:04 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] kexec: add resriction on the kexec_load
References: <1469165782-13193-1-git-send-email-zhongjiang@huawei.com> <20160722125856.59eb02d94a57f9871e2a38b2@linux-foundation.org>
In-Reply-To: <20160722125856.59eb02d94a57f9871e2a38b2@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ebiederm@xmission.com, linux-mm@kvack.org, kexec@lists.infradead.org

On 2016/7/23 3:58, Andrew Morton wrote:
> On Fri, 22 Jul 2016 13:36:22 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
>
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> I hit the following question when run trinity in my system. The
>> kernel is 3.4 version. but the mainline have same question to be
>> solved. The root cause is the segment size is too large, it can
>> expand the most of the area or the whole memory, therefore, it
>> may waste an amount of time to abtain a useable page. and other
>> cases will block until the test case quit. at the some time,
>> OOM will come up.
>>
>> Call Trace:
>>  [<ffffffff81106eac>] __alloc_pages_nodemask+0x14c/0x8f0
>>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>>  [<ffffffff8113e5ef>] alloc_pages_current+0xaf/0x120
>>  [<ffffffff810a0da0>] kimage_alloc_pages+0x10/0x60
>>  [<ffffffff810a15ad>] kimage_alloc_control_pages+0x5d/0x270
>>  [<ffffffff81027e85>] machine_kexec_prepare+0xe5/0x6c0
>>  [<ffffffff810a0d52>] ? kimage_free_page_list+0x52/0x70
>>  [<ffffffff810a1921>] sys_kexec_load+0x141/0x600
>>  [<ffffffff8115e6b0>] ? vfs_write+0x100/0x180
>>  [<ffffffff8145fbd9>] system_call_fastpath+0x16/0x1b
>>
>> The patch just add condition on sanity_check_segment_list to
>> restriction the segment size.
>>
>> ...
>>
>> --- a/kernel/kexec_core.c
>> +++ b/kernel/kexec_core.c
>> @@ -148,6 +148,7 @@ static struct page *kimage_alloc_page(struct kimage *image,
>>  int sanity_check_segment_list(struct kimage *image)
>>  {
>>  	int result, i;
>> +	unsigned long total_segments = 0;
>>  	unsigned long nr_segments = image->nr_segments;
>>  
>>  	/*
>> @@ -209,6 +210,21 @@ int sanity_check_segment_list(struct kimage *image)
>>  			return result;
>>  	}
>>  
>> +	/* Verity all segment size donnot exceed the specified size.
>> +	 * if segment size from user space is too large,  a large
>> +	 * amount of time will be wasted when allocating page. so,
>> +	 * softlockup may be come up.
>> +	 */
>> +	for (i = 0; i < nr_segments; i++) {
>> +		if (image->segment[i].memsz > (totalram_pages / 2))
>> +			return result;
>> +
>> +		total_segments += image->segment[i].memsz;
>> +	}
>> +
>> +	if (total_segments > (totalram_pages / 2))
>> +		return result;
>> +
>>  	/*
>>  	 * Verify we have good destination addresses.  Normally
>>  	 * the caller is responsible for making certain we don't
> This needed a few adjustments for pending changes in linux-next's
> sanity_check_segment_list().  Mainly s/return result/return -EINVAL/. 
> I also tweaked the patch changelog.  Please check.
>
> From: zhong jiang <zhongjiang@huawei.com>
> Subject: kexec: add restriction on kexec_load() segment sizes
>
> I hit the following issue when run trinity in my system.  The kernel is
> 3.4 version, but mainline has the same issue.
>
> The root cause is that the segment size is too large so the kerenl spends
> too long trying to allocate a page.  Other cases will block until the test
> case quits.  Also, OOM conditions will occur.
>
> Call Trace:
>  [<ffffffff81106eac>] __alloc_pages_nodemask+0x14c/0x8f0
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8113e5ef>] alloc_pages_current+0xaf/0x120
>  [<ffffffff810a0da0>] kimage_alloc_pages+0x10/0x60
>  [<ffffffff810a15ad>] kimage_alloc_control_pages+0x5d/0x270
>  [<ffffffff81027e85>] machine_kexec_prepare+0xe5/0x6c0
>  [<ffffffff810a0d52>] ? kimage_free_page_list+0x52/0x70
>  [<ffffffff810a1921>] sys_kexec_load+0x141/0x600
>  [<ffffffff8115e6b0>] ? vfs_write+0x100/0x180
>  [<ffffffff8145fbd9>] system_call_fastpath+0x16/0x1b
>
> The patch chnages sanity_check_segment_list() to verify that no segment is
> larger than half of memory.
>
> Link: http://lkml.kernel.org/r/1469165782-13193-1-git-send-email-zhongjiang@huawei.com
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> Cc: Eric Biederman <ebiederm@xmission.com>
> Cc: Vivek Goyal <vgoyal@redhat.com>
> Cc: Dave Young <dyoung@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  kernel/kexec_core.c |   16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
>
> diff -puN kernel/kexec_core.c~kexec-add-resriction-on-the-kexec_load kernel/kexec_core.c
> --- a/kernel/kexec_core.c~kexec-add-resriction-on-the-kexec_load
> +++ a/kernel/kexec_core.c
> @@ -154,6 +154,7 @@ static struct page *kimage_alloc_page(st
>  int sanity_check_segment_list(struct kimage *image)
>  {
>  	int i;
> +	unsigned long total_segments = 0;
>  	unsigned long nr_segments = image->nr_segments;
>  
>  	/*
> @@ -214,6 +215,21 @@ int sanity_check_segment_list(struct kim
>  			return -EINVAL;
>  	}
>  
> +	/* Verity all segment size donnot exceed the specified size.
> +	 * if segment size from user space is too large,  a large
> +	 * amount of time will be wasted when allocating page. so,
> +	 * softlockup may be come up.
> +	 */
> +	for (i = 0; i < nr_segments; i++) {
> +		if (image->segment[i].memsz > (totalram_pages / 2))
> +			return -EINVAL;
> +
> +		total_segments += image->segment[i].memsz;
> +	}
> +
> +	if (total_segments > (totalram_pages / 2))
> +		return -EINVAL;
> +
>  	/*
>  	 * Verify we have good destination addresses.  Normally
>  	 * the caller is responsible for making certain we don't
> _
>
>
>
>
> also I tweaked the comments a bit:
>
> --- a/kernel/kexec_core.c~kexec-add-resriction-on-the-kexec_load-fix
> +++ a/kernel/kexec_core.c
> @@ -215,10 +215,10 @@ int sanity_check_segment_list(struct kim
>  			return -EINVAL;
>  	}
>  
> -	/* Verity all segment size donnot exceed the specified size.
> -	 * if segment size from user space is too large,  a large
> -	 * amount of time will be wasted when allocating page. so,
> -	 * softlockup may be come up.
> +	/*
> +	 * Verify that no segment is larger than half of memory.  If a segment
> +	 * from userspace is too large,  a large amount of time will be wasted
> +	 * allocating pages, which can cause a soft lockup.
>  	 */
>  	for (i = 0; i < nr_segments; i++) {
>  		if (image->segment[i].memsz > (totalram_pages / 2))
> _
>
>
> Eric ack?
>
> .
>
Thanks,   the comment is  exact.
 v1->v2 :  the modification  was  suggested  by Eric.
 I guess that he is offline.  I have another patch about kexec is  still not conclusion.

Thanks
zhongjiang
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
