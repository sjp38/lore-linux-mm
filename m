MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Oct 1999 06:59:04 -0400 (EDT)
From: Rik Faith <faith@precisioninsight.com>
Subject: Re: MMIO regions
In-Reply-To: [James Simmons <jsimmons@edgeglobal.com>] Sun 10 Oct 1999 20:21:15 -0400
References: <14336.53971.896012.84699@light.alephnull.com>
	<Pine.LNX.4.10.9910102015030.4696-100000@imperial.edgeglobal.com>
Message-ID: <14337.44116.941615.384442@light.alephnull.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Rik Faith <faith@precisioninsight.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun 10 Oct 1999 20:21:15 -0400,
   James Simmons <jsimmons@edgeglobal.com> wrote:
> 
> > No.  The DRI assumes that direct-rendering clients are running as non-root
> > users.  A direct-rendering client, with an open connection to the X server,
> > is allowed to mmap the MMIO region via a special device (additional
> > restrictions also apply).  For more information, please see "A Security
> > Analysis of the Direct Rendering Infrastructure"
> > (http://precisioninsight.com/dr/security.html).
> 
> > Just to clarify, the DRI does _not_ require that clients be SUID.
> 
> Oh my. Non root and direct access to buggy hardware.

For those on the list who haven't read the Security Analysis document, let
me summarize the DRI's security policy with respect to mapping the MMIO
region: A non-root direct-rendering client is allowed to map the MMIO
region if:

    1) the client already has an open connection to the X server (so, for
       example, all xauth authentication has already been performed), and

    2) the client is running with the appropriate access rights that allow
       it to open the DRM device (so the system administrator can easily
       restrict direct-rendering access to a certain group of users).

> Yeah since your familar with SGI can you explain to me the use of 
> /dev/shmiq, /dev/qcntl and /dev/usemaclone. I have seen them used for the
> X server on IRIX and was just interested to see if they could be of use on
> other platforms. Yes SGI linux supports these.

I believe the shmiq (shared memory input queue) and qcntl devices are
mostly used by the input device drivers (e.g, keyboard, mouse, tablet,
dial/button box) to serialize input events destined for the X server.  For
Linux, much of the functionality of these devices has already been
implemented as pure user-space programs (e.g., gpm can serialize input from
multiple mice).

The usema device provides spinlocks and semaphores.  SGI uses these to
provide synchronization between X server threads for indirect-rendering
with their multi-rendering implementation.  This is discussed in:

  [KHLS94] Mark J. Kilgard, Simon Hui, Allen A Leinwand, and Dave
  Spalding.  X Server Multi-rendering for OpenGL and PEX.  8th Annual X
  Technical Conference, Boston, Mass., January 25, 1994.  Available from
  <http://reality.sgi.com/opengl/multirender/multirender.html>.

Note that the two-tiered lock that the DRM implements can be viewed as a
specially optimized "user-space" semaphore, and that the DRM already
provides other functionality that is described in this paper (although our
initial implementation has concentrated on the performance-critical case of 
direct rendering).

Because PC-class hardware is so different from SGI-class hardware, direct
rendering on non-SGI machines requires the implementation of interfaces
that SGI does not need (i.e., implementing all of the traditional SGI
interfaces is not sufficient to provide fast direct rendering on PC-class
hardware).  The DRI, however, has been designed for hardware ranging from
low-end PC-class hardware to high-end SGI-class hardware, so it can be used 
on hardware that requires cooperative locking as well on hardware that can
be virtualized.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
