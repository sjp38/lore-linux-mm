Date: Wed, 9 Apr 2003 03:18:45 -0700
From: Andrew Morton <akpm@digeo.com>
Message-ID: <PAO-EX01DJb0LxA56iY0000151b@pao-ex01.pao.digeo.com>
Sender: owner-linux-mm@kvack.org
Subject: Re: 2.5.67-mm1 cause framebuffer crash at bootup
Message-Id: <20030409031845.185d853f.akpm@digeo.com>
In-Reply-To: <3E93EB0E.4030609@aitel.hist.no>
References: <20030408042239.053e1d23.akpm@digeo.com>
	<3E93EB0E.4030609@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, vandrove@vc.cvut.cz
List-ID: <linux-mm.kvack.org>


Helge Hafting <helgehaf@aitel.hist.no> wrote:
>
> 2.5.67 works with framebuffer console, 2.5.67-mm1 dies before activating
> graphichs mode on two different machines:
> 
> smp with matroxfb, also using a patch that makes matroxfb work in 2.5
> up with radeonfb, also using patches that fixes the broken devfs in mm1.
> 
> I use devfs and preempt in both cases, and monolithic kernels without module
> support.
> 
> 2.5.67-mm1 works if I drop framebuffer support completely.
>
> Here is the printed backtrace for the radeon case, the matrox case was 
> similiar:

Well I tried to reproduce this with an

	nVidia Corporation NV17 [GeForce4 MX440] (rev a3)

and the screen came up in a strange mixture of penguins and obviously uninitialised
video RAM overlayed on top of text.  I can't read a thing.

But there is no oops.

The Cirrus drivers still do not compile, so scrub that test box.

We have some compilation scruffies:
drivers/video/aty/mach64_gx.c:194: warning: initialization from incompatible pointer type
drivers/video/aty/mach64_gx.c:486: warning: initialization from incompatible pointer type
drivers/video/aty/mach64_gx.c:602: warning: initialization from incompatible pointer type
drivers/video/aty/mach64_gx.c:726: warning: initialization from incompatible pointer type
drivers/video/aty/mach64_gx.c:873: warning: initialization from incompatible pointer type

Another machine here uses

	ATI Technologies Inc Rage Mobility M3 AGP 2x (rev 02)

and..... it oopses!   Backing out 

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.67/2.5.67-mm1/broken-out/earlier-keyboard-init.patch

prevents it oopsing.  Can you please try that?


Despite the lack of oopses, framebuffer support is sick on this machine also.
The LCD alternates between blackness and a strange smeary set of flickering
lines.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
