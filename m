Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1A76B031F
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 11:57:20 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id w6-v6so1428570qka.15
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 08:57:20 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f23-v6si634097qvd.124.2018.10.26.08.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 08:57:19 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Date: Fri, 26 Oct 2018 15:56:55 +0000
Message-ID: <20181026155652.GA7647@tower.DHCP.thefacebook.com>
References: <20181023164302.20436-1-guro@fb.com>
 <20181026085735.GZ18839@dhcp22.suse.cz>
In-Reply-To: <20181026085735.GZ18839@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F06829E07D1E6740BB7B73B6C40FC021@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Rik van
 Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "dairinin@gmail.com" <dairinin@gmail.com>

On Fri, Oct 26, 2018 at 10:57:35AM +0200, Michal Hocko wrote:
> Spock doesn't seem to be cced here - fixed now
>=20
> On Tue 23-10-18 16:43:29, Roman Gushchin wrote:
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
> Has this actually fixed/worked around the issue?

Spock wrote this earlier to me directly. I believe I can quote it here:

"Patch applied, looks good so far. System behaves like it was with
pre-4.18.15 kernels.
Also tried to add some user-level tests to the geneic background activity, =
like
- stat'ing a bunch of files
- streamed read several large files at once on ext4 and XFS
- random reads on the whole collection with a read size of 16K

I will be monitoring while fragmentation stacks up and report back if
something bad happens."

Spock, please let me know if you have any new results.

Thanks!
