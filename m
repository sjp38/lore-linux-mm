Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F31C5280911
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 06:36:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 190so82772089pgg.3
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 03:36:11 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d198si2708450pga.192.2017.03.10.03.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 03:36:11 -0800 (PST)
Message-ID: <58C28FF8.5040403@intel.com>
Date: Fri, 10 Mar 2017 19:37:28 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 kernel 3/5] virtio-balloon: implementation of VIRTIO_BALLOON_F_CHUNK_TRANSFER
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com> <1488519630-89058-4-git-send-email-wei.w.wang@intel.com> <20170309141411.GZ16328@bombadil.infradead.org>
In-Reply-To: <20170309141411.GZ16328@bombadil.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, Liang Li <liang.z.li@intel.com>, "Michael S . Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

On 03/09/2017 10:14 PM, Matthew Wilcox wrote:
> On Fri, Mar 03, 2017 at 01:40:28PM +0800, Wei Wang wrote:
>> From: Liang Li <liang.z.li@intel.com>
>> 1) allocating pages (6.5%)
>> 2) sending PFNs to host (68.3%)
>> 3) address translation (6.1%)
>> 4) madvise (19%)
>>
>> This patch optimizes step 2) by transfering pages to the host in
>> chunks. A chunk consists of guest physically continuous pages, and
>> it is offered to the host via a base PFN (i.e. the start PFN of
>> those physically continuous pages) and the size (i.e. the total
>> number of the pages). A normal chunk is formated as below:
>> -----------------------------------------------
>> |  Base (52 bit)               | Size (12 bit)|
>> -----------------------------------------------
>> For large size chunks, an extended chunk format is used:
>> -----------------------------------------------
>> |                 Base (64 bit)               |
>> -----------------------------------------------
>> -----------------------------------------------
>> |                 Size (64 bit)               |
>> -----------------------------------------------
> What's the advantage to extended chunks?  IOW, why is the added complexity
> of having two chunk formats worth it?  You already reduced the overhead by
> a factor of 4096 with normal chunks ... how often are extended chunks used
> and how much more efficient are they than having several normal chunks?
>

Right, chunk_ext may be rarely used, thanks. I will remove chunk_ext if 
there is no objection from others.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
