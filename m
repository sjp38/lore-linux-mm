Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3BEE26B025D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 05:57:43 -0400 (EDT)
Received: by obqa2 with SMTP id a2so130647135obq.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:57:43 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id d197si8992089oig.18.2015.09.15.02.57.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 02:57:42 -0700 (PDT)
From: Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: Test program: check if fsync() can detect I/O error (2/2)
Date: Tue, 15 Sep 2015 09:52:18 +0000
Message-ID: <20150915095217.GC13399@xzibit.linux.bs1.fc.nec.co.jp>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915094946.GB13399@xzibit.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150915094946.GB13399@xzibit.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FB247A58DDDC6748B67DC3AE323BCFA5@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "david@fromorbit.com" <david@fromorbit.com>, Tejun Heo <tj@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 09/15/15 17:39, Jun'ichi Nomura wrote:
>> However if admins run a command such as sync or fsfreeze along side,
>> fsync/fdatasync may return success even if writeback has failed.
>> That could lead to data corruption.
>
> For reproducing the problem, compile the attached C program (iogen.c)
> and run with 'runtest.sh' script in the next mail:
>   # gcc -o iogen iogen.c
>   # bash ./runtest.sh

-- cut here --
#!/bin/bash

# preparation for hwpoison injection
export KERNEL_SRC=3D/lib/modules/$(uname -r)/build
[ -d "$KERNEL_SRC" ] || exit 1 # no kernel source given
make vm -C $KERNEL_SRC/tools || exit 1 # tools/vm failed to build
pagetypes=3D$KERNEL_SRC/tools/vm/page-types
[ -x $pagetypes ] || exit 1
modprobe hwpoison-inject

# -------------------------------------------------------------------
fstype=3Dext4

# file name of loopback image
loopfile=3Dtest.img
imgsize=3D16M
lodev=3D/dev/loop0

# filesystem to use
mkfs=3Dmkfs.$fstype

# device-mapper map name
testmap=3Dtestmap

# file name to store device-mapper table data
mapok=3Dtestmap.ok
maperr=3Dtestmap.err

# mount point and file name used for testing
testdir=3D/mnt/test
testfile=3D$testdir/x

# test file size
filesize=3D16384

# -------------------------------------------------------------------
# Set up
#

endtest() {
	sleep 3
	umount $testdir
	dmsetup remove $testmap
	losetup -d $lodev
	exit
}

# Create loopback device for testing
dd if=3D/dev/zero of=3D$loopfile bs=3D$imgsize count=3D1
losetup $lodev $loopfile || endtest
if [ ! -b $lodev ]; then
	endtest
fi


# Layer DM device for error injection
echo "0 $(blockdev --getsz $lodev) linear $lodev 0" | dmsetup create $testm=
ap
dmsetup table $testmap > $mapok || endtest
if [ ! -b /dev/mapper/$testmap ]; then
	endtest
fi

# Mount and create target file
mkdir -p $testdir
$mkfs /dev/mapper/$testmap
mount /dev/mapper/$testmap $testdir || endtest
dd if=3D/dev/zero of=3D$testfile bs=3D$filesize count=3D1 oflag=3Ddirect ||=
 endtest

# Find physical location of the target file
find_location() {
	# pick up physical block number of file offset 0
	filefrag -v $1 | \
		awk '$1 =3D=3D "0" {print $3} $1 =3D=3D "0:" {print $4}' | \
		sed 's/\.//g'
}
filefrag -v $testfile
block=3D$(find_location $testfile)
if [ -z "$block" ]; then
	endtest
fi
blocksize=3D$(stat -c %s -f $testfile)
secsize=3D512
sector=3D$((block * blocksize / secsize + 1))

# Create error mapping: inject error at $sector
next=3D$((sector + 1))
total=3D$(blockdev --getsz $lodev)
remainder=3D$((total - next))
cat <<EOF > $maperr
0 $sector linear $lodev 0
$sector 1 error
$next $remainder linear $lodev $next
EOF

map_replace() {
	cat $1 | dmsetup load $testmap
	dmsetup suspend --nolockfs $testmap
	dmsetup resume $testmap
}

inject_memory_error() {
	local pfn=3D0x$($pagetypes -f $testfile -Nl | grep ^1$'\t' | cut -f2)
	[ "$pfn" =3D 0x ] && return 1 # target pfn not found
	$pagetypes -a $pfn -X -N
}

# -------------------------------------------------------------------
# Test
#

msg() {
	echo $* > /dev/kmsg
	echo $*
}

injector_ioerr_nop() {
	# start
	read x
	msg "TEST: $fstype / ioerr / (no admin action)"

	# inject
	read x
	msg "(admin): Injecting I/O error"
	map_replace $maperr
	msg "(admin): Do nothing"

	# remove
	read x
	map_replace $mapok

	# end
	read x
	umount /dev/mapper/$testmap || endtest
	mount /dev/mapper/$testmap $testdir || endtest
}

injector_ioerr_synccmd() {
	# start
	read x
	msg "TEST: $fstype / ioerr / sync-command"

	# inject
	read x
	msg "(admin): Injecting I/O error"
	map_replace $maperr
	msg "(admin): Calling sync(2)"
	sync

	# remove
	read x
	map_replace $mapok

	# end
	read x
	umount /dev/mapper/$testmap || endtest
	mount /dev/mapper/$testmap $testdir || endtest
}

injector_hwpoison_synccmd() {
	# start
	read x
	msg "TEST: $fstype / memory-error / sync-command"

	# inject
	read x
	msg "(admin): Injecting memory error"
	inject_memory_error
	msg "(admin): Calling sync(2)"
	sync

	# remove
	read x

	# end
	read x
	umount /dev/mapper/$testmap || endtest
	mount /dev/mapper/$testmap $testdir || endtest
}

msg '=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D'
./iogen $testfile $filesize | injector_ioerr_nop
msg '=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D'
./iogen $testfile $filesize | injector_ioerr_synccmd
msg '=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D'
./iogen $testfile $filesize | injector_hwpoison_synccmd

# -------------------------------------------------------------------
# Clean up
#
endtest

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
