Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0DE6B005A
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 10:16:00 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id w7so2100050qcr.26
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 07:16:00 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1lp0141.outbound.protection.outlook.com. [207.46.163.141])
        by mx.google.com with ESMTPS id e11si4633276qga.5.2014.07.17.07.15.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Jul 2014 07:15:59 -0700 (PDT)
Message-ID: <53C7DA82.7000502@amd.com>
Date: Thu, 17 Jul 2014 17:15:30 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 01/25] mm: Add kfd_process pointer to mm_struct
References: <1405603773-32688-1-git-send-email-oded.gabbay@amd.com>
 <53C7D666.6000405@amd.com> <20140717141216.GA1963@gmail.com>
In-Reply-To: <20140717141216.GA1963@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?ISO-8859-1?Q?Christian_K=F6nig?= <deathsimple@vodafone.de>, =?ISO-8859-1?Q?Michel_D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "Kirill
 A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, =?ISO-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 17/07/14 17:12, Jerome Glisse wrote:
> On Thu, Jul 17, 2014 at 04:57:58PM +0300, Oded Gabbay wrote:
>> Forgot to add mm mailing list. Sorry.
>>
>> This patch enables the amdkfd driver to retrieve the kfd_process
>> object from the process's mm_struct. This is needed because kfd_proces=
s
>> lifespan is bound to the process's mm_struct lifespan.
>>
>> When amdkfd is notified about an mm_struct tear-down, it checks if the
>> kfd_process pointer is valid. If so, it releases the kfd_process objec=
t
>> and all relevant resources.
>>
>> In v3 of the patchset I will update the binding to match the final dis=
cussions
>> on [PATCH 1/8] mmput: use notifier chain to call subsystem exit handle=
r.
>> In the meantime, I'm going to try and see if I can drop the kfd_proces=
s
>> in mm_struct and remove the use of the new notification chain in mmput=
.
>> Instead, I will try to use the mmu release notifier.
>
> So the mmput notifier chain will not happen. I did a patch with call_sr=
cu
> and adding couple more helper to mmu_notifier. I will send that today f=
or
> review.
>
> That being said, adding a device driver specific to mm_struct will most
> likely be a big no. I am myself gonna remove hmm from mm_struct as peop=
le
> are reluctant to see such change.
>
> Cheers,
> J=E9r=F4me
>
Yes, I followed that email thread and you can see that in the commit mess=
age I=20
referred to it (saying that in v3 of the patchset I'm also going to use=20
mmu_notifier). I will take your patch once you publish it and use it to c=
hange=20
amdkfd behavior.

	Oded
>
>>
>> Signed-off-by: Oded Gabbay <oded.gabbay@amd.com>
>> ---
>>   include/linux/mm_types.h | 14 ++++++++++++++
>>   1 file changed, 14 insertions(+)
>>
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 678097c..ff71496 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -20,6 +20,10 @@
>>   struct hmm;
>>   #endif
>>   +#if defined(CONFIG_HSA_RADEON) || defined(CONFIG_HSA_RADEON_MODULE)
>> +struct kfd_process;
>> +#endif
>> +
>>   #ifndef AT_VECTOR_SIZE_ARCH
>>   #define AT_VECTOR_SIZE_ARCH 0
>>   #endif
>> @@ -439,6 +443,16 @@ struct mm_struct {
>>   	 */
>>   	struct hmm *hmm;
>>   #endif
>> +#if defined(CONFIG_HSA_RADEON) || defined(CONFIG_HSA_RADEON_MODULE)
>> +	/*
>> +	 * kfd always register an mmu_notifier we rely on mmu notifier to ke=
ep
>> +	 * refcount on mm struct as well as forbiding registering kfd on a
>> +	 * dying mm
>> +	 *
>> +	 * This field is set with mmap_sem old in write mode.
>> +	 */
>> +	struct kfd_process *kfd_process;
>> +#endif
>>   #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>>   	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
>>   #endif
>> --
>> 1.9.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
