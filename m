Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F19DC6B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 04:23:54 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id u188so92920838qkc.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 01:23:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 129si6529173qkh.179.2017.03.02.01.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 01:23:54 -0800 (PST)
Date: Thu, 2 Mar 2017 17:23:52 +0800
From: Xiong Zhou <xzhou@redhat.com>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302092352.r7dcykmddwue6san@XZHOUW.usersys.redhat.com>
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
 <20170302003731.GB24593@infradead.org>
 <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
 <d4c2cf89-8d82-ea78-b742-5bf6923a69c1@linux.vnet.ibm.com>
 <20170302084222.GA1404@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302084222.GA1404@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Xiong Zhou <xzhou@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, Mar 02, 2017 at 09:42:23AM +0100, Michal Hocko wrote:
> On Thu 02-03-17 12:17:47, Anshuman Khandual wrote:
> > On 03/02/2017 10:49 AM, Xiong Zhou wrote:
> > > On Wed, Mar 01, 2017 at 04:37:31PM -0800, Christoph Hellwig wrote:
> > >> On Wed, Mar 01, 2017 at 12:46:34PM +0800, Xiong Zhou wrote:
> > >>> Hi,
> > >>>
> > >>> It's reproduciable, not everytime though. Ext4 works fine.
> > >> On ext4 fsstress won't run bulkstat because it doesn't exist.  Either
> > >> way this smells like a MM issue to me as there were not XFS changes
> > >> in that area recently.
> > > Yap.
> > > 
> > > First bad commit:
> > > 
> > > commit 5d17a73a2ebeb8d1c6924b91e53ab2650fe86ffb
> > > Author: Michal Hocko <mhocko@suse.com>
> > > Date:   Fri Feb 24 14:58:53 2017 -0800
> > > 
> > >     vmalloc: back off when the current task is killed
> > > 
> > > Reverting this commit on top of
> > >   e5d56ef Merge tag 'watchdog-for-linus-v4.11'
> > > survives the tests.
> > 
> > Does fsstress test or the system hang ? I am not familiar with this
> > code but If it's the test which is getting hung and its hitting this
> > new check introduced by the above commit that means the requester is
> > currently being killed by OOM killer for some other memory allocation
> > request.
> 
> Well, not exactly. It is sufficient for it to be _killed_ by SIGKILL.
> And for that it just needs to do a group_exit when one thread was still
> in the kernel (see zap_process). While I can change this check to
> actually do the oom specific check I believe a more generic
> fatal_signal_pending is the right thing to do here. I am still not sure
> what is the actual problem here, though. Could you be more specific
> please?

It's blocking the test and system-shutdown. fsstress wont exit.

For anyone interested, a simple ugly reproducer:

cat > fst.sh <<EOFF
#! /bin/bash -x

[ \$# -ne 3 ] && { echo "./single FSTYP TEST XFSTESTS_DIR"; exit 1; }

FST=\$1
BLKSZ=4096

fallocate -l 10G /home/test.img
fallocate -l 15G /home/scratch.img

MNT1=/loopmnt
MNT2=/loopsch

mkdir -p \$MNT1
mkdir -p \$MNT2

DEV1=\$(losetup --find --show /home/test.img)
DEV2=\$(losetup --find --show /home/scratch.img)

cleanup()
{
	umount -d \$MNT1
	umount -d \$MNT2
	umount \$DEV1 \$DEV2
	losetup -D || losetup -a | awk -F: '{print \$1}' | xargs losetup -d
	rm -f /home/{test,scratch}.img
}

trap cleanup 0 1 2

if [[ \$FST =~ ext ]] ; then
	mkfs.\${FST} -Fq -b \${BLKSZ} \$DEV1
elif [[ \$FST =~ xfs ]] ; then
	mkfs.\${FST} -fq -b size=\${BLKSZ} \$DEV1
fi
if test \$? -ne 0 ; then
	echo "mkfs \$DEV1 failed" 
	exit 1
fi

if [[ \$FST =~ ext ]] ; then
	mkfs.\${FST} -Fq -b \${BLKSZ} \$DEV2
elif [[ \$FST =~ xfs ]] ; then
	mkfs.\${FST} -fq -b size=\${BLKSZ} \$DEV2
fi
if test \$? -ne 0 ; then
	echo "mkfs \$DEV2 failed"
	exit 1
fi

mount \$DEV1 \$MNT1
if test \$? -ne 0 ; then
	echo "mount \$DEV1 failed" 
	exit 1
fi
mount \$DEV2 \$MNT2
if test \$? -ne 0 ; then
	echo "mount \$DEV2 failed" 
	exit 1
fi

pushd \$3 || exit 1

cat > local.config <<EOF
TEST_DEV=\$DEV1
TEST_DIR=\$MNT1
SCRATCH_MNT=\$MNT2
SCRATCH_DEV=\$DEV2
EOF

i=0
while [ \$i -lt 50 ] ; do
	./check \$2
	echo \$i
	((i=\$i+1))
done

popd
EOFF

git clone git://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git
cd xfstests-dev
make -j2 && make install || exit 1
cd -
sh -x ./fst.sh xfs generic/269 xfstests-dev


> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
