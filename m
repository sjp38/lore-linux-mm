Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D8AD46B0358
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 15:01:33 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <af8b0006-0eb7-468a-bbf8-36ecec9bec35@default>
Date: Tue, 3 Aug 2010 12:09:54 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V3 0/8] Cleancache: overview
References: <20100621231809.GA11111%ca-server1.us.oracle.com4C49468B.40307@vflare.org>
 <840b32ff-a303-468e-9d4e-30fc92f629f8@default>
 <20100723140440.GA12423@infradead.org>
 <364c83bd-ccb2-48cc-920d-ffcf9ca7df19@default>
 <a7f4db53-c348-4cff-8762-7ea4031e4813@default
 22A6238E-0BA4-4AB9-A4FA-28B206A47513@oracle.com>
In-Reply-To: <22A6238E-0BA4-4AB9-A4FA-28B206A47513@oracle.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andreas Dilger <andreas.dilger@oracle.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, Christoph Hellwig <hch@infradead.org>, ngupta@vflare.org, akpm@linux-foundation.org, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

> From: Andreas Dilger
> Sent: Tuesday, August 03, 2010 12:34 PM
> To: Dan Magenheimer
> Subject: Re: [PATCH V3 0/8] Cleancache: overview
>=20
> On 2010-08-03, at 11:35, Dan Magenheimer wrote:
> > - The FS should be block-device-based (e.g. a ram-based FS
> >  such as tmpfs should not enable cleancache)
>=20
> When you say "block device based", does this exclude network
> filesystems?  It would seem cleancache, like fscache, is actually best
> suited to high-latency network filesystems.

I don't think it should exclude network FSs and agree cleancache
might be well-suited for them.  So if "block device based"
leaves out the possibility of network FSs, I am just
displaying my general ignorance of FSs and I/O, and
welcome clarification from FS developers.  What I really
meant is: Don't use cleancache for RAM-based filesystems.
=20
> > - To ensure coherency/correctness, inode numbers must be unique
> >  (e.g. no emulating 64-bit inode space on 32-bit inode numbers)
>=20
> Does it need to be restricted to inode numbers at all (i.e. can it use
> an opaque internal identifier like the NFS file handle)?  Disallowing
> cleancache on a filesystem that uses 64-bit (or larger) inodes on a 32-
> bit system reduces its usefulness.

True... Earlier versions of the patch did not use ino_t but
instead used an opaque always-64-bit-unsigned "object id".
The patch changed to use ino_t in response to Al Viro's comment
to "use sane types".

The <pool_id,object_id,pg_offset> triple must uniquely
and permanently (unless explicitly flushed) describe
exactly one page of FS data.  So if usefulness is increased
by changing object_id back to an explicit 64-bit value,
I'm happy to do that.  The only disadvantage I can
see is that 32-bit systems pass an extra 32 bits on
every call that may always be zero on most FSs.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
