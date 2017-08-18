Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 021D16B02C3
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 04:38:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n11so14875871pgt.9
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 01:38:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k133si3233936pgc.90.2017.08.18.01.38.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 01:38:52 -0700 (PDT)
Message-ID: <5996A845.4010405@intel.com>
Date: Fri, 18 Aug 2017 16:41:41 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v14 5/5] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com> <1502940416-42944-6-git-send-email-wei.w.wang@intel.com> <20170818045519-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170818045519-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 08/18/2017 10:13 AM, Michael S. Tsirkin wrote:
> On Thu, Aug 17, 2017 at 11:26:56AM +0800, Wei Wang wrote:
>> Add a new vq to report hints of guest free pages to the host.
> Please add some text here explaining the report_free_page_signal
> thing.
>
>
> I also really think we need some kind of ID in the
> buffer to do a handshake. whenever id changes you
> add another outbuf.

Please let me introduce the current design first:
1) device put the signal buf to the vq and notify the driver (we need
a buffer because currently the device can't notify when the vq is empty);

2) the driver starts the report of free page blocks via inbuf;

3) the driver adds an the signal buf via outbuf to tell the device all 
are reported.


Could you please elaborate more on the usage of ID?

>> +retry:
>> +	ret = virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
>> +	virtqueue_kick(vq);
>> +	if (unlikely(ret == -ENOSPC)) {
> what if there's another error?

Another error is -EIO, how about disabling the free page report feature?
(I also saw it isn't handled in many other virtio devices e.g. virtio-net)

>> +		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>> +		goto retry;
>> +	}
> what is this trickery doing? needs more comments or
> a simplification.

Just this:
if the vq is full, blocking wait till an entry gets released, then 
retry. This is the
final one, which puts the signal buf to the vq to signify the end of the 
report and
the mm lock is not held here, so it is fine to block.


>
>
>> +}
>> +
>> +static void report_free_page(struct work_struct *work)
>> +{
>> +	struct virtio_balloon *vb;
>> +
>> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
>> +	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> That's a lot of work here. And system_wq documentation says:
>   *
>   * system_wq is the one used by schedule[_delayed]_work[_on]().
>   * Multi-CPU multi-threaded.  There are users which expect relatively
>   * short queue flush time.  Don't queue works which can run for too
>   * long.
>
> You might want to create your own wq, maybe even with WQ_CPU_INTENSIVE.

Thanks for the reminder. If not creating a new wq, how about 
system_unbound_wq?
The first round of live migration needs the free pages, in that way we 
can have the
pages reported to the hypervisor quicker.

>
>> +	report_free_page_completion(vb);
> So first you get list of pages, then an outbuf telling you
> what they are in end of.  I think it's backwards.
> Add an outbuf first followed by inbufs that tell you
> what they are.


If we have the signal filled with those flags like
VIRTIO_BALLOON_F_FREE_PAGE_REPORT_START,
Probably not necessary to have an inbuf followed by an outbuf, right?


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
