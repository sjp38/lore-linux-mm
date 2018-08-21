Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 28E1E6B2129
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 19:04:51 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z18-v6so21723qki.22
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 16:04:51 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o18-v6si27807qtq.263.2018.08.21.16.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 16:04:49 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.1 \(3445.4.7\))
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
From: Liran Alon <liran.alon@oracle.com>
In-Reply-To: <1534861342.14722.11.camel@infradead.org>
Date: Wed, 22 Aug 2018 02:04:17 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <893B27C3-0532-407C-9D4A-B8EAB1B28957@oracle.com>
References: <20180820212556.GC2230@char.us.oracle.com>
 <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk>
 <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <1534845423.10027.44.camel@infradead.org>
 <ED24D811-C740-417F-A443-B7A249F4FF4C@oracle.com>
 <1534861342.14722.11.camel@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Joao Martins <joao.m.martins@oracle.com>, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Kees Cook <keescook@google.com>, jsteckli@os.inf.tu-dresden.de, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>



> On 21 Aug 2018, at 17:22, David Woodhouse <dwmw2@infradead.org> wrote:
>=20
> On Tue, 2018-08-21 at 17:01 +0300, Liran Alon wrote:
>>=20
>>> On 21 Aug 2018, at 12:57, David Woodhouse <dwmw2@infradead.org>
>> wrote:
>>> =20
>>> Another alternative... I'm told POWER8 does an interesting thing
>> with
>>> hyperthreading and gang scheduling for KVM. The host kernel doesn't
>>> actually *see* the hyperthreads at all, and KVM just launches the
>> full
>>> set of siblings when it enters a guest, and gathers them again when
>> any
>>> of them exits. That's definitely worth investigating as an option
>> for
>>> x86, too.
>>=20
>> I actually think that such scheduling mechanism which prevents
>> leaking cache entries to sibling hyperthreads should co-exist
>> together with the KVM address space isolation to fully mitigate L1TF
>> and other similar vulnerabilities. The address space isolation should
>> prevent VMExit handlers code gadgets from loading arbitrary host
>> memory to the cache. Once VMExit code path switches to full host
>> address space, then we should also make sure that no other sibling
>> hyprethread is running in the guest.
>=20
> The KVM POWER8 solution (see arch/powerpc/kvm/book3s_hv.c) does that.
> The siblings are *never* running host kernel code; they're all torn
> down when any of them exits the guest. And it's always the *same*
> guest.
>=20

I wasn=E2=80=99t aware of this KVM Power8 mechanism. Thanks for the =
pointer.
(371fefd6f2dc ("KVM: PPC: Allow book3s_hv guests to use SMT processor =
modes=E2=80=9D))

Note though that my point regarding the co-existence of the isolated =
address space together with such scheduling mechanism is still valid.
The scheduling mechanism should not be seen as an alternative to the =
isolated address space if we wish to reduce the frequency of events
in which we need to kick sibling hyperthreads from guest.

>> Focusing on the scheduling mechanism, we must make sure that when a
>> logical processor runs guest code, all siblings logical processors
>> must run code which do not populate L1D cache with information
>> unrelated to this VM. This includes forbidding one logical processor
>> to run guest code while sibling is running a host task such as a NIC
>> interrupt handler.
>> Thus, when a vCPU thread exits the guest into the host and VMExit
>> handler reaches code flow which could populate L1D cache with this
>> information, we should force an exit from the guest of the siblings
>> logical processors, such that they will be allowed to resume only on
>> a core which we can promise that the L1D cache is free from
>> information unrelated to this VM.
>>=20
>> At first, I have created a patch series which attempts to implement
>> such mechanism in KVM. However, it became clear to me that this may
>> need to be implemented in the scheduler itself. This is because:
>> 1. It is difficult to handle all new scheduling contrains only in
>> KVM.
>> 2. This mechanism should be relevant for any Type-2 hypervisor which
>> runs inside Linux besides KVM (Such as VMware Workstation or
>> VirtualBox).
>> 3. This mechanism could also be used to prevent future =E2=80=9Ccore-ca=
che-
>> leaking=E2=80=9D vulnerabilities to be exploited between processes of
>> different security domains which run as siblings on the same core.
>=20
> I'm not sure I agree. If KVM is handling "only let siblings run the
> *same* guest" and the siblings aren't visible to the host at all,
> that's quite simple. Any other hypervisor can also do it.
>=20
> Now, the down-side of this is that the siblings aren't visible to the
> host. They can't be used to run multiple threads of the same userspace
> processes; only multiple threads of the same KVM guest. A truly =
generic
> core scheduler would cope with userspace threads too.
>=20
> BUT I strongly suspect there's a huge correlation between the set of
> people who care enough about the KVM/L1TF issue to enable a costly
> XFPO-like solution, and the set of people who mostly don't give a shit
> about having sibling CPUs available to run the host's userspace =
anyway.
>=20
> This is not the "I happen to run a Windows VM on my Linux desktop" use
> case...

If I understand your proposal correctly, you suggest to do something =
similar to the KVM Power8 solution:
1. Disable HyperThreading for use by host user space.
2. Use sibling hyperthreads only in KVM and schedule group of vCPUs that =
run on a single core as a =E2=80=9Cgang=E2=80=9D to enter and exit guest =
together.

This solution may work well for KVM-based cloud providers that match the =
following criteria:
1. All compute instances run with SR-IOV and IOMMU Posted-Interrupts.
2. Configure affinity such that host dedicate distinct set of physical =
cores per guest. No physical core is able to run vCPUs from multiple =
guests.

However, this may not necessarily be the case: Some cloud providers have =
compute instances which all their devices are emulated or =
ParaVirtualized.
In the proposed scheduling mechanism, all the IOThreads of these guests =
will not be able to utilize HyperThreading which can be a significant =
performance hit.
So Oracle Cloud (OCI) are folks who do care enough about the KVM/L1TF =
issue but gives a shit about having sibling CPUs available to run host =
userspace. :)
Unless I=E2=80=99m missing something of course...

In addition, desktop users who run VMs today, expect a security boundary =
to exist between the guest and the host.
Besides the L1TF HyperThreading variant, we were able to preserve such a =
security boundary.
It seems a bit weird that we will implement a mechanism in x86 KVM that =
it=E2=80=99s message to users is basically:
=E2=80=9CIf you want to have a security boundary between a VM and the =
host, you need to enable this knob which will also cause the rest of =
your host
to see half the amount of logical processors=E2=80=9D.

Furthermore, I think it is important to think about a mechanism which =
may help us to mitigate future similar =E2=80=9Ccore-cache-leak=E2=80=9D =
vulnerabilities.
As I previously mentioned, the =E2=80=9Ccore scheduler=E2=80=9D could =
help us mitigate these vulnerabilities on OS-level by disallowing =
userspace tasks of different =E2=80=9Csecurity domain=E2=80=9D
to run as siblings on the same core.

-Liran

(Cc Paolo who probably have good feedback on the entire email thread =
as-well)
