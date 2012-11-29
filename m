Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C290C6B0071
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 14:52:12 -0500 (EST)
Date: Fri, 30 Nov 2012 06:52:07 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] tmpfs: support SEEK_DATA and SEEK_HOLE (reprise)
Message-ID: <20121129195206.GB6434@dastard>
References: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils>
 <20121129012933.GA9112@kernel>
 <alpine.LNX.2.00.1211281745200.1641@eggly.anvils>
 <87lidlxcw9.fsf@rho.meyering.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lidlxcw9.fsf@rho.meyering.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Meyering <jim@meyering.net>
Cc: Hugh Dickins <hughd@google.com>, Jaegeuk Hanse <jaegeuk.hanse@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Zheng Liu <wenqing.lz@taobao.com>, Jeff liu <jeff.liu@oracle.com>, Paul Eggert <eggert@cs.ucla.edu>, Christoph Hellwig <hch@infradead.org>, Josef Bacik <josef@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andreas Dilger <adilger@dilger.ca>, Marco Stornelli <marco.stornelli@gmail.com>, Chris Mason <chris.mason@fusionio.com>, Sunil Mushran <sunil.mushran@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 29, 2012 at 05:15:50AM +0100, Jim Meyering wrote:
> Hugh Dickins wrote:
> > On Thu, 29 Nov 2012, Jaegeuk Hanse wrote:
> ...
> >> But this time in which scenario will use it?
> >
> > I was not very convinced by the grep argument from Jim and Paul:
> > that seemed to be grep holding on to a no-arbitrary-limits dogma,
> > at the expense of its users, causing an absurd line-length issue,
> > which use of SEEK_DATA happens to avoid in some cases.
> >
> > The cp of sparse files from Jeff and Dave was more convincing;
> > but I still didn't see why little old tmpfs needed to be ahead
> > of the pack.
> >
> > But at LinuxCon/Plumbers in San Diego in August, a more convincing
> > case was made: I was hoping you would not ask, because I did not take
> > notes, and cannot pass on the details - was it rpm building on tmpfs?
> > I was convinced enough to promise support on tmpfs when support on
> > ext4 goes in.
> 
> Re the cp-vs-sparse-file case, the current FIEMAP-based code in GNU
> cp is ugly and complicated enough that until recently it harbored a
> hard-to-reproduce data-corrupting bug[*].  Now that SEEK_DATA/SEEK_HOLE
> support work will work also for tmpfs and ext4, we can plan to remove
> the FIEMAP-based code in favor of a simpler SEEK_DATA/SEEK_HOLE-based
> implementation.
> 
> With the rise of virtualization, copying sparse images efficiently
> (probably searching, too) is becoming more and more important.
> 
> So, yes, GNU cp will soon use this feature.

It would be nice if utilities like grep used it, too, because having
grep burn gigabytes of memory scanning holes in large files and
then going OOM is, well, kind of nasty:

$ xfs_io -f -c "truncate 1t" blah
$ ls -l
total 0
-rw-r--r-- 1 dave dave 1.0T Nov 30 06:42 blah
$ grep foo blah
grep: memory exhausted
$ $ grep -V
grep (GNU grep) 2.12
....

It looks like it's doing something silly when holes are found - the
buffer size just keeps getting doubled until it's larger than
physical memory (4GB in this case).

openat(AT_FDCWD, "blah", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0600, st_size=1099511627776, ...}) = 0
ioctl(3, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7ffff31d4c80) = -1 ENOTTY (Inappropriate ioctl for device)
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 32768) = 32768
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 32768) = 32768
mmap(NULL, 139264, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62b0291000
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 65536) = 65536
mmap(NULL, 270336, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62b024f000
munmap(0x7f62b0291000, 139264)          = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 131072) = 131072
mmap(NULL, 532480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62afc0d000
munmap(0x7f62b024f000, 270336)          = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 262144) = 262144
mmap(NULL, 1056768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62afb0b000
munmap(0x7f62afc0d000, 532480)          = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 524288) = 524288
mmap(NULL, 2105344, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62af909000
munmap(0x7f62afb0b000, 1056768)         = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1048576
mmap(NULL, 4202496, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62af507000
munmap(0x7f62af909000, 2105344)         = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 2097152) = 2097152
mmap(NULL, 8396800, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62aed05000
munmap(0x7f62af507000, 4202496)         = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 4194304) = 4194304
mmap(NULL, 16785408, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62add03000
munmap(0x7f62aed05000, 8396800)         = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 8388608) = 8388608
mmap(NULL, 33562624, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62abd01000
munmap(0x7f62add03000, 16785408)        = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 16777216) = 16777216
mmap(NULL, 67117056, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f62a7cff000
munmap(0x7f62abd01000, 33562624)        = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 33554432) = 33554432
mmap(NULL, 134225920, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f629fcfd000
munmap(0x7f62a7cff000, 67117056)        = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 67108864) = 67108864
mmap(NULL, 268443648, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f628fcfb000
munmap(0x7f629fcfd000, 134225920)       = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 134217728) = 134217728
mmap(NULL, 536879104, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f626fcf9000
munmap(0x7f628fcfb000, 268443648)       = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 268435456) = 268435456
mmap(NULL, 1073750016, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f622fcf7000
munmap(0x7f626fcf9000, 536879104)       = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 536870912) = 536870912
mmap(NULL, 2147491840, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f61afcf5000
munmap(0x7f622fcf7000, 1073750016)      = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1073741824) = 1073741824
mmap(NULL, 4294975488, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f60afcf3000
munmap(0x7f61afcf5000, 2147491840)      = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 2147483648) = 2147479552
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 4096) = 4096
mmap(NULL, 8589942784, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = -1 ENOMEM (Cannot allocate memory)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
