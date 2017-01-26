Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3E5C6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 04:48:59 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id ez4so38474524wjd.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 01:48:59 -0800 (PST)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.186])
        by mx.google.com with ESMTPS id u5si1325133wru.47.2017.01.26.01.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 01:48:58 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/6 v3] kvmalloc
Date: Thu, 26 Jan 2017 09:48:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB026EB24@AcuExch.aculab.com>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
 <588907AA.1020704@iogearbox.net> <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
In-Reply-To: <5889C331.7020101@iogearbox.net>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Daniel Borkmann' <daniel@iogearbox.net>, Michal Hocko <mhocko@kernel.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "marcelo.leitner@gmail.com" <marcelo.leitner@gmail.com>

From: Daniel Borkmann
> Sent: 26 January 2017 09:37
...
> >> I assume that kvzalloc() is still the same from [1], right? If so, the=
n
> >> it would unfortunately (partially) reintroduce the issue that was fixe=
d.
> >> If you look above at flags, they're also passed to __vmalloc() to not
> >> trigger OOM in these situations I've experienced.
> >
> > Pushing __GFP_NORETRY to __vmalloc doesn't have the effect you might
> > think it would. It can still trigger the OOM killer becauset the flags
> > are no propagated all the way down to all allocations requests (e.g.
> > page tables). This is the same reason why GFP_NOFS is not supported in
> > vmalloc.
>=20
> Ok, good to know, is that somewhere clearly documented (like for the
> case with kmalloc())? If not, could we do that for non-mm folks, or
> at least add a similar WARN_ON_ONCE() as you did for kvmalloc() to make
> it obvious to users that a given flag combination is not supported all
> the way down?

ISTM that requests for the relatively small memory blocks needed for page
tables aren't really likely to invoke the OOM killer when it isn't already
being invoked by other actions. So that isn't really a problem.

More of a problem is that requests that you really don't mind failing
can use the last 'reasonably available' memory.
This will cause the next allocate to fail when it would be better for
the earlier one to fail instead.

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
