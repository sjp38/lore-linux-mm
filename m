Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A40336B560A
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 04:43:58 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q11-v6so10339696oih.15
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 01:43:58 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id a186-v6si6175066oif.147.2018.08.31.01.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 31 Aug 2018 01:43:57 -0700 (PDT)
Message-ID: <1535705027.3085.5.camel@HansenPartnership.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated
 CPUs in mind (for KVM to isolate its guests per CPU)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 31 Aug 2018 09:43:47 +0100
In-Reply-To: <1534801939.10027.24.camel@amazon.co.uk>
References: <20180820212556.GC2230@char.us.oracle.com>
	 <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
	 <1534801939.10027.24.camel@amazon.co.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Woodhouse, David" <dwmw@amazon.co.uk>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
Cc: "juerg.haefliger@hpe.com" <juerg.haefliger@hpe.com>, "deepa.srinivasan@oracle.com" <deepa.srinivasan@oracle.com>, "jmattson@google.com" <jmattson@google.com>, "andrew.cooper3@citrix.com" <andrew.cooper3@citrix.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>, "pradeep.vincent@oracle.com" <pradeep.vincent@oracle.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "khalid.aziz@oracle.com" <khalid.aziz@oracle.com>, "kanth.ghatraju@oracle.com" <kanth.ghatraju@oracle.com>, "liran.alon@oracle.com" <liran.alon@oracle.com>, "keescook@google.com" <keescook@google.com>, "jsteckli@os.inf.tu-dresden.de" <jsteckli@os.inf.tu-dresden.de>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "chris.hyser@oracle.com" <chris.hyser@oracle.com>, "tyhicks@canonical.com" <tyhicks@canonical.com>, "john.haxby@oracle.com" <john.haxby@oracle.com>, "jcm@redhat.com" <jcm@redhat.com>

On Mon, 2018-08-20 at 21:52 +0000, Woodhouse, David wrote:
> On Mon, 2018-08-20 at 14:48 -0700, Linus Torvalds wrote:
> > 
> > Of course, after the long (and entirely unrelated) discussion about
> > the TLB flushing bug we had, I'm starting to worry about my own
> > competence, and maybe I'm missing something really fundamental, and
> > the XPFO patches do something else than what I think they do, or my
> > "hey, let's use our Meltdown code" idea has some fundamental
> > weakness
> > that I'm missing.
> 
> The interesting part is taking the user (and other) pages out of the
> kernel's 1:1 physmap.
> 
> It's the *kernel* we don't want being able to access those pages,
> because of the multitude of unfixable cache load gadgets.

A long time ago, I gave a talk about precisely this at OLS (2005 I
think).  On PA-RISC we have a problem with inequivalent aliasing in the
 page cache (same physical page with two different virtual addresses
modulo 4MB) which causes a machine check if it occurs. 
Architecturally, PA can move into the cache any page for which it has a
mapping and the kernel offset map of every page causes an inequivalency
if the same page is in use in user space.  Of course, practically the
caching machinery is too busy moving in and out pages we reference to
have an interest in speculating on other pages it has a mapping for, so
it almost never (the almost being a set of machine checks we see very
occasionally in the latest and most aggressively cached and speculating
CPUs).  If this were implemented, we'd be interested in using it.

James
