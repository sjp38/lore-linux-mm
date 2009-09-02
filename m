Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 225A06B006A
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 02:46:36 -0400 (EDT)
From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Date: Wed, 2 Sep 2009 14:45:38 +0800
Subject: RE: [RFC] Virtual Machine Device Queues(VMDq) support on KVM
Message-ID: <C85CEDA13AB1CF4D9D597824A86D2B9006AEC03200@PDSMSX501.ccr.corp.intel.com>
References: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB94861@PDSMSX501.ccr.corp.intel.com>
 <20090901090518.1193e412@nehalam>
In-Reply-To: <20090901090518.1193e412@nehalam>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Stephen Hemminger <shemminger@vyatta.com>
Cc: "mst@redhat.com" <mst@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@elte.hu" <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "gregory.haskins@gmail.com" <gregory.haskins@gmail.com>
List-ID: <linux-mm.kvack.org>

>* Code is easier to review than bullet points.

	Yes. We'd send the code soon.

>* Direct I/O has to be safe when page is shared by multiple threads,
> and has to be non-blocking since network I/O can take indeterminately
> long (think big queue's, tunneling, ...)

In the situation, one queue pair NIC is assigned to only one guest, the pag=
es=20
are locked and a KVM guest will not swapped out.


>* In the past attempts at Direct I/O on network have always had SMP
> TLB issues. The page has to be flipped or marked as COW on all CPU's
> and the cost of the Inter Processor Interrupt to steal the page has
> been slower than copying

It may be, we have not thought about this more . Thanks.

Thanks
Xiaohui

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com]=20
Sent: Wednesday, September 02, 2009 12:05 AM
To: Xin, Xiaohui
Cc: mst@redhat.com; netdev@vger.kernel.org; virtualization@lists.linux-foun=
dation.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org; mingo@elte.h=
u; linux-mm@kvack.org; akpm@linux-foundation.org; hpa@zytor.com; gregory.ha=
skins@gmail.com
Subject: Re: [RFC] Virtual Machine Device Queues(VMDq) support on KVM

On Tue, 1 Sep 2009 14:58:19 +0800
"Xin, Xiaohui" <xiaohui.xin@intel.com> wrote:

>               [RFC] Virtual Machine Device Queues (VMDq) support on KVM
>=20
> Network adapter with VMDq technology presents multiple pairs of tx/rx que=
ues,
> and renders network L2 sorting mechanism based on MAC addresses and VLAN =
tags
> for each tx/rx queue pair. Here we present a generic framework, in which =
network
> traffic to/from a tx/rx queue pair can be directed from/to a KVM guest wi=
thout
> any software copy.
>=20
> Actually this framework can apply to traditional network adapters which h=
ave
> just one tx/rx queue pair. And applications using the same user/kernel in=
terface
> can utilize this framework to send/receive network traffic directly thru =
a tx/rx
> queue pair in a network adapter.
>=20
> We use virtio-net architecture to illustrate the framework.
>=20
>=20
> |--------------------|     pop               add_buf    |----------------=
|
> |    Qemu process    |  <---------    TX   <----------  | Guest Kernel   =
|
> |                    |  --------->         ---------->  |                =
|
> |    Virtio-net      |     push              get_buf    |                =
|
> |  (Backend service) |  --------->    RX   ---------->  |  Virtio-net    =
|
> |                    |  <---------         <----------  |    driver      =
|
> |                    |     push              get_buf    |                =
|
> |--------------------|                                  |----------------=
|
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
>=20
> The basic idea is to utilize the kernel Asynchronous I/O combined with Di=
rect
> I/O to implements copy-less TUN/TAP device. AIO and Direct I/O is not new=
 to
> kernel, we still can see it in SCSI tape driver.
>=20
> With traditional file operations, a copying of payload contents from/to t=
he
> kernel DMA address to/from a user buffer is needed. That's what the copyi=
ng we
> want to save.
>=20
> The proposed framework is like this:
> A TUN/TAP device is bound to a traditional NIC adapter or a tx/rx queue p=
air in
> host side. KVM virto-net Backend service, the user space program submits
> asynchronous read/write I/O requests to the host kernel through TUN/TAP d=
evice.
> The requests are corresponding to the vqueue elements include both transm=
ission
> & receive. They can be queued in one AIO request and later, the completio=
n will
> be notified through the underlying packets tx/rx processing of the rx/tx =
queue
> pair.
>=20
> Detailed path:
>=20
> To guest Virtio-net driver, packets receive corresponding to asynchronous=
 read
> I/O requests of Backend service.
>=20
> 1) Guest Virtio-net driver provides header and payload address through th=
e
> receive vqueue to Virtio-net backend service.
>=20
> 2) Virtio-net backend service encapsulates multiple vqueue elements into
> multiple AIO control blocks and composes them into one AIO read request.
>=20
> 3) Virtio-net backend service uses io_submit() syscall to pass the reques=
t to
> the TUN/TAP device.
>=20
> 4) Virtio-net backend service uses io_getevents() syscall to check the
> completion of the request.
>=20
> 5) The TUN/TAP driver receives packets from the queue pair of NIC, and pr=
epares
> for Direct I/O.
>    A modified NIC driver may render a skb which header is allocated in ho=
st
> kernel, but the payload buffer is directly mapped from user space buffer =
which
> are rendered through the AIO request by the Backend service. get_user_pag=
es()
> may do this. For one AIO read request, the TUN/TAP driver maintains a lis=
t for
> the directly mapped buffers, and a NIC driver tries to get the buffers as
> payload buffer to compose the new skbs. Of course, if getting the buffers
> fails, then kernel allocated buffers are used.
>=20
> 6) Modern NIC cards now mostly have the header split feature. The NIC que=
ue
> pair then may directly DMA the payload into the user spaces mapped payloa=
d
> buffers.
> Thus a zero-copy for payload is implemented in packet receiving.
>=20
> 7) The TUN/TAP driver manually copy the host header to space user mapped.
>=20
> 8) aio_complete() to notify the Virtio-net backend service for io_geteven=
ts().
>=20
>=20
> To guest Virtio-net driver, packets send corresponding to asynchronous wr=
ite
> I/O requests of backend. The path is similar to packet receive.
>=20
> 1) Guest Virtio-net driver provides header and payload address filled wit=
h
> contents through the transmit vqueue to Virtio-net backed service.
>=20
> 2) Virtio-net backend service encapsulates the vqueue elements into multi=
ple
> AIO control blocks and composes them into one AIO write request.
>=20
> 3) Virtio-net backend service uses the io_submit() syscall to pass the
> requests to the TUN/TAP device.
>=20
> 4) Virtio-net backend service uses io_getevents() syscall to check the re=
quest
> completion.
>=20
> 5) The TUN/TAP driver gets the write requests and allocates skbs for it. =
The
> header contents are copied into the skb header. The directly mapped user =
space
> buffer is easily hooked into skb. Thus a zero copy for payload is impleme=
nted
> in packet sending.
>=20
> 6) aio_complete() to notify the Virtio-net backend service for io_geteven=
ts().
>=20
> The proposed framework is described as above.
>=20
> Consider the modifications to the kernel and qemu:
>=20
> To kernel:
> 1) The TUN/TAP driver may be modified a lot to implement AIO device opera=
tions
> and to implement directly user space mapping into kernel. Code to maintai=
n the
> directly mapped user buffers should be in. It's just a modification for d=
river.
>=20
> 2) The NIC driver may be modified to compose skb differently and slightly=
 data
> structure change to add user directly mapped buffer pointer.
> Here, maybe it's better for a NIC driver to present an interface for an r=
x/tx
> queue pair instance which will also apply to traditional hardware, the ke=
rnel
> interface should not be changed to make the other components happy.
> The abstraction is useful, though it is not needed immediately here.
>=20
> 3) The skb shared info structure may be modified a little to contain the =
user
> directly mapped info.
>=20
> To Qemu:
> 1) The Virtio-net backend service may be modified to handle AIO read/writ=
e
> requests from the vqueues.
> 2) Maybe a separate pthread to handle the AIO request triggering is neede=
d.
>=20
> Any comments are appreciated here.

* Code is easier to review than bullet points.

* Direct I/O has to be safe when page is shared by multiple threads,
  and has to be non-blocking since network I/O can take indeterminately
  long (think big queue's, tunneling, ...)

* In the past attempts at Direct I/O on network have always had SMP
  TLB issues. The page has to be flipped or marked as COW on all CPU's
  and the cost of the Inter Processor Interrupt to steal the page has
  been slower than copying



--=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
