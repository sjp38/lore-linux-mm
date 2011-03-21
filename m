Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B44678D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 10:32:27 -0400 (EDT)
Message-ID: <4D8761D1.6010605@ladisch.de>
Date: Mon, 21 Mar 2011 15:33:53 +0100
From: Clemens Ladisch <clemens@ladisch.de>
MIME-Version: 1.0
Subject: Re: BUG in vb_alloc() (was: [Bug 31572] New: firewire crash at boot)
References: <bug-31572-4803@https.bugzilla.kernel.org/>	<20110321143203.0fb19bee@stein> <20110321145002.5aa8114d@stein>
In-Reply-To: <20110321145002.5aa8114d@stein>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>, Nick Piggin <npiggin@suse.de>
Cc: linux1394-devel@lists.sourceforge.net, Pavel Kysilka <goldenfish@linuxsoft.cz>, linux-mm@kvack.org

Stefan Richter wrote:
> > > https://bugzilla.kernel.org/show_bug.cgi?id=31572
> > > Created an attachment (id=51502)
> > >  --> (https://bugzilla.kernel.org/attachment.cgi?id=51502)
> > > photo of oops
> 
> EIP is at vm_map_ram+0xff/0x363.

This is in some inlined part of vb_alloc (which means that the FireWire
code is not directly at fault, it's just the first one that happens to
use this code).

> Clemens, does the hex dump tell you anything?

Half of it is missing.  (What's going on with that video output?
This GPU works fine in my machine, with a 64-bit kernel.  (And why
is an 8 GB machine using a 32-bit kernel?))

Anyway, the part immediately before the crashing instruction is:
c109c993:   31 d2                   xor    %edx,%edx
c109c995:   f7 f1                   div    %ecx
c109c997:   31 d2                   xor    %edx,%edx
c109c999:   89 c7                   mov    %eax,%edi
c109c99b:   8b 45 cc                mov    -0x34(%ebp),%eax
c109c99e:   f7 f1                   div    %ecx
c109c9a0:   39 c7                   cmp    %eax,%edi
c109c9a2:   74 04                   je     0xc109c9a8
c109c9a4:   ??...                   ???                   <-- crash here

This looks as if this check in vb_alloc triggered:

                BUG_ON(addr_to_vb_idx(addr) !=
                                addr_to_vb_idx(vb->va->va_start));

On x86, we call vm_map_ram() with 8+2 pages, so the parameters here
are vb_alloc(40960, GFP_KERNEL).

I've never tested this code during bootup; I always loaded firewire-ohci
later.


Regards,
Clemens

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
