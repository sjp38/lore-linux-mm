Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9C856B03B2
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:36:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b13so168859541pgn.4
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:36:16 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y73si12475574pfg.102.2017.06.21.01.36.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 01:36:15 -0700 (PDT)
Message-ID: <594A307F.1090108@intel.com>
Date: Wed, 21 Jun 2017 16:38:23 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [Qemu-devel] [PATCH v11 4/6] mm: function to offer a page block
 on the free list
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>	<1497004901-30593-5-git-send-email-wei.w.wang@intel.com>	<b92af473-f00e-b956-ea97-eb4626601789@intel.com>	<1497977049.20270.100.camel@redhat.com>	<7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com> <1497979740.20270.102.camel@redhat.com>
In-Reply-To: <1497979740.20270.102.camel@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com
Cc: Nitesh Narayan Lal <nilal@redhat.com>

On 06/21/2017 01:29 AM, Rik van Riel wrote:
> On Tue, 2017-06-20 at 18:49 +0200, David Hildenbrand wrote:
>> On 20.06.2017 18:44, Rik van Riel wrote:
>>> Nitesh Lal (on the CC list) is working on a way
>>> to efficiently batch recently freed pages for
>>> free page hinting to the hypervisor.
>>>
>>> If that is done efficiently enough (eg. with
>>> MADV_FREE on the hypervisor side for lazy freeing,
>>> and lazy later re-use of the pages), do we still
>>> need the harder to use batch interface from this
>>> patch?
>>>
>> David's opinion incoming:
>>
>> No, I think proper free page hinting would be the optimum solution,
>> if
>> done right. This would avoid the batch interface and even turn
>> virtio-balloon in some sense useless.
> I agree with that.  Let me go into some more detail of
> what Nitesh is implementing:
>
> 1) In arch_free_page, the being-freed page is added
>     to a per-cpu set of freed pages.

I got some questions here:

1. Are the pages managed one by one on the per-CPU set?
For example, when there are 2 adjacent pages, are they still
put as two nodes on the per-CPU list? or the buddy algorithm
will be re-implemented on the per-CPU list as well?

2. Looks like this will be added to the common free function.
Normally, people may not need the free page hint, do they
need to carry the added burden?


> 2) Once that set is full, arch_free_pages goes into a
>     slow path, which:
>     2a) Iterates over the set of freed pages, and
>     2b) Checks whether they are still free, and

The pages that have been double checked as "free"
pages here and added to the list for the hypervisor can
also be immediately used.


>     2c) Adds the still free pages to a list that is
>         to be passed to the hypervisor, to be MADV_FREEd.
>     2d) Makes that hypercall.
>
> Meanwhile all arch_alloc_pages has to do is make sure it
> does not allocate a page while it is currently being
> MADV_FREEd on the hypervisor side.

Is this proposed to replace the balloon driver?

>
> The code Wei is working on looks like it could be
> suitable for steps (2c) and (2d) above. Nitesh already
> has code for steps 1 through 2b.
>

May I know the advantages of the added steps? Thanks.

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
