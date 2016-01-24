Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 799116B0009
	for <linux-mm@kvack.org>; Sun, 24 Jan 2016 12:07:08 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id r129so38517541wmr.0
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 09:07:08 -0800 (PST)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id 2si22854928wjr.171.2016.01.24.09.07.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Jan 2016 09:07:07 -0800 (PST)
Date: Sun, 24 Jan 2016 17:06:56 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [LSF/MM TOPIC] VM containers
Message-ID: <20160124170656.6c5460a3@lxorguk.ukuu.org.uk>
In-Reply-To: <439BF796-53D3-48C9-8578-A0733DDE8001@intel.com>
References: <56A2511F.1080900@redhat.com>
	<439BF796-53D3-48C9-8578-A0733DDE8001@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Nakajima, Jun" <jun.nakajima@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "lsf-pc@lists.linuxfoundation.org" <lsf-pc@lists.linuxfoundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>

> > That changes some of the goals the memory management subsystem has,
> > from "use all the resources effectively" to "use as few resources as
> > necessary, in case the host needs the memory for something else".

Also "and take guidance/provide telemetry" - because you want to tune the
VM behaviours based upon policy and to learn from them for when you re-run
that container.

> Beyond memory consumption, I would be interested whether we can harden the kernel by the paravirt interfaces for memory protection in VMs (if any). For example, the hypervisor could write-protect part of the page tables or kernel data structures in VMs, and does it help?

There are four behaviours I can think of, some of which you see in
various hypervisors and security hardening systems

- die on write (a write here causes a security trap and termination after
  the guest has marked the page range die on write, and it cannot be
  unmarked). The guest OS at boot can for example mark all it's code as
  die-on-write.
- irrevocably read only (VM never allows page to be rewritten by guest
  after the guest marks the page range irrevocably r/o)
- asynchronous faulting (pages the guest thinks are in it's memory but
  are in fact on the hosts swap cause a subscribable fault in the guest
  so that it can (where possible) be context switched
- free if needed - marking pages as freed up and either you get a page
  back as it was or a fault and a zeroed page

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
