Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45ED06B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:35:20 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 73so1471370pfz.11
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:35:20 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0078.outbound.protection.outlook.com. [104.47.42.78])
        by mx.google.com with ESMTPS id 94si617334ple.413.2017.12.13.01.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:35:19 -0800 (PST)
Subject: Re: [patch 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
 <20171212200542.GJ5848@hpe.com>
 <alpine.DEB.2.10.1712121326280.134224@chino.kir.corp.google.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <d6487124-b613-6614-f355-14b7388a8ae3@amd.com>
Date: Wed, 13 Dec 2017 10:34:59 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1712121326280.134224@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Dimitri Sivanich <sivanich@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Am 12.12.2017 um 22:28 schrieb David Rientjes:
> On Tue, 12 Dec 2017, Dimitri Sivanich wrote:
>
>>> --- a/drivers/misc/sgi-gru/grutlbpurge.c
>>> +++ b/drivers/misc/sgi-gru/grutlbpurge.c
>>> @@ -298,6 +298,7 @@ struct gru_mm_struct *gru_register_mmu_notifier(void)
>>>   			return ERR_PTR(-ENOMEM);
>>>   		STAT(gms_alloc);
>>>   		spin_lock_init(&gms->ms_asid_lock);
>>> +		gms->ms_notifier.flags = 0;
>>>   		gms->ms_notifier.ops = &gru_mmuops;
>>>   		atomic_set(&gms->ms_refcnt, 1);
>>>   		init_waitqueue_head(&gms->ms_wait_queue);
>>> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
>> There is a kzalloc() just above this:
>> 	gms = kzalloc(sizeof(*gms), GFP_KERNEL);
>>
>> Is that not sufficient to clear the 'flags' field?
>>
> Absolutely, but whether it is better to explicitly document that the mmu
> notifier has cleared flags, i.e. there are no blockable callbacks, is
> another story.  I can change it if preferred.

Actually I would invert the new flag, in other words specify that an MMU 
notifier will never sleep.

The first reason is that we have 8 blocking notifiers and 5 not blocking 
if I counted right. So it is actually more common to sleep than not to.

The second reason is to be conservative and assume the worst, e.g. that 
the flag is forgotten when a new notifier is added.

Regards,
Christian.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
