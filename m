Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1326B01F5
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 16:10:31 -0400 (EDT)
Subject: Re: [PATCH] VM: kswapd should not do blocking memory allocations
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20100818193440.GZ5854@think>
References: <1282158241.8540.85.camel@heimdal.trondhjem.org>
	 <20100818193440.GZ5854@think>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 18 Aug 2010 16:10:10 -0400
Message-ID: <1282162210.8540.100.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-08-18 at 15:34 -0400, Chris Mason wrote:
> On Wed, Aug 18, 2010 at 03:04:01PM -0400, Trond Myklebust wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> >=20
> > Allowing kswapd to do GFP_KERNEL memory allocations (or any blocking me=
mory
> > allocations) is wrong and can cause deadlocks in try_to_release_page(),=
 as
> > the filesystem believes it is safe to allocate new memory and block,
> > whereas kswapd is there specifically to clear a low-memory situation...
> >=20
> > Set the gfp_mask to GFP_IOFS instead.
>=20
> I always thought releasepage was supposed to do almost zero work.  It
> could release an instantly freeable page but it wasn't supposed to dive
> in and solve world hunger or anything.
>=20
> I thought the VM would be using writepage for that.

writepage isn't sufficient for the NFS case: the page may be in the
'clean but unstable' state, in which case the NFS client needs to send a
COMMIT rpc call before the page can finally be released.

That is why we need the gfp_flag to tell us when it is safe to do this,
and when it is not.
The main case where it is safe and necessary for try_to_release_page()
to initiate a COMMIT call is in the invalidate_inode_pages2(). We might
want to do it in the kswapd case too, but in that case, we definitely
should tell the filesystem that it is unsafe to block.

Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
