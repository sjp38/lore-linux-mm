Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id D42156B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 15:41:48 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so2150817igb.5
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 12:41:48 -0700 (PDT)
Received: from fujitsu25.fnanic.fujitsu.com (fujitsu25.fnanic.fujitsu.com. [192.240.6.15])
        by mx.google.com with ESMTPS id wl19si7535985icb.28.2014.06.25.12.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 12:41:48 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Wed, 25 Jun 2014 12:41:17 -0700
Subject: RE: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo()
 interfaces
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E341D585464@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <4b46c5b21263c446923caf3da3f0dca6febc7b55.1403709665.git.aquini@redhat.com>
In-Reply-To: <4b46c5b21263c446923caf3da3f0dca6febc7b55.1403709665.git.aquini@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



> -----Original Message-----
> From: Rafael Aquini [mailto:aquini@redhat.com]
> Sent: Wednesday, June 25, 2014 2:40 PM
> To: linux-mm@kvack.org
> Cc: Andrew Morton; Rik van Riel; Mel Gorman; Johannes Weiner; Motohiro Ko=
saki JP; linux-kernel@vger.kernel.org
> Subject: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo() interf=
aces
>=20
> This patch leverages the addition of explicit accounting for pages used b=
y shmem/tmpfs -- "4b02108 mm: oom analysis: add shmem
> vmstat" -- in order to make the users of sysinfo(2) and si_meminfo*() fri=
ends aware of that vmstat entry consistently across the
> interfaces.

Why?
Traditionally sysinfo.sharedram was not used for shmem. It was totally stra=
nge semantics and completely outdated feature.=20
So, we may reuse it for another purpose. But I'm not sure its benefit.=20

Why don't you use /proc/meminfo?
I'm afraid userland programs get a confusion.=20


>=20
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  drivers/base/node.c | 2 +-
>  fs/proc/meminfo.c   | 2 +-
>  mm/page_alloc.c     | 3 ++-
>  3 files changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/base/node.c b/drivers/base/node.c index 8f7ed99..c6d=
3ae0 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -126,7 +126,7 @@ static ssize_t node_read_meminfo(struct device *dev,
>  		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
>  		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
>  		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
> -		       nid, K(node_page_state(nid, NR_SHMEM)),
> +		       nid, K(i.sharedram),
>  		       nid, node_page_state(nid, NR_KERNEL_STACK) *
>  				THREAD_SIZE / 1024,
>  		       nid, K(node_page_state(nid, NR_PAGETABLE)), diff --git a/fs/pro=
c/meminfo.c b/fs/proc/meminfo.c index
> 7445af0..aa1eee0 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -168,7 +168,7 @@ static int meminfo_proc_show(struct seq_file *m, void=
 *v)
>  		K(global_page_state(NR_WRITEBACK)),
>  		K(global_page_state(NR_ANON_PAGES)),
>  		K(global_page_state(NR_FILE_MAPPED)),
> -		K(global_page_state(NR_SHMEM)),
> +		K(i.sharedram),
>  		K(global_page_state(NR_SLAB_RECLAIMABLE) +
>  				global_page_state(NR_SLAB_UNRECLAIMABLE)),
>  		K(global_page_state(NR_SLAB_RECLAIMABLE)),
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c index 20d17f8..f72ea38 100=
644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3040,7 +3040,7 @@ static inline void show_node(struct zone *zone)  vo=
id si_meminfo(struct sysinfo *val)  {
>  	val->totalram =3D totalram_pages;
> -	val->sharedram =3D 0;
> +	val->sharedram =3D global_page_state(NR_SHMEM);
>  	val->freeram =3D global_page_state(NR_FREE_PAGES);
>  	val->bufferram =3D nr_blockdev_pages();
>  	val->totalhigh =3D totalhigh_pages;
> @@ -3060,6 +3060,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
>  	for (zone_type =3D 0; zone_type < MAX_NR_ZONES; zone_type++)
>  		managed_pages +=3D pgdat->node_zones[zone_type].managed_pages;
>  	val->totalram =3D managed_pages;
> +	val->sharedram =3D node_page_state(nid, NR_SHMEM);
>  	val->freeram =3D node_page_state(nid, NR_FREE_PAGES);  #ifdef CONFIG_HI=
GHMEM
>  	val->totalhigh =3D pgdat->node_zones[ZONE_HIGHMEM].managed_pages;
> --
> 1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
