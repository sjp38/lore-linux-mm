Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC6F6B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 09:41:11 -0400 (EDT)
Received: by lahh2 with SMTP id h2so136058520lah.0
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 06:41:10 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id wq3si1256071lac.97.2015.09.27.06.41.07
        for <linux-mm@kvack.org>;
        Sun, 27 Sep 2015 06:41:09 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Sun, 27 Sep 2015 16:09:25 +0200
Message-ID: <3461169.v5xKdGLGjP@vostro.rjw.lan>
In-Reply-To: <1443297128.2181.11.camel@HansenPartnership.com>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org> <2524822.pQu4UKMrlb@vostro.rjw.lan> <1443297128.2181.11.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Johannes Berg <johannes@sipsolutions.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>

On Saturday, September 26, 2015 12:52:08 PM James Bottomley wrote:
> On Fri, 2015-09-25 at 22:58 +0200, Rafael J. Wysocki wrote:
> > On Friday, September 25, 2015 01:25:49 PM Viresh Kumar wrote:
> > > On 25 September 2015 at 13:33, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> > > > You're going to change that into bool in the next patch, right?
> > > 
> > > Yeah.
> > > 
> > > > So what if bool is a byte and the field is not word-aligned
> > > 
> > > Its between two 'unsigned long' variables today, and the struct isn't packed.
> > > So, it will be aligned, isn't it?
> > > 
> > > > and changing
> > > > that byte requires a read-modify-write.  How do we ensure that things remain
> > > > consistent in that case?
> > > 
> > > I didn't understood why a read-modify-write is special here? That's
> > > what will happen
> > > to most of the non-word-sized fields anyway?
> > > 
> > > Probably I didn't understood what you meant..
> > 
> > Say you have three adjacent fields in a structure, x, y, z, each one byte long.
> > Initially, all of them are equal to 0.
> > 
> > CPU A writes 1 to x and CPU B writes 2 to y at the same time.
> > 
> > What's the result?
> 
> I think every CPU's  cache architecure guarantees adjacent store
> integrity, even in the face of SMP, so it's x==1 and y==2.  If you're
> thinking of old alpha SMP system where the lowest store width is 32 bits
> and thus you have to do RMW to update a byte, this was usually fixed by
> padding (assuming the structure is not packed).  However, it was such a
> problem that even the later alpha chips had byte extensions.

OK, thanks!

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
