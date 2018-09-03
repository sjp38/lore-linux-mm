Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB366B688F
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 11:27:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id h4-v6so400019pls.17
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 08:27:23 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id p16-v6si18741432pgc.82.2018.09.03.08.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 08:27:22 -0700 (PDT)
Date: Mon, 3 Sep 2018 08:26:16 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Message-ID: <20180903152616.GE27886@tassilo.jf.intel.com>
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: jsteckli@amazon.de, David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On Sat, Sep 01, 2018 at 02:38:43PM -0700, Linus Torvalds wrote:
> On Fri, Aug 31, 2018 at 12:45 AM Julian Stecklina <jsteckli@amazon.de> wrote:
> >
> > I've been spending some cycles on the XPFO patch set this week. For the
> > patch set as it was posted for v4.13, the performance overhead of
> > compiling a Linux kernel is ~40% on x86_64[1]. The overhead comes almost
> > completely from TLB flushing. If we can live with stale TLB entries
> > allowing temporary access (which I think is reasonable), we can remove
> > all TLB flushing (on x86). This reduces the overhead to 2-3% for
> > kernel compile.
> 
> I have to say, even 2-3% for a kernel compile sounds absolutely horrendous.
> 
> Kernel bullds are 90% user space at least for me, so a 2-3% slowdown
> from a kernel is not some small unnoticeable thing.

Also the problem is that depending on the workload everything may fit
into the TLBs, so the temporary stale TLB entries may be around
for a long time. Modern CPUs have very large TLBs, and good
LRU policies. For the kernel entries with global bit set and
which are used for something there may be no reason ever to evict.

Julian, I think you would need at least some quantitative perfmon data about
TLB replacement rates in the kernel to show that it's "reasonable"
instead of hand waving.

Most likely I suspect you would need a low frequency regular TLB
flush for the global entries at least, which will increase
the overhead again.

-Andi
