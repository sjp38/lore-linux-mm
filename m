Received: from hoemail2.firewall.lucent.com (localhost [127.0.0.1])
	by hoemail2.firewall.lucent.com (Switch-2.1.3/Switch-2.1.0) with ESMTP id f58Gdo325288
	for <linux-mm@kvack.org>; Fri, 8 Jun 2001 12:39:50 -0400 (EDT)
Received: from ihlss.ih.lucent.com (h135-185-80-10.lucent.com [135.185.80.10])
	by hoemail2.firewall.lucent.com (Switch-2.1.3/Switch-2.1.0) with ESMTP id f58Gdjp25178
	for <linux-mm@kvack.org>; Fri, 8 Jun 2001 12:39:50 -0400 (EDT)
Message-ID: <3B20FFBB.5E29CE37@lucent.com>
Date: Fri, 08 Jun 2001 11:39:23 -0500
From: Tom Roberts <tjroberts@lucent.com>
MIME-Version: 1.0
Subject: Re: mtsr and mfsr?
References: <A33AEFDC2EC0D411851900D0B73EBEF766E100@NAPA>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hua Ji <hji@netscreen.com>
Cc: linuxppc-embedded@lists.linuxppc.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hua Ji wrote:
> I was trying to clear and write some values into those 15 sr registers by
> using **mtsr**.
> But looks like it doesn't work. The testing I did looks like follows:
> #define RESET 0
> li %r3, RESET;
> 
> sync
> isync
> mtsr sr0, %r3
> isync
> sync
> 
> mfsr %r3, sr0
> bl uart_print

While the general registers are scoreboarded, the SR registers are not.
Synchronization is especially tricky between the CPU and the MMU. I suspect
that if you interchange that second "isync;sync" pair to be the usual
"sync; isync" this will work -- the "sync" ensures that the memory system
is synchronized, and the "isync" ensures that the following mfsr does not
execute until the "sync" is _complete_. But I am not certain; I do remember
this is finicky, and there may well be errors of omission in the manuals....

While "isync" says the following instructions execute in the context 
established by the preceeding instructions, I suspect that in the case of
MMU registers that really only applies to their being _used_ by the MMU, and 
not necessarily to being _read_ by the CPU.

My (non-Linux) context-switching code simply loads all SR-s and does a single
isync. It then loads all the registers (via BAT memory addressing), does a 
little bit of housekeeping (again via BAT addressing), and then does an rfi. 
At that point the SRs are all valid.

So if the above interchange does not get it to work, try inserting a
few hundred NOP-s between setting and reading sr0 (:-)).


Tom Roberts	tjroberts@Lucent.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
