Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FDDF6B02FA
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 04:40:38 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t10so24497470qte.14
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 01:40:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u74si7080467qki.35.2017.06.13.01.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 01:40:37 -0700 (PDT)
Date: Tue, 13 Jun 2017 16:40:34 +0800
From: Eryu Guan <eguan@redhat.com>
Subject: Re: [xfstests PATCH v4 5/5] btrfs: make a btrfs version of writeback
 error reporting test
Message-ID: <20170613084034.GE4788@eguan.usersys.redhat.com>
References: <20170612124213.14855-1-jlayton@redhat.com>
 <20170612124213.14855-6-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170612124213.14855-6-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Mon, Jun 12, 2017 at 08:42:13AM -0400, Jeff Layton wrote:
> Make a new btrfs/999 test that works the way Chris Mason suggested:
> 
> Build a filesystem with 2 devices that stripes the data across
> both devices, but mirrors metadata across both. Then, make one
> of the devices fail and see how fsync is handled.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  tests/btrfs/999   | 93 +++++++++++++++++++++++++++++++++++++++++++++++++++++++

Missing btrfs/999.out file

>  tests/btrfs/group |  1 +
>  2 files changed, 94 insertions(+)
>  create mode 100755 tests/btrfs/999
> 
> diff --git a/tests/btrfs/999 b/tests/btrfs/999
> new file mode 100755
> index 000000000000..84031cc0d913
> --- /dev/null
> +++ b/tests/btrfs/999
> @@ -0,0 +1,93 @@
> +#! /bin/bash
> +# FS QA Test No. 999
> +#
> +# Open a file several times, write to it, fsync on all fds and make sure that
> +# they all return 0. Change the device to start throwing errors. Write again
> +# on all fds and fsync on all fds. Ensure that we get errors on all of them.
> +# Then fsync on all one last time and verify that all return 0.
> +#
> +#-----------------------------------------------------------------------
> +# Copyright (c) 2017, Jeff Layton <jlayton@redhat.com>
> +#
> +# This program is free software; you can redistribute it and/or
> +# modify it under the terms of the GNU General Public License as
> +# published by the Free Software Foundation.
> +#
> +# This program is distributed in the hope that it would be useful,
> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> +# GNU General Public License for more details.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write the Free Software Foundation,
> +# Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
> +#-----------------------------------------------------------------------
> +
> +seq=`basename $0`
> +seqres=$RESULT_DIR/$seq
> +echo "QA output created by $seq"
> +
> +here=`pwd`
> +tmp=/tmp/$$
> +status=1    # failure is the default!
> +trap "_cleanup; exit \$status" 0 1 2 3 15
> +
> +_cleanup()
> +{
> +    cd /
> +    rm -rf $tmp.* $testdir
> +    _dmerror_cleanup
> +}
> +
> +# get standard environment, filters and checks
> +. ./common/rc
> +. ./common/filter
> +. ./common/dmerror
> +
> +# real QA test starts here
> +_supported_os Linux
> +_require_dm_target error
> +_require_test_program fsync-err
> +_require_test_program dmerror
> +
> +# bring up dmerror device
> +_scratch_unmount
> +_dmerror_init
> +
> +# Replace first device with error-test device
> +old_SCRATCH_DEV=$SCRATCH_DEV
> +SCRATCH_DEV_POOL=`echo $SCRATCH_DEV_POOL | perl -pe "s#$SCRATCH_DEV#$DMERROR_DEV#"`
> +SCRATCH_DEV=$DMERROR_DEV
> +
> +_require_scratch
> +_require_scratch_dev_pool

Need "_require_scratch_dev_pool_equal_size" too, since test creates
raid1 profile for metadata.

Thanks,
Eryu

> +
> +rm -f $seqres.full
> +
> +echo "Format and mount"
> +
> +_scratch_pool_mkfs "-d raid0 -m raid1" > $seqres.full 2>&1
> +_scratch_mount
> +
> +# How much do we need to write? We need to hit all of the stripes. btrfs uses
> +# a fixed 64k stripesize, so write enough to hit each one
> +number_of_devices=`echo $SCRATCH_DEV_POOL | wc -w`
> +write_kb=$(($number_of_devices * 64))
> +_require_fs_space $SCRATCH_MNT $write_kb
> +
> +testfile=$SCRATCH_MNT/fsync-err-test
> +
> +SCRATCH_DEV=$old_SCRATCH_DEV
> +$here/src/fsync-err -b $(($write_kb * 1024)) -d $here/src/dmerror $testfile
> +
> +# success, all done
> +_dmerror_load_working_table
> +
> +# fs may be corrupt after this -- attempt to repair it
> +_repair_scratch_fs >> $seqres.full
> +
> +# remove dmerror device
> +_dmerror_cleanup
> +
> +status=0
> +exit
> diff --git a/tests/btrfs/group b/tests/btrfs/group
> index 6f19619e877c..8dbdfbfe29fd 100644
> --- a/tests/btrfs/group
> +++ b/tests/btrfs/group
> @@ -145,3 +145,4 @@
>  141 auto quick
>  142 auto quick
>  143 auto quick
> +999 auto quick
> -- 
> 2.13.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
