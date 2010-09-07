Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1DFF46B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 04:37:28 -0400 (EDT)
Received: by iwn33 with SMTP id 33so6893056iwn.14
        for <linux-mm@kvack.org>; Tue, 07 Sep 2010 01:37:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100907114505.fc40ea3d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100907114505.fc40ea3d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 7 Sep 2010 01:37:27 -0700
Message-ID: <AANLkTintQqzx50Jp_zyKQMaAfhSEFah3HhseNmNfNMjB@mail.gmail.com>
Subject: Re: [RFC][PATCH] big continuous memory allocator v2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Nice cleanup.
There are some comments in below.

On Mon, Sep 6, 2010 at 7:45 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> This is a page allcoator based on memory migration/hotplug code.
> passed some small tests, and maybe easier to read than previous one.
>
> =3D=3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> This patch as a memory allocator for contiguous memory larger than MAX_OR=
DER.
>
> =A0alloc_contig_pages(hint, size, node);

I have thought this patch is to be good for dumb device drivers which
want big contiguous
memory. So if some device driver want big memory and they can tolerate
latency or fail,
this is good solution, I think.
And some device driver can't tolerate fail, they have to use MOVABLE zone.

For it, I hope we have a option like ALLOC_FIXED(like MAP_FIXED).
That's because embedded people wanted to aware BANK of memory.
So if they get free page which they don't want, it can be pointless.

In addition, I hope it can support CROSS_ZONE migration mode.
Most of small system can't support swap system. So if we can't migrate
anon pages into other zones, external fragment problem still happens.

I think reclaim(ex, discard file-backed pages) can become one option to pre=
vent
the problem. But it's more cost so we can support it by calling mode.
(But it could be trivial since caller should know this function is very cos=
t)

ex) alloc_contig_pages(hint, size, node, ALLOC_FIXED|ALLOC_RECLAIM);


Thanks, Kame.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
