Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8A4B8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:29:17 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id k18-v6so10595770pls.12
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:29:17 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id q23-v6si18683584pgj.354.2018.09.10.17.29.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 17:29:16 -0700 (PDT)
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <35c2c79f-efbe-f6b2-43a6-52da82145638@nvidia.com>
 <55b44432-ade5-f090-bfe7-ea20f3e87285@redhat.com>
 <20180910172011.GB3902@linux-r8p5>
 <78fa0507-4789-415b-5b9c-18e3fcefebab@nvidia.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <3db2b742-9e09-a934-e4ef-c87465e6715a@oracle.com>
Date: Mon, 10 Sep 2018 20:29:00 -0400
MIME-Version: 1.0
In-Reply-To: <78fa0507-4789-415b-5b9c-18e3fcefebab@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, Waiman Long <longman@redhat.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On 9/10/18 1:34 PM, John Hubbard wrote:
> On 9/10/18 10:20 AM, Davidlohr Bueso wrote:
>> On Mon, 10 Sep 2018, Waiman Long wrote:
>>> On 09/08/2018 12:13 AM, John Hubbard wrote:
> [...]
>>>> It's also interesting that there are two main huge page systems (THP and Hugetlbfs), and I sometimes
>>>> wonder the obvious thing to wonder: are these sufficiently different to warrant remaining separate,
>>>> long-term?A  Yes, I realize they're quite different in some ways, but still, one wonders. :)
>>>
>>> One major difference between hugetlbfs and THP is that the former has to
>>> be explicitly managed by the applications that use it whereas the latter
>>> is done automatically without the applications being aware that THP is
>>> being used at all. Performance wise, THP may or may not increase
>>> application performance depending on the exact memory access pattern,
>>> though the chance is usually higher that an application will benefit
>>> than suffer from it.
>>>
>>> If an application know what it is doing, using hughtblfs can boost
>>> performance more than it can ever achieved by THP. Many large enterprise
>>> applications, like Oracle DB, are using hugetlbfs and explicitly disable
>>> THP. So unless THP can improve its performance to a level that is
>>> comparable to hugetlbfs, I won't see the later going away.
>>
>> Yep, there are a few non-trivial workloads out there that flat out discourage
>> thp, ie: redis to avoid latency issues.
>>
> 
> Yes, the need for guaranteed, available-now huge pages in some cases is
> understood. That's not the quite same as saying that there have to be two different
> subsystems, though. Nor does it even necessarily imply that the pool has to be
> reserved in the same way as hugetlbfs does it...exactly.
> 
> So I'm wondering if THP behavior can be made to mimic hugetlbfs enough (perhaps
> another option, in addition to "always, never, madvise") that we could just use
> THP in all cases. But the "transparent" could become a sliding scale that could
> go all the way down to "opaque" (hugetlbfs behavior).

Leaving the interface aside, the idea that we could deduplicate redundant parts of the hugetlbfs and THP implementations, without user-visible change, seems promising.
