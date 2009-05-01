Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0CBDA6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 07:46:42 -0400 (EDT)
Message-ID: <49FAE12F.4020005@cosmosbay.com>
Date: Fri, 01 May 2009 13:46:55 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils> <20090430132544.GB21997@csn.ul.ie> <Pine.LNX.4.64.0905011202530.8513@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0905011202530.8513@blonde.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins a =E9crit :
> On Thu, 30 Apr 2009, Mel Gorman wrote:
>> On Wed, Apr 29, 2009 at 10:09:48PM +0100, Hugh Dickins wrote:
>>> On an x86_64 with 4GB ram, tcp_init()'s call to alloc_large_system_ha=
sh(),
>>> to allocate tcp_hashinfo.ehash, is now triggering an mmotm WARN_ON_ON=
CE on
>>> order >=3D MAX_ORDER - it's hoping for order 11.  alloc_large_system_=
hash()
>>> had better make its own check on the order.

Well, I dont know why, since alloc_large_system_hash() already take
care of retries, halving size between each tries.

>>>
>>> Signed-off-by: Hugh Dickins <hugh@veritas.com>
>> Looks good
>>
>> Reviewed-by: Mel Gorman <mel@csn.ul.ie>
>=20
> Thanks.
>=20
>> As I was looking there, it seemed that alloc_large_system_hash() shoul=
d be
>> using alloc_pages_exact() instead of having its own "give back the spa=
re
>> pages at the end of the buffer" logic. If alloc_pages_exact() was used=
, then
>> the check for an order >=3D MAX_ORDER can be pushed down to alloc_page=
s_exact()
>> where it may catch other unwary callers.
>>
>> How about adding the following patch on top of yours?
>=20
> Well observed, yes indeed.  In fact, it even looks as if, shock horror,=

> alloc_pages_exact() was _plagiarized_ from alloc_large_system_hash().
> Blessed be the GPL, I'm sure we can skip the lengthy lawsuits!

As a matter of fact, I was planning to call my lawyer, so I'll reconsider=

this and save some euros, thanks !

;)

It makes sense to use a helper function if it already exist, of course !

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
