Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAF56B005A
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 15:56:56 -0400 (EDT)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id n6UJtlwh026172
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 20:55:48 +0100
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by spaceape7.eur.corp.google.com with ESMTP id n6UJtieo008577
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 12:55:45 -0700
Received: by pzk5 with SMTP id 5so1150132pzk.23
        for <linux-mm@kvack.org>; Thu, 30 Jul 2009 12:55:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090730040803.GA20652@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
	 <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
	 <20090729114322.GA9335@localhost>
	 <33307c790907290711s320607b0i79c939104d4c2d61@mail.gmail.com>
	 <20090730010630.GA7326@localhost>
	 <33307c790907291812j40146a96tc2e9c5e097a33615@mail.gmail.com>
	 <20090730015754.GC7326@localhost>
	 <33307c790907291959r47b1bd3ap7cfa06fd5154aaad@mail.gmail.com>
	 <20090730040803.GA20652@localhost>
Date: Thu, 30 Jul 2009 12:55:44 -0700
Message-ID: <33307c790907301255j136e003dtac0e4ba2032e890e@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Rubin <mrubin@google.com>, "sandeen@redhat.com" <sandeen@redhat.com>, Michael Davidson <md@google.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

> Note that this is a simple fix that may have suboptimal write performance=
.
> Here is an old reasoning:
>
> =A0 =A0 =A0 =A0http://lkml.org/lkml/2009/3/28/235

The other thing I've been experimenting with is to disable the per-page
check in write_cache_pages, ie:

                        if (wbc->nonblocking && bdi_write_congested(bdi)) {
                                wb_stats_inc(WB_STATS_WCP_SECTION_CONG);
                                wbc->encountered_congestion =3D 1;
                                /* done =3D 1; */

This treats the congestion limits as soft, but encourages us to write
back in larger, more efficient chunks. If that's not going to scare
people unduly, I can submit that as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
