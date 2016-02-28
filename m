Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id CA0306B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 01:27:21 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so30896119wmp.1
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 22:27:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l64si13465715wmf.60.2016.02.27.22.27.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Feb 2016 22:27:20 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Sun, 28 Feb 2016 17:27:03 +1100
Subject: Re: [PATCH 3/3] radix-tree: support locking of individual exception entries.
In-Reply-To: <145663616983.3865.11911049648442320016.stgit@notabene>
References: <145663588892.3865.9987439671424028216.stgit@notabene> <145663616983.3865.11911049648442320016.stgit@notabene>
Message-ID: <87oab1pcy0.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain

On Sun, Feb 28 2016, NeilBrown <neilb@suse.com> wrote:

> +static int wake_slot_function(wait_queue_t *wait, unsigned mode, int sync,
> +			      void *arg)
> +{
> +	struct wait_bit_key *key = arg;
> +	struct wait_slot_queue *wait_slot =
> +		container_of(wait, struct wait_slot_queue, wait);
> +	void **slot;
> +
> +	if (wait_slot->root != key->flags ||
> +	    wait_slot->index != key->timeout)
> +		/* Not waking this waiter */
> +		return 0;
> +	if (wait_slot->state != SLOT_WAITING)
> +		/* Should be impossible.... */
> +		return 1;
> +	if (key->bit_nr == -3)
> +		/* Was just deleted, no point in doing a lookup */
> +		wait_slot = NULL;
> +	else
> +		wait_slot->ret = __radix_tree_lookup(
> +			wait_slot->root, wait_slot->index, NULL, &slot);
> +	if (!wait_slot->ret || !radix_tree_exceptional_entry(wait_slot->ret)) {
> +		wait_slot->state = SLOT_GONE;
> +		return 1;
> +	}
> +	if (slot_locked(slot))
> +		/* still locked */
> +		return 0;
> +	wait_slot->ret = lock_slot(slot);
> +	wait_slot->state = SLOT_LOCKED;
> +	return 1;
> +}

Sorry, just realized that this should:
  return autoremove_wake_function(wait, mode, sync, arg);

instead of "return 1;"

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW0pM3AAoJEDnsnt1WYoG5U5QP/iLUtFEexzyaeyH4VjewXBWC
WdDKQI7/FIyMwQufk74AGnHu60oBS56x7K48x/Zzcdo6RXFfgxItrozVWcY+YTPJ
7MhBm2Z3ubABFw5iZ6A2/eqsezcUuYRKY5YIohmfLUQsxSWjLFCYePwqCDxJPpds
Ur0TlpDVc5ihloVtoCqEy4se/ARKE6jUUQId+8LgO6xfioT+igOtJZOfDIPHPp7l
jkJMkL3eVNz1e0CWTbcUkJbOV4yVHKosCmSt3yDQ0OrTjfBoQ8WqWLiGPkDXZ7Ed
7w82IhZ7U76gOFrvw6NtQVNIOMwnzT159ZeM3mNKya5YvVsidtEOmPu7IMy8Q9t2
/a+k5etQlNYUzJeUHy6GiHJW7cj7yLoZtzJ5Zu1GYFb6W2AkJY05VcwVGbucRz21
m5WDGPB8RD9CbnwaNYtDXQ2YEbjbQHHRoJMM6mqRPQnRof9fJJVWEOacDai9/1l4
YxhyHG3FnfxJWyFUmmh+AnhMVxJYlbxZ9rRyqfsak6fZ3ahs1NgtFoT4I7B5gxjW
BoXMoWqGhLFYepvD7+JNqW75gFnplnYywwp3h6VhqZWXFs1W3EolQQQ5rBEBY+/7
oIFx114B1Dhl0d1Lb/rM3mLCCf14wFC2QoCzQP9906rhizcfG2RjnzJs21GVdUuL
MP/ssZlAjaYAHYDraq58
=JhMu
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
