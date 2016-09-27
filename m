Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC4B28027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:40:29 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so15338781lfb.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:40:29 -0700 (PDT)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.191])
        by mx.google.com with ESMTPS id s132si873609lja.42.2016.09.27.04.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 04:40:27 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] fs/select: add vmalloc fallback for select(2)
Date: Tue, 27 Sep 2016 11:37:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB010A97D@AcuExch.aculab.com>
References: <20160922152831.24165-1-vbabka@suse.cz>
        <006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
        <20160923172434.7ad8f2e0@roar.ozlabs.ibm.com>
        <57E55CBB.5060309@akamai.com>
        <5014387d-43da-03f6-a74b-2dc4fbf4fe32@suse.cz>
 <20160927212458.3ab42b41@roar.ozlabs.ibm.com>
In-Reply-To: <20160927212458.3ab42b41@roar.ozlabs.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Nicholas Piggin' <npiggin@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Jason Baron <jbaron@akamai.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Michal Hocko' <mhocko@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>

From: Nicholas Piggin
> Sent: 27 September 2016 12:25
> On Tue, 27 Sep 2016 10:44:04 +0200
> Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
> > On 09/23/2016 06:47 PM, Jason Baron wrote:
> > > Hi,
> > >
> > > On 09/23/2016 03:24 AM, Nicholas Piggin wrote:
> > >> On Fri, 23 Sep 2016 14:42:53 +0800
> > >> "Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:
> > >>
> > >>>>
> > >>>> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where s=
ize grows
> > >>>> with the number of fds passed. We had a customer report page alloc=
ation
> > >>>> failures of order-4 for this allocation. This is a costly order, s=
o it might
> > >>>> easily fail, as the VM expects such allocation to have a lower-ord=
er fallback.
> > >>>>
> > >>>> Such trivial fallback is vmalloc(), as the memory doesn't have to =
be
> > >>>> physically contiguous. Also the allocation is temporary for the du=
ration of the
> > >>>> syscall, so it's unlikely to stress vmalloc too much.
> > >>>>
> > >>>> Note that the poll(2) syscall seems to use a linked list of order-=
0 pages, so
> > >>>> it doesn't need this kind of fallback.
> > >>
> > >> How about something like this? (untested)
> >
> > This pushes the limit further, but might just delay the problem. Could =
be an
> > optimization on top if there's enough interest, though.
>=20
> What's your customer doing with those selects? If they care at all about
> performance, I doubt they want select to attempt order-4 allocations, fai=
l,
> then use vmalloc :)

If they care about performance they shouldn't be passing select() lists tha=
t
are anywhere near that large.
If the number of actual fd is small - use poll().

Otherwise you want one of the 'event' mechanisms in order to avoid setting
the markers on every fd after every event (can't remember how you do that
in Linux).

At least this isn't SYSV - poll() was O(n^2) in the number of fd
(because the fd were on a linked list).

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
