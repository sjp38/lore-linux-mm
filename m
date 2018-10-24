Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8E7D6B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 11:00:46 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 98so5726193qkp.22
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 08:00:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20-v6sor5654069qtl.30.2018.10.24.08.00.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 08:00:45 -0700 (PDT)
Date: Wed, 24 Oct 2018 16:00:29 +0100
From: Tycho Andersen <tycho@tycho.ws>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Message-ID: <20181024150029.GB9019@cisco>
References: <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
 <ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <5efc291c-b0ed-577e-02d1-285d080c293d@oracle.com>
 <ciirm8va743105.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <7221975d-6b67-effa-2747-06c22c041e78@oracle.com>
 <1537800341.9745.20.camel@amazon.de>
 <063f5efc-afb2-471f-eb4b-79bf90db22dd@oracle.com>
 <6cc985bb-6aed-4fb7-0ef2-43aad2717095@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6cc985bb-6aed-4fb7-0ef2-43aad2717095@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: "Stecklina, Julian" <jsteckli@amazon.de>, "juerg.haefliger@hpe.com" <juerg.haefliger@hpe.com>, "deepa.srinivasan@oracle.com" <deepa.srinivasan@oracle.com>, "jmattson@google.com" <jmattson@google.com>, "andrew.cooper3@citrix.com" <andrew.cooper3@citrix.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "pradeep.vincent@oracle.com" <pradeep.vincent@oracle.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "kanth.ghatraju@oracle.com" <kanth.ghatraju@oracle.com>, "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>, "liran.alon@oracle.com" <liran.alon@oracle.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "keescook@google.com" <keescook@google.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "chris.hyser@oracle.com" <chris.hyser@oracle.com>, "tyhicks@canonical.com" <tyhicks@canonical.com>, "john.haxby@oracle.com" <john.haxby@oracle.com>, "jcm@redhat.com" <jcm@redhat.com>

On Wed, Oct 24, 2018 at 04:30:42PM +0530, Khalid Aziz wrote:
> On 10/15/2018 01:37 PM, Khalid Aziz wrote:
> > On 09/24/2018 08:45 AM, Stecklina, Julian wrote:
> > > I didn't test the version with TLB flushes, because it's clear that the
> > > overhead is so bad that no one wants to use this.
> > 
> > I don't think we can ignore the vulnerability caused by not flushing
> > stale TLB entries. On a mostly idle system, TLB entries hang around long
> > enough to make it fairly easy to exploit this. I was able to use the
> > additional test in lkdtm module added by this patch series to
> > successfully read pages unmapped from physmap by just waiting for system
> > to become idle. A rogue program can simply monitor system load and mount
> > its attack using ret2dir exploit when system is mostly idle. This brings
> > us back to the prohibitive cost of TLB flushes. If we are unmapping a
> > page from physmap every time the page is allocated to userspace, we are
> > forced to incur the cost of TLB flushes in some way. Work Tycho was
> > doing to implement Dave's suggestion can help here. Once Tycho has
> > something working, I can measure overhead on my test machine. Tycho, I
> > can help with your implementation if you need.
> 
> I looked at Tycho's last patch with batch update from
> <https://lkml.org/lkml/2017/11/9/951>. I ported it on top of Julian's
> patches and got it working well enough to gather performance numbers. Here
> is what I see for system times on a machine with dual Xeon E5-2630 and 256GB
> of memory when running "make -j30 all" on 4.18.6 kernel (percentages are
> relative to base 4.19-rc8 kernel without xpfo):
> 
> 
> Base 4.19-rc8				913.84s
> 4.19-rc8 + xpfo, no TLB flush		1027.985s (+12.5%)
> 4.19-rc8 + batch update, no TLB flush	970.39s (+6.2%)
> 4.19-rc8 + xpfo, TLB flush		8458.449s (+825.6%)
> 4.19-rc8 + batch update, TLB flush	4665.659s (+410.6%)
> 
> Batch update is significant improvement but we are starting so far behind
> baseline, it is still a huge slow down.

There's some other stuff that Dave suggested that I didn't do; in
particular coalesce xpfo bits instead of setting things once per page
when mappings are shared, etc.

Perhaps that will help more?

I'm still stuck working on something else for now, but I hope to be
able to participate more on this Soon (TM). Thanks for the testing!

Tycho
