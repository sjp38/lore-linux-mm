Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB286B0254
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 14:47:40 -0500 (EST)
Received: by wmvv187 with SMTP id v187so965572wmv.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 11:47:39 -0800 (PST)
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com. [195.75.94.104])
        by mx.google.com with ESMTPS id y4si13583605wjr.114.2015.11.11.11.47.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 11:47:38 -0800 (PST)
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 11 Nov 2015 19:47:38 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 376A317D8042
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 19:47:55 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tABJla0I590304
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 19:47:36 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tABIla1f020954
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 11:47:36 -0700
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
References: <1447256116-16461-1-git-send-email-jjherne@linux.vnet.ibm.com>
 <20151111173044.GF4573@redhat.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56439B56.1090105@de.ibm.com>
Date: Wed, 11 Nov 2015 20:47:34 +0100
MIME-Version: 1.0
In-Reply-To: <20151111173044.GF4573@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, linux-mm@kvack.org, KVM list <kvm@vger.kernel.org>

Am 11.11.2015 um 18:30 schrieb Andrea Arcangeli:
> Hi Jason,
> 
> On Wed, Nov 11, 2015 at 10:35:16AM -0500, Jason J. Herne wrote:
>> MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
>> hugepage but hugepage_madvise() takes the error path when we ask to turn
>> on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's
> 
> I wonder why KVM disables transparent hugepages on s390. It sounds
> weird to disable transparent hugepages with KVM. In fact on x86 we
> call MADV_HUGEPAGE to be sure transparent hugepages are enabled on the
> guest physical memory, even if the transparent_hugepage/enabled ==
> madvise.

KVM on s390 does not support huge pages as of today, as it interfers with storage
keys and other extensions (like cooperative paging). The architectural place to 
store these extensions is in the page table extension, which do not exist with
lage pages. We have recently implemented keyless guests and working on additional
changes to allow large pages for guest backing - but not today.

>> new postcopy migration feature to fail on s390 because its first action is
>> to madvise the guest address space as NOHUGEPAGE. This patch modifies the
>> code so that the operation succeeds without error now.
> 
> The other way is to change qemu to keep track it already called
> MADV_NOHUGEPAGE and not to call it again. I don't have a strong
> opinion on this, I think it's ok to return 0 but it's a visible change
> to userland, I can't imagine it to break anything though. It sounds
> very unlikely that an app could error out if it notices the kernel
> doesn't error out on the second call of MADV_NOHUGEPAGE.

the sequence of
madvise (something); == ok
madvise (something); == EINVAL;
seems strange. So I think changing the kernel is the better approach.
> 
> Glad to hear KVM postcopy live migration is already running on s390 too.
> 
> Thanks,
> Andrea
> 
>>
>> Signed-off-by: Jason J. Herne <jjherne@linux.vnet.ibm.com>

Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
Who is going to take this patch? If I should take the patch, I need an
ACK from the memory mgmt folks.

Christian


>> ---
>>  mm/huge_memory.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index c29ddeb..a8b5347 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2025,7 +2025,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
>>  		/*
>>  		 * Be somewhat over-protective like KSM for now!
>>  		 */
>> -		if (*vm_flags & (VM_NOHUGEPAGE | VM_NO_THP))
>> +		if (*vm_flags & VM_NO_THP)
>>  			return -EINVAL;
>>  		*vm_flags &= ~VM_HUGEPAGE;
>>  		*vm_flags |= VM_NOHUGEPAGE;
>> -- 
>> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
