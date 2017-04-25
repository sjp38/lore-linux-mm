Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A96C06B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 16:39:14 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c26so89503640itd.16
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 13:39:14 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id o80si5025122ito.126.2017.04.25.13.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 13:39:13 -0700 (PDT)
Date: Tue, 25 Apr 2017 14:39:11 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/2] dax: add regression test for stale mmap reads
Message-ID: <20170425203911.GC11773@linux.intel.com>
References: <20170421034437.4359-1-ross.zwisler@linux.intel.com>
 <20170424174932.15613-1-ross.zwisler@linux.intel.com>
 <20170424174932.15613-2-ross.zwisler@linux.intel.com>
 <20170425112738.GV26397@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425112738.GV26397@eguan.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eryu Guan <eguan@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, fstests@vger.kernel.org, Xiong Zhou <xzhou@redhat.com>, jmoyer@redhat.com, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Apr 25, 2017 at 07:27:39PM +0800, Eryu Guan wrote:
> On Mon, Apr 24, 2017 at 11:49:32AM -0600, Ross Zwisler wrote:
> > This adds a regression test for the following kernel patch:
> > 
> >   dax: fix data corruption due to stale mmap reads
> > 
> 
> Seems that this patch hasn't been merged into linus tree, thus 4.11-rc8
> kernel should fail this test, but it passed for me, tested with 4.11-rc8
> kernel on both ext4 and xfs, with both brd devices and pmem devices
> created from "memmap=10G!5G memmap=15G!15G" kernel boot command line.
> Did I miss anything?
> 
> # ./check -s ext4_pmem_4k generic/427
> SECTION       -- ext4_pmem_4k

Ooh, I didn't add this 'ext4_pmem_4k' section goodness, and it's not present
in the xfstests/master that I was using.  Do you have patches to add that?

> RECREATING    -- ext4 on /dev/pmem0
> FSTYP         -- ext4
> PLATFORM      -- Linux/x86_64 hp-dl360g9-15 4.11.0-rc8.kasan
> MKFS_OPTIONS  -- -b 4096 /dev/pmem1
> MOUNT_OPTIONS -- -o acl,user_xattr -o context=system_u:object_r:root_t:s0 /dev/pmem1 /scratch
> 
> generic/427 1s ... 1s
> Ran: generic/427
> Passed all 1 tests

Your memmap params look fine.  I tested with BRD and PMEM, and with EXT4 and
XFS, and all combinations failed for me as expected with v4.11-rc8.

One issue could have been that the test file already existed when the test was
run.  I wasn't removing it between runs earlier, but I've fixed that for v2.

Another issue I guess could have been that the hole that we got back from the
filesystem was smaller than 2MiB?  Can you try running v2 (which I'll post in
a second) against a TEST_DEV made with one of the following:

ext4: mkfs.ext4 -b 4096 -E stride=512 -F $TEST_DEV
xfs:  mkfs.xfs -f -d su=2m,sw=1 $TEST_DEV

This helps us get 2MiB sized and aligned allocations so we can fault in PMDs,
but I'm not sure whether or not it would matter for holes.

> Some comments inline.
> 
> > The above patch fixes an issue where users of DAX can suffer data
> > corruption from stale mmap reads via the following sequence:
> > 
> > - open an mmap over a 2MiB hole
> > 
> > - read from a 2MiB hole, faulting in a 2MiB zero page
> > 
> > - write to the hole with write(3p).  The write succeeds but we incorrectly
> >   leave the 2MiB zero page mapping intact.
> > 
> > - via the mmap, read the data that was just written.  Since the zero page
> >   mapping is still intact we read back zeroes instead of the new data.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  .gitignore            |  1 +
> >  src/Makefile          |  2 +-
> >  src/t_dax_stale_pmd.c | 56 ++++++++++++++++++++++++++++++++++++++++++
> >  tests/generic/427     | 68 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  tests/generic/427.out |  2 ++
> >  tests/generic/group   |  1 +
> >  6 files changed, 129 insertions(+), 1 deletion(-)
> >  create mode 100644 src/t_dax_stale_pmd.c
> >  create mode 100755 tests/generic/427
> >  create mode 100644 tests/generic/427.out
> > 
> > diff --git a/.gitignore b/.gitignore
> > index ded4a61..9664dc9 100644
> > --- a/.gitignore
> > +++ b/.gitignore
> > @@ -134,6 +134,7 @@
> >  /src/renameat2
> >  /src/t_rename_overwrite
> >  /src/t_mmap_dio
> > +/src/t_dax_stale_pmd
> >  
> >  # dmapi/ binaries
> >  /dmapi/src/common/cmd/read_invis
> > diff --git a/src/Makefile b/src/Makefile
> > index abfd873..7e22b50 100644
> > --- a/src/Makefile
> > +++ b/src/Makefile
> > @@ -12,7 +12,7 @@ TARGETS = dirstress fill fill2 getpagesize holes lstat64 \
> >  	godown resvtest writemod makeextents itrash rename \
> >  	multi_open_unlink dmiperf unwritten_sync genhashnames t_holes \
> >  	t_mmap_writev t_truncate_cmtime dirhash_collide t_rename_overwrite \
> > -	holetest t_truncate_self t_mmap_dio af_unix
> > +	holetest t_truncate_self t_mmap_dio af_unix t_dax_stale_pmd
> >  
> >  LINUX_TARGETS = xfsctl bstat t_mtab getdevicesize preallo_rw_pattern_reader \
> >  	preallo_rw_pattern_writer ftrunc trunc fs_perms testx looptest \
> > diff --git a/src/t_dax_stale_pmd.c b/src/t_dax_stale_pmd.c
> > new file mode 100644
> > index 0000000..d0016eb
> > --- /dev/null
> > +++ b/src/t_dax_stale_pmd.c
> > @@ -0,0 +1,56 @@
> > +#include <errno.h>
> > +#include <fcntl.h>
> > +#include <libgen.h>
> > +#include <stdio.h>
> > +#include <stdlib.h>
> > +#include <string.h>
> > +#include <sys/mman.h>
> > +#include <sys/stat.h>
> > +#include <sys/types.h>
> > +#include <unistd.h>
> > +
> > +#define MiB(a) ((a)*1024*1024)
> > +
> > +void err_exit(char *op)
> > +{
> > +	fprintf(stderr, "%s: %s\n", op, strerror(errno));
> > +	exit(1);
> > +}
> > +
> > +int main(int argc, char *argv[])
> > +{
> > +	volatile int a __attribute__((__unused__));
> > +	char *buffer = "HELLO WORLD!";
> > +	char *data;
> > +	int fd;
> > +
> > +	if (argc < 2) {
> > +		printf("Usage: %s <pmem file>\n", basename(argv[0]));
> > +		exit(0);
> > +	}
> > +
> > +	fd = open(argv[1], O_RDWR);
> > +	if (fd < 0)
> > +		err_exit("fd");
>                          ^^^^ Nitpick, the "op" should be "open"?
> > +
> > +	data = mmap(NULL, MiB(2), PROT_READ, MAP_SHARED, fd, MiB(2));
> > +
> > +	/*
> > +	 * This faults in a 2MiB zero page to satisfy the read.
> > +	 * 'a' is volatile so this read doesn't get optimized out.
> > +	 */
> > +	a = data[0];
> > +
> > +	pwrite(fd, buffer, strlen(buffer), MiB(2));
> > +
> > +	/*
> > +	 * Try and use the mmap to read back the data we just wrote with
> > +	 * pwrite().  If the kernel bug is present the mapping from the 2MiB
> > +	 * zero page will still be intact, and we'll read back zeros instead.
> > +	 */
> > +	if (strncmp(buffer, data, strlen(buffer)))
> > +		err_exit("strncmp mismatch!");
> 
> strncmp doesn't set errno, this err_exit message might be confusing:
> "strncmp mismatch!: Success"

Ah, thanks, fixed in v2.

> > +
> > +	close(fd);
> > +	return 0;
> > +}
> > diff --git a/tests/generic/427 b/tests/generic/427
> > new file mode 100755
> > index 0000000..baf1099
> > --- /dev/null
> > +++ b/tests/generic/427
> > @@ -0,0 +1,68 @@
> > +#! /bin/bash
> > +# FS QA Test 427
> > +#
> > +# This is a regression test for kernel patch:
> > +#  dax: fix data corruption due to stale mmap reads
> > +# created by Ross Zwisler <ross.zwisler@linux.intel.com>
> > +#
> > +#-----------------------------------------------------------------------
> > +# Copyright (c) 2017 Intel Corporation.  All Rights Reserved.
> > +#
> > +# This program is free software; you can redistribute it and/or
> > +# modify it under the terms of the GNU General Public License as
> > +# published by the Free Software Foundation.
> > +#
> > +# This program is distributed in the hope that it would be useful,
> > +# but WITHOUT ANY WARRANTY; without even the implied warranty of
> > +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > +# GNU General Public License for more details.
> > +#
> > +# You should have received a copy of the GNU General Public License
> > +# along with this program; if not, write the Free Software Foundation,
> > +# Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
> > +#-----------------------------------------------------------------------
> > +#
> > +
> > +seq=`basename $0`
> > +seqres=$RESULT_DIR/$seq
> > +echo "QA output created by $seq"
> > +
> > +here=`pwd`
> > +tmp=/tmp/$$
> > +status=1	# failure is the default!
> > +trap "_cleanup; exit \$status" 0 1 2 3 15
> > +
> > +_cleanup()
> > +{
> > +	cd /
> > +	rm -f $tmp.*
> > +}
> > +
> > +# get standard environment, filters and checks
> > +. ./common/rc
> > +. ./common/filter
> > +
> > +# remove previous $seqres.full before test
> > +rm -f $seqres.full
> > +
> > +# Modify as appropriate.
> > +_supported_fs generic
> > +_supported_os Linux
> > +_require_scratch_dax
> 
> I don't think dax is a requirement here, this test could run on normal
> block device without "-o dax" option too. It won't hurt to run with more
> test configurations. And test on nvdimm device with dax mount option
> could be one of the test configs, e.g.
> 
> TEST_DEV=/dev/pmem0
> SCRATCH_DEV=/dev/pmem1
> MOUNT_OPTIONS="-o dax"
> ...

Yep, agreed, fixed in v2.

> > +_require_test_program "t_dax_stale_pmd"
> > +_require_user
> 
> _require_xfs_io_command "falloc"
> 
> So test _notrun on ext2/3.

Fixed in v2.

> > +
> > +# real QA test starts here
> > +_scratch_mkfs >>$seqres.full 2>&1
> > +_scratch_mount "-o dax"
> 
> Same here, dax is not required.

Fixed in v2.

> 
> > +
> > +$XFS_IO_PROG -f -c "falloc 0 4M" $SCRATCH_MNT/testfile >> $seqres.full 2>&1
> > +chmod 0644 $SCRATCH_MNT/testfile
> > +chown $qa_user $SCRATCH_MNT/testfile
> 
> Any specific reason to use $qa_user to run this test? Comments would be
> great.

Nope, just cargo-culting my way through my first xfstest. :)  I've removed
this for v2.

> Thanks,
> Eryu

Thanks for the review!

> > +
> > +_user_do "src/t_dax_stale_pmd $SCRATCH_MNT/testfile"
> > +
> > +# success, all done
> > +echo "Silence is golden"
> > +status=0
> > +exit
> > diff --git a/tests/generic/427.out b/tests/generic/427.out

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
