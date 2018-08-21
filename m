Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A04A36B1F0D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 10:02:37 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id v20-v6so1660160iom.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 07:02:37 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j2-v6si2004553ite.90.2018.08.21.07.02.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 07:02:35 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.1 \(3445.4.7\))
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
From: Liran Alon <liran.alon@oracle.com>
In-Reply-To: <1534845423.10027.44.camel@infradead.org>
Date: Tue, 21 Aug 2018 17:01:57 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <ED24D811-C740-417F-A443-B7A249F4FF4C@oracle.com>
References: <20180820212556.GC2230@char.us.oracle.com>
 <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk>
 <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <1534845423.10027.44.camel@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Kees Cook <keescook@google.com>, jsteckli@os.inf.tu-dresden.de, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>


> On 21 Aug 2018, at 12:57, David Woodhouse <dwmw2@infradead.org> wrote:
>=20
> Another alternative... I'm told POWER8 does an interesting thing with
> hyperthreading and gang scheduling for KVM. The host kernel doesn't
> actually *see* the hyperthreads at all, and KVM just launches the full
> set of siblings when it enters a guest, and gathers them again when =
any
> of them exits. That's definitely worth investigating as an option for
> x86, too.

I actually think that such scheduling mechanism which prevents leaking =
cache entries to sibling hyperthreads should co-exist together with the =
KVM address space isolation to fully mitigate L1TF and other similar =
vulnerabilities. The address space isolation should prevent VMExit =
handlers code gadgets from loading arbitrary host memory to the cache. =
Once VMExit code path switches to full host address space, then we =
should also make sure that no other sibling hyprethread is running in =
the guest.

Focusing on the scheduling mechanism, we must make sure that when a =
logical processor runs guest code, all siblings logical processors must =
run code which do not populate L1D cache with information unrelated to =
this VM. This includes forbidding one logical processor to run guest =
code while sibling is running a host task such as a NIC interrupt =
handler.
Thus, when a vCPU thread exits the guest into the host and VMExit =
handler reaches code flow which could populate L1D cache with this =
information, we should force an exit from the guest of the siblings =
logical processors, such that they will be allowed to resume only on a =
core which we can promise that the L1D cache is free from information =
unrelated to this VM.

At first, I have created a patch series which attempts to implement such =
mechanism in KVM. However, it became clear to me that this may need to =
be implemented in the scheduler itself. This is because:
1. It is difficult to handle all new scheduling contrains only in KVM.
2. This mechanism should be relevant for any Type-2 hypervisor which =
runs inside Linux besides KVM (Such as VMware Workstation or =
VirtualBox).
3. This mechanism could also be used to prevent future =
=E2=80=9Ccore-cache-leaking=E2=80=9D vulnerabilities to be exploited =
between processes of different security domains which run as siblings on =
the same core.

The main idea is a mechanism which is very similar to Microsoft's "core =
scheduler" which they implemented to mitigate this vulnerability. The =
mechanism should work as follows:
1. Each CPU core will now be tagged with a "security domain id".
2. The scheduler will provide a mechanism to tag a task with a security =
domain id.
3. Tasks will inherit their security domain id from their parent task.
    3.1. First task in system will have security domain id of 0. Thus, =
if nothing special is done, all tasks will be assigned with security =
domain id of 0.
4. Tasks will be able to allocate a new security domain id from the =
scheduler and assign it to another task dynamically.
5. Linux scheduler will prevent scheduling tasks on a core with a =
different security domain id:
    5.0. CPU core security domain id will be set to the security domain =
id of the tasks which currently run on it.
    5.1. The scheduler will attempt to first schedule a task on a core =
with required security domain id if such exists.
    5.2. Otherwise, will need to decide if it wishes to kick all tasks =
running on some core to run the task with a different security domain id =
on that core.

The above mechanism can be used to mitigate the L1TF HT variant by just =
assigning vCPU tasks with a security domain id which is unique per VM =
and also different than the security domain id of the host which is 0.

I would be glad to hear feedback on the above suggestion.
If this should better be discussed on a separate email thread, please =
say so and I will open a new thread.

Thanks,
-Liran
