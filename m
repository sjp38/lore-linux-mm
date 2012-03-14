Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id DEA666B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 21:57:59 -0400 (EDT)
Date: Tue, 13 Mar 2012 18:57:56 -0700
From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH 0/5] Persist printk buffer across reboots.
Message-ID: <20120314015755.GB5218@fifo99.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
 <20120312.225302.488696931454771146.davem@davemloft.net>
 <1331646604.18960.76.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331646604.18960.76.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: David Miller <davem@davemloft.net>, apenwarr@gmail.com, akpm@linux-foundation.org, josh@joshtriplett.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, fdinitto@redhat.com, hannes@cmpxchg.org, olaf@aepfle.de, paul.gortmaker@windriver.com, tj@kernel.org, hpa@linux.intel.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 13, 2012 at 02:50:04PM +0100, Peter Zijlstra wrote:
> On Mon, 2012-03-12 at 22:53 -0700, David Miller wrote:
> > From: Avery Pennarun <apenwarr@gmail.com>
> > Date: Tue, 13 Mar 2012 01:36:36 -0400
> > 
> > > The last patch in this series implements a new CONFIG_PRINTK_PERSIST option
> > > that, when enabled, puts the printk buffer in a well-defined memory location
> > > so that we can keep appending to it after a reboot.  The upshot is that,
> > > even after a kernel panic or non-panic hard lockup, on the next boot
> > > userspace will be able to grab the kernel messages leading up to it.  It
> > > could then upload the messages to a server (for example) to keep crash
> > > statistics.
> > 
> > On some platforms there are formal ways to reserve areas of memory
> > such that the bootup firmware will know to not touch it on soft resets
> > no matter what.  For example, on Sparc there are OpenFirmware calls to
> > set aside such an area of soft-reset preserved memory.
> > 
> > I think some formal agreement with the system firmware is a lot better
> > when available, and should be explicitly accomodated in these changes
> > so that those of us with such facilities can very easily hook it up.
> 
> Shouldn't this all be near the pstore effort? I know pstore and the
> soft-reset stuff aren't quite the same, but if that's the best Sparc can
> do, then why not?
> 
> OTOH if Sparc can actually do pstore too, then it might make sense.
> 
> What I guess I'm saying is that we should try and minimize the duplicate
> efforts here.. and it seems to me that writing a soft reset x86 backend
> to pstore for those machines that don't actually have the acpi flash
> crap might be more useful and less duplicative.

I don't disagree, but pstore is written with this transactional notion in
mind. It's doesn't appear to be setup to handle just a straight memory
area. Changing mtdoops to do this would be more trivial. It would be merging
android ram_console with mtdoops basically. However, I don't know if that would
cover what Avery is doing here.

pstore does seems to have the nicest user interface (might be better in
debugfs tho). If someone wanted to move forward with pstore they
would have to write some some sort of,

int pstore_register_simple(unsigned long addr, unsigned long size);

to cover all the memory areas that aren't transaction based, or make
pstore accept a platform_device.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
