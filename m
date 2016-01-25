Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id AFD336B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 12:25:57 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id e32so114591662qgf.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:25:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f34si18511014qgd.87.2016.01.25.09.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 09:25:57 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] VM containers
References: <56A2511F.1080900@redhat.com>
 <439BF796-53D3-48C9-8578-A0733DDE8001@intel.com>
 <20160124170656.6c5460a3@lxorguk.ukuu.org.uk>
From: Rik van Riel <riel@redhat.com>
Message-ID: <56A65AA2.6040307@redhat.com>
Date: Mon, 25 Jan 2016 12:25:54 -0500
MIME-Version: 1.0
In-Reply-To: <20160124170656.6c5460a3@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, "Nakajima, Jun" <jun.nakajima@intel.com>
Cc: "lsf-pc@lists.linuxfoundation.org" <lsf-pc@lists.linuxfoundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>

On 01/24/2016 12:06 PM, One Thousand Gnomes wrote:
>>> That changes some of the goals the memory management subsystem has,
>>> from "use all the resources effectively" to "use as few resources as
>>> necessary, in case the host needs the memory for something else".
> 
> Also "and take guidance/provide telemetry" - because you want to tune the
> VM behaviours based upon policy and to learn from them for when you re-run
> that container.
> 
>> Beyond memory consumption, I would be interested whether we can harden the kernel by the paravirt interfaces for memory protection in VMs (if any). For example, the hypervisor could write-protect part of the page tables or kernel data structures in VMs, and does it help?
> 
> There are four behaviours I can think of, some of which you see in
> various hypervisors and security hardening systems
> 
> - die on write (a write here causes a security trap and termination after
>   the guest has marked the page range die on write, and it cannot be
>   unmarked). The guest OS at boot can for example mark all it's code as
>   die-on-write.
> - irrevocably read only (VM never allows page to be rewritten by guest
>   after the guest marks the page range irrevocably r/o)

For these we get the question "how do we make it harder for the
guest to remap the page tables to point at read/write memory,
and modify that instead of the read-only memory?"

On "smaller" guests (less than 1TB in size), it may be enough to
ensure that the kernel PUD pointer points to the (read-only) kernel
PUD at context switch time, placing the main kernel page tables,
kernel text, and some other things in read-only memory.

> - asynchronous faulting (pages the guest thinks are in it's memory but
>   are in fact on the hosts swap cause a subscribable fault in the guest
>   so that it can (where possible) be context switched

KVM (and s390) already do the asynchronous page fault trick.

> - free if needed - marking pages as freed up and either you get a page
>   back as it was or a fault and a zeroed page

People have worked on this for KVM. I do not remember what
happened to the code.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
