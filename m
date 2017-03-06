Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACECC6B0388
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 22:06:23 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n11so25417122wma.5
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 19:06:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w110si24657425wrb.207.2017.03.05.19.06.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 05 Mar 2017 19:06:22 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Mon, 06 Mar 2017 14:06:11 +1100
Subject: Re: [PATCH 0/3] mm/fs: get PG_error out of the writeback reporting business
In-Reply-To: <20170305133535.6516-1-jlayton@redhat.com>
References: <20170305133535.6516-1-jlayton@redhat.com>
Message-ID: <871subkst8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk, konishi.ryusuke@lab.ntt.co.jp
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 05 2017, Jeff Layton wrote:

> I recently did some work to wire up -ENOSPC handling in ceph, and found
> I could get back -EIO errors in some cases when I should have instead
> gotten -ENOSPC. The problem was that the ceph writeback code would set
> PG_error on a writeback error, and that error would clobber the mapping
> error.
>
> While I fixed that problem by simply not setting that bit on errors,
> that led me down a rabbit hole of looking at how PG_error is being
> handled in the kernel.

Speaking of rabbit holes... I thought to wonder how IO error propagate
up from NFS.
It doesn't use SetPageError or mapping_set_error() for files (except in
one case that looks a bit odd).
It has an "nfs_open_context" and store the latest error in ctx->error.

So when you get around to documenting how this is supposed to work, it
would be worth while describing the required observable behaviour, and
note that while filesystems can use mapping_set_error() to achieve this,
they don't have to.

I notice that
  drivers/staging/lustre/lustre/llite/rw.c
  fs/afs/write.c
  fs/btrfs/extent_io.c
  fs/cifs/file.c
  fs/jffs2/file.c
  fs/jfs/jfs_metapage.c
  fs/ntfs/aops.c

(and possible others) all have SetPageError() calls that seem to be
in response to a write error to a file, but don't appear to have
matching mapping_set_error() calls.  Did you look at these?  Did I miss
something?

Thanks,
NeilBrown

>
> This patch series is a few fixes for things that I 100% noticed by
> inspection. I don't have a great way to test these since they involve
> error handling. I can certainly doctor up a kernel to inject errors
> in this code and test by hand however if these look plausible up front.
>
> Jeff Layton (3):
>   nilfs2: set the mapping error when calling SetPageError on writeback
>   mm: don't TestClearPageError in __filemap_fdatawait_range
>   mm: set mapping error when launder_pages fails
>
>  fs/nilfs2/segment.c |  1 +
>  mm/filemap.c        | 19 ++++---------------
>  mm/truncate.c       |  6 +++++-
>  3 files changed, 10 insertions(+), 16 deletions(-)
>
> --=20
> 2.9.3

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli80iQACgkQOeye3VZi
gblO6hAAhio2Ndl5HR0tR+Ao1Kmj9lz3P41Gmjv4+PTuHhYn0311U38WQ42hvI7U
CUu4mMv+b2M508vEk6w2VSgwYJdA6Mfs6yvEqEBkceKfWfgfcHjQ40Hk5xWuQ5kZ
V0JFVMHK6vxKOn/GhZsVZ9Y7BllG6iY2gqRXwIoTyqqS7fxPt40KL+jEj1Xg9OMT
nLBqfhaofimah+WlxPdajveOAAXbjRws/7NH+GEYaD/Z6zjhletSMKumNgkN6i1k
kgoHNsN+wHMKULef7AoE3BS9mNQjxvu86VBXnS36MmFIHkVAiTcWXZTaUp98ye3a
WvxapiMfcBl9x7tfQHV0QkK2aV0Xw/Y1KlqyO6f649ZQAMLsAvgyWOJd/2T/E7u1
M+pa7GhVKFwBC5Sa7qm5WrriNsVR9Ue0+kMgPmjJxBXBZtuRh7idNxP+5Da7GRO2
ySNK359Lv2ZpcbT9Z8H+fT3siueaMW835+dSCWqCaC/S2daEq5D6f9qB5V5hDmRD
Hz/9TYDiyCvQt4U8Vr/2ne73Zu8hfpgiP8c7FtpUtcFgvo4sblfs1RTnoRz5CHWC
gNG1K/04CLZgnR+Ya0SO4lU24lvP0NGId7Cyr6WfTA2zMxRRAR5wvG4zve3SOk8j
DPjhAIyWf2mDhXSvKC0NVy0umRCPr/Kx03veJ+w88P64hbtyJvQ=
=Z5g1
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
