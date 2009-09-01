Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1455F6B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 12:05:25 -0400 (EDT)
Date: Tue, 1 Sep 2009 09:05:18 -0700
From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] Virtual Machine Device Queues(VMDq) support on KVM
Message-ID: <20090901090518.1193e412@nehalam>
In-Reply-To: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB94861@PDSMSX501.ccr.corp.intel.com>
References: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB94861@PDSMSX501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Cc: "mst@redhat.com" <mst@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@elte.hu" <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "gregory.haskins@gmail.com" <gregory.haskins@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009 14:58:19 +0800
"Xin, Xiaohui" <xiaohui.xin@intel.com> wrote:

>               [RFC] Virtual Machine Device Queues (VMDq) support on KVM
> 
> Network adapter with VMDq technology presents multiple pairs of tx/rx queues,
> and renders network L2 sorting mechanism based on MAC addresses and VLAN tags
> for each tx/rx queue pair. Here we present a generic framework, in which network
> traffic to/from a tx/rx queue pair can be directed from/to a KVM guest without
> any software copy.
> 
> Actually this framework can apply to traditional network adapters which have
> just one tx/rx queue pair. And applications using the same user/kernel interface
> can utilize this framework to send/receive network traffic directly thru a tx/rx
> queue pair in a network adapter.
> 
> We use virtio-net architecture to illustrate the framework.
> 
> 
> |--------------------|     pop               add_buf    |----------------|
> |    Qemu process    |  <---------    TX   <----------  | Guest Kernel   |
> |                    |  --------->         ---------->  |                |
> |    Virtio-net      |     push              get_buf    |                |
> |  (Backend service) |  --------->    RX   ---------->  |  Virtio-net    |
> |                    |  <---------         <----------  |    driver      |
> |                    |     push              get_buf    |                |
> |--------------------|                                  |----------------|
>                    |
>                    |
>                    | AIO (read & write) combined with Direct I/O
>                    |   (which substitute synced file operations)
> |-----------------------------------------------------------------------|
> |     Host kernel  | read: copy-less with directly mapped user          |
> |                  |       space to kernel, payload directly DMAed      |
> |                  |       into user space                              |
> |                  | write: copy-less with directly mapped user         |
> |                  |       space to kernel, payload directly hooked     |
> |                  |       to a skb                                     |
> |                  |                                                    |
> |  (a likely       |                                                    |
> |   queue pair     |                                                    |
> |   instance)      |                                                    |
> |      |           |                                                    |
> | NIC driver <-->  TUN/TAP driver                                       |
> |-----------------------------------------------------------------------|
>        |
>        |
>    traditional adapter or a tx/rx queue pair
> 
> The basic idea is to utilize the kernel Asynchronous I/O combined with Direct
> I/O to implements copy-less TUN/TAP device. AIO and Direct I/O is not new to
> kernel, we still can see it in SCSI tape driver.
> 
> With traditional file operations, a copying of payload contents from/to the
> kernel DMA address to/from a user buffer is needed. That's what the copying we
> want to save.
> 
> The proposed framework is like this:
> A TUN/TAP device is bound to a traditional NIC adapter or a tx/rx queue pair in
> host side. KVM virto-net Backend service, the user space program submits
> asynchronous read/write I/O requests to the host kernel through TUN/TAP device.
> The requests are corresponding to the vqueue elements include both transmission
> & receive. They can be queued in one AIO request and later, the completion will
> be notified through the underlying packets tx/rx processing of the rx/tx queue
> pair.
> 
> Detailed path:
> 
> To guest Virtio-net driver, packets receive corresponding to asynchronous read
> I/O requests of Backend service.
> 
> 1) Guest Virtio-net driver provides header and payload address through the
> receive vqueue to Virtio-net backend service.
> 
> 2) Virtio-net backend service encapsulates multiple vqueue elements into
> multiple AIO control blocks and composes them into one AIO read request.
> 
> 3) Virtio-net backend service uses io_submit() syscall to pass the request to
> the TUN/TAP device.
> 
> 4) Virtio-net backend service uses io_getevents() syscall to check the
> completion of the request.
> 
> 5) The TUN/TAP driver receives packets from the queue pair of NIC, and prepares
> for Direct I/O.
>    A modified NIC driver may render a skb which header is allocated in host
> kernel, but the payload buffer is directly mapped from user space buffer which
> are rendered through the AIO request by the Backend service. get_user_pages()
> may do this. For one AIO read request, the TUN/TAP driver maintains a list for
> the directly mapped buffers, and a NIC driver tries to get the buffers as
> payload buffer to compose the new skbs. Of course, if getting the buffers
> fails, then kernel allocated buffers are used.
> 
> 6) Modern NIC cards now mostly have the header split feature. The NIC queue
> pair then may directly DMA the payload into the user spaces mapped payload
> buffers.
> Thus a zero-copy for payload is implemented in packet receiving.
> 
> 7) The TUN/TAP driver manually copy the host header to space user mapped.
> 
> 8) aio_complete() to notify the Virtio-net backend service for io_getevents().
> 
> 
> To guest Virtio-net driver, packets send corresponding to asynchronous write
> I/O requests of backend. The path is similar to packet receive.
> 
> 1) Guest Virtio-net driver provides header and payload address filled with
> contents through the transmit vqueue to Virtio-net backed service.
> 
> 2) Virtio-net backend service encapsulates the vqueue elements into multiple
> AIO control blocks and composes them into one AIO write request.
> 
> 3) Virtio-net backend service uses the io_submit() syscall to pass the
> requests to the TUN/TAP device.
> 
> 4) Virtio-net backend service uses io_getevents() syscall to check the request
> completion.
> 
> 5) The TUN/TAP driver gets the write requests and allocates skbs for it. The
> header contents are copied into the skb header. The directly mapped user space
> buffer is easily hooked into skb. Thus a zero copy for payload is implemented
> in packet sending.
> 
> 6) aio_complete() to notify the Virtio-net backend service for io_getevents().
> 
> The proposed framework is described as above.
> 
> Consider the modifications to the kernel and qemu:
> 
> To kernel:
> 1) The TUN/TAP driver may be modified a lot to implement AIO device operations
> and to implement directly user space mapping into kernel. Code to maintain the
> directly mapped user buffers should be in. It's just a modification for driver.
> 
> 2) The NIC driver may be modified to compose skb differently and slightly data
> structure change to add user directly mapped buffer pointer.
> Here, maybe it's better for a NIC driver to present an interface for an rx/tx
> queue pair instance which will also apply to traditional hardware, the kernel
> interface should not be changed to make the other components happy.
> The abstraction is useful, though it is not needed immediately here.
> 
> 3) The skb shared info structure may be modified a little to contain the user
> directly mapped info.
> 
> To Qemu:
> 1) The Virtio-net backend service may be modified to handle AIO read/write
> requests from the vqueues.
> 2) Maybe a separate pthread to handle the AIO request triggering is needed.
> 
> Any comments are appreciated here.

* Code is easier to review than bullet points.

* Direct I/O has to be safe when page is shared by multiple threads,
  and has to be non-blocking since network I/O can take indeterminately
  long (think big queue's, tunneling, ...)

* In the past attempts at Direct I/O on network have always had SMP
  TLB issues. The page has to be flipped or marked as COW on all CPU's
  and the cost of the Inter Processor Interrupt to steal the page has
  been slower than copying



-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
