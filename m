Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1511B6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 09:12:13 -0500 (EST)
Received: by wiwl15 with SMTP id l15so3170972wiw.1
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 06:12:12 -0800 (PST)
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com. [74.125.82.170])
        by mx.google.com with ESMTPS id n15si14201448wiw.71.2015.03.05.06.12.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 06:12:11 -0800 (PST)
Received: by wevm14 with SMTP id m14so53176586wev.8
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 06:12:10 -0800 (PST)
From: Boaz Harrosh <boaz@plexistor.com>
Message-ID: <54F86437.9090609@panasas.com>
Date: Thu, 05 Mar 2015 16:12:07 +0200
MIME-Version: 1.0
Subject: Re: [PATCH 1/3 v2] xfstest: generic/080 test that mmap-write updates
 c/mtime
References: <54F733BD.7060807@plexistor.com> <54F734C4.7080409@plexistor.com> <20150305001312.GA4251@dastard> <54F861F3.9000805@plexistor.com>
In-Reply-To: <54F861F3.9000805@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Omer Zilberberg <omzg@plexistor.com>, fstests@vger.kernel.org

I again forgot to CC: fstests@vger.kernel.org

Thanks
Boaz

On 03/05/2015 04:02 PM, Boaz Harrosh wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> when using mmap() for file i/o, writing to the file should update
> it's c/mtime. Specifically if we first mmap-read from a page, then
> memap-write to the same page.
> 
> This test was failing for the initial submission of DAX because
> pfn based mapping do not have an page_mkwrite called for them.
> The new Kernel patches that introduce pfn_mkwrite fixes this test.
> 
> Written by Dave Chinner but edited and tested by:
> 	Omer Zilberberg
> 
> Tested-by: Omer Zilberberg <omzg@plexistor.com>
> Signed-off-by: Omer Zilberberg <omzg@plexistor.com>
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
> Dave hands-up man, it looks like you edited this directly
> in the email, but there was not even a single typo.
> 
> We have tested this both with and without the pfn_mkwrite patch.
> And it works as expected fails without and success with.
> 
> Thanks
> 
>  tests/generic/080     | 79 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/080.out |  2 ++
>  tests/generic/group   |  1 +
>  3 files changed, 82 insertions(+)
>  create mode 100755 tests/generic/080
>  create mode 100644 tests/generic/080.out
> 
> diff --git a/tests/generic/080 b/tests/generic/080
> new file mode 100755
> index 0000000..2bc580d
> --- /dev/null
> +++ b/tests/generic/080
> @@ -0,0 +1,79 @@
> +#! /bin/bash
> +# FS QA Test No. 080
> +#
> +# Verify that mtime is updated when writing to mmap-ed pages
> +#
> +#-----------------------------------------------------------------------
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
> +#
> +
> +seq=`basename $0`
> +seqres=$RESULT_DIR/$seq
> +echo "QA output created by $seq"
> +
> +here=`pwd`
> +tmp=/tmp/$$
> +status=0
> +trap "_cleanup; exit \$status" 0 1 2 3 15
> +
> +_cleanup()
> +{
> +    cd /
> +    rm -f $tmp.*
> +    rm -f $TEST_DIR/mmap_mtime_testfile
> +}
> +
> +# get standard environment, filters and checks
> +. ./common/rc
> +. ./common/filter
> +
> +# real QA test starts here
> +
> +# Modify as appropriate.
> +_supported_fs generic
> +_supported_os IRIX Linux
> +_require_test
> +
> +echo "Silence is golden."
> +rm -f $seqres.full
> +
> +# pattern the file.
> +testfile=$TEST_DIR/mmap_mtime_testfile
> +$XFS_IO_PROG -f -c "pwrite 0 4k" -c fsync $testfile >> $seqres.full
> +
> +# sample timestamps.
> +mtime1=`stat -c %Y $testfile`
> +ctime1=`stat -c %Z $testfile`
> +echo "before mwrite: $mtime1 $ctime1" >> $seqres.full
> +
> +# map read followed by map write to trigger timestamp change
> +sleep 2
> +$XFS_IO_PROG -c "mmap 0 4k" -c "mread 0 4k" -c "mwrite 0 4k" $testfile |_filter_xfs_io >> $seqres.full
> +
> +# sample and verify that timestamps have changed.
> +mtime2=`stat -c %Y $testfile`
> +ctime2=`stat -c %Z $testfile`
> +echo "after mwrite : $mtime2 $ctime2" >> $seqres.full
> +
> +if [ "$mtime1" == "$mtime2" ]; then
> +	echo "mtime not updated"
> +	let status=$status+1
> +fi
> +if [ "$ctime1" == "$ctime2" ]; then
> +	echo "ctime not updated"
> +	let status=$status+1
> +fi
> +
> +exit
> diff --git a/tests/generic/080.out b/tests/generic/080.out
> new file mode 100644
> index 0000000..cccac52
> --- /dev/null
> +++ b/tests/generic/080.out
> @@ -0,0 +1,2 @@
> +QA output created by 080
> +Silence is golden.
> diff --git a/tests/generic/group b/tests/generic/group
> index 11ce3e4..7ee5cdc 100644
> --- a/tests/generic/group
> +++ b/tests/generic/group
> @@ -77,6 +77,7 @@
>  076 metadata rw udf auto quick stress
>  077 acl attr auto enospc
>  079 acl attr ioctl metadata auto quick
> +080 auto quick
>  083 rw auto enospc stress
>  088 perms auto quick
>  089 metadata auto
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
