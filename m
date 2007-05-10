From: Rob Landley <rob@landley.net>
Subject: Re: [patch] removes MAX_ARG_PAGES
Date: Wed, 9 May 2007 21:04:42 -0400
References: <65dd6fd50705060151m78bb9b4fpcb941b16a8c4709e@mail.gmail.com> <20070509134815.81cb9aa9.akpm@linux-foundation.org>
In-Reply-To: <20070509134815.81cb9aa9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705092104.43353.rob@landley.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ollie Wild <aaw@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wednesday 09 May 2007 4:48 pm, Andrew Morton wrote:
> On Sun, 6 May 2007 01:51:34 -0700
> "Ollie Wild" <aaw@google.com> wrote:
> 
> > A while back, I sent out a preliminary patch
> > (http://thread.gmane.org/gmane.linux.ports.hppa/752) to remove the
> > MAX_ARG_PAGES limit on command line sizes.  Since then, Peter Zijlstra
> > and I have fixed a number of bugs and addressed the various
> > outstanding issues.
> > 
> > The attached patch incorporates the following changes:
> > 
> > - Fixes a BUG_ON() assertion failure discovered by Ingo Molnar.
> > - Adds CONFIG_STACK_GROWSUP (parisc) support.
> > - Adds auditing support.
> > - Reverts to the old behavior on architectures with no MMU.
> > - Fixes broken execution of 64-bit binaries from 32-bit binaries.
> > - Adds elf_fdpic support.
> > - Fixes cache coherency bugs.
> > 
> > We've tested the following architectures: i386, x86_64, um/i386,
> > parisc, and frv.  These are representative of the various scenarios
> > which this patch addresses, but other architecture teams should try it
> > out to make sure there aren't any unexpected gotchas.
>
> I'll duck this for now, given the couple of problems which people have
> reported. 

Just FYI, a really really quick and dirty way of testing this sort of thing on 
more architectures and you're likely to physically have?

1) Install QEMU.

2) Grab http://landley.net/code/firmware (releases in the downloads directory, 
or tarball of most recent repository snapshot is 
wget "http://landley.net/hg/firmware?ca=tip;type=gz").

3) Edit "download.sh" to point at the URL of your tarball instead of whatever 
kernel.org version it's using.  (Or add your patch to sources/patches if it 
applies to the version it's already using.  Note that if you set SHA1= blank 
in download.sh it'll skip the checksum test, so you don't have to recalculate 
the sha1sum if you don't want to.)

4) Run ./build.sh for the architecture you're interested in.  (I suggest 
armv4l, i686, mipsel, and x86_64.  Both sparc and ppc are currently broken 
for different reasons; I'm working on it.)  Wait a longish time for it to 
finish compiling. :)

5) "cd build; ./run-armv4l.sh" and your shell prompt should now be in qemu 
running a kernel for the appropriate architecture.  (You even have a native 
version of gcc you can build stuff with, although you may have 
to "ln -s /tools/lib /lib" to run the results, for reasons Linux From Scratch 
developers will recognize. :)

This won't help you test real hardware (at least hardware qemu doesn't 
emulate), but for stuff like filesystems or executable file formats, it's 
handy. :)

Email me if something doesn't work...

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
