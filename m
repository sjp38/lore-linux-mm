Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF08D6B2F68
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 08:19:10 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t3-v6so7440745oif.20
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 05:19:10 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0074.outbound.protection.outlook.com. [104.47.42.74])
        by mx.google.com with ESMTPS id t84-v6si5341221oij.173.2018.08.24.05.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Aug 2018 05:19:09 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180716115058.5559-1-mhocko@kernel.org>
 <8cbfb09f-0c5a-8d43-1f5e-f3ff7612e289@I-love.SAKURA.ne.jp>
 <20180824113248.GH29735@dhcp22.suse.cz>
 <b088e382-e90e-df63-a079-19b2ae2b985d@gmail.com>
 <20180824115226.GK29735@dhcp22.suse.cz>
 <a27ad1a3-34bd-6b7d-fd09-7737ec3c888d@gmail.com>
 <20180824120339.GL29735@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <eb546bcb-9c5f-7d5d-43a7-bfde489f0e7f@amd.com>
Date: Fri, 24 Aug 2018 14:18:44 +0200
MIME-Version: 1.0
In-Reply-To: <20180824120339.GL29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kvm@vger.kernel.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Dimitri Sivanich <sivanich@sgi.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, Jani Nikula <jani.nikula@linux.intel.com>, Leon Romanovsky <leonro@mellanox.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, LKML <linux-kernel@vger.kernel.org>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Felix Kuehling <felix.kuehling@amd.com>

Am 24.08.2018 um 14:03 schrieb Michal Hocko:
> On Fri 24-08-18 13:57:52, Christian KA?nig wrote:
>> Am 24.08.2018 um 13:52 schrieb Michal Hocko:
>>> On Fri 24-08-18 13:43:16, Christian KA?nig wrote:
> [...]
>>>> That won't work like this there might be multiple
>>>> invalidate_range_start()/invalidate_range_end() pairs open at the same time.
>>>> E.g. the lock might be taken recursively and that is illegal for a
>>>> rw_semaphore.
>>> I am not sure I follow. Are you saying that one invalidate_range might
>>> trigger another one from the same path?
>> No, but what can happen is:
>>
>> invalidate_range_start(A,B);
>> invalidate_range_start(C,D);
>> ...
>> invalidate_range_end(C,D);
>> invalidate_range_end(A,B);
>>
>> Grabbing the read lock twice would be illegal in this case.
> I am sorry but I still do not follow. What is the context the two are
> called from?

I don't have the slightest idea.

> Can you give me an example. I simply do not see it in the
> code, mostly because I am not familiar with it.

I'm neither.

We stumbled over that by pure observation and after discussing the 
problem with Jerome came up with this solution.

No idea where exactly that case comes from, but I can confirm that it 
indeed happens.

Regards,
Christian.
