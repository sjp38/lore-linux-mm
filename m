Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2033D6B0253
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 11:35:13 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id x187so12695492oix.3
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:35:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k129si6663144oia.231.2017.12.22.08.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 08:35:12 -0800 (PST)
Subject: Re: [RFC PATCH v4 08/18] kvm: add the VM introspection subsystem
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-9-alazar@bitdefender.com>
 <533d5a75-1ac7-4cd4-347d-237a3c9a54c5@redhat.com>
 <06e5932438614d7092d67b88e336d3d8@mb1xmail.bitdefender.biz>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <2cb44ae2-cc54-61b5-86c7-5658010791e5@redhat.com>
Date: Fri, 22 Dec 2017 17:35:07 +0100
MIME-Version: 1.0
In-Reply-To: <06e5932438614d7092d67b88e336d3d8@mb1xmail.bitdefender.biz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mircea CIRJALIU-MELIU <mcirjaliu@bitdefender.com>, =?UTF-8?Q?Adalber_Laz=c4=83r?= <alazar@bitdefender.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>, Nicusor CITU <ncitu@bitdefender.com>, Marian Cristian ROTARIU <mrotariu@bitdefender.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>

On 22/12/2017 17:18, Mircea CIRJALIU-MELIU wrote:
> 
> 
>> -----Original Message-----
>> From: Paolo Bonzini [mailto:pbonzini@redhat.com]
>> Sent: Friday, 22 December 2017 18:02
>> To: Adalber LazA?r <alazar@bitdefender.com>; kvm@vger.kernel.org
>> Cc: linux-mm@kvack.org; Radim KrA?mA!A? <rkrcmar@redhat.com>; Xiao
>> Guangrong <guangrong.xiao@linux.intel.com>; Mihai DonE?u
>> <mdontu@bitdefender.com>; Nicusor CITU <ncitu@bitdefender.com>;
>> Mircea CIRJALIU-MELIU <mcirjaliu@bitdefender.com>; Marian Cristian
>> ROTARIU <mrotariu@bitdefender.com>
>> Subject: Re: [RFC PATCH v4 08/18] kvm: add the VM introspection subsystem
>>
>> On 18/12/2017 20:06, Adalber LazA?r wrote:
>>> +	/* VMAs will be modified */
>>> +	down_write(&req_mm->mmap_sem);
>>> +	down_write(&map_mm->mmap_sem);
>>> +
>>
>> Is there a locking rule when locking multiple mmap_sems at the same
>> time?  As it's written, this can cause deadlocks.
> 
> First req_mm, second map_mm.
> The other function uses the same nesting.

You could have two tasks, both of which register themselves as the
introspector of the other.  That would cause a deadlock.  There may be
also other cases in the kernel that lock two VMAs at the same time, and
you have to be consistent with those.

Usually what you do is comparing pointers and locking the lowest address
first.  Alternatively, you could have a separate lock that is taken by
everyone who needs more than one lock, that is:

	down_write(&some_mm->mmap_sem);

but:

	mutex_lock(&locking_many_mmaps);
	down_write(&some_mm->mmap_sem);
	down_write(&another_mm->mmap_sem);
	mutex_unlock(&locking_many_mmaps);
	...
	up_write(&some_mm->mmap_sem);
	up_write(&another_mm->mmap_sem);

However, I'm not sure how it works for mmap_sem.  We'll have to ask the
mm guys, let me Cc a few of them randomly.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
