Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2FFD96B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 23:43:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so8618644lfe.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 20:43:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fq8si4412601wjc.159.2016.07.26.20.43.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 20:43:47 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Wed, 27 Jul 2016 13:43:35 +1000
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE tasks
In-Reply-To: <20160725083247.GD9401@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz> <878twt5i1j.fsf@notabene.neil.brown.name> <20160725083247.GD9401@dhcp22.suse.cz>
Message-ID: <87lh0n4ufs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mikulas Patocka <mpatocka@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 25 2016, Michal Hocko wrote:

> On Sat 23-07-16 10:12:24, NeilBrown wrote:

>> Maybe that is impractical, but having firm rules like that would go a
>> long way to make it possible to actually understand and reason about how
>> MM works.  As it is, there seems to be a tendency to put bandaids over
>> bandaids.
>
> Ohh, I would definitely wish for this to be more clear but as it turned
> out over time there are quite some interdependencies between MM/FS/IO
> layers which make the picture really blur. If there is a brave soul to
> make that more clear without breaking any of that it would be really
> cool ;)

Just need that comprehensive regression-test-suite and off we go....


>> > My thinking was that throttle_vm_writeout is there to prevent from
>> > dirtying too many pages from the reclaim the context.  PF_LESS_THROTTLE
>> > is part of the writeout so throttling it on too many dirty pages is
>> > questionable (well we get some bias but that is not really reliable). =
It
>> > still makes sense to throttle when the backing device is congested
>> > because the writeout path wouldn't make much progress anyway and we al=
so
>> > do not want to cycle through LRU lists too quickly in that case.
>>=20
>> "dirtying ... from the reclaim context" ??? What does that mean?
>
> Say you would cause a swapout from the reclaim context. You would
> effectively dirty that anon page until it gets written down to the
> storage.

I should probably figure out how swap really works.  I have vague ideas
which are probably missing important details...
Isn't the first step that the page gets moved into the swap-cache - and
marked dirty I guess.  Then it gets written out and the page is marked
'clean'.
Then further memory pressure might push it out of the cache, or an early
re-use would pull it back from the cache.
If so, then "dirtying in reclaim context" could also be described as
"moving into the swap cache" - yes?  So should there be a limit on dirty
pages in the swap cache just like there is for dirty pages in any
filesystem (the max_dirty_ratio thing) ??
Maybe there is?

>> The use of PF_LESS_THROTTLE in current_may_throttle() in vmscan.c is to
>> avoid a live-lock.  A key premise is that nfsd only allocates unbounded
>> memory when it is writing to the page cache.  So it only needs to be
>> throttled when the backing device it is writing to is congested.  It is
>> particularly important that it *doesn't* get throttled just because an
>> NFS backing device is congested, because nfsd might be trying to clear
>> that congestion.
>
> Thanks for the clarification. IIUC then removing throttle_vm_writeout
> for the nfsd writeout should be harmless as well, right?

Certainly shouldn't hurt from the perspective of nfsd.

>> >> The purpose of that flag is to allow a thread to dirty a page-cache p=
age
>> >> as part of cleaning another page-cache page.
>> >> So it makes sense for loop and sometimes for nfsd.  It would make sen=
se
>> >> for dm-crypt if it was putting the encrypted version in the page cach=
e.
>> >> But if dm-crypt is just allocating a transient page (which I think it
>> >> is), then a mempool should be sufficient (and we should make sure it =
is
>> >> sufficient) and access to an extra 10% (or whatever) of the page cache
>> >> isn't justified.
>> >
>> > If you think that PF_LESS_THROTTLE (ab)use in mempool_alloc is not
>> > appropriate then would a PF_MEMPOOL be any better?
>>=20
>> Why a PF rather than a GFP flag?
>
> Well, short answer is that gfp masks are almost depleted.

Really?  We have 26.

pagemap has a cute hack to store both GFP flags and other flag bits in
the one 32 it number per address_space.  'struct address_space' could
afford an extra 32 number I think.

radix_tree_root adds 3 'tag' flags to the gfp_mask.
There is 16bits of free space in radix_tree_node (between 'offset' and
'count').  That space on the root node could store a record of which tags
are set anywhere.  Or would that extra memory de-ref be a killer?

I think we'd end up with cleaner code if we removed the cute-hacks.  And
we'd be able to use 6 more GFP flags!!  (though I do wonder if we really
need all those 26).

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXmC3oAAoJEDnsnt1WYoG5ra4P/i5JZtF5py+6vNFiiZdOoJx1
ZMuitWbsn0b7/fWZslBeOTign4CDKD4SIQE5lbY1NsGUMv6+K9VmTAT0yopFT47U
zdyWQSNnJUh8Y/MCXUdRYD5nxi/tccj9WyGGvSguGOrHNgz0vT2+EN9ve3a7H39r
grQv722jqiQRu2AYYJbL+WX+vSWpHOi3mTasg2f2qYJlAGJ4jNrKsSu4jcnfEdLA
bdk6EY7wuT/6UmF5p+kbRYwlwb5VfVf4S4wFAw5s/8so7ZphxXk6DpGairyqW/CI
Kyex1tdI/8hNBCMYkQYjv5FC4KBHuPzBjNNfkNtLOjDQI78yku3+L6cZA4rGP2F3
BSU8aHQUisyahoSKgyMF0nlHFWcpkVzctCE3NPOjzXrIBLe0xwGs13wxMaVn9R/i
ClC9/7y2z0QqEf075J8j5uvdxsOhVZOrhmD9DSpuZXi+biSC+vBEwghp4Pzeccm1
xpLAdNpUqtd62ztz5ixPklyXdIuL9Z+xkbUjctxPmMYdfTanjENnGkhYlKylvlFN
fXyVpmi93cqneD94tNcS2XTHyArTmytu5S9B4/X79q5FJxO+KHwkBr9qJfoYGpIj
fSmLk+cVk+iZdXRDTyH2Vf7T84hasbXGwugWdrUJEhhoK4zPNIMw97WmbJrqimtk
VTaAa6OQ1Hovk/FSz9qj
=v9wZ
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
