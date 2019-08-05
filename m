Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F330BC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:20:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D7A6217F4
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:20:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D7A6217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C67B6B0003; Mon,  5 Aug 2019 00:20:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3506C6B0005; Mon,  5 Aug 2019 00:20:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 217EC6B0006; Mon,  5 Aug 2019 00:20:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0F786B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 00:20:54 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id m198so71244987qke.22
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 21:20:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=wdZW2uL5IbhafpWKB6FLhdhDUn4cBxmP9oQw5MeLpJA=;
        b=bJEfjjnZN17KVV8EOpnTCOTkICKGLvmS6mA/Mko1Tj4E5/c+25smniRJtHWpVPoI1w
         qvGgjroTAjdsuctYBPhaw36qJ0KfwhmYw5lFFjkES9F9mi0ZVnYmqEmNeHkcVth2bb41
         Gq7zN4jXs5cHiLaxtUPp2lj1dshoUK1XCW39Z+8Ox8x57iE2IW3maT13LnpgiFYOKlYE
         6ARPzAkbZPEWJrmf0mzEFr1zq6YBUimJakbzJ3RdtO0jhyxmmpXR3K5M/R0yyvd/bkpt
         MZsEguZ07juv3f9HxNXfL6hMn3ca8tHIFNqicfvRyoP+ONn2hTc8XxY/07DqVxjPnUD1
         +i2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/5lQBZh13zj2wEadOJMX4yT0dOpD89WWB9tytlk5W7q/6mTg8
	vEzDd4awWfEmED3+ZB4qleWB2EZgpypuUWfJa08K5lXuMn6oFzAUsEHijebEjIUWHwYdtWI9/8m
	uXYIGq3cOWM6ioHZHiagVvLzyO9iNEQbNTYrHX/ARJ5IrA6QnlacAHyHlyuyksvLHxQ==
X-Received: by 2002:a05:620a:11a1:: with SMTP id c1mr103468718qkk.234.1564978854722;
        Sun, 04 Aug 2019 21:20:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydMC+rLPF7d92HXBX7Grnnkrcj8eo7jqcvuGoCkwDWlTYd1frbKNaudYW/58QncXUNN0mg
X-Received: by 2002:a05:620a:11a1:: with SMTP id c1mr103468695qkk.234.1564978854064;
        Sun, 04 Aug 2019 21:20:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564978854; cv=none;
        d=google.com; s=arc-20160816;
        b=FvdF15NXCRLy02Yz6MuffhnZgojD/oFVbbVt1fdFyaGRh0TfHI+UuAHgglKqTqtBUi
         AQx2G53Im6x5VvYjtcOKDMghxp6e7+1aaRkeNUilN9egluF+uiBx7fVAPE26s6VYK8Kg
         YC1ueX2OU6d3F/KSAlUSNbLys8FdOVXYovyQjOAvpdWDlFOaGwxYJLz68qGC7MkD+4J7
         2yv5pP55IciF9UZqSj2gDhL1tfQsdwdv9exdYRbHuldAcYXelzMmtlTq7XjyPMKmM7YD
         vsXcb1/J9yQ7a/fqulTYQnSCiLsXc9nYDJnGNYa4cXUgVfcy2gSrByaASLcf+Tmn5f6Z
         jiaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=wdZW2uL5IbhafpWKB6FLhdhDUn4cBxmP9oQw5MeLpJA=;
        b=E9sPXlUCoTdRGMXL1IX+pA40pFzUxFeMMEub5E9ZEG/QjmnCvM2rmKTVO8PtDzmdLS
         /L4FdS6+XXCOPW1CkVmbiLV32FI/AiKge286bGfURv/YeshpWKt+MZuTJwdmEIFxoZKY
         cyJCn2vFGdkIjQRArbi7c7cdVxy99r3gUmOaULiVIM4SPy+BsJhTOXLHBOyKXTbc8nf3
         JO8PMkE95mj1LPW4iPQw8l8BfiueTWu+UlpuBd9bB8plwTWWZR1dKe0Pe9MKIgAfJ8wT
         S8dYUPaGv5RtIZOG7X5IAnm1cdUykcmz3w0KH2UoFZh5LrEdvVQ4EMRY653WqkYNCnlC
         KSIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z25si46916584qtq.66.2019.08.04.21.20.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 21:20:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4E8B5A3EB3;
	Mon,  5 Aug 2019 04:20:53 +0000 (UTC)
Received: from [10.72.12.115] (ovpn-12-115.pek2.redhat.com [10.72.12.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 870955D9E2;
	Mon,  5 Aug 2019 04:20:47 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com> <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <11b2a930-eae4-522c-4132-3f8a2da05666@redhat.com>
Date: Mon, 5 Aug 2019 12:20:45 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190802124613.GA11245@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 05 Aug 2019 04:20:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/2 下午8:46, Jason Gunthorpe wrote:
> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
>>> This must be a proper barrier, like a spinlock, mutex, or
>>> synchronize_rcu.
>>
>> I start with synchronize_rcu() but both you and Michael raise some
>> concern.
> I've also idly wondered if calling synchronize_rcu() under the various
> mm locks is a deadlock situation.


Maybe, that's why I suggest to use vhost_work_flush() which is much 
lightweight can can achieve the same function. It can guarantee all 
previous work has been processed after vhost_work_flush() return.


>
>> Then I try spinlock and mutex:
>>
>> 1) spinlock: add lots of overhead on datapath, this leads 0 performance
>> improvement.
> I think the topic here is correctness not performance improvement


But the whole series is to speed up vhost.


>
>> 2) SRCU: full memory barrier requires on srcu_read_lock(), which still leads
>> little performance improvement
>   
>> 3) mutex: a possible issue is need to wait for the page to be swapped in (is
>> this unacceptable ?), another issue is that we need hold vq lock during
>> range overlap check.
> I have a feeling that mmu notififers cannot safely become dependent on
> progress of swap without causing deadlock. You probably should avoid
> this.


Yes, so that's why I try to synchronize the critical region by myself.


>>> And, again, you can't re-invent a spinlock with open coding and get
>>> something better.
>> So the question is if waiting for swap is considered to be unsuitable for
>> MMU notifiers. If not, it would simplify codes. If not, we still need to
>> figure out a possible solution.
>>
>> Btw, I come up another idea, that is to disable preemption when vhost thread
>> need to access the memory. Then register preempt notifier and if vhost
>> thread is preempted, we're sure no one will access the memory and can do the
>> cleanup.
> I think you should use the spinlock so at least the code is obviously
> functionally correct and worry about designing some properly justified
> performance change after.
>
> Jason


Spinlock is correct but make the whole series meaningless consider it 
won't bring any performance improvement.

Thanks


