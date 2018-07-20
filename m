Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCD46B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 09:18:21 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id z13-v6so5589591wrt.19
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 06:18:20 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b9-v6si1455589wrp.210.2018.07.20.06.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jul 2018 06:18:19 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:17:54 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv5 08/19] x86/mm: Introduce variables to store number,
 shift and mask of KeyIDs
In-Reply-To: <20180720123415.57m2fqbdjtvnietu@kshutemo-mobl1>
Message-ID: <alpine.DEB.2.21.1807201511560.1580@nanos.tec.linutronix.de>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com> <20180717112029.42378-9-kirill.shutemov@linux.intel.com> <1edc05b0-8371-807e-7cfa-6e8f61ee9b70@intel.com> <20180719102130.b4f6b6v5wg3modtc@kshutemo-mobl1> <alpine.DEB.2.21.1807191436300.1602@nanos.tec.linutronix.de>
 <20180719131245.sxnqsgzvkqriy3o2@kshutemo-mobl1> <alpine.DEB.2.21.1807191515150.1602@nanos.tec.linutronix.de> <20180719132312.75lduymla2uretax@kshutemo-mobl1> <alpine.DEB.2.21.1807191539370.1602@nanos.tec.linutronix.de>
 <20180720123415.57m2fqbdjtvnietu@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 20 Jul 2018, Kirill A. Shutemov wrote:
> On Thu, Jul 19, 2018 at 03:40:41PM +0200, Thomas Gleixner wrote:
> > > > I still don't see how that's supposed to work.
> > > > 
> > > > When the inconsistent CPU is brought up _AFTER_ MKTME is enabled, then how
> > > > does clearing the variables help? It does not magically make all the other
> > > > stuff go away.
> > > 
> > > We don't actually enable MKTME in kernel. BIOS does. Kernel makes choose
> > > to use it or not. Current design targeted to be used by userspace.
> > > So until init we don't have any other stuff to go away. We can just
> > > pretend that MKTME was never there.
> > 
> > Hotplug is not guaranteed to happen _BEFORE_ init. Think about physical
> > hotplug.
> 
> Ouch. I didn't think about this. :/
> 
> In this case I don't see how to handle the situation properly.
> Is it okay to WARN() && pray()?

Not really. First of all, you want to do the initial checking on the boot
CPU and then when secondary CPUs are brought up, verify that they have
matching parameters. If they do not, then we should just shut them down
right away before they can touch anything which is TME related and mark
them as 'don't online again'. That needs some extra logic in the hotplug
code, but I already have played with that for different reasons. Stick a
fat comment into that 'not matching' code path for now and I'll give you
the magic for preventing full bringup after polishing it a bit.

Thanks,

	tglx
