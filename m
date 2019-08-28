Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6C89C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 18:45:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64D8F208C2
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 18:45:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="jfuvoZov"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64D8F208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E13C46B0005; Wed, 28 Aug 2019 14:45:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEB026B000C; Wed, 28 Aug 2019 14:45:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D02816B000D; Wed, 28 Aug 2019 14:45:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0014.hostedemail.com [216.40.44.14])
	by kanga.kvack.org (Postfix) with ESMTP id AFB036B0005
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:45:08 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4FE86824CA24
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 18:45:08 +0000 (UTC)
X-FDA: 75872713896.16.run86_8423e493a6b3f
X-HE-Tag: run86_8423e493a6b3f
X-Filterd-Recvd-Size: 5813
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com [54.240.9.34])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 18:45:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1567017907;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=fJm0E0W8D/Ih72kYyGNG7xR38hRVhDF2+dGEhyCLpNo=;
	b=jfuvoZovM5la8e5cNSplwMxmwZS/RBqS1wOZQJXGe9DNLIYMj6qyuUXkj9vP1t4V
	TTY8HsoyS11RSsbJiIbcvr/I97cjjAXSpwxxCI0LUZQ9vs5Ukl1F2BJ2hCc8jiwT+mf
	Ev2y1vC/94piZjsxt9npj2LnwOHeeE3wIb9bT/aE=
Date: Wed, 28 Aug 2019 18:45:07 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Vlastimil Babka <vbabka@suse.cz>
cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Ming Lei <ming.lei@redhat.com>, 
    Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>, 
    Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, 
    James Bottomley <James.Bottomley@HansenPartnership.com>, 
    linux-btrfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] mm, sl[aou]b: guarantee natural alignment for
 kmalloc(power-of-two)
In-Reply-To: <20190826111627.7505-3-vbabka@suse.cz>
Message-ID: <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com>
References: <20190826111627.7505-1-vbabka@suse.cz> <20190826111627.7505-3-vbabka@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8323329-457157129-1567017905=:17409"
X-SES-Outgoing: 2019.08.28-54.240.9.34
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-457157129-1567017905=:17409
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, 26 Aug 2019, Vlastimil Babka wrote:

> The topic has been discussed at LSF/MM 2019 [3]. Adding a 'kmalloc_alig=
ned()'
> variant would not help with code unknowingly relying on the implicit al=
ignment.
> For slab implementations it would either require creating more kmalloc =
caches,
> or allocate a larger size and only give back part of it. That would be
> wasteful, especially with a generic alignment parameter (in contrast wi=
th a
> fixed alignment to size).

The additional caches will be detected if similar to existing ones and
merged into one. So the overhead is not that significant.

> Ideally we should provide to mm users what they need without difficult
> workarounds or own reimplementations, so let's make the kmalloc() align=
ment to
> size explicitly guaranteed for power-of-two sizes under all configurati=
ons.

The objection remains that this will create exceptions for the general
notion that all kmalloc caches are aligned to KMALLOC_MINALIGN which may
be suprising and it limits the optimizations that slab allocators may use
for optimizing data use. The SLOB allocator was designed in such a way
that data wastage is limited. The changes here sabotage that goal and sho=
w
that future slab allocators may be similarly constrained with the
exceptional alignents implemented. Additional debugging features etc etc
must all support the exceptional alignment requirements.

> * SLUB layout is also unchanged unless redzoning is enabled through
>   CONFIG_SLUB_DEBUG and boot parameter for the particular kmalloc cache=
. With
>   this patch, explicit alignment is guaranteed with redzoning as well. =
This
>   will result in more memory being wasted, but that should be acceptabl=
e in a
>   debugging scenario.

Well ok. That sounds fine (apart from breaking the rules for slab object
alignment).

> * SLOB has no implicit alignment so this patch adds it explicitly for
>   kmalloc(). The potential downside is increased fragmentation. While
>   pathological allocation scenarios are certainly possible, in my testi=
ng,
>   after booting a x86_64 kernel+userspace with virtme, around 16MB memo=
ry
>   was consumed by slab pages both before and after the patch, with diff=
erence
>   in the noise.

This change to slob will cause a significant additional use of memory. Th=
e
advertised advantage of SLOB is that *minimal* memory will be used since
it is targeted for embedded systems. Different types of slab objects of
varying sizes can be allocated in the same memory page to reduce
allocation overhead.

Having these exceptional rules for aligning power of two sizes caches
will significantly increase the memory wastage in SLOB.

The result of this patch is just to use more memory to be safe from
certain pathologies where one subsystem was relying on an alignment that
was not specified. That is why this approach should not be called
=EF=BF=BDnatural" but "implicit alignment". The one using the slab cache =
is not
aware that the slab allocator provides objects aligned in a special way
(which is in general not needed. There seems to be a single pathological
case that needs to be addressed and I thought that was due to some
brokenness in the hardware?).

It is better to ensure that subsystems that require special alignment
explicitly tell the allocator about this.

I still think implicit exceptions to alignments are a bad idea. Those nee=
d
to be explicity specified and that is possible using kmem_cache_create().


--8323329-457157129-1567017905=:17409--

