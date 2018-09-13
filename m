Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 39ABB8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 02:11:54 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u74-v6so5258434oie.16
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 23:11:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h189-v6sor2954390oif.19.2018.09.12.23.11.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 23:11:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com> <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
 <ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com> <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
From: Juerg Haefliger <juergh@gmail.com>
Date: Thu, 13 Sep 2018 08:11:49 +0200
Message-ID: <CADLDEKsxx=MSFu=4_4JLX1afUMr3GVjNxSQ-726NrbLn8KQaQg@mail.gmail.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Stecklina <jsteckli@amazon.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On Wed, Sep 12, 2018 at 5:37 PM, Julian Stecklina <jsteckli@amazon.de> wrote:
> Julian Stecklina <jsteckli@amazon.de> writes:
>
>> Linus Torvalds <torvalds@linux-foundation.org> writes:
>>
>>> On Fri, Aug 31, 2018 at 12:45 AM Julian Stecklina <jsteckli@amazon.de> wrote:
>>>>
>>>> I've been spending some cycles on the XPFO patch set this week. For the
>>>> patch set as it was posted for v4.13, the performance overhead of
>>>> compiling a Linux kernel is ~40% on x86_64[1]. The overhead comes almost
>>>> completely from TLB flushing. If we can live with stale TLB entries
>>>> allowing temporary access (which I think is reasonable), we can remove
>>>> all TLB flushing (on x86). This reduces the overhead to 2-3% for
>>>> kernel compile.
>>>
>>> I have to say, even 2-3% for a kernel compile sounds absolutely horrendous.
>>
>> Well, it's at least in a range where it doesn't look hopeless.
>>
>>> Kernel bullds are 90% user space at least for me, so a 2-3% slowdown
>>> from a kernel is not some small unnoticeable thing.
>>
>> The overhead seems to come from the hooks that XPFO adds to
>> alloc/free_pages. These hooks add a couple of atomic operations per
>> allocated (4K) page for book keeping. Some of these atomic ops are only
>> for debugging and could be removed. There is also some opportunity to
>> streamline the per-page space overhead of XPFO.
>
> I've updated my XPFO branch[1] to make some of the debugging optional
> and also integrated the XPFO bookkeeping with struct page, instead of
> requiring CONFIG_PAGE_EXTENSION, which removes some checks in the hot
> path.

FWIW, that was my original design but there was some resistance to
adding more to the page struct and page extension was suggested
instead.


> These changes push the overhead down to somewhere between 1.5 and
> 2% for my quad core box in kernel compile. This is close to the
> measurement noise, so I take suggestions for a better benchmark here.
>
> Of course, if you hit contention on the xpfo spinlock then performance
> will suffer. I guess this is what happened on Khalid's large box.
>
> I'll try to remove the spinlocks and add fixup code to the pagefault
> handler to see whether this improves the situation on large boxes. This
> might turn out to be ugly, though.

I'm wondering how much performance we're loosing by having to split
hugepages. Any chance this can be quantified somehow? Maybe we can
have a pool of some sorts reserved for userpages and group allocations
so that we can track the XPFO state at the hugepage level instead of
at the 4k level to prevent/reduce page splitting. Not sure if that
causes issues or has any unwanted side effects though...

...Juerg


> Julian
>
> [1] http://git.infradead.org/users/jsteckli/linux-xpfo.git/shortlog/refs/heads/xpfo-master
> --
> Amazon Development Center Germany GmbH
> Berlin - Dresden - Aachen
> main office: Krausenstr. 38, 10117 Berlin
> Geschaeftsfuehrer: Dr. Ralf Herbrich, Christian Schlaeger
> Ust-ID: DE289237879
> Eingetragen am Amtsgericht Charlottenburg HRB 149173 B
>
