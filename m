Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id C9BDA6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 21:13:19 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p65so51764040wmp.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 18:13:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r76si7967373wmg.70.2016.03.08.18.13.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 18:13:18 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Mar 2016 13:13:08 +1100
Subject: Re: [PATCH 3/3] radix-tree: support locking of individual exception entries.
In-Reply-To: <20160304123112.GA17393@quack.suse.cz>
References: <145663588892.3865.9987439671424028216.stgit@notabene> <145663616983.3865.11911049648442320016.stgit@notabene> <20160303131033.GC12118@quack.suse.cz> <87a8mfm86l.fsf@notabene.neil.brown.name> <87si06lfcv.fsf@notabene.neil.brown.name> <20160304123112.GA17393@quack.suse.cz>
Message-ID: <87oaaojt57.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 04 2016, Jan Kara wrote:

> On Fri 04-03-16 21:14:24, NeilBrown wrote:
>> On Fri, Mar 04 2016, NeilBrown wrote:
>>=20
>> >
>> > By not layering on top of wait_bit_key, you've precluded the use of the
>> > current page wait_queues for these locks - you need to allocate new wa=
it
>> > queue heads.
>> >
>> > If in
>> >
>> >> +struct wait_exceptional_entry_queue {
>> >> +	wait_queue_t wait;
>> >> +	struct exceptional_entry_key key;
>> >> +};
>> >
>> > you had the exceptional_entry_key first (like wait_bit_queue does) you
>> > would be closer to being able to re-use the queues.
>>=20
>> Scratch that bit, I was confusing myself again.  Sorry.
>> Each wait_queue_t has it's own function so one function will never be
>> called on other items in the queue - of course.
>
> Yes.

I was thinking about this some more, wondering why I thought what I did,
and realised there is a small issue that it is worth being aware of.

If different users of the same work queue use different "keys", a wake
function can get a key of a different type to the one it is expecting.

e.g. __wake_up_bit passes the address of a "struct wait_bit_key" to
__wake_up which is then passed as a "void* arg" to the
wait_queue_func_t.

With your code, a "struct exceptional_entry_key" could be passed to
wake_bit_function, or a "struct wait_bit_key" could be passed to
wake_exceptional_entry_func.

Both structures start with a pointer which will never appear in the
wrong type, and both function test that pointer first and access nothing
else if it doesn't match, so the code is safe.  But it could be seen as
a bit fragile, and doing something to make it obvious that the different
key types need to align on that primary key field would not be a bad
thing. .... If we end up using this code.

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW34a0AAoJEDnsnt1WYoG5wGYP/ji46e8tp8B5KWB4c5m00gl5
d1mCuG2R5PSoLdfR8194om2MUnN4NvW76qx0CKe36Zd+GCA+NachFzjJwq782qez
XaICVis0kDeO09E9DyUA3DhHRScdQ8MxNEWoFT0/RMA8NTasAd4rUNLcwOzmXqfZ
jgzVCa8l15EiRB46Ko69oVez+NgP9SfmBrc5ffHanZTbL2/A2Fn4QmVWcM2+0pqt
OFTagUVyNKh70qn0AbaoyMGPK9y7qwSDaiAEROvgYnOmLqAuRCp1C0XRmmTsamk3
bmcaTNYHKlcYrHV9ZeVceTsQAGG5+S7P2TN7BetrF4HdAcPAf7D+wU1cdPBTgbuP
HSKupIFTABf9NsLfVy66GTBo0g+6wcQBTawtrWCeH7aOIdkGs0hIPoH0muwMY64+
/bfpIIxvoJz6+CLtsBcu1DMZssRukW/Mp5r1I4KM32WySk3w7IPWNSG6YFHtOLka
TvXNLQ1pML5xfXB3AE5xyNSB1YOvR60TmPoS68PykkWyZeLFYUy5sjvKxbral0Yc
LeLBNf68GW/MHtNjyY6tgYiu5EsOBFVSzKpP+dsaFs4co5ZuPEiXNG/kaaso+fzX
rSuhLkIsbCg6UeQeyhEwj0We5EO5S2FmNHDxfoYlcD3+wO87bC/NNsVi1T/WJjx0
hgPFyNjXsbnVTN59KqHT
=Efuj
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
