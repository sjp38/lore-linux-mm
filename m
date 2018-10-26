Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD376B0324
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 13:00:21 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id t7-v6so1414856ioc.12
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 10:00:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r8-v6sor2395762ior.19.2018.10.26.10.00.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Oct 2018 10:00:19 -0700 (PDT)
MIME-Version: 1.0
References: <20181023164302.20436-1-guro@fb.com> <20181026085735.GZ18839@dhcp22.suse.cz>
 <20181026155652.GA7647@tower.DHCP.thefacebook.com>
In-Reply-To: <20181026155652.GA7647@tower.DHCP.thefacebook.com>
From: Spock <dairinin@gmail.com>
Date: Fri, 26 Oct 2018 20:00:07 +0300
Message-ID: <CADa=ObqajeQkJA6cR_LXDLT8hrZcFY7kHFxSTFuX=Fg8GkQv1w@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guro@fb.com
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, riel@surriel.com, rdunlap@infradead.org, akpm@linux-foundation.org

=D0=BF=D1=82, 26 =D0=BE=D0=BA=D1=82. 2018 =D0=B3. =D0=B2 18:57, Roman Gushc=
hin <guro@fb.com>:
>
> On Fri, Oct 26, 2018 at 10:57:35AM +0200, Michal Hocko wrote:
> > Spock doesn't seem to be cced here - fixed now
> >
> > On Tue 23-10-18 16:43:29, Roman Gushchin wrote:
> > > Spock reported that the commit 172b06c32b94 ("mm: slowly shrink slabs
> > > with a relatively small number of objects") leads to a regression on
> > > his setup: periodically the majority of the pagecache is evicted
> > > without an obvious reason, while before the change the amount of free
> > > memory was balancing around the watermark.
> > >
> > > The reason behind is that the mentioned above change created some
> > > minimal background pressure on the inode cache. The problem is that
> > > if an inode is considered to be reclaimed, all belonging pagecache
> > > page are stripped, no matter how many of them are there. So, if a hug=
e
> > > multi-gigabyte file is cached in the memory, and the goal is to
> > > reclaim only few slab objects (unused inodes), we still can eventuall=
y
> > > evict all gigabytes of the pagecache at once.
> > >
> > > The workload described by Spock has few large non-mapped files in the
> > > pagecache, so it's especially noticeable.
> > >
> > > To solve the problem let's postpone the reclaim of inodes, which have
> > > more than 1 attached page. Let's wait until the pagecache pages will
> > > be evicted naturally by scanning the corresponding LRU lists, and onl=
y
> > > then reclaim the inode structure.
> >
> > Has this actually fixed/worked around the issue?
>
> Spock wrote this earlier to me directly. I believe I can quote it here:
>
> "Patch applied, looks good so far. System behaves like it was with
> pre-4.18.15 kernels.
> Also tried to add some user-level tests to the geneic background activity=
, like
> - stat'ing a bunch of files
> - streamed read several large files at once on ext4 and XFS
> - random reads on the whole collection with a read size of 16K
>
> I will be monitoring while fragmentation stacks up and report back if
> something bad happens."
>
> Spock, please let me know if you have any new results.
>
> Thanks!

Hello,

I'd say the patch fixed the problem, at least with my workload

MemTotal:        8164968 kB
MemFree:          135852 kB
MemAvailable:    6406088 kB
Buffers:           11988 kB
Cached:          6414124 kB
SwapCached:            0 kB
Active:          1491952 kB
Inactive:        5989576 kB
Active(anon):     542512 kB
Inactive(anon):   523780 kB
Active(file):     949440 kB
Inactive(file):  5465796 kB
Unevictable:        8872 kB
Mlocked:            8872 kB
SwapTotal:       4194300 kB
SwapFree:        4194300 kB
Dirty:               128 kB
Writeback:             0 kB
AnonPages:       1064232 kB
Mapped:            32348 kB
Shmem:              3952 kB
Slab:             205108 kB
SReclaimable:     148792 kB
SUnreclaim:        56316 kB
KernelStack:        3984 kB
PageTables:        11100 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     8276784 kB
Committed_AS:    1944792 kB
VmallocTotal:   34359738367 kB
VmallocUsed:           0 kB
VmallocChunk:          0 kB
AnonHugePages:      6144 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
Hugetlb:               0 kB
DirectMap4k:      271872 kB
DirectMap2M:     8116224 kB
