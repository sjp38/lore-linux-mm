From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Mon, 7 Jul 2003 21:07:09 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <200307071955.58774.phillips@arcor.de> <Pine.LNX.4.55.0307071105110.4704@bigblue.dev.mcafeelabs.com>
In-Reply-To: <Pine.LNX.4.55.0307071105110.4704@bigblue.dev.mcafeelabs.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307072107.09855.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Jamie Lokier <jamie@shareable.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 07 July 2003 20:36, Davide Libenzi wrote:
> On Mon, 7 Jul 2003, Daniel Phillips wrote:
> > On Monday 07 July 2003 19:25, Davide Libenzi wrote:
> > > Jamie, looking at those reports it seems it is not only a sound players
> > > problem.
> >
> > You still seem to be having trouble with the idea that the sound
> > servicing thread is a realtime process, and thus fundamentally different
> > from other kinds of processes.  Could you please explain why you disagree
> > with this?
>
> I'm just trying to figure out why :
>
> 1) RealPlayer does not skip on my 2.4.20
                                    ^^^^^^
We're talking about 2.5.

> 2) RealPlayer does not skip on my office XP
> 3) MediaPlayer does not skip on my office XP
>
> Maybe it is more of an application problem.

Partly.  We've been through that in pretty good detail.  There are 
combinations of hardware and kernel versions that happen to be pretty good at 
running sound, that doesn't mean the problem is dealt with so that corner 
cases don't come up.  A 99% solution is not good enough, that still will 
leave 10,000's of Linux users with poor sound performance.

Zinf does things correctly: it has a big buffer and it tries to set an 
elevated priority for its sound servicing thread.  With 2.5, that isn't 
enough, and Con's tweaking isn't enough.  And that's not wrong, because the 
kernel *should not* try to identify realtime threads automagically.

Zinf could go further and try to set a posix realtime scheduling mode, but 
that attempt would be blocked by the root requirement for realtime 
scheduling, which is ihmo due to braindamage in the definition of the posix 
realtime scheduling modes.  This last we *can* fix in the kernel, by creating 
a new realtime scheduling mode that is sane enough to be used by normal 
users.  Then sound applications would need to be changed to use it, which 
really is no big deal.

In the meantime, a combination of Con's priority tweaks and user-initiated 
nice works well.

> > > The *application* has to hint the scheduler, not the user.
> >
> > Partly true, in that users should be able to supply the hint in some way,
> > they desire.  However in this case - Zinf - the point is moot, because
> > Zinf is trying hard to give the hint, but it fails because of
> > above-mentioned braindamage.
>
> Try to play with SNDCTL_DSP_SETFRAGMENT. Last time I checked the kernel
> let you set a dma buf for 0.5 up to 1 sec of play (upper limited by 64Kb).
> Feeding the sound card with 4Kb writes will make you skip after about 50ms
> CPU blackout at 44KHz 16 bit. RealPlayer uses 16Kb feeding chunks that
> makes it able to sustain up to 200ms of blackout.

That's just fiddling, it doesn't deal with the basic problem.  Anyway, big 
buffers have their own annoyances.  Have you tried the graphic equalizer in 
xmms lately?  A one second lag on slider adjustment is not nice.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
