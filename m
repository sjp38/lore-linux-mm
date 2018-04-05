Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C93F96B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 00:16:56 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id h2so18116804uae.1
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 21:16:56 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k3si2581603uan.392.2018.04.04.21.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 21:16:55 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
In-Reply-To: <20180403211253.GC30145@bombadil.infradead.org>
Date: Wed, 4 Apr 2018 21:08:15 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <A3DE5382-B5AA-4E6F-9E78-55CE6132CF71@oracle.com>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
 <20180403133115.GA5501@dhcp22.suse.cz>
 <20180403190759.GB6779@bombadil.infradead.org>
 <A1EF8129-7F59-49CB-BEEC-E615FB878CE2@oracle.com>
 <20180403211253.GC30145@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, akpm@linux-foundation.org


> On Apr 3, 2018, at 2:12 PM, Matthew Wilcox <willy@infradead.org> =
wrote:
>=20
> On Tue, Apr 03, 2018 at 01:49:25PM -0700, Buddy Lumpkin wrote:
>>> Yes, very much this.  If you have a single-threaded workload which =
is
>>> using the entirety of memory and would like to use even more, then =
it
>>> makes sense to use as many CPUs as necessary getting memory out of =
its
>>> way.  If you have N CPUs and N-1 threads happily occupying =
themselves in
>>> their own reasonably-sized working sets with one monster process =
trying
>>> to use as much RAM as possible, then I'd be pretty unimpressed to =
see
>>> the N-1 well-behaved threads preempted by kswapd.
>>=20
>> The default value provides one kswapd thread per NUMA node, the same
>> it was without the patch. Also, I would point out that just because =
you devote
>> more threads to kswapd, doesn=E2=80=99t mean they are busy. If =
multiple kswapd threads
>> are busy, they are almost certainly doing work that would have =
resulted in
>> direct reclaims, which are often substantially more expensive than a =
couple
>> extra context switches due to preemption.
>=20
> [...]
>=20
>> In my previous response to Michal Hocko, I described
>> how I think we could scale watermarks in response to direct reclaims, =
and
>> launch more kswapd threads when kswapd peaks at 100% CPU usage.
>=20
> I think you're missing my point about the workload ... kswapd isn't
> "nice", so it will compete with the N-1 threads which are chugging =
along
> at 100% CPU inside their working sets.  In this scenario, we _don't_
> want to kick off kswapd at all; we want the monster thread to clean up
> its own mess.  If we have idle CPUs, then yes, absolutely, lets have
> them clean up for the monster, but otherwise, I want my N-1 threads
> doing their own thing.
>=20
> Maybe we should renice kswapd anyway ... thoughts?  We don't seem to =
have
> had a nice'd kswapd since 2.6.12, but maybe we played with that =
earlier
> and discovered it was a bad idea?
>=20


Trying to distinguish between the monster and a high value task that you =
want
to run as quickly as possible would be challenging. I like your idea of =
using
renice. It probably makes sense to continue to run the first thread on =
each node
at a standard nice value, and run each additional task with a positive =
nice value.
