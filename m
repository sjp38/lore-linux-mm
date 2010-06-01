Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4776B01B6
	for <linux-mm@kvack.org>; Mon, 31 May 2010 20:24:55 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <4510198c-1562-4766-9cdc-a1df70b14910@default>
Date: Mon, 31 May 2010 17:23:52 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 0/4] Frontswap (was Transcendent Memory): overview
References: <20100528174020.GA28150@ca-server1.us.oracle.com>
 <4C02AB5A.5000706@vflare.org> <a38d5a97-1517-46c4-9b2f-27e16aba58f2@default
 4C040981.8030002@vflare.org>
In-Reply-To: <4C040981.8030002@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com, avi@redhat.com, pavel@ucw.cz, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> From: Nitin Gupta [mailto:ngupta@vflare.org]

> frontswap is a particular use case of zram disks. However, we still
> need to work on some issues with zram:
>  - zram cannot return write/put failures for arbitrary pages. OTOH,
> frontswap can consult host before every put and may forward pages to
> in-guest swap device when put fails.
>  - When a swap slot is freed, the notification from guest does
> not reach zram device(s) as exported from host. OTOH, frontswap calls
> frontswap_flush() which frees corresponding page from host memory.
>  - Being a block device, it is potentially slower than frontswap
> approach. But being a generic device, its useful for all kinds
> of guest OS (including windows etc).

Hi Nitin --

This is a good list (not sure offhand it is complete or not) of
the key differences between zram and frontswap.  Unless/until
zram solves each of these issues -- which are critical to the
primary objective of frontswap (namely intelligent overcommit) --
I simply can't agree that frontswap is a particular use case
of zram.  Zram is just batched asynchronous I/O to a fixed-size
device with a bonus of on-the-fly compression.  Cool, yes.
Useful, yes.  Useful in some cases in a virtualized environment,
yes.  But a superset/replacement of frontswap, no.

> Yes, zram cannot return write/put failure for arbitrary pages but other
> than that what additional benefits does frontswap bring? Even with
> frontswap,
> whatever pages are once given out to hypervisor just stay there till
> guest
> reads them back. Unlike cleancache, you cannot free them at any point.
> So,
> it does not seem anyway more flexible than zram.

The flexibility is that the hypervisor can make admittance
decisions on each individual page... this is exactly what
allows for intelligent overcommit.  Since the pages "just
stay there until the guest reads them back", the hypervisor
must be very careful about which and how many pages it accepts
and the admittance decisions must be very dynamic, depending
on a lot of factors not visible to any individual guest
and not timely enough to be determined by the asynchronous
"backend I/O" subsystem of a host or dom0.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
