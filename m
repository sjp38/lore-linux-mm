Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA7B6B68AF
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 12:04:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j5-v6so822301oiw.13
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 09:04:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 126-v6si13058630oih.306.2018.09.03.09.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 09:04:02 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w83G41LL125158
	for <linux-mm@kvack.org>; Mon, 3 Sep 2018 12:04:01 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m97kt19px-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 03 Sep 2018 12:04:01 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 3 Sep 2018 17:03:55 +0100
Subject: Re: [RFC][PATCH 1/5] [PATCH 1/5] kvm: register in task_struct
References: <D3FBF73C-3C33-4F94-8BBB-CE6C70B81A70@oracle.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Mon, 3 Sep 2018 18:03:49 +0200
MIME-Version: 1.0
In-Reply-To: <D3FBF73C-3C33-4F94-8BBB-CE6C70B81A70@oracle.com>
Content-Language: en-US
Message-Id: <0ef9ccdc-3eae-f0b9-5304-8552cb94d166@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikita Leshenko <nikita.leshchenko@oracle.com>, fengguang.wu@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dongx.peng@intel.com, jingqi.liu@intel.com, eddie.dong@intel.com, dave.hansen@intel.com, ying.huang@intel.com, bgregg@netflix.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org



On 09/03/2018 04:10 PM, Nikita Leshenko wrote:
> On September 2, 2018 5:21:15 AM, fengguang.wu@intel.com wrote:
>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>> index 8b47507faab5..0c483720de8d 100644
>> --- a/virt/kvm/kvm_main.c
>> +++ b/virt/kvm/kvm_main.c
>> @@ -3892,6 +3892,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm)
>>  	if (type == KVM_EVENT_CREATE_VM) {
>>  		add_uevent_var(env, "EVENT=create");
>>  		kvm->userspace_pid = task_pid_nr(current);
>> +		current->kvm = kvm;
> 
> Is it OK to store `kvm` on the task_struct? What if the thread that
> originally created the VM exits? From the documentation it seems
> like a VM is associated with an address space and not a specific
> thread, so maybe it should be stored on mm_struct?

Yes, ioctls accessing the kvm can happen from all threads.
> 
> From Documentation/virtual/kvm/api.txt:
>    Only run VM ioctls from the same process (address space) that was used
>    to create the VM.
> 
> -Nikita
>>  	} else if (type == KVM_EVENT_DESTROY_VM) {
>>  		add_uevent_var(env, "EVENT=destroy");
>>  	}
>> -- 
>> 2.15.0
>>
>>
>>
> 
