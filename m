Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE6D16B1B85
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 19:00:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n17-v6so8509316pff.17
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 16:00:24 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l1-v6si11936307pfd.193.2018.08.20.16.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 16:00:23 -0700 (PDT)
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
References: <20180820212556.GC2230@char.us.oracle.com>
 <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk>
 <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <20180820223557.GC16961@cisco.cisco.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <bd148fb6-e139-a065-1bf5-8054f932d30a@intel.com>
Date: Mon, 20 Aug 2018 15:59:54 -0700
MIME-Version: 1.0
In-Reply-To: <20180820223557.GC16961@cisco.cisco.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@tycho.ws>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, jsteckli@os.inf.tu-dresden.de, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On 08/20/2018 03:35 PM, Tycho Andersen wrote:
> Since meltdown hit, I haven't worked seriously on understand and
> implementing his suggestions, in part because it wasn't clear to me
> what pieces of the infrastructure we might be able to re-use. Someone
> who knows more about mm/ might be able to suggest an approach, though

Unfortunately, I'm not sure there's much of KPTI we can reuse.  KPTI
still has a very static kernel map (well, two static kernel maps) and
XPFO really needs a much more dynamic map.

We do have a bit of infrastructure now to do TLB flushes near the kernel
exit point, but it's entirely for the user address space, which isn't
affected by XPFO.
