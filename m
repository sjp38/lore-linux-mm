Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 95B356B0256
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 11:11:54 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so177078163pac.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:11:54 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id ra1si29143503pbb.202.2015.09.28.08.11.53
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 08:11:53 -0700 (PDT)
Message-ID: <1443453111.2168.9.camel@HansenPartnership.com>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 28 Sep 2015 08:11:51 -0700
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBA4232@AcuExch.aculab.com>
References: 
	<e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	 <2524822.pQu4UKMrlb@vostro.rjw.lan>
	 <1443297128.2181.11.camel@HansenPartnership.com>
	 <3461169.v5xKdGLGjP@vostro.rjw.lan>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBA3BF7@AcuExch.aculab.com>
	 <1443450406.2168.3.camel@HansenPartnership.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBA4232@AcuExch.aculab.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: "'Rafael J. Wysocki'" <rjw@rjwysocki.net>, Viresh Kumar <viresh.kumar@linaro.org>, Johannes Berg <johannes@sipsolutions.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO
 POWER MANAGEM..." <alsa-devel@alsa-project.org>

On Mon, 2015-09-28 at 14:50 +0000, David Laight wrote:
> From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> > Sent: 28 September 2015 15:27
> > On Mon, 2015-09-28 at 08:58 +0000, David Laight wrote:
> > > From: Rafael J. Wysocki
> > > > Sent: 27 September 2015 15:09
> > > ...
> > > > > > Say you have three adjacent fields in a structure, x, y, z, each one byte long.
> > > > > > Initially, all of them are equal to 0.
> > > > > >
> > > > > > CPU A writes 1 to x and CPU B writes 2 to y at the same time.
> > > > > >
> > > > > > What's the result?
> > > > >
> > > > > I think every CPU's  cache architecure guarantees adjacent store
> > > > > integrity, even in the face of SMP, so it's x==1 and y==2.  If you're
> > > > > thinking of old alpha SMP system where the lowest store width is 32 bits
> > > > > and thus you have to do RMW to update a byte, this was usually fixed by
> > > > > padding (assuming the structure is not packed).  However, it was such a
> > > > > problem that even the later alpha chips had byte extensions.
> > >
> > > Does linux still support those old Alphas?
> > >
> > > The x86 cpus will also do 32bit wide rmw cycles for the 'bit' operations.
> > 
> > That's different: it's an atomic RMW operation.  The problem with the
> > alpha was that the operation wasn't atomic (meaning that it can't be
> > interrupted and no intermediate output states are visible).
> 
> It is only atomic if prefixed by the 'lock' prefix.
> Normally the read and write are separate bus cycles.

The essential point is that x86 has atomic bit ops and byte writes.
Early alpha did not.

> > > You still have to ensure the compiler doesn't do wider rmw cycles.
> > > I believe the recent versions of gcc won't do wider accesses for volatile data.
> > 
> > I don't understand this comment.  You seem to be implying gcc would do a
> > 64 bit RMW for a 32 bit store ... that would be daft when a single
> > instruction exists to perform the operation on all architectures.
> 
> Read the object code and weep...
> It is most likely to happen for operations that are rmw (eg bit set).
> For instance the arm cpu has limited offsets for 16bit accesses, for
> normal structures the compiler is likely to use a 32bit rmw sequence
> for a 16bit field that has a large offset.
> The C language allows the compiler to do it for any access (IIRC including
> volatiles).

I think you might be confusing different things.  Most RISC CPUs can't
do 32 bit store immediates because there aren't enough bits in their
arsenal, so they tend to split 32 bit loads into a left and right part
(first the top then the offset).  This (and other things) are mostly
what you see in code.  However, 32 bit register stores are still atomic,
which is all we require.  It's not really the compiler's fault, it's
mostly an architectural limitation.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
