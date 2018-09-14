Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E27D8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:07:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j15-v6so4944629pfi.10
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:07:15 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b19-v6si7601338pfb.89.2018.09.14.10.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 10:07:14 -0700 (PDT)
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
 <ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <5efc291c-b0ed-577e-02d1-285d080c293d@oracle.com>
Date: Fri, 14 Sep 2018 11:06:53 -0600
MIME-Version: 1.0
In-Reply-To: <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Stecklina <jsteckli@amazon.de>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On 09/12/2018 09:37 AM, Julian Stecklina wrote:
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
> path. These changes push the overhead down to somewhere between 1.5 and
> 2% for my quad core box in kernel compile. This is close to the
> measurement noise, so I take suggestions for a better benchmark here.
> 
> Of course, if you hit contention on the xpfo spinlock then performance
> will suffer. I guess this is what happened on Khalid's large box.
> 
> I'll try to remove the spinlocks and add fixup code to the pagefault
> handler to see whether this improves the situation on large boxes. This
> might turn out to be ugly, though.
> 

Hi Julian,

I ran tests with your updated code and gathered lock statistics. Change in system time for "make -j60" was in the noise margin (It actually went up by about 2%). There is some contention on xpfo_lock. Average wait time does not look high compared to other locks. Max hold time looks a little long. From /proc/lock_stat:

              &(&page->xpfo_lock)->rlock:         29698          29897           0.06         134.39       15345.58           0.51      422474670      960222532           0.05       30362.05   195807002.62           0.20

Nevertheless even a smaller average wait time can add up.

--
Khalid
