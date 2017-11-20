Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D55046B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 06:40:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id c123so9336078pga.17
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 03:40:54 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b34si6801526plc.374.2017.11.20.03.40.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 03:40:53 -0800 (PST)
Message-ID: <5A12BFB0.5030402@intel.com>
Date: Mon, 20 Nov 2017 19:42:40 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v17 6/6] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com> <1509696786-1597-7-git-send-email-wei.w.wang@intel.com> <5A097548.8000608@intel.com> <20171113192309-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171113192309-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, Nitesh Narayan Lal <nilal@redhat.com>, Rik van Riel <riel@redhat.com>

On 11/14/2017 01:32 AM, Michael S. Tsirkin wrote:
> You should Cc Nitesh who is working on a related feature.

OK, I'll do. We have two more issues which haven't been discussed yet, 
please have a check below.

>
> On Mon, Nov 13, 2017 at 06:34:48PM +0800, Wei Wang wrote:
>> Ping for comments, thanks.
>>
>> On 11/03/2017 04:13 PM, Wei Wang wrote:
>>> +static void virtballoon_cmd_report_free_page_start(struct virtio_balloon *vb)
>>> +{
>>> +	unsigned long flags;
>>> +
>>> +	vb->report_free_page_stop = false;
> this flag is used a lot outside any locks. Why is this safe?
> Please add some comments explaining access to this flag.

I will revert the logic as suggested: vb->report_free_page. Also plan to 
simplify its usage as below.

The flag is set or cleared in the config handler according to the 
new_cmd_id given
by the host:

new_cmd_id=0:                    WRITE_ONCE(vb->report_free_page, 
false); // stop reporting
new_cmd_id != old_cmd_id: WRITE_ONCE(vb->report_free_page, true);  // 
start reporting


The flag is read by virtio_balloon_send_free_pages() - the callback to 
report free pages:

if (!READ_ONCE(vb->report_free_page))
                 return false;

I don't find where it could be unsafe then (the flag is written by the 
config handler only).



>
>>> +}
>>> +
>>>    static inline s64 towards_target(struct virtio_balloon *vb)
>>>    {
>>>    	s64 target;
>>> @@ -597,42 +673,147 @@ static void update_balloon_size_func(struct work_struct *work)
>>>    		queue_work(system_freezable_wq, work);
>>>    }
>>> -static int init_vqs(struct virtio_balloon *vb)
>>> +static bool virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
>>> +					   unsigned long nr_pages)
>>>    {
>>> -	struct virtqueue *vqs[3];
>>> -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
>>> -	static const char * const names[] = { "inflate", "deflate", "stats" };
>>> -	int err, nvqs;
>>> +	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
>>> +	void *addr = (void *)pfn_to_kaddr(pfn);
> How do we know all free pages have a kaddr?

For x86_64, it works well since the kernel has all the physical memory 
mapped already. But for 32-bit kernel, yes, the high memory usually 
isn't mapped and thus no kaddr. Essentially, this pfn_to_kaddr convert 
isn't necessary, we do it here because the current API that virtio has 
is based on "struct scatterlist", which takes a kaddr, and this kaddr is 
then convert back to physical address in virtqueue_add() when assigning 
to desc->addr.

I think a better solution would be to add a new API, which directly 
assigns the caller's guest physical address to desc->addr, similar to 
the previous implementation "add_one_chunk()" 
(https://lists.gnu.org/archive/html/qemu-devel/2017-06/msg02452.html). 
But we can change that to a general virtio API:
virtqueue_add_one_desc(struct virtqueue *_vq, u64 base_addr, u32 size, 
bool in_desc, void *data);

What do you think?

Best,
Wei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
