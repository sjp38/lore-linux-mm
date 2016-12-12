Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9753B6B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 09:49:34 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so250073104pgc.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 06:49:34 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id b34si43679632pld.128.2016.12.12.06.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 06:49:33 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id p66so1184919pga.2
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 06:49:33 -0800 (PST)
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
References: <20161205153132.283fcb0e@redhat.com>
 <20161212083812.GA19987@rapoport-lnx> <20161212104042.0a011212@redhat.com>
 <20161212141433.GB19987@rapoport-lnx>
From: John Fastabend <john.fastabend@gmail.com>
Message-ID: <584EB8DF.8000308@gmail.com>
Date: Mon, 12 Dec 2016 06:49:03 -0800
MIME-Version: 1.0
In-Reply-To: <20161212141433.GB19987@rapoport-lnx>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Kalman Meth <METH@il.ibm.com>, Vladislav Yasevich <vyasevich@gmail.com>

On 16-12-12 06:14 AM, Mike Rapoport wrote:
> On Mon, Dec 12, 2016 at 10:40:42AM +0100, Jesper Dangaard Brouer wrote:
>>
>> On Mon, 12 Dec 2016 10:38:13 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
>>
>>> Hello Jesper,
>>>
>>> On Mon, Dec 05, 2016 at 03:31:32PM +0100, Jesper Dangaard Brouer wrote:
>>>> Hi all,
>>>>
>>>> This is my design for how to safely handle RX zero-copy in the network
>>>> stack, by using page_pool[1] and modifying NIC drivers.  Safely means
>>>> not leaking kernel info in pages mapped to userspace and resilience
>>>> so a malicious userspace app cannot crash the kernel.
>>>>
>>>> Design target
>>>> =============
>>>>
>>>> Allow the NIC to function as a normal Linux NIC and be shared in a
>>>> safe manor, between the kernel network stack and an accelerated
>>>> userspace application using RX zero-copy delivery.
>>>>
>>>> Target is to provide the basis for building RX zero-copy solutions in
>>>> a memory safe manor.  An efficient communication channel for userspace
>>>> delivery is out of scope for this document, but OOM considerations are
>>>> discussed below (`Userspace delivery and OOM`_).  
>>>
>>> Sorry, if this reply is a bit off-topic.
>>
>> It is very much on topic IMHO :-)
>>
>>> I'm working on implementation of RX zero-copy for virtio and I've dedicated
>>> some thought about making guest memory available for physical NIC DMAs.
>>> I believe this is quite related to your page_pool proposal, at least from
>>> the NIC driver perspective, so I'd like to share some thoughts here.
>>
>> Seems quite related. I'm very interested in cooperating with you! I'm
>> not very familiar with virtio, and how packets/pages gets channeled
>> into virtio.
> 
> They are copied :-)
> Presuming we are dealing only with vhost backend, the received skb
> eventually gets converted to IOVs, which in turn are copied to the guest
> memory. The IOVs point to the guest memory that is allocated by virtio-net
> running in the guest.
> 

Great I'm also doing something similar.

My plan was to embed the zero copy as an AF_PACKET mode and then push
a AF_PACKET backend into vhost. I'll post a patch later this week.

>>> The idea is to dedicate one (or more) of the NIC's queues to a VM, e.g.
>>> using macvtap, and then propagate guest RX memory allocations to the NIC
>>> using something like new .ndo_set_rx_buffers method.
>>
>> I believe the page_pool API/design aligns with this idea/use-case.
>>
>>> What is your view about interface between the page_pool and the NIC
>>> drivers?
>>
>> In my Prove-of-Concept implementation, the NIC driver (mlx5) register
>> a page_pool per RX queue.  This is done for two reasons (1) performance
>> and (2) for supporting use-cases where only one single RX-ring queue is
>> (re)configured to support RX-zero-copy.  There are some associated
>> extra cost of enabling this mode, thus it makes sense to only enable it
>> when needed.
>>
>> I've not decided how this gets enabled, maybe some new driver NDO.  It
>> could also happen when a XDP program gets loaded, which request this
>> feature.
>>
>> The macvtap solution is nice and we should support it, but it requires
>> VM to have their MAC-addr registered on the physical switch.  This
>> design is about adding flexibility. Registering an XDP eBPF filter
>> provides the maximum flexibility for matching the destination VM.
> 
> I'm not very familiar with XDP eBPF, and it's difficult for me to estimate
> what needs to be done in BPF program to do proper conversion of skb to the
> virtio descriptors.

I don't think XDP has much to do with this code and they should be done
separately. XDP runs eBPF code on received packets after the DMA engine
has already placed the packet in memory so its too late in the process.

The other piece here is enabling XDP in vhost but that is again separate
IMO.

Notice that ixgbe supports pushing packets into a macvlan via 'tc'
traffic steering commands so even though macvlan gets an L2 address it
doesn't mean it can't use other criteria to steer traffic to it.

> 
> We were not considered using XDP yet, so we've decided to limit the initial
> implementation to macvtap because we can ensure correspondence between a
> NIC queue and virtual NIC, which is not the case with more generic tap
> device. It could be that use of XDP will allow for a generic solution for
> virtio case as well.

Interesting this was one of the original ideas behind the macvlan
offload mode. iirc Vlad also was interested in this.

I'm guessing this was used because of the ability to push macvlan onto
its own queue?

>  
>>
>>> Have you considered using "push" model for setting the NIC's RX memory?
>>
>> I don't understand what you mean by a "push" model?
> 
> Currently, memory allocation in NIC drivers boils down to alloc_page with
> some wrapping code. I see two possible ways to make NIC use of some
> preallocated pages: either NIC driver will call an API (probably different
> from alloc_page) to obtain that memory, or there will be NDO API that
> allows to set the NIC's RX buffers. I named the later case "push".

I prefer the ndo op. This matches up well with AF_PACKET model where we
have "slots" and offload is just a transparent "push" of these "slots"
to the driver. Below we have a snippet of our proposed API,

(https://patchwork.ozlabs.org/patch/396714/ note the descriptor mapping
bits will be dropped)

+ * int (*ndo_direct_qpair_page_map) (struct vm_area_struct *vma,
+ *				     struct net_device *dev)
+ *	Called to map queue pair range from split_queue_pairs into
+ *	mmap region.
+

> +
> +static int
> +ixgbe_ndo_qpair_page_map(struct vm_area_struct *vma, struct net_device *dev)
> +{
> +	struct ixgbe_adapter *adapter = netdev_priv(dev);
> +	phys_addr_t phy_addr = pci_resource_start(adapter->pdev, 0);
> +	unsigned long pfn_rx = (phy_addr + RX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
> +	unsigned long pfn_tx = (phy_addr + TX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
> +	unsigned long dummy_page_phy;
> +	pgprot_t pre_vm_page_prot;
> +	unsigned long start;
> +	unsigned int i;
> +	int err;
> +
> +	if (!dummy_page_buf) {
> +		dummy_page_buf = kzalloc(PAGE_SIZE_4K, GFP_KERNEL);
> +		if (!dummy_page_buf)
> +			return -ENOMEM;
> +
> +		for (i = 0; i < PAGE_SIZE_4K / sizeof(unsigned int); i++)
> +			dummy_page_buf[i] = 0xdeadbeef;
> +	}
> +
> +	dummy_page_phy = virt_to_phys(dummy_page_buf);
> +	pre_vm_page_prot = vma->vm_page_prot;
> +	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> +
> +	/* assume the vm_start is 4K aligned address */
> +	for (start = vma->vm_start;
> +	     start < vma->vm_end;
> +	     start += PAGE_SIZE_4K) {
> +		if (start == vma->vm_start + RX_DESC_ADDR_OFFSET) {
> +			err = remap_pfn_range(vma, start, pfn_rx, PAGE_SIZE_4K,
> +					      vma->vm_page_prot);
> +			if (err)
> +				return -EAGAIN;
> +		} else if (start == vma->vm_start + TX_DESC_ADDR_OFFSET) {
> +			err = remap_pfn_range(vma, start, pfn_tx, PAGE_SIZE_4K,
> +					      vma->vm_page_prot);
> +			if (err)
> +				return -EAGAIN;
> +		} else {
> +			unsigned long addr = dummy_page_phy > PAGE_SHIFT;
> +
> +			err = remap_pfn_range(vma, start, addr, PAGE_SIZE_4K,
> +					      pre_vm_page_prot);
> +			if (err)
> +				return -EAGAIN;
> +		}
> +	}
> +	return 0;
> +}
> +

Any thoughts on something like the above? We could push it when net-next
opens. One piece that fits naturally into vhost/macvtap is the kicks and
queue splicing are already there so no need to implement this making the
above patch much simpler.

.John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
