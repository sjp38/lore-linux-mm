Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B9B7A6B0003
	for <linux-mm@kvack.org>; Sat,  2 Jan 2016 06:33:14 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so128144344wmf.0
        for <linux-mm@kvack.org>; Sat, 02 Jan 2016 03:33:14 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id n129si118178542wmb.97.2016.01.02.03.33.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Jan 2016 03:33:13 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id f206so156188980wmf.0
        for <linux-mm@kvack.org>; Sat, 02 Jan 2016 03:33:13 -0800 (PST)
Subject: Re: GPF in shm_lock ipc
References: <CACT4Y+aqaR8QYk2nyN1n1iaSZWofBEkWuffvsfcqpvmGGQyMAw@mail.gmail.com>
 <20151012122702.GC2544@node> <20151012174945.GC3170@linux-uzut.site>
 <20151012181040.GC6447@node> <20151012185533.GD3170@linux-uzut.site>
 <20151013031821.GA3052@linux-uzut.site> <20151013123028.GA12934@node>
 <CACT4Y+ZBdLqPdW+fJm=-=zJfbVFgQsgiy+eqiDTWp9rW43u+tw@mail.gmail.com>
 <20151105142336.46D907FD@black.fi.intel.com>
 <CACT4Y+bwixTW5YZjPsN7qgCbhR=HR=SMoZi9yHfBaFWdqDkoXQ@mail.gmail.com>
From: Manfred Spraul <manfred@colorfullife.com>
Message-ID: <5687B576.7020303@colorfullife.com>
Date: Sat, 2 Jan 2016 12:33:10 +0100
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bwixTW5YZjPsN7qgCbhR=HR=SMoZi9yHfBaFWdqDkoXQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, syzkaller <syzkaller@googlegroups.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, Joe Perches <joe@perches.com>, sds@tycho.nsa.gov, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, mhocko@suse.cz, gang.chen.5i5j@gmail.com, Peter Feiner <pfeiner@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Andrey Konovalov <andreyknvl@google.com>, Sasha Levin <sasha.levin@oracle.com>

Hi Dmitry,

shm locking differs too much from msg/sem locking, I never looked at it 
in depth, so I'm not able to perform a proper review.

Except for the obvious: Races that can be triggered from user space are 
inacceptable.
Regardless if there is a BUG_ON, a WARN_ON or nothing at all.

On 12/21/2015 04:44 PM, Dmitry Vyukov wrote:
>> +
>> +/* This is called by fork, once for every shm attach. */
>> +static void shm_open(struct vm_area_struct *vma)
>> +{
>> +       int err = __shm_open(vma);
>> +       /*
>> +        * We raced in the idr lookup or with shm_destroy().
>> +        * Either way, the ID is busted.
>> +        */
>> +       WARN_ON_ONCE(err);
>>   }
Is it possible to trigger this race? Parallel IPC_RMID & fork()?

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
