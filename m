Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66543280910
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 08:26:25 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id v125so166706299qkh.5
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 05:26:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e134si8038344qka.272.2017.03.10.05.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 05:26:24 -0800 (PST)
Subject: Re: [virtio-dev] Re: [PATCH v7 kernel 3/5] virtio-balloon:
 implementation of VIRTIO_BALLOON_F_CHUNK_TRANSFER
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
 <1488519630-89058-4-git-send-email-wei.w.wang@intel.com>
 <20170308054813-mutt-send-email-mst@kernel.org> <58C279B7.2060106@intel.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <2572fe97-4d28-fb34-4513-924959bc5cb2@redhat.com>
Date: Fri, 10 Mar 2017 14:26:18 +0100
MIME-Version: 1.0
In-Reply-To: <58C279B7.2060106@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Liang Li <liang.z.li@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Liang Li <liliang324@gmail.com>

Am 10.03.2017 um 11:02 schrieb Wei Wang:
> On 03/08/2017 12:01 PM, Michael S. Tsirkin wrote:
>> On Fri, Mar 03, 2017 at 01:40:28PM +0800, Wei Wang wrote:
>>> From: Liang Li <liang.z.li@intel.com>
>>>
>>> The implementation of the current virtio-balloon is not very
>>> efficient, because the pages are transferred to the host one by one.
>>> Here is the breakdown of the time in percentage spent on each
>>> step of the balloon inflating process (inflating 7GB of an 8GB
>>> idle guest).
>>>
>>> 1) allocating pages (6.5%)
>>> 2) sending PFNs to host (68.3%)
>>> 3) address translation (6.1%)
>>> 4) madvise (19%)
>>>
>>> It takes about 4126ms for the inflating process to complete.
>>> The above profiling shows that the bottlenecks are stage 2)
>>> and stage 4).
>>>
>>> This patch optimizes step 2) by transfering pages to the host in
>>> chunks. A chunk consists of guest physically continuous pages, and
>>> it is offered to the host via a base PFN (i.e. the start PFN of
>>> those physically continuous pages) and the size (i.e. the total
>>> number of the pages). A normal chunk is formated as below:
>>> -----------------------------------------------
>>> |  Base (52 bit)               | Size (12 bit)|
>>> -----------------------------------------------
>>> For large size chunks, an extended chunk format is used:
>>> -----------------------------------------------
>>> |                 Base (64 bit)               |
>>> -----------------------------------------------
>>> -----------------------------------------------
>>> |                 Size (64 bit)               |
>>> -----------------------------------------------
>>>
>>> By doing so, step 4) can also be optimized by doing address
>>> translation and madvise() in chunks rather than page by page.
>>>
>>> This optimization requires the negotation of a new feature bit,
>>> VIRTIO_BALLOON_F_CHUNK_TRANSFER.
>>>
>>> With this new feature, the above ballooning process takes ~590ms
>>> resulting in an improvement of ~85%.
>>>
>>> TODO: optimize stage 1) by allocating/freeing a chunk of pages
>>> instead of a single page each time.
>>>
>>> Signed-off-by: Liang Li <liang.z.li@intel.com>
>>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>>> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
>>> Cc: Michael S. Tsirkin <mst@redhat.com>
>>> Cc: Paolo Bonzini <pbonzini@redhat.com>
>>> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
>>> Cc: Amit Shah <amit.shah@redhat.com>
>>> Cc: Dave Hansen <dave.hansen@intel.com>
>>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>>> Cc: David Hildenbrand <david@redhat.com>
>>> Cc: Liang Li <liliang324@gmail.com>
>>> Cc: Wei Wang <wei.w.wang@intel.com>
>> Does this pass sparse? I see some endian-ness issues here.
> 
> "pass sparse"- what does that mean?
> I didn't see any complaints from "make" on my machine.

https://kernel.org/doc/html/latest/dev-tools/sparse.html

Static code analysis. You have to run it explicitly.

-- 
Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
