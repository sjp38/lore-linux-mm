Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 44B1A6B005C
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 09:25:41 -0400 (EDT)
Message-ID: <4AAF95D1.1080600@redhat.com>
Date: Tue, 15 Sep 2009 16:25:37 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com>
In-Reply-To: <4AAF909F.9080306@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/15/2009 04:03 PM, Gregory Haskins wrote:
>
>> In this case the x86 is the owner and the ppc boards use translated
>> access.  Just switch drivers and device and it falls into place.
>>
>>      
> You could switch vbus roles as well, I suppose.

Right, there's not real difference in this regard.

> Another potential
> option is that he can stop mapping host memory on the guest so that it
> follows the more traditional model.  As a bus-master device, the ppc
> boards should have access to any host memory at least in the GFP_DMA
> range, which would include all relevant pointers here.
>
> I digress:  I was primarily addressing the concern that Ira would need
> to manage the "host" side of the link using hvas mapped from userspace
> (even if host side is the ppc boards).  vbus abstracts that access so as
> to allow something other than userspace/hva mappings.  OTOH, having each
> ppc board run a userspace app to do the mapping on its behalf and feed
> it to vhost is probably not a huge deal either.  Where vhost might
> really fall apart is when any assumptions about pageable memory occur,
> if any.
>    

Why?  vhost will call get_user_pages() or copy_*_user() which ought to 
do the right thing.

> As an aside: a bigger issue is that, iiuc, Ira wants more than a single
> ethernet channel in his design (multiple ethernets, consoles, etc).  A
> vhost solution in this environment is incomplete.
>    

Why?  Instantiate as many vhost-nets as needed.

> Note that Ira's architecture highlights that vbus's explicit management
> interface is more valuable here than it is in KVM, since KVM already has
> its own management interface via QEMU.
>    

vhost-net and vbus both need management, vhost-net via ioctls and vbus 
via configfs.  The only difference is the implementation.  vhost-net 
leaves much more to userspace, that's the main difference.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
