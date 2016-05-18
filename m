Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2AC6B007E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 23:41:31 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so18377761lfc.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 20:41:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v132si8235179wme.82.2016.05.17.20.41.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 May 2016 20:41:30 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Wed, 18 May 2016 13:41:20 +1000
Subject: [PATCH] MM: increase safety margin provided by PF_LESS_THROTTLE
Message-ID: <87futgowwv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, NFS List <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

--=-=-=
Content-Type: text/plain


When nfsd is exporting a filesystem over NFS which is then NFS-mounted
on the local machine there is a risk of deadlock.  This happens when
there are lots of dirty pages in the NFS filesystem and they cause
NFSD to be throttled, either in throttle_vm_writeout() or in
balance_dirty_pages().

To avoid this problem the PF_LESS_THROTTLE flag is set for NFSD
threads and it provides a 25% increase to the limits that affect NFSD.
Any process writing to an NFS filesystem will be throttled well
before the number of dirty NFS pages reaches the limit imposed on
NFSD, so NFSD will not deadlock on pages that it needs to write out.
At least it shouldn't.

All processes are allowed a small excess margin to avoid performing
too many calculations: ratelimit_pages.

ratelimit_pages is set so that if a thread on every CPU uses the
entire margin, the total will only go 3% over the limit, and this is
much less than the 25% bonus that PF_LESS_THROTTLE provides, so this
margin shouldn't be a problem.  But it is.

The "total memory" that these 3% and 25% are calculated against are not
really total memory but are "global_dirtyable_memory()" which doesn't
include anonymous memory, just free memory and page-cache memory.

The "ratelimit_pages" number is based on whatever the
global_dirtyable_memory was on the last CPU hot-plug, which might not
be what you expect, but is probably close to the total freeable memory.

The throttle threshold uses the global_dirtable_memory at the moment
when the throttling happens, which could be much less than at the last
CPU hotplug.  So if lots of anonymous memory has been allocated, thus
pushing out lots of page-cache pages, then NFSD might end up being
throttled due to dirty NFS pages because the "25%" bonus it gets is
calculated against a rather small amount of dirtyable memory, while
the "3%" margin that other processes are allowed to dirty without
penalty is calculated against a much larger number.

To remove this possibility of deadlock we need to make sure that the
margin granted to PF_LESS_THROTTLE exceeds that rate-limit margin.
Simply adding ratelimit_pages isn't enough as that should be
multiplied by the number of cpus.

So add "global_wb_domain.dirty_limit / 32" as that more accurately
reflects the current total over-shoot margin.  This ensures that the
number of dirty NFS pages never gets so high that nfsd will be
throttled waiting for them to be written.

Signed-off-by: NeilBrown <neilb@suse.com>

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index bc5149d5ec38..bbdcd7ccef57 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -407,8 +407,8 @@ static void domain_dirty_limits(struct dirty_throttle_control *dtc)
 		bg_thresh = thresh / 2;
 	tsk = current;
 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
-		bg_thresh += bg_thresh / 4;
-		thresh += thresh / 4;
+		bg_thresh += bg_thresh / 4 + global_wb_domain.dirty_limit / 32;
+		thresh += thresh / 4 + global_wb_domain.dirty_limit / 32;
 	}
 	dtc->thresh = thresh;
 	dtc->bg_thresh = bg_thresh;

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXO+RgAAoJEDnsnt1WYoG57XEP/0kHGOr9T9yt1KxtWuKljofR
zR/Pfve2jC4aQd9TY3ZEbFzsx9DbVGgk9CINEU7KYF4t7oIZgcNbM/gP2NUNav9I
jASpv7tILjUXJnvMXCkWSWiafBmYjUTyCQX7VIuoZwsPlPPAyrD/AV4zBQ3pTcTZ
WQon3assMgogKTpvdH55MYC6g0MtZTSFONbwrhigjKyIN1AyKKyaXmXqbRDU/zun
hGJ7IAWJYmjhuVDmN8YWTJlZupCt5P0PmzwUyssINqle5rdeeYhxR65TLpoN/zih
S609W5phhH0gmyJ361XM/AlGSoy0v5NNmdbQw3//QtychgupfC5FegYp0FYvZoQ4
W1u4CUUxC/Weqg5Y/CunmI7UhTpjvr8SBQev+eFNkXz6Oi8c2okbK5CEfUMhg/7Y
+KMUup+Hgtf1HOchBxbpQfFzlbnoyrWjViLMBEBK0mM7qj5Vm8frbztwJGpcrX72
/RJ3mCQLIgFyIzZSwo/K1irOCzUycN7z9FKfEEY03/NvCxDmwia7awrmn/Fn+vr/
rF0DiviE05JxfNW0RGkPSwsEohTURmxJEAQL/oVIimjaSWEXqbPfk+HEWx1kVh5/
CKg6aRXW0v7N0WVYGey/HbsS5fZY6RyKGWc4+w8sNH2D99xN2S5UUcOe2M5bz3FU
VzqWryyyuCwEHMttrF6g
=cucN
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
