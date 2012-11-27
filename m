Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 9B8286B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 17:37:08 -0500 (EST)
Subject: Re: [PATCH] mm,vmscan: only loop back if compaction would fail in all zones
In-Reply-To: Your message of "Sun, 25 Nov 2012 23:10:41 -0500."
             <20121126041041.GD2799@cmpxchg.org>
From: Valdis.Kletnieks@vt.edu
References: <20121119202152.4B0E420004E@hpza10.eem.corp.google.com> <20121125175728.3db4ac6a@fem.tu-ilmenau.de> <20121125132950.11b15e38@annuminas.surriel.com> <20121125224433.GB2799@cmpxchg.org> <20121125191645.0ebc6d59@annuminas.surriel.com> <20121126031518.GC2799@cmpxchg.org>
            <20121126041041.GD2799@cmpxchg.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1354055756_2187P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 27 Nov 2012 17:35:56 -0500
Message-ID: <27425.1354055756@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, akpm@linux-foundation.org, mgorman@suse.de, jirislaby@gmail.com, jslaby@suse.cz, zkabelac@redhat.com, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

--==_Exmh_1354055756_2187P
Content-Type: text/plain; charset=us-ascii

On Sun, 25 Nov 2012 23:10:41 -0500, Johannes Weiner said:

> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: vmscan: fix endless loop in kswapd balancing
>
> Kswapd does not in all places have the same criteria for when it
> considers a zone balanced.  This leads to zones being not reclaimed
> because they are considered just fine and the compaction checks to
> loop over the zonelist again because they are considered unbalanced,
> causing kswapd to run forever.
>
> Add a function, zone_balanced(), that checks the watermark and if
> compaction has enough free memory to do its job.  Then use it
> uniformly for when kswapd needs to check if a zone is balanced.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c | 27 ++++++++++++++++++---------
>  1 file changed, 18 insertions(+), 9 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 48550c6..3b0aef4 100644

> +	if (COMPACTION_BUILD && order && !compaction_suitable(zone, order))
> +		return false;

Applying to next-20121117,I had to hand-patch for this other apkm patch:

./Next/merge.log:Applying: mm: use IS_ENABLED(CONFIG_COMPACTION) instead of COMPACTION_BUILD

Probably won't be till tomorrow before I know if this worked, it seems
to take a while before the kswapd storms start hitting (appears to be
a function of uptime - see almost none for 8-16 hours, after 24-30 hours
I'll be having a spinning kswapd most of the time).

--==_Exmh_1354055756_2187P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBULVATAdmEQWDXROgAQLEoBAApVp6hc1/HiMpkLQubEqbab+Nhvz6oXri
MqALE0I1kfpFiqxROmMAvejy+1nEp6AEL6MYYAh7Kdz9nlHZaJvCg8YByr3jpt5n
DRXc7e0817rlnrYEvf+Jq4vXJwwpCWKRGOUr40hOAZfn727pwwkTHTEz58UqDkUd
RiK4GUJflaH5FgHrbYNMtJk3B4cpYqFG61168m/glwRD2gI2v6r1gQQ3OJ1zaEhp
KHUtwbSKlfWjd3pk2u9qauiE814bU550s+hnPBwgUcUxG5PjCExPVJNQq5iOZMHi
93IdjV5mRwZC7afRPXQY5u6g5IdqgYFCNGKywgBvBlaiuEy2aHJTSx14S+qo7BMg
2DZokE4F3Jt8X53b1FtMGLD11PUHTzHRhgyL35cNggfe6OP9Mqg4XrFXqY8gbYX2
1xZ9uJk0rzFZ5HWxs6DSzreYTcznIccI2Umw/a9MeUuPCfQuGovPAhdjOz2l8JXn
pdcgXX9H+oaS2BF2Ws8mQOtclmxsG/2W5bIxMUB4+VNG/Tbjw2d0iSCzOhxBoV3v
J5ad6OkAMroqXAC2cQO4n/9qIcGPenmKBQK8FysrF627rO4r3s2JMpmZclOEVIfX
f90OV5p9q+PicYnShDekVd8hq3JhaqLTXJyNBaSfyPIERwIyr8G4c90bSfhyAUdq
CCFM6a28/ko=
=xGoo
-----END PGP SIGNATURE-----

--==_Exmh_1354055756_2187P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
