Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A07296B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 18:32:45 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y51so9526988wry.6
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 15:32:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r15si10652003wmf.95.2017.02.27.15.32.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 15:32:44 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Tue, 28 Feb 2017 10:32:34 +1100
Subject: Re: [LSF/MM TOPIC] do we really need PG_error at all?
In-Reply-To: <DC27F5BA-BCCA-41FF-8D41-7BB99AA4DB26@dilger.ca>
References: <1488120164.2948.4.camel@redhat.com> <1488129033.4157.8.camel@HansenPartnership.com> <877f4cr7ew.fsf@notabene.neil.brown.name> <1488151856.4157.50.camel@HansenPartnership.com> <874lzgqy06.fsf@notabene.neil.brown.name> <1488208047.2876.6.camel@redhat.com> <DC27F5BA-BCCA-41FF-8D41-7BB99AA4DB26@dilger.ca>
Message-ID: <87varvp5v1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>, Jeff Layton <jlayton@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, linux-scsi <linux-scsi@vger.kernel.org>, linux-block@vger.kernel.org

--=-=-=
Content-Type: text/plain

On Mon, Feb 27 2017, Andreas Dilger wrote:

>
> My thought is that PG_error is definitely useful for applications to get
> correct errors back when doing write()/sync_file_range() so that they know
> there is an error in the data that _they_ wrote, rather than receiving an
> error for data that may have been written by another thread, and in turn
> clearing the error from another thread so it *doesn't* know it had a write
> error.

It might be useful in that way, but it is not currently used that way.
Such usage would be a change in visible behaviour.

sync_file_range() calls filemap_fdatawait_range(), which calls
filemap_check_errors().
If there have been any errors in the file recently, inside or outside
the range, the latter will return an error which will propagate up.

>
> As for stray sync() clearing PG_error from underneath an application, that
> shouldn't happen since filemap_fdatawait_keep_errors() doesn't clear errors
> and is used by device flushing code (fdatawait_one_bdev(), wait_sb_inodes()).

filemap_fdatawait_keep_errors() calls __filemap_fdatawait_range() which
clears PG_error on every page.
What it doesn't do is call filemap_check_errors(), and so doesn't clear
AS_ENOSPC or AS_EIO.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli0txIACgkQOeye3VZi
gblSPBAAhZnmLy6Gbs0dPtECjM7L9gvjquDqZW1O6wtHw0KJJb3o3whnh0LGn8h1
QqeZZG1jCYN98tvFmtaoZRAQTuc3WwQyXvQFzBQKcM7PLRDMNKUvZGG+/eyI80tn
zZlEIxUWUJhZGivl5BsJpVAcl8VSjeCbPLVM77nx+DpD3wdE2DDXzG9g0dialAOo
16xbTt0sq4NE/bw0tSE2PbD9AiNiUdCSCa9MgqEOpkYV2JmUUMr8mMInZ64Sor10
RRtKd3RLcjBqxjC6TyUCTxvXsZ5bXpRYB31tRVzhkZlG5BjVJHpTBlomKAOQq4VE
D+vgptI7uCbYry/FoIevkDo8+ubBMjlOdaLnlk7uJ/3xKdi52EnJFkhEl0C/kKcu
bjQjV2GtikhtUghNUWbrKwLsi1N8kEq1Bh2TMiDKd6wpZhgJw1sC3xDvEZ1z1vn4
bpOdpoiSY8dvKYHl3eFDndLVCulIycKDTEj+qfMEXE961S+eTcOjFmzmx0om3SN3
rUa9xjzoVUPgiYzVt79EWnJq5elM8BSMaI6qMxPuE9YDVz7c/Mpe1P7LKIglRQVx
VxOHB+GSHxqX53eQ9KKzXssSjk33n/Nhxuq2SoOpVw7jwMBv9KkpdEDybwvBNFX3
k+gDdv0G7sC/3/5bohqaX88hHGx39PkGZQ/QTMwp4ZSWNxN92jQ=
=OyWv
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
