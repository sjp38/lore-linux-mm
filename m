Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5988C6B685C
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 11:10:03 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y46-v6so799061qth.9
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 08:10:03 -0700 (PDT)
Received: from smtp-fw-9102.amazon.com (smtp-fw-9102.amazon.com. [207.171.184.29])
        by mx.google.com with ESMTPS id z12-v6si5801594qva.223.2018.09.03.08.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 08:10:02 -0700 (PDT)
From: Julian Stecklina <jsteckli@amazon.de>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs in mind (for KVM to isolate its guests per CPU)
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
	<ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
	<CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
Date: Mon, 03 Sep 2018 16:51:35 +0200
In-Reply-To: <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
	(Linus Torvalds's message of "Sat, 1 Sep 2018 14:38:43 -0700")
Message-ID: <ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Fri, Aug 31, 2018 at 12:45 AM Julian Stecklina <jsteckli@amazon.de> wrote:
>>
>> I've been spending some cycles on the XPFO patch set this week. For the
>> patch set as it was posted for v4.13, the performance overhead of
>> compiling a Linux kernel is ~40% on x86_64[1]. The overhead comes almost
>> completely from TLB flushing. If we can live with stale TLB entries
>> allowing temporary access (which I think is reasonable), we can remove
>> all TLB flushing (on x86). This reduces the overhead to 2-3% for
>> kernel compile.
>
> I have to say, even 2-3% for a kernel compile sounds absolutely horrendous.

Well, it's at least in a range where it doesn't look hopeless.

> Kernel bullds are 90% user space at least for me, so a 2-3% slowdown
> from a kernel is not some small unnoticeable thing.

The overhead seems to come from the hooks that XPFO adds to
alloc/free_pages. These hooks add a couple of atomic operations per
allocated (4K) page for book keeping. Some of these atomic ops are only
for debugging and could be removed. There is also some opportunity to
streamline the per-page space overhead of XPFO.

I'll do some more in-depth profiling later this week.

Julian
Amazon Development Center Germany GmbH
Berlin - Dresden - Aachen
main office: Krausenstr. 38, 10117 Berlin
Geschaeftsfuehrer: Dr. Ralf Herbrich, Christian Schlaeger
Ust-ID: DE289237879
Eingetragen am Amtsgericht Charlottenburg HRB 149173 B
