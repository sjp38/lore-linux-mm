Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 5DF0E6B002B
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 17:25:53 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [patch 2/8] mm: vmscan: disregard swappiness shortly before
 going OOM
Date: Thu, 13 Dec 2012 22:25:43 +0000
Message-ID: <8631DC5930FA9E468F04F3FD3A5D007214AD2FA2@USINDEM103.corp.hds.com>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-3-git-send-email-hannes@cmpxchg.org>
 <20121213103420.GW1009@suse.de> <20121213152959.GE21644@dhcp22.suse.cz>
 <20121213160521.GG21644@dhcp22.suse.cz>
In-Reply-To: <20121213160521.GG21644@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


On 12/13/2012 11:05 AM, Michal Hocko wrote:> On Thu 13-12-12 16:29:59, Mich=
al Hocko wrote:
>> On Thu 13-12-12 10:34:20, Mel Gorman wrote:
>>> On Wed, Dec 12, 2012 at 04:43:34PM -0500, Johannes Weiner wrote:
>>>> When a reclaim scanner is doing its final scan before giving up and=20
>>>> there is swap space available, pay no attention to swappiness=20
>>>> preference anymore.  Just swap.
>>>>
>>>> Note that this change won't make too big of a difference for=20
>>>> general
>>>> reclaim: anonymous pages are already force-scanned when there is=20
>>>> only very little file cache left, and there very likely isn't when=20
>>>> the reclaimer enters this final cycle.
>>>>
>>>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>>>
>>> Ok, I see the motivation for your patch but is the block inside=20
>>> still wrong for what you want? After your patch the block looks like=20
>>> this
>>>
>>>                 if (sc->priority || noswap) {
>>>                         scan >>=3D sc->priority;
>>>                         if (!scan && force_scan)
>>>                                 scan =3D SWAP_CLUSTER_MAX;
>>>                         scan =3D div64_u64(scan * fraction[file], denom=
inator);
>>>                 }
>>>
>>> if sc->priority =3D=3D 0 and swappiness=3D=3D0 then you enter this bloc=
k but=20
>>> fraction[0] for anonymous pages will also be 0 and because of the=20
>>> ordering of statements there, scan will be
>>>
>>> scan =3D scan * 0 / denominator
>>>
>>> so you are still not reclaiming anonymous pages in the swappiness=3D0=20
>>> case. What did I miss?
>>
>> Yes, now that you have mentioned that I realized that it really=20
>> doesn't make any sense. fraction[0] is _always_ 0 for swappiness=3D=3D0.=
=20
>> So we just made a bigger pressure on file LRUs. So this sounds like a=20
>> misuse of the swappiness. This all has been introduced with fe35004f=20
>> (mm: avoid swapping out with swappiness=3D=3D0).
>>
>> I think that removing swappiness check make sense but I am not sure=20
>> it does what the changelog says. It should have said that checking=20
>> swappiness doesn't make any sense for small LRUs.
>
> Bahh, wait a moment. Now I remember why the check made sense=20
> especially for memcg.
> It made "don't swap _at all_ for swappiness=3D=3D0" for real - you are=20
> even willing to sacrifice OOM. Maybe this is OK for the global case=20
> because noswap would safe you here (assuming that there is no swap if=20
> somebody doesn't want to swap at all and swappiness doesn't play such=20
> a big role) but for memcg you really might want to prevent from=20
> swapping - not everybody has memcg swap extension enabled and swappiness =
is handy then.
> So I am not sure this is actually what we want. Need to think about it.

I introduced swappiness check here with fe35004f because, in some
cases, we prefer OOM to swap out pages to detect problems as soon
as possible. Basically, we design the system not to swap out and
so if it causes swapping, something goes wrong.

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
