Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E86896B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:29:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u199so80635710pgb.13
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:29:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f3si8275767plb.337.2017.07.25.02.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 02:29:23 -0700 (PDT)
Message-ID: <59771010.6080108@intel.com>
Date: Tue, 25 Jul 2017 17:32:00 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com> <1499863221-16206-7-git-send-email-wei.w.wang@intel.com> <20170714123023.GA2624@dhcp22.suse.cz> <20170714181523-mutt-send-email-mst@kernel.org> <20170717152448.GN12888@dhcp22.suse.cz> <596D6E7E.4070700@intel.com> <20170719081311.GC26779@dhcp22.suse.cz> <596F4A0E.4010507@intel.com> <20170724090042.GF25221@dhcp22.suse.cz>
In-Reply-To: <20170724090042.GF25221@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 07/24/2017 05:00 PM, Michal Hocko wrote:
> On Wed 19-07-17 20:01:18, Wei Wang wrote:
>> On 07/19/2017 04:13 PM, Michal Hocko wrote:
> [...
>>> All you should need is the check for the page reference count, no?  I
>>> assume you do some sort of pfn walk and so you should be able to get an
>>> access to the struct page.
>> Not necessarily - the guest struct page is not seen by the hypervisor. The
>> hypervisor only gets those guest pfns which are hinted as unused. From the
>> hypervisor (host) point of view, a guest physical address corresponds to a
>> virtual address of a host process. So, once the hypervisor knows a guest
>> physical page is unsued, it knows that the corresponding virtual memory of
>> the process doesn't need to be transferred in the 1st round.
> I am sorry, but I do not understand. Why cannot _guest_ simply check the
> struct page ref count and send them to the hypervisor?

Were you suggesting the following?
1) get a free page block from the page list using the API;
2) if page->ref_count == 0, send it to the hypervisor

Btw, ref_count may also change at any time.

> Is there any
> documentation which describes the workflow or code which would use your
> new API?
>

It's used in the balloon driver (patch 8). We don't have any docs yet, but
I think the high level workflow is the two steps above.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
