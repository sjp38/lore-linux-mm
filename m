Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA9D6B025E
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:09:36 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id k15so6416643qtg.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:09:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n55si18733303qta.191.2017.01.18.02.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 02:09:35 -0800 (PST)
Subject: Re: [PATCH v6 kernel 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <2a32f616-25a8-ba5a-f74c-d619fc8ab333@redhat.com>
Date: Wed, 18 Jan 2017 11:09:30 +0100
MIME-Version: 1.0
In-Reply-To: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, kvm@vger.kernel.org
Cc: virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, mst@redhat.com, aarcange@redhat.com, dgilbert@redhat.com, quintela@redhat.com

Am 21.12.2016 um 07:52 schrieb Liang Li:
> This patch set contains two parts of changes to the virtio-balloon.
>
> One is the change for speeding up the inflating & deflating process,
> the main idea of this optimization is to use {pfn|length} to present
> the page information instead of the PFNs, to reduce the overhead of
> virtio data transmission, address translation and madvise(). This can
> help to improve the performance by about 85%.
>
> Another change is for speeding up live migration. By skipping process
> guest's unused pages in the first round of data copy, to reduce needless
> data processing, this can help to save quite a lot of CPU cycles and
> network bandwidth. We put guest's unused page information in a
> {pfn|length} array and send it to host with the virt queue of
> virtio-balloon. For an idle guest with 8GB RAM, this can help to shorten
> the total live migration time from 2Sec to about 500ms in 10Gbps network
> environment. For an guest with quite a lot of page cache and with little
> unused pages, it's possible to let the guest drop it's page cache before
> live migration, this case can benefit from this new feature too.

I agree that both changes make sense (although the second change just 
smells very racy, as you also pointed out in the patch description),
however I am not sure if virtio-balloon is really the right place for
the latter change.

virtio-balloon is all about ballooning, nothing else. What you're doing
is using it as a way to communicate balloon-unrelated data from/to the
hypervisor. Yes, it is also about guest memory, but completely unrelated
to the purpose of the balloon device.

Maybe using virtio-balloon for this purpose is okay - I have mixed
feelings (especially as I can't tell where else this could go). I would
like to get a second opinion on this.

-- 

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
