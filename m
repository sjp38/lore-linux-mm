Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 746746B0269
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:34:21 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d22-v6so7303361pls.4
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:34:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor464304pgf.66.2018.07.20.05.34.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 05:34:20 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:34:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 08/19] x86/mm: Introduce variables to store number,
 shift and mask of KeyIDs
Message-ID: <20180720123415.57m2fqbdjtvnietu@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-9-kirill.shutemov@linux.intel.com>
 <1edc05b0-8371-807e-7cfa-6e8f61ee9b70@intel.com>
 <20180719102130.b4f6b6v5wg3modtc@kshutemo-mobl1>
 <alpine.DEB.2.21.1807191436300.1602@nanos.tec.linutronix.de>
 <20180719131245.sxnqsgzvkqriy3o2@kshutemo-mobl1>
 <alpine.DEB.2.21.1807191515150.1602@nanos.tec.linutronix.de>
 <20180719132312.75lduymla2uretax@kshutemo-mobl1>
 <alpine.DEB.2.21.1807191539370.1602@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807191539370.1602@nanos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 19, 2018 at 03:40:41PM +0200, Thomas Gleixner wrote:
> On Thu, 19 Jul 2018, Kirill A. Shutemov wrote:
> > On Thu, Jul 19, 2018 at 03:18:03PM +0200, Thomas Gleixner wrote:
> > > On Thu, 19 Jul 2018, Kirill A. Shutemov wrote:
> > > > On Thu, Jul 19, 2018 at 02:37:35PM +0200, Thomas Gleixner wrote:
> > > > > On Thu, 19 Jul 2018, Kirill A. Shutemov wrote:
> > > > > > On Wed, Jul 18, 2018 at 04:19:10PM -0700, Dave Hansen wrote:
> > > > > > > >  	} else {
> > > > > > > >  		/*
> > > > > > > >  		 * Reset __PHYSICAL_MASK.
> > > > > > > > @@ -591,6 +592,9 @@ static void detect_tme(struct cpuinfo_x86 *c)
> > > > > > > >  		 * between CPUs.
> > > > > > > >  		 */
> > > > > > > >  		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> > > > > > > > +		mktme_keyid_mask = 0;
> > > > > > > > +		mktme_keyid_shift = 0;
> > > > > > > > +		mktme_nr_keyids = 0;
> > > > > > > >  	}
> > > > > > > 
> > > > > > > Should be unnecessary.  These are zeroed by the compiler.
> > > > > > 
> > > > > > No. detect_tme() called for each CPU in the system.
> > > > > 
> > > > > And then the variables are cleared out while other CPUs can access them?
> > > > > How is that supposed to work?
> > > > 
> > > > This code path only matter in patalogical case: when MKTME configuation is
> > > > inconsitent between CPUs. Basically if BIOS screwed things up we disable
> > > > MKTME.
> > > 
> > > I still don't see how that's supposed to work.
> > > 
> > > When the inconsistent CPU is brought up _AFTER_ MKTME is enabled, then how
> > > does clearing the variables help? It does not magically make all the other
> > > stuff go away.
> > 
> > We don't actually enable MKTME in kernel. BIOS does. Kernel makes choose
> > to use it or not. Current design targeted to be used by userspace.
> > So until init we don't have any other stuff to go away. We can just
> > pretend that MKTME was never there.
> 
> Hotplug is not guaranteed to happen _BEFORE_ init. Think about physical
> hotplug.

Ouch. I didn't think about this. :/

In this case I don't see how to handle the situation properly.
Is it okay to WARN() && pray()?

-- 
 Kirill A. Shutemov
