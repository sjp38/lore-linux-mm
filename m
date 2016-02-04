Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id F28394403D8
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 19:46:51 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id u30so29900326qge.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 16:46:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g131si7972083qkb.102.2016.02.03.16.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 16:46:51 -0800 (PST)
Subject: Re: [RFC][PATCH 0/3] Speed up SLUB poisoning + disable checks
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
 <20160126070320.GB28254@js1304-P5Q-DELUXE> <56B24B01.30306@redhat.com>
 <CAGXu5jJK1UhNX7h2YmxxTrCABr8oS=Y2OBLMr4KTxk7LctRaiQ@mail.gmail.com>
 <56B272B8.2050808@redhat.com>
 <alpine.DEB.2.20.1602031658060.6707@east.gentwo.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56B29F77.1010607@redhat.com>
Date: Wed, 3 Feb 2016 16:46:47 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1602031658060.6707@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@fedoraproject.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 02/03/2016 03:02 PM, Christoph Lameter wrote:
>> The fast path uses the per cpu caches. No locks are taken and there
>> is no IRQ disabling. For concurrency protection this comment
>> explains it best:
>>
>> /*
>>   * The cmpxchg will only match if there was no additional
>>   * operation and if we are on the right processor.
>>   *
>>   * The cmpxchg does the following atomically (without lock
>>   * semantics!)
>>   * 1. Relocate first pointer to the current per cpu area.
>>   * 2. Verify that tid and freelist have not been changed
>>   * 3. If they were not changed replace tid and freelist
>>   *
>>   * Since this is without lock semantics the protection is only
>>   * against code executing on this cpu *not* from access by
>>   * other cpus.
>>   */
>>
>> in the slow path, IRQs and locks have to be taken at the minimum.
>> The debug options disable ever loading the per CPU caches so it
>> always falls back to the slow path.
>
> You could add the use of per cpu lists to the slow paths as well in
> order
> to increase performance. Then weave in the debugging options.
>

How would that work? The use of the CPU caches is what defines the
fast path so I'm not sure how to add them in on the slow path and
not affect the fast path.
  
> But the performance of the fast path is critical to the overall
> performance of the kernel as a whole since this is a heavily used code
> path for many subsystems.
>

I also notice that __CMPXCHG_DOUBLE is turned off when the debug
options are turned on. I don't see any details about why. What's
the reason for turning it off when the debug options are enabled?

Thanks,
Laura  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
