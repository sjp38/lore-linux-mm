Message-ID: <37EF30FF.456EBA6B@kieray1.p.y.ki.era.ericsson.se>
Date: Mon, 27 Sep 1999 10:55:27 +0200
From: Marcus Sundberg <erammsu@kieray1.p.y.ki.era.ericsson.se>
MIME-Version: 1.0
Subject: Re: mm->mmap_sem
References: <Pine.LNX.4.10.9909252050590.25425-100000@imperial.edgeglobal.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: James Simmons <jsimmons@edgeglobal.com>
List-ID: <linux-mm.kvack.org>

James Simmons wrote:
> To be exactly I'm trying to do cooperative locking between a mmaping of
> the accel region of /dev/gfx and the framebuffer region of /dev/fb. I
> notice that after mmapping the kernel can no long control access to the
> memory regions. So I need to block any process from accessing the
> framebuffer while the accel engine is running. Since many low end cards
> lock if you access the framebuffer and accel engine at the same time.

No, you are trying to do _mandatory_ locking enforced by the kernel.
For cooperative locking on sane GFX hardware a userspace spinlock is
indeed all that is required, but for the broken hardware you are talking
about kernel locking would be required.

This means that when the accel engine is initiated you must unmap all
pages of the framebuffer (8k pages on modern cards), install a no-page
handler and flush the TLBs of all processors. If accel commands are
batched, applications do accesses in an intelligent way, and the
framebuffer is only re-mapped when it is actually accessed you might
get usable performance.

Still, I'm not sure it's worth the trouble. Personally I'd rather buy
decent hardware or only run trusted applications than take this 
performance hit.

//Marcus
-- 
-------------------------------+------------------------------------
        Marcus Sundberg        | http://www.stacken.kth.se/~mackan/
 Royal Institute of Technology |       Phone: +46 707 295404
       Stockholm, Sweden       |   E-Mail: mackan@stacken.kth.se
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
