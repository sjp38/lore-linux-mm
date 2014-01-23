Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 724126B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 16:34:44 -0500 (EST)
Received: by mail-bk0-f50.google.com with SMTP id w16so681088bkz.37
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 13:34:43 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id tb1si338890bkb.197.2014.01.23.13.34.42
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 13:34:43 -0800 (PST)
From: Chris Mason <clm@fb.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Date: Thu, 23 Jan 2014 21:34:08 +0000
Message-ID: <1390512936.1198.76.camel@ret.masoncoding.com>
References: <52DFD168.8080001@redhat.com> <20140122143452.GW4963@suse.de>
	 <52DFDCA6.1050204@redhat.com> <20140122151913.GY4963@suse.de>
	 <1390410233.1198.7.camel@ret.masoncoding.com>
	 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
	 <1390413819.1198.20.camel@ret.masoncoding.com>
	 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
	 <1390415924.1198.36.camel@ret.masoncoding.com>
	 <1390416421.2372.68.camel@dabdike.int.hansenpartnership.com>
	 <20140123212714.GB25376@localhost>
In-Reply-To: <20140123212714.GB25376@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <6D6D2A0E58E35242BCD21F557B2D861D@fb.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jlbec@evilplan.org" <jlbec@evilplan.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

On Thu, 2014-01-23 at 13:27 -0800, Joel Becker wrote:
+AD4- On Wed, Jan 22, 2014 at 10:47:01AM -0800, James Bottomley wrote:
+AD4- +AD4- On Wed, 2014-01-22 at 18:37 +-0000, Chris Mason wrote:
+AD4- +AD4- +AD4- On Wed, 2014-01-22 at 10:13 -0800, James Bottomley wrote:
+AD4- +AD4- +AD4- +AD4- On Wed, 2014-01-22 at 18:02 +-0000, Chris Mason wro=
te:
+AD4- +AD4- +AFs-agreement cut because it's boring for the reader+AF0-
+AD4- +AD4- +AD4- +AD4- Realistically, if you look at what the I/O schedule=
rs output on a
+AD4- +AD4- +AD4- +AD4- standard (spinning rust) workload, it's mostly larg=
e transfers.
+AD4- +AD4- +AD4- +AD4- Obviously these are misalgned at the ends, but we c=
an fix some of that
+AD4- +AD4- +AD4- +AD4- in the scheduler.  Particularly if the FS helps us =
with layout.  My
+AD4- +AD4- +AD4- +AD4- instinct tells me that we can fix 99+ACU- of this w=
ith layout on the FS +- io
+AD4- +AD4- +AD4- +AD4- schedulers ... the remaining 1+ACU- goes to the dri=
ve as needing to do RMW
+AD4- +AD4- +AD4- +AD4- in the device, but the net impact to our throughput=
 shouldn't be that
+AD4- +AD4- +AD4- +AD4- great.
+AD4- +AD4- +AD4-=20
+AD4- +AD4- +AD4- There are a few workloads where the VM and the FS would t=
eam up to make
+AD4- +AD4- +AD4- this fairly miserable
+AD4- +AD4- +AD4-=20
+AD4- +AD4- +AD4- Small files.  Delayed allocation fixes a lot of this, but=
 the VM doesn't
+AD4- +AD4- +AD4- realize that fileA, fileB, fileC, and fileD all need to b=
e written at
+AD4- +AD4- +AD4- the same time to avoid RMW.  Btrfs and MD have setup plug=
ging callbacks
+AD4- +AD4- +AD4- to accumulate full stripes as much as possible, but it st=
ill hurts.
+AD4- +AD4- +AD4-=20
+AD4- +AD4- +AD4- Metadata.  These writes are very latency sensitive and we=
'll gain a lot
+AD4- +AD4- +AD4- if the FS is explicitly trying to build full sector IOs.
+AD4- +AD4-=20
+AD4- +AD4- OK, so these two cases I buy ... the question is can we do some=
thing
+AD4- +AD4- about them today without increasing the block size?
+AD4- +AD4-=20
+AD4- +AD4- The metadata problem, in particular, might be block independent=
: we
+AD4- +AD4- still have a lot of small chunks to write out at fractured loca=
tions.
+AD4- +AD4- With a large block size, the FS knows it's been bad and can exp=
ect the
+AD4- +AD4- rolled up newspaper, but it's not clear what it could do about =
it.
+AD4- +AD4-=20
+AD4- +AD4- The small files issue looks like something we should be tacklin=
g today
+AD4- +AD4- since writing out adjacent files would actually help us get big=
ger
+AD4- +AD4- transfers.
+AD4-=20
+AD4- ocfs2 can actually take significant advantage here, because we store
+AD4- small file data in-inode.  This would grow our in-inode size from +AH=
4-3K to
+AD4- +AH4-15K or +AH4-63K.  We'd actually have to do more work to start pu=
tting more
+AD4- than one inode in a block (thought that would be a promising avenue t=
oo
+AD4- once the coordination is solved generically.

Btrfs already defaults to 16K metadata and can go as high as 64k.  The
part we don't do is multi-page sectors for data blocks.

I'd tend to leverage the read/modify/write engine from the raid code for
that.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
