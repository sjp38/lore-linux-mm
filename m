Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2B076B1B29
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 17:26:12 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n26-v6so14393942iog.15
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 14:26:12 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x138-v6si510588itb.33.2018.08.20.14.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 14:26:11 -0700 (PDT)
Date: Mon, 20 Aug 2018 17:25:56 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs in
 mind (for KVM to isolate its guests per CPU)
Message-ID: <20180820212556.GC2230@char.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Liran Alon <liran.alon@oracle.com>, Deepa Srinivasan <deepa.srinivasan@oracle.com>, linux-mm@kvack.org, juerg.haefliger@hpe.com, khalid.aziz@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, keescook@google.com, andrew.cooper3@citrix.com, jcm@redhat.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Kanth <kanth.ghatraju@oracle.com>, Joao Martins <joao.m.martins@oracle.com>, jmattson@google.com, pradeep.vincent@oracle.com, Linus Torvalds <torvalds@linux-foundation.org>, ak@linux.intel.com, john.haxby@oracle.com, jsteckli@os.inf.tu-dresden.de
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de

Hi!

See eXclusive Page Frame Ownership (https://lwn.net/Articles/700606/) which was posted
way back in in 2016..

In the last couple of months there has been a slew of CPU issues that have complicated
a lot of things. The latest - L1TF - is still fresh in folks's mind and it is
especially acute to virtualization workloads.

As such a bunch of various folks from different cloud companies (CCed) are looking
at a way to make Linux kernel be more resistant to hardware having these sort of 
bugs.

In particular we are looking at a way to "remove as many mappings from the global
kernel address space as possible. Specifically, while being in the
context of process A, memory of process B should not be visible in the
kernel." (email from Julian Stecklina). That is the high-level view and 
how this could get done, well, that is why posting this on
LKML/linux-hardening/kvm-devel/linux-mm to start the discussion.

Usually I would start with a draft of RFC patches so folks can rip it apart, but
thanks to other people (Juerg thank you!) it already exists:

(see https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1222756.html)

The idea would be to extend this to:

 1) Only do it for processes that run under CPUS which are in isolcpus list.

 2) Expand this to be a per-cpu page tables. That is each CPU has its own unique
    set of pagetables - naturally _START_KERNEL -> __end would be mapped but the
    rest would not.

Thoughts? Is this possible? Crazy? Better ideas?
