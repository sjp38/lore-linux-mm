Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 652AD6B036A
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:49:43 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id g83so38343650qkb.14
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:49:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s6si11684400qkl.38.2017.06.20.09.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 09:49:42 -0700 (PDT)
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
 <1497977049.20270.100.camel@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
Date: Tue, 20 Jun 2017 18:49:33 +0200
MIME-Version: 1.0
In-Reply-To: <1497977049.20270.100.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com
Cc: Nitesh Narayan Lal <nilal@redhat.com>

On 20.06.2017 18:44, Rik van Riel wrote:
> On Mon, 2017-06-12 at 07:10 -0700, Dave Hansen wrote:
> 
>> The hypervisor is going to throw away the contents of these pages,
>> right?  As soon as the spinlock is released, someone can allocate a
>> page, and put good data in it.  What keeps the hypervisor from
>> throwing
>> away good data?
> 
> That looks like it may be the wrong API, then?
> 
> We already have hooks called arch_free_page and
> arch_alloc_page in the VM, which are called when
> pages are freed, and allocated, respectively.
> 
> Nitesh Lal (on the CC list) is working on a way
> to efficiently batch recently freed pages for
> free page hinting to the hypervisor.
> 
> If that is done efficiently enough (eg. with
> MADV_FREE on the hypervisor side for lazy freeing,
> and lazy later re-use of the pages), do we still
> need the harder to use batch interface from this
> patch?
> 
David's opinion incoming:

No, I think proper free page hinting would be the optimum solution, if
done right. This would avoid the batch interface and even turn
virtio-balloon in some sense useless.

-- 

Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
