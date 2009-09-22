Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9A8B36B006A
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 05:43:47 -0400 (EDT)
Message-ID: <4AB89C48.4020903@redhat.com>
Date: Tue, 22 Sep 2009 12:43:36 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu>
In-Reply-To: <20090921214312.GJ7182@ovro.caltech.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Cc: Gregory Haskins <gregory.haskins@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/22/2009 12:43 AM, Ira W. Snyder wrote:
>
>> Sure, virtio-ira and he is on his own to make a bus-model under that, or
>> virtio-vbus + vbus-ira-connector to use the vbus framework.  Either
>> model can work, I agree.
>>
>>      
> Yes, I'm having to create my own bus model, a-la lguest, virtio-pci, and
> virtio-s390. It isn't especially easy. I can steal lots of code from the
> lguest bus model, but sometimes it is good to generalize, especially
> after the fourth implemention or so. I think this is what GHaskins tried
> to do.
>    

Yes.  vbus is more finely layered so there is less code duplication.

The virtio layering was more or less dictated by Xen which doesn't have 
shared memory (it uses grant references instead).  As a matter of fact 
lguest, kvm/pci, and kvm/s390 all have shared memory, as you do, so that 
part is duplicated.  It's probably possible to add a virtio-shmem.ko 
library that people who do have shared memory can reuse.

> I've given it some thought, and I think that running vhost-net (or
> similar) on the ppc boards, with virtio-net on the x86 crate server will
> work. The virtio-ring abstraction is almost good enough to work for this
> situation, but I had to re-invent it to work with my boards.
>
> I've exposed a 16K region of memory as PCI BAR1 from my ppc board.
> Remember that this is the "host" system. I used each 4K block as a
> "device descriptor" which contains:
>
> 1) the type of device, config space, etc. for virtio
> 2) the "desc" table (virtio memory descriptors, see virtio-ring)
> 3) the "avail" table (available entries in the desc table)
>    

Won't access from x86 be slow to this memory (on the other hand, if you 
change it to main memory access from ppc will be slow... really depends 
on how your system is tuned.

> Parts 2 and 3 are repeated three times, to allow for a maximum of three
> virtqueues per device. This is good enough for all current drivers.
>    

The plan is to switch to multiqueue soon.  Will not affect you if your 
boards are uniprocessor or small smp.

> I've gotten plenty of email about this from lots of interested
> developers. There are people who would like this kind of system to just
> work, while having to write just some glue for their device, just like a
> network driver. I hunch most people have created some proprietary mess
> that basically works, and left it at that.
>    

So long as you keep the system-dependent features hookable or 
configurable, it should work.

> So, here is a desperate cry for help. I'd like to make this work, and
> I'd really like to see it in mainline. I'm trying to give back to the
> community from which I've taken plenty.
>    

Not sure who you're crying for help to.  Once you get this working, post 
patches.  If the patches are reasonably clean and don't impact 
performance for the main use case, and if you can show the need, I 
expect they'll be merged.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
