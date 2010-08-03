Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8076B0354
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:28:15 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a7f4db53-c348-4cff-8762-7ea4031e4813@default>
Date: Tue, 3 Aug 2010 10:35:57 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V3 0/8] Cleancache: overview
References: <20100621231809.GA11111@ca-server1.us.oracle.com4C49468B.40307@vflare.org>
 <840b32ff-a303-468e-9d4e-30fc92f629f8@default>
 <20100723140440.GA12423@infradead.org>
 <364c83bd-ccb2-48cc-920d-ffcf9ca7df19@default>
 <fc254547-5926-4cb9-98e1-7a79f7284e30@default 4C58424C.1020208@panasas.com>
In-Reply-To: <4C58424C.1020208@panasas.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>, ngupta@vflare.org, akpm@linux-foundation.org, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

> From: Boaz Harrosh [mailto:bharrosh@panasas.com]
> Sent: Tuesday, August 03, 2010 10:23 AM
> To: Dan Magenheimer
> Subject: Re: [PATCH V3 0/8] Cleancache: overview
>=20
> On 07/24/2010 12:17 AM, Dan Magenheimer wrote:
> >>> On Fri, Jul 23, 2010 at 06:58:03AM -0700, Dan Magenheimer wrote:
> >>>> CHRISTOPH AND ANDREW, if you disagree and your concerns have
> >>>> not been resolved, please speak up.
> >>
> >> Hi Christoph --
> >>
> >> Thanks very much for the quick (instantaneous?) reply!
> >>
> >>> Anything that need modification of a normal non-shared fs is
> utterly
> >>> broken and you'll get a clear NAK, so the propsal before is a good
> >>> one.
> >>
> >> No, the per-fs opt-in is very sensible; and its design is
> >> very minimal.
> >
> > Not to belabor the point, but maybe the right way to think about
> > this is:
> >
> > Cleancache is a new optional feature provided by the VFS layer
> > that potentially dramatically increases page cache effectiveness
> > for many workloads in many environments at a negligible cost.
> >
> > Filesystems that are well-behaved and conform to certain restrictions
> > can utilize cleancache simply by making a call to cleancache_init_fs
> > at mount time.  Unusual, misbehaving, or poorly layered filesystems
> > must either add additional hooks and/or undergo extensive additional
> > testing... or should just not enable the optional cleancache.
>=20
> OK, So I maintain a filesystem in Kernel. How do I know if my FS
> is not "Unusual, misbehaving, or poorly layered"

A reasonable question.  I'm not a FS expert so this may not be
a complete answer, but please consider it a start:

- The FS should be block-device-based (e.g. a ram-based FS
  such as tmpfs should not enable cleancache)

- To ensure coherency/correctness, the FS must ensure that all
  file removal or truncation operations either go through VFS
  or add hooks to do the equivalent "flush" operations (e.g.
  I started looking at FS-cache-based net FS's and was concerned
  there might be problems, dunno for sure)

- To ensure coherency/correctness, inode numbers must be unique
  (e.g. no emulating 64-bit inode space on 32-bit inode numbers)

- The FS must call the VFS superblock alloc and deactivate routines
  or add hooks to do the equivalent cleancache calls done there.

- To maximize performance, all pages fetched from the FS should
  go through the do_mpage_readpage routine or the FS should add
  hooks to do the equivalent (e.g. btrfs requires a hook for this)

- Currently, the FS blocksize must be the same as PAGESIZE.  This
  is not an architectural restriction, but no backends currently
  support anything different (e.g. hugetlbfs? should not enable
  cleancache)

- A clustered FS should invoke the "shared_init_fs" cleancache
  hook to get best performance for some backends.

Does that help?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
