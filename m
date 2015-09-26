Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 60EA66B0255
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 15:52:12 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so136200269pac.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 12:52:12 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id ra1si14753589pbb.202.2015.09.26.12.52.11
        for <linux-mm@kvack.org>;
        Sat, 26 Sep 2015 12:52:11 -0700 (PDT)
Message-ID: <1443297128.2181.11.camel@HansenPartnership.com>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sat, 26 Sep 2015 12:52:08 -0700
In-Reply-To: <2524822.pQu4UKMrlb@vostro.rjw.lan>
References: 
	<e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	 <4357538.Wlf88yQie6@vostro.rjw.lan>
	 <CAKohpok2Z2m7GZt1GzZzofeHEioF=XJEq8YVgtY=VtS9tmpb_Q@mail.gmail.com>
	 <2524822.pQu4UKMrlb@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Johannes Berg <johannes@sipsolutions.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO
 POWER MANAGEM..." <alsa-devel@alsa-project.org>

On Fri, 2015-09-25 at 22:58 +0200, Rafael J. Wysocki wrote:
> On Friday, September 25, 2015 01:25:49 PM Viresh Kumar wrote:
> > On 25 September 2015 at 13:33, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> > > You're going to change that into bool in the next patch, right?
> > 
> > Yeah.
> > 
> > > So what if bool is a byte and the field is not word-aligned
> > 
> > Its between two 'unsigned long' variables today, and the struct isn't packed.
> > So, it will be aligned, isn't it?
> > 
> > > and changing
> > > that byte requires a read-modify-write.  How do we ensure that things remain
> > > consistent in that case?
> > 
> > I didn't understood why a read-modify-write is special here? That's
> > what will happen
> > to most of the non-word-sized fields anyway?
> > 
> > Probably I didn't understood what you meant..
> 
> Say you have three adjacent fields in a structure, x, y, z, each one byte long.
> Initially, all of them are equal to 0.
> 
> CPU A writes 1 to x and CPU B writes 2 to y at the same time.
> 
> What's the result?

I think every CPU's  cache architecure guarantees adjacent store
integrity, even in the face of SMP, so it's x==1 and y==2.  If you're
thinking of old alpha SMP system where the lowest store width is 32 bits
and thus you have to do RMW to update a byte, this was usually fixed by
padding (assuming the structure is not packed).  However, it was such a
problem that even the later alpha chips had byte extensions.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
