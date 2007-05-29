Date: Tue, 29 May 2007 16:57:16 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1/2] tmpfs doc. question/update
In-Reply-To: <20070524000029.8c9b16eb.randy.dunlap@oracle.com>
Message-ID: <Pine.LNX.4.64.0705291604310.21029@blonde.wat.veritas.com>
References: <20070524000029.8c9b16eb.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, cr@sap.com
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Randy Dunlap wrote:
> 
> 1.  Documentation/filesystems/tmpfs.txt says:
> 
> """
> 2) glibc 2.2 and above expect tmpfs to be mounted at /dev/shm for
>    POSIX shared memory (shm_open, shm_unlink). Adding the following
>    line to /etc/fstab should take care of this:
> 
> 	tmpfs	/dev/shm	tmpfs	defaults	0 0
> 
>    Remember to create the directory that you intend to mount tmpfs on
>    if necessary.
> """
> 
> Is this still accurate?

Well, yes, -ish: perhaps that amounts to no.  Certainly the paragraph
dates from early days of tmpfs, before any distro would be doing that
for you.  And now you prompt me to look, I see here (openSUSE 10.2)
that with udev using a tmpfs mounted on /dev, they've sensibly decided
not to mount yet another tmpfs within that on /dev/shm (whereas FC6
does have that separate mount; I've not checked FC7).

Could certainly benefit from some rewording: perhaps change the second
sentence to say "If /dev/shm is not already inside a tmpfs, adding the
following..."?  Or just delete all but the first sentence, since now
any distro would already be doing that, and anyone capable of putting
together their own won't need the beginner's instructions that follow?

> 2.  I have a few doc. updates:

Thanks a lot for taking the trouble.  Most of your corrections
look good to me, but a couple not: comments inserted below.

Hugh

> 
> ---
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix tmpfs.txt typos, language (ambiguities) etc.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  Documentation/filesystems/tmpfs.txt |   39 ++++++++++++++++++------------------
>  1 file changed, 20 insertions(+), 19 deletions(-)
> 
> --- linux-2.6.21-rc2-git4.orig/Documentation/filesystems/tmpfs.txt
> +++ linux-2.6.21-rc2-git4/Documentation/filesystems/tmpfs.txt
> @@ -10,16 +10,16 @@ shrinks to accommodate the files it cont
>  unneeded pages out to swap space. It has maximum size limits which can
>  be adjusted on the fly via 'mount -o remount ...'
>  
> -If you compare it to ramfs (which was the template to create tmpfs)
> -you gain swapping and limit checking. Another similar thing is the RAM
> -disk (/dev/ram*), which simulates a fixed size hard disk in physical
> -RAM, where you have to create an ordinary filesystem on top. Ramdisks
> -cannot swap and you do not have the possibility to resize them. 
> +If you compare it to ramfs (which was the template to create tmpfs), you
> +gain swapping and checking of limits (via mount options). Another similar
> +thing is the RAM disk (/dev/ram*), which simulates a fixed size hard disk
> +in physical RAM, where you have to create an ordinary filesystem on top.
> +Ramdisks cannot swap and you do not have the possibility to resize them.

If I'm reading that right, essentially you're inserting "(via mount
options)".  But that's not right: there's no mount option to enable
swapping, nor to enable limit checking.  True you can adjust the
limits (or even suppress them) by mount options, but that would need
a different sentence; and those options are spelt out further down,
so I don't think there's any need to modify this paragraph at all.

>  
>  Since tmpfs lives completely in the page cache and on swap, all tmpfs
> -pages currently in memory will show up as cached. It will not show up
> -as shared or something like that. Further on you can check the actual
> -RAM+swap use of a tmpfs instance with df(1) and du(1).
> +pages currently in memory will show up as cached. They will not show up
> +as shared or something like that. You can check the actual RAM+swap use
> +of a tmpfs instance with df(1) and du(1).
>  
>  
>  tmpfs has the following uses:
> @@ -29,10 +29,10 @@ tmpfs has the following uses:
>     memory. 
>  
>     This mount does not depend on CONFIG_TMPFS. If CONFIG_TMPFS is not
> -   set, the user visible part of tmpfs is not build. But the internal
> +   set, the user visible part of tmpfs is not built, but the internal
>     mechanisms are always present.
>  
> -2) glibc 2.2 and above expects tmpfs to be mounted at /dev/shm for
> +2) glibc 2.2 and above expect tmpfs to be mounted at /dev/shm for
>     POSIX shared memory (shm_open, shm_unlink). Adding the following
>     line to /etc/fstab should take care of this:
>  
> @@ -44,7 +44,7 @@ tmpfs has the following uses:
>     This mount is _not_ needed for SYSV shared memory. The internal
>     mount is used for that. (In the 2.3 kernel versions it was
>     necessary to mount the predecessor of tmpfs (shm fs) to use SYSV
> -   shared memory)
> +   shared memory.)
>  
>  3) Some people (including me) find it very convenient to mount it
>     e.g. on /tmp and /var/tmp and have a big swap partition. And now
> @@ -69,18 +69,18 @@ nr_inodes: The maximum number of inodes 
>  These parameters accept a suffix k, m or g for kilo, mega and giga and
>  can be changed on remount.  The size parameter also accepts a suffix %
>  to limit this tmpfs instance to that percentage of your physical RAM:
> -the default, when neither size nor nr_blocks is specified, is size=50%
> +the default, when neither size nor nr_blocks is specified, is size=50%.

Although your change is correct there, I'd nonetheless prefer you to omit
that fullstop, since the "size=50%" is doubling as an example of how the
option looks.  (Which you've respected in the mpol=bind case lower down.)

>  
>  If nr_blocks=0 (or size=0), blocks will not be limited in that instance;
>  if nr_inodes=0, inodes will not be limited.  It is generally unwise to
>  mount with such options, since it allows any user with write access to
>  use up all the memory on the machine; but enhances the scalability of
> -that instance in a system with many cpus making intensive use of it.
> +that instance in a system with many CPUs making intensive use of it.
>  
>  
>  tmpfs has a mount option to set the NUMA memory allocation policy for
> -all files in that instance (if CONFIG_NUMA is enabled) - which can be
> -adjusted on the fly via 'mount -o remount ...'
> +all files in that instance (if CONFIG_NUMA is enabled).  This can be
> +adjusted on the fly via 'mount -o remount ...'.  The mpol options are:
>  
>  mpol=default             prefers to allocate memory from the local node
>  mpol=prefer:Node         prefers to allocate memory from the given Node
> @@ -89,8 +89,9 @@ mpol=interleave          prefers to allo
>  mpol=interleave:NodeList allocates from each node of NodeList in turn
>  
>  NodeList format is a comma-separated list of decimal numbers and ranges,
> -a range being two hyphen-separated decimal numbers, the smallest and
> -largest node numbers in the range.  For example, mpol=bind:0-3,5,7,9-15
> +a range being two hyphen-separated decimal numbers, representing the
> +smallest and largest node numbers in the range.  For example:
> +mpol=bind:0-3,5,7,9-15
>  
>  Note that trying to mount a tmpfs with an mpol option will fail if the
>  running kernel does not support NUMA; and will fail if its nodelist
> @@ -114,11 +115,11 @@ parameters with chmod(1), chown(1) and c
>  
>  
>  So 'mount -t tmpfs -o size=10G,nr_inodes=10k,mode=700 tmpfs /mytmpfs'
> -will give you tmpfs instance on /mytmpfs which can allocate 10GB
> +will give you a tmpfs instance on /mytmpfs which can allocate 10GB
>  RAM/SWAP in 10240 inodes and it is only accessible by root.
>  
>  
>  Author:
> -   Christoph Rohland <cr@sap.com>, 1.12.01
> +   Christoph Rohland <cr@sap.com>, 01.DEC.2001

Maybe I'm being fussy, but that seems like interfering with Christoph's
signature; and I don't think anyone's going to be seriously put out now
by whether that was 1st December or 12th January; plus what you've
substituted isn't even any standard form of date AFAIK.

>  Updated:
>     Hugh Dickins <hugh@veritas.com>, 19 February 2006

Do feel free to add your own name and email and date in whichever
form _you_ prefer there - but perhaps you don't want tmpfs enquiries
coming your way ever after: feel free to leave it out if you prefer!

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
