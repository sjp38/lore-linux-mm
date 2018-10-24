Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCBB26B0008
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 19:51:35 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 7-v6so7352724qtx.6
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 16:51:35 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p33-v6si3384829qtd.311.2018.10.24.16.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 16:51:35 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Date: Wed, 24 Oct 2018 23:51:07 +0000
Message-ID: <20181024235101.GB15663@castle.DHCP.thefacebook.com>
References: <20181023164302.20436-1-guro@fb.com>
 <20181024151950.36fe2c41957d807756f587ca@linux-foundation.org>
In-Reply-To: <20181024151950.36fe2c41957d807756f587ca@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <79CFF4DBB7966C44A8429A0EEE6994C0@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Michal
 Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>

On Wed, Oct 24, 2018 at 03:19:50PM -0700, Andrew Morton wrote:
> On Tue, 23 Oct 2018 16:43:29 +0000 Roman Gushchin <guro@fb.com> wrote:
>=20
> > Spock reported that the commit 172b06c32b94 ("mm: slowly shrink slabs
> > with a relatively small number of objects") leads to a regression on
> > his setup: periodically the majority of the pagecache is evicted
> > without an obvious reason, while before the change the amount of free
> > memory was balancing around the watermark.
> >=20
> > The reason behind is that the mentioned above change created some
> > minimal background pressure on the inode cache. The problem is that
> > if an inode is considered to be reclaimed, all belonging pagecache
> > page are stripped, no matter how many of them are there. So, if a huge
> > multi-gigabyte file is cached in the memory, and the goal is to
> > reclaim only few slab objects (unused inodes), we still can eventually
> > evict all gigabytes of the pagecache at once.
> >=20
> > The workload described by Spock has few large non-mapped files in the
> > pagecache, so it's especially noticeable.
> >=20
> > To solve the problem let's postpone the reclaim of inodes, which have
> > more than 1 attached page. Let's wait until the pagecache pages will
> > be evicted naturally by scanning the corresponding LRU lists, and only
> > then reclaim the inode structure.
>=20
> Is this regression serious enough to warrant fixing 4.19.1?

I'd give it some testing in the mm tree (and I'll test it by myself
on our fleet), and then backport to 4.19.x.

Thanks!
