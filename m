Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2216B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 05:04:27 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id n12so671387wgh.29
        for <linux-mm@kvack.org>; Wed, 07 May 2014 02:04:26 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id gq2si5481605wib.60.2014.05.07.02.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 May 2014 02:04:25 -0700 (PDT)
Date: Wed, 7 May 2014 11:04:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 03/17] mm: page_alloc: Use jump labels to avoid checking
 number_of_cpusets
Message-ID: <20140507090421.GO11096@twins.programming.kicks-ass.net>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-4-git-send-email-mgorman@suse.de>
 <20140506202350.GE1429@laptop.programming.kicks-ass.net>
 <20140506222118.GB23991@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zGa1rFMfQatMxgJk"
Content-Disposition: inline
In-Reply-To: <20140506222118.GB23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>


--zGa1rFMfQatMxgJk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 06, 2014 at 11:21:18PM +0100, Mel Gorman wrote:
> On Tue, May 06, 2014 at 10:23:50PM +0200, Peter Zijlstra wrote:

> > Why the HAVE_JUMP_LABEL and number_of_cpusets thing? When
> > !HAVE_JUMP_LABEL the static_key thing reverts to an atomic_t and
> > static_key_false() becomes:
> >=20
>=20
> Because number_of_cpusets is used to size a kmalloc(). Potentially I could
> abuse the internals of static keys and use the value of key->enabled but
> that felt like abuse of the API.

But are those ifdefs worth the saving of 4 bytes of .data?

That said, I see no real problem adding static_key_count(). Static keys
(jump labels back then) were specifically designed to include the count
and act as 'ref/usage' counter. Its just that so far everybody only
cared about the boolean 'are there users' question, but there is no
reason not to also return the full count.

Maybe I should also do a patch that renames the static_key::enabled
field to static_key::count to better reflect this.

---
 include/linux/jump_label.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/jump_label.h b/include/linux/jump_label.h
index 5c1dfb2a9e73..1a48d16622aa 100644
--- a/include/linux/jump_label.h
+++ b/include/linux/jump_label.h
@@ -197,4 +197,9 @@ static inline bool static_key_enabled(struct static_key=
 *key)
 	return (atomic_read(&key->enabled) > 0);
 }
=20
+static inline int static_key_count(struct static_key *key)
+{
+	return atomic_read(&key->enabled);
+}
+
 #endif	/* _LINUX_JUMP_LABEL_H */

--zGa1rFMfQatMxgJk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTafcPAAoJEHZH4aRLwOS68gMP+weojsBEVtG6Cen48VCEGgKB
w5twCWRYhJfLJBoRDjsO3zvpDPcdoatTHJ53TXmv0aj7yFYAmdq83yypWf7gwypF
FH7gW+2Xn0lpirGwu4F/lp8YRctyIGnjaV9kRGrB5Poty3YD9VB74YmfIXhUs3Lu
zCtQ62oa6mM2jBRA2CK3JPXG62HvyoNlIpsgUNg/tHkdWj1Yt5yzWGYRBKeXoOcX
QAU0Pcnt15E+SO+1RUiAlBnDRbju0uik0eix4zYLoVgzqiPYOf3nvWZKutLhuIX+
lOUfiN7gezIQg2mCBSmRQtzBOoV4FZ218NZqquFhxZlaxnltVODaN5KTr5b11hAk
NG1qUx/RBP/nTAUm41aJjjl2rZ1kapXLpBuVIe0rB0fbFpX26yS52arNggt4hAg6
I9GMt9CXxlXzs8MXDBjECi9MLHeuG3BmlVyoGPDyG3WbplZHf4XXNcnGM8lz5CAy
lQzp5iJ4UZhBJK02Ur/QDePnIiRQiZCunLiYviI0IRbGxz8+F8Co2OI0glkoBkzO
hq4Uc/hDZxLNBRp4RZL7NLgYLQ5q5mv7UO5+Mx8sJ9D5E6w/nAMknUnv5N3JQvoA
xMvYuqSC1i6Upbeums/OgOUFFgZsLhb10VbbHXJXgmQIjj6MLGYyfjTDX2kwcQuM
RGta4lAZNWuC7cWPEzPy
=MyKT
-----END PGP SIGNATURE-----

--zGa1rFMfQatMxgJk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
