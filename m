Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 759A26B0265
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 18:51:57 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l68so56663962wml.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 15:51:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dj3si935605wjb.135.2016.03.03.15.51.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 15:51:56 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Fri, 04 Mar 2016 10:51:46 +1100
Subject: Re: [PATCH 3/3] radix-tree: support locking of individual exception entries.
In-Reply-To: <20160303131033.GC12118@quack.suse.cz>
References: <145663588892.3865.9987439671424028216.stgit@notabene> <145663616983.3865.11911049648442320016.stgit@notabene> <20160303131033.GC12118@quack.suse.cz>
Message-ID: <87a8mfm86l.fsf@notabene.neil.brown.name>
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

> Hi Neil,
>
> On Sun 28-02-16 16:09:29, NeilBrown wrote:
>> The least significant bit of an exception entry is used as a lock flag.
>> A caller can:
>>  - create a locked entry by simply adding an entry with this flag set
>>  - lock an existing entry with radix_tree_lookup_lock().  This may return
>>     NULL if the entry doesn't exists, or was deleted while waiting for
>>     the lock.  It may return a non-exception entry if that is what is
>>     found.  If it returns a locked entry then it has exclusive rights
>>     to delete the entry.
>>  - unlock an entry that is already locked.  This will wake any waiters.
>>  - delete an entry that is locked.  This will wake waiters so that they
>>    return NULL without looking at the slot in the radix tree.
>>=20
>> These must all be called with the radix tree locked (i.e. a spinlock hel=
d).
>> That spinlock is passed to radix_tree_lookup_lock() so that it can drop
>> the lock while waiting.
>>=20
>> This is a "demonstration of concept".  I haven't actually tested, only c=
ompiled.
>> A possible use case is for the exception entries used by DAX.
>>=20
>> It is possible that some of the lookups can be optimised away in some
>> cases by storing a slot pointer.  I wanted to keep it reasonable
>> simple until it was determined if it might be useful.
>
> Thanks for having a look! So the patch looks like it would do the work but
> frankly the amount of hackiness in it has exceeded my personal threshold.=
..
> several times ;)

Achievement unlocked ? :-)

>
> In particular I don't quite understand why have you decided to re-lookup
> the exceptional entry in the wake function? That seems to be the source of
> a lot of a hackiness?

Yes.....

My original idea was that there would only be a single lookup.  If the
slot was found to be locked, the address of the slot would be stored in
the key so the wakeup function could trivially detect if it was being
deleted, or could claim the lock, and would signal the result to the
caller.

But then I realized that the address of the slot is not necessarily
stable.  In particular the slot for address 0 can be in the root, or it
can be in a node.  I could special-case address zero but it was easier
just to do the search.

Of course the slot disappears if the entry is deleted.  That is why the
wakeup function (which is called under the tree lock so can still safely
inspect the slot) would signal to the caller that the delete had
happened.

So the patch was a little confused....

>                       I was hoping for something simpler like what I've
> attached (compile tested only). What do you think?

Certainly simpler.

By not layering on top of wait_bit_key, you've precluded the use of the
current page wait_queues for these locks - you need to allocate new wait
queue heads.

If in

> +struct wait_exceptional_entry_queue {
> +	wait_queue_t wait;
> +	struct exceptional_entry_key key;
> +};

you had the exceptional_entry_key first (like wait_bit_queue does) you
would be closer to being able to re-use the queues.

Also I don't think it is safe to use an exclusive wait.  When a slot is
deleted, you need to wake up *all* the waiters.

Thanks,
NeilBrown


>
> To avoid false wakeups and thundering herd issues which my simple version=
 does
> have, we could do something like what I outline in the second patch. Now
> that I look at the result that is closer to your patch, just cleaner IMHO=
 :).
> But I wanted to have it separated to see how much complexity does this
> additional functionality brings...
>
> Now I'm going to have a look how to use this in DAX...
>
> 								Honza

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW2M4SAAoJEDnsnt1WYoG5s4EP/3jtMA3Quso7J35dASFP48rF
tl2IFoog9MKoV+MFM3agbC5LCLg4ffCSMbvIK0pjWSCKBkrt5zioL/XoFBJT0Uia
GyqxnoKJQ3bAkhmT8VInhJzXaYrI4CEuv472X5/k5GuR+w+JpZHdlSxF7ZuSR8YH
Xl5cZ2u50t3qK3rh3K/zHv+AQKUqwHURxg5hxgrWQmRG67AKhazLT0jmgM0YcvCT
LxramUwa9dgGqzLfLmLNidMxfCrHsyTtTc0cw31p+WYqSTyqiPdQZEGXbbOELKIM
leF2Stv530DyrP+Pcwb7jkhzcckizahu1LsC8zBzc/qcGBrZME1we15pBLkwThFF
Ths/3PdcFfhagqdIm+oqcNWvHgb7FN59HnCZwdNFAYLPtBdMiGqDrG2iWX+gt18W
gsKV0mdks4kFS/yGouDgYymQfsgVMGzcdKGSST3iN09Ai8TVtBrjXAHG5Xi9sXBF
F8RlBM6Ce5LrcsYnA/JtYt1ZMHN639kwxH+Wrz96X1WK6y+Mc8ghV2ABWhXSODRn
SDMVR6Rx3cSW6bOwgb7v8aaxx76n0+Yf+eTLnMegOi4fYalr4KB8VTWlqtGkwt97
k+3qQdIEwtMuoQVCmXkgn8K8RRT0uq2+CKNWc5ff2Pi7mEVcENNOCejNb6BpLCWL
MyZ2w+07apT6fZFYGQ4E
=s1RM
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
