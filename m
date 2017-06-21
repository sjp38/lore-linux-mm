Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33F1B6B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 23:25:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u62so55563082pgb.13
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 20:25:44 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r3si13130671plb.313.2017.06.20.20.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 20:25:43 -0700 (PDT)
Message-ID: <5949E7C0.3050106@intel.com>
Date: Wed, 21 Jun 2017 11:28:00 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v11 6/6] virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com> <1497004901-30593-7-git-send-email-wei.w.wang@intel.com> <20170620190343-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170620190343-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 06/21/2017 12:18 AM, Michael S. Tsirkin wrote:
> On Fri, Jun 09, 2017 at 06:41:41PM +0800, Wei Wang wrote:
>> -	if (!virtqueue_indirect_desc_table_add(vq, desc, num)) {
>> +	if (!virtqueue_indirect_desc_table_add(vq, desc, *num)) {
>>   		virtqueue_kick(vq);
>> -		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>> -		vb->balloon_page_chunk.chunk_num = 0;
>> +		if (busy_wait)
>> +			while (!virtqueue_get_buf(vq, &len) &&
>> +			       !virtqueue_is_broken(vq))
>> +				cpu_relax();
>> +		else
>> +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>
> This is something I didn't previously notice.
> As you always keep a single buffer in flight, you do not
> really need indirect at all. Just add all descriptors
> in the ring directly, then kick.
>
> E.g.
> 	virtqueue_add_first
> 	virtqueue_add_next
> 	virtqueue_add_last
>
> ?
>
> You also want a flag to avoid allocations but there's no need to do it
> per descriptor, set it on vq.
>

Without using the indirect table, I'm thinking about changing to use
the standard sg (i.e. struct scatterlist), instead of vring_desc, so that
we don't need to modify or add any new functions of virtqueue_add().

In this case, we will kmalloc an array of sgs in probe(), and we can add
the sgs one by one to the vq, which won't trigger the allocation of an
indirect table inside virtqueue_add(), and then kick when all are added.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
