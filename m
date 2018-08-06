Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 554E96B000D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 09:29:19 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s68-v6so11822592oih.23
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 06:29:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c17-v6si7498896oic.229.2018.08.06.06.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 06:29:15 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] virtio_balloon: replace oom notifier with shrinker
References: <1533285146-25212-1-git-send-email-wei.w.wang@intel.com>
 <1533285146-25212-3-git-send-email-wei.w.wang@intel.com>
 <16c56ee5-eef7-dd5f-f2b6-e3c11df2765c@i-love.sakura.ne.jp>
 <5B681B41.6070205@intel.com>
 <c8d25019-1990-f0dd-c83d-e4def5b5f7fe@i-love.sakura.ne.jp>
 <286AC319A985734F985F78AFA26841F7397222E8@SHSMSX101.ccr.corp.intel.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <109ff5ec-692d-67fe-4c5a-2de8b48e8300@i-love.sakura.ne.jp>
Date: Mon, 6 Aug 2018 22:28:59 +0900
MIME-Version: 1.0
In-Reply-To: <286AC319A985734F985F78AFA26841F7397222E8@SHSMSX101.ccr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 2018/08/06 21:44, Wang, Wei W wrote:
> On Monday, August 6, 2018 6:29 PM, Tetsuo Handa wrote:
>> On 2018/08/06 18:56, Wei Wang wrote:
>>> On 08/03/2018 08:11 PM, Tetsuo Handa wrote:
>>>> On 2018/08/03 17:32, Wei Wang wrote:
>>>>> +static int virtio_balloon_register_shrinker(struct virtio_balloon
>>>>> +*vb) {
>>>>> +A A A  vb->shrinker.scan_objects = virtio_balloon_shrinker_scan;
>>>>> +A A A  vb->shrinker.count_objects = virtio_balloon_shrinker_count;
>>>>> +A A A  vb->shrinker.batch = 0;
>>>>> +A A A  vb->shrinker.seeks = DEFAULT_SEEKS;
>>>> Why flags field is not set? If vb is allocated by kmalloc(GFP_KERNEL)
>>>> and is nowhere zero-cleared, KASAN would complain it.
>>>
>>> Could you point where in the code that would complain it?
>>> I only see two shrinker flags (NUMA_AWARE and MEMCG_AWARE), and
>> they seem not related to that.
>>
>> Where is vb->shrinker.flags initialized?
> 
> Is that mandatory to be initialized?

Of course. ;-)

> I find it's not initialized in most shrinkers (e.g. zs_register_shrinker, huge_zero_page_shrinker).

Because most shrinkers are "statically initialized (which means that unspecified fields are
implicitly zero-cleared)" or "dynamically allocated with __GFP_ZERO or zero-cleared using
memset() (which means that all fields are once zero-cleared)".

And if you once zero-clear vb at allocation time, you will get a bonus that
calling unregister_shrinker() without corresponding register_shrinker() is safe
(which will simplify initialization failure path).
