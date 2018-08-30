Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9196B55AF
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 03:45:48 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y54-v6so12466834qta.8
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 00:45:48 -0700 (PDT)
Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com. [52.95.49.90])
        by mx.google.com with ESMTPS id u2-v6si244759qvu.284.2018.08.31.00.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 00:45:46 -0700 (PDT)
From: Julian Stecklina <jsteckli@amazon.de>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs in mind (for KVM to isolate its guests per CPU)
In-Reply-To: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
Date: Thu, 30 Aug 2018 18:00:51 +0200
Message-ID: <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

Hey everyone,

On Mon, 20 Aug 2018 15:27 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> On Mon, Aug 20, 2018 at 3:02 PM Woodhouse, David <dwmw@amazon.co.uk> wrote:
>>
>> It's the *kernel* we don't want being able to access those pages,
>> because of the multitude of unfixable cache load gadgets.
>
> Ahh.
> 
> I guess the proof is in the pudding. Did somebody try to forward-port
> that patch set and see what the performance is like?

I've been spending some cycles on the XPFO patch set this week. For the
patch set as it was posted for v4.13, the performance overhead of
compiling a Linux kernel is ~40% on x86_64[1]. The overhead comes almost
completely from TLB flushing. If we can live with stale TLB entries
allowing temporary access (which I think is reasonable), we can remove
all TLB flushing (on x86). This reduces the overhead to 2-3% for
kernel compile.

There were no problems in forward-porting the patch set to master.
You can find the result here, including a patch makes the TLB flushing
configurable:
http://git.infradead.org/users/jsteckli/linux-xpfo.git/shortlog/refs/heads/xpfo-master

It survived some casual stress-ng runs. I can rerun the benchmarks on
this version, but I doubt there is any change.

> It used to be just 500 LOC. Was that because they took horrible
> shortcuts?

The patch is still fairly small. As for the horrible shortcuts, I let
others comment on that.

HTH,
Julian

[1] Measured on my quad-core (8 hyperthreads) Kaby Lake desktop building
Linux 4.18 with the Phoronix Test Suite.

--
Amazon Development Center Germany GmbH
Berlin - Dresden - Aachen
main office: Krausenstr. 38, 10117 Berlin
Geschaeftsfuehrer: Dr. Ralf Herbrich, Christian Schlaeger
Ust-ID: DE289237879
Eingetragen am Amtsgericht Charlottenburg HRB 149173 B
