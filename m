Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2FCD36B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 21:41:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b65so23454572wmg.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 18:41:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w140si6924814wmw.139.2016.07.21.18.41.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 18:41:44 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Fri, 22 Jul 2016 11:41:34 +1000
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from the reclaim path
In-Reply-To: <20160721145309.GR26379@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <20160719135426.GA31229@cmpxchg.org> <alpine.DEB.2.10.1607191315400.58064@chino.kir.corp.google.com> <20160720081541.GF11249@dhcp22.suse.cz> <alpine.DEB.2.10.1607201353230.22427@chino.kir.corp.google.com> <20160721085202.GC26379@dhcp22.suse.cz> <20160721121300.GA21806@cmpxchg.org> <20160721145309.GR26379@dhcp22.suse.cz>
Message-ID: <87vazy78kx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 22 2016, Michal Hocko wrote:

> On Thu 21-07-16 08:13:00, Johannes Weiner wrote:
>> On Thu, Jul 21, 2016 at 10:52:03AM +0200, Michal Hocko wrote:
>> > Look, there are
>> > $ git grep mempool_alloc | wc -l
>> > 304
>> >=20
>> > many users of this API and we do not want to flip the default behavior
>> > which is there for more than 10 years. So far you have been arguing
>> > about potential deadlocks and haven't shown any particular path which
>> > would have a direct or indirect dependency between mempool and normal
>> > allocator and it wouldn't be a bug. As the matter of fact the change
>> > we are discussing here causes a regression. If you want to change the
>> > semantic of mempool allocator then you are absolutely free to do so. In
>> > a separate patch which would be discussed with IO people and other
>> > users, though. But we _absolutely_ want to fix the regression first
>> > and have a simple fix for 4.6 and 4.7 backports. At this moment there
>> > are revert and patch 1 on the table.  The later one should make your
>> > backtrace happy and should be only as a temporal fix until we find out
>> > what is actually misbehaving on your systems. If you are not interested
>> > to pursue that way I will simply go with the revert.
>>=20
>> +1
>>=20
>> It's very unlikely that decade-old mempool semantics are suddenly a
>> fundamental livelock problem, when all the evidence we have is one
>> hang and vague speculation. Given that the patch causes regressions,
>> and that the bug is most likely elsewhere anyway, a full revert rather
>> than merely-less-invasive mempool changes makes the most sense to me.
>
> OK, fair enough. What do you think about the following then? Mikulas, I
> have dropped your Tested-by and Reviewed-by because the patch is
> different but unless you have hit the OOM killer then the testing
> results should be same.
> ---
> From d64815758c212643cc1750774e2751721685059a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 21 Jul 2016 16:40:59 +0200
> Subject: [PATCH] Revert "mm, mempool: only set __GFP_NOMEMALLOC if there =
are
>  free elements"
>
> This reverts commit f9054c70d28bc214b2857cf8db8269f4f45a5e23.
>
> There has been a report about OOM killer invoked when swapping out to
> a dm-crypt device. The primary reason seems to be that the swapout
> out IO managed to completely deplete memory reserves. Ondrej was
> able to bisect and explained the issue by pointing to f9054c70d28b
> ("mm, mempool: only set __GFP_NOMEMALLOC if there are free elements").
>
> The reason is that the swapout path is not throttled properly because
> the md-raid layer needs to allocate from the generic_make_request path
> which means it allocates from the PF_MEMALLOC context. dm layer uses
> mempool_alloc in order to guarantee a forward progress which used to
> inhibit access to memory reserves when using page allocator. This has
> changed by f9054c70d28b ("mm, mempool: only set __GFP_NOMEMALLOC if
> there are free elements") which has dropped the __GFP_NOMEMALLOC
> protection when the memory pool is depleted.
>
> If we are running out of memory and the only way forward to free memory
> is to perform swapout we just keep consuming memory reserves rather than
> throttling the mempool allocations and allowing the pending IO to
> complete up to a moment when the memory is depleted completely and there
> is no way forward but invoking the OOM killer. This is less than
> optimal.
>
> The original intention of f9054c70d28b was to help with the OOM
> situations where the oom victim depends on mempool allocation to make a
> forward progress. David has mentioned the following backtrace:
>
> schedule
> schedule_timeout
> io_schedule_timeout
> mempool_alloc
> __split_and_process_bio
> dm_request
> generic_make_request
> submit_bio
> mpage_readpages
> ext4_readpages
> __do_page_cache_readahead
> ra_submit
> filemap_fault
> handle_mm_fault
> __do_page_fault
> do_page_fault
> page_fault
>
> We do not know more about why the mempool is depleted without being
> replenished in time, though. In any case the dm layer shouldn't depend
> on any allocations outside of the dedicated pools so a forward progress
> should be guaranteed. If this is not the case then the dm should be
> fixed rather than papering over the problem and postponing it to later
> by accessing more memory reserves.
>
> mempools are a mechanism to maintain dedicated memory reserves to guaratee
> forward progress. Allowing them an unbounded access to the page allocator
> memory reserves is going against the whole purpose of this mechanism.
>
> Bisected-by: Ondrej Kozina <okozina@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/mempool.c | 20 ++++----------------
>  1 file changed, 4 insertions(+), 16 deletions(-)
>
> diff --git a/mm/mempool.c b/mm/mempool.c
> index 8f65464da5de..5ba6c8b3b814 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -306,36 +306,25 @@ EXPORT_SYMBOL(mempool_resize);
>   * returns NULL. Note that due to preallocation, this function
>   * *never* fails when called from process contexts. (it might
>   * fail if called from an IRQ context.)
> - * Note: neither __GFP_NOMEMALLOC nor __GFP_ZERO are supported.
> + * Note: using __GFP_ZERO is not supported.
>   */
> -void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
> +void * mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>  {
>  	void *element;
>  	unsigned long flags;
>  	wait_queue_t wait;
>  	gfp_t gfp_temp;
>=20=20
> -	/* If oom killed, memory reserves are essential to prevent livelock */
> -	VM_WARN_ON_ONCE(gfp_mask & __GFP_NOMEMALLOC);
> -	/* No element size to zero on allocation */
>  	VM_WARN_ON_ONCE(gfp_mask & __GFP_ZERO);
> -
>  	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
>=20=20
> +	gfp_mask |=3D __GFP_NOMEMALLOC;	/* don't allocate emergency reserves */
>  	gfp_mask |=3D __GFP_NORETRY;	/* don't loop in __alloc_pages */
>  	gfp_mask |=3D __GFP_NOWARN;	/* failures are OK */

As I was reading through this thread I kept thinking "Surely
mempool_alloc() should never ever allocate from emergency reserves.
Ever."
Then I saw this patch.  It made me happy.

Thanks.

Acked-by: NeilBrown <neilb@suse.com>
(if you want it)

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXkXnOAAoJEDnsnt1WYoG5fnkP/0GxjTDVoHAcht/8o2WLlXpb
lIcB20GYPsc/XujGOGSn/v5MbrGINEa6XTF1FHuorQFAAvbdVA6GBmffJY36HUDG
1ZvdfN81ctUayVuqmj9YerYs5ITEqFzTHZNyuPdb10HndEzwDw44ER50aacYc9WU
dBYl5NA7ms6JigsA1ust337CA73itBZceANWelyAfIa9REw3Candnkdk001Apwxj
hvT0hQJnENauyQTUg82fRaC4//Np1iXHX6Sjnq77oDEfR5AaIx6ONPGZKxk8ctNi
u5xvXV7b7btAxKSMy/fQekinKgGPFxCnlY6OgtM6HYxqLfRGNkV3fKgvtWx+8mAM
boLMfsQu9gbmawlapTQuNezE4iBMI0uwD89Gx9pMspUtNJIcG9WgwO+vnB/7la0A
L6fXejMf971xHKUXDfQNZ2lHSHG4Ul2cfamc3C78XAo6Y1/bnHJ1FRNJU48pUypN
tzo3cNftS9tFnsEQGI92jmqX/6UaT1laHVFQ4Fefn7IOeK87FaEFWVG/fnpD4WnV
TjflTfZjBEP+ieq8fwYODoD47yTvGOeZP33XAQRo043yEv0EK5FjKRzfmlGP0b57
mr7pf4zI/sGDjS0CI6X0rV4TTFcgTC+iLySvg2TOSwJNIKxeETrNbTvlfy5o4aeE
GRmUnA7NWP3ZZUWszWI8
=dIDo
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
