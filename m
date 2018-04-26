Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFBE6B0007
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 14:59:01 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id e12-v6so20919424qtp.17
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 11:59:01 -0700 (PDT)
Received: from mail.stoffel.org (mail.stoffel.org. [104.236.43.127])
        by mx.google.com with ESMTPS id m15-v6si8485114qtm.248.2018.04.26.11.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Apr 2018 11:59:00 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Message-ID: <23266.8532.619051.784274@quad.stoffel.home>
Date: Thu, 26 Apr 2018 14:58:28 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
In-Reply-To: <1524697697.4100.23.camel@HansenPartnership.com>
References: <20180421144757.GC14610@bombadil.infradead.org>
	<alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
	<20180423151545.GU17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
	<20180424125121.GA17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com>
	<20180424162906.GM17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>
	<20180424170349.GQ17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>
	<20180424173836.GR17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
	<1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
	<alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>
	<alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
	<1524694663.4100.21.camel@HansenPartnership.com>
	<alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com>
	<1524697697.4100.23.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Michal@stoffel.org, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Hocko <mhocko@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>, Andrew@stoffel.org, David Rientjes <rientjes@google.com>, Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, edumazet@google.com

>>>>> "James" =3D=3D James Bottomley <James.Bottomley@HansenPartnership=
.com> writes:

James> On Wed, 2018-04-25 at 19:00 -0400, Mikulas Patocka wrote:
>>=20
>> On Wed, 25 Apr 2018, James Bottomley wrote:
>>=20
>> > > > Do we really need the new config option?=A0=A0This could just =
be
>> > > > manually=A0 tunable via fault injection IIUC.
>> > >=A0
>> > > We do, because we want to enable it in RHEL and Fedora debugging=

>> > > kernels,=A0so that it will be tested by the users.
>> > >=A0
>> > > The users won't use some extra magic kernel options or debugfs
>> files.
>> >=A0
>> > If it can be enabled via a tunable, then the distro can turn it on=

>> > without the user having to do anything.=A0 If you want to present =
the
>> > user with a different boot option, you can (just have the tunable
>> set
>> > on the command line), but being tunable driven means that you don'=
t
>> > have to choose that option, you could automatically enable it unde=
r
>> a
>> > range of circumstances.=A0 I think most sane distributions would w=
ant
>> > that flexibility.
>> >=A0
>> > Kconfig proliferation, conversely, is a bit of a nightmare from
>> both
>> > the user and the tester's point of view, so we're trying to avoid
>> it
>> > unless absolutely necessary.
>> >=A0
>> > James
>>=20
>> BTW. even developers who compile their own kernel should have this
>> enabled=A0by a CONFIG option - because if the developer sees the opt=
ion
>> when=A0browsing through menuconfig, he may enable it. If he doesn't =
see
>> the=A0option, he won't even know that such an option exists.

James> I may be an atypical developer but I'd rather have a root canal
James> than browse through menuconfig options.  The way to get people
James> to learn about new debugging options is to blog about it (or
James> write an lwn.net article) which google will find the next time
James> I ask it how I debug XXX.  Google (probably as a service to
James> humanity) rarely turns up Kconfig options in response to a
James> query.

I agree with James here.  Looking at the SLAB vs SLUB Kconfig entries
tells me *nothing* about why I should pick one or the other, as an
example.

John
