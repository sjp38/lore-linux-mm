Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 414E86B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 16:25:16 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so2075151ier.26
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 13:25:16 -0700 (PDT)
Received: from fujitsu25.fnanic.fujitsu.com (fujitsu25.fnanic.fujitsu.com. [192.240.6.15])
        by mx.google.com with ESMTPS id hs3si5404277igb.51.2014.06.25.13.25.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 13:25:15 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Wed, 25 Jun 2014 13:25:00 -0700
Subject: RE: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo()
 interfaces
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E341D5854F7@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <4b46c5b21263c446923caf3da3f0dca6febc7b55.1403709665.git.aquini@redhat.com>
 <6B2BA408B38BA1478B473C31C3D2074E341D585464@SV-EXCHANGE1.Corp.FC.LOCAL>
In-Reply-To: <6B2BA408B38BA1478B473C31C3D2074E341D585464@SV-EXCHANGE1.Corp.FC.LOCAL>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Rafael Aquini <aquini@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



> -----Original Message-----
> From: Motohiro.Kosaki@us.fujitsu.com [mailto:Motohiro.Kosaki@us.fujitsu.c=
om]
> Sent: Wednesday, June 25, 2014 3:41 PM
> To: Rafael Aquini; linux-mm@kvack.org
> Cc: Andrew Morton; Rik van Riel; Mel Gorman; Johannes Weiner; Motohiro Ko=
saki JP; linux-kernel@vger.kernel.org
> Subject: RE: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo() in=
terfaces
>=20
>=20
>=20
> > -----Original Message-----
> > From: Rafael Aquini [mailto:aquini@redhat.com]
> > Sent: Wednesday, June 25, 2014 2:40 PM
> > To: linux-mm@kvack.org
> > Cc: Andrew Morton; Rik van Riel; Mel Gorman; Johannes Weiner; Motohiro
> > Kosaki JP; linux-kernel@vger.kernel.org
> > Subject: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo()
> > interfaces
> >
> > This patch leverages the addition of explicit accounting for pages
> > used by shmem/tmpfs -- "4b02108 mm: oom analysis: add shmem vmstat" --
> > in order to make the users of sysinfo(2) and si_meminfo*() friends awar=
e of that vmstat entry consistently across the interfaces.
>=20
> Why?
> Traditionally sysinfo.sharedram was not used for shmem. It was totally st=
range semantics and completely outdated feature.
> So, we may reuse it for another purpose. But I'm not sure its benefit.
>=20
> Why don't you use /proc/meminfo?
> I'm afraid userland programs get a confusion.

For the record. This is historical implementation at linux-2.3.12. I.e. acc=
ount sum of page count.


void si_meminfo(struct sysinfo *val)
{
        int i;

        i =3D max_mapnr;
        val->totalram =3D 0;
        val->sharedram =3D 0;
        val->freeram =3D nr_free_pages << PAGE_SHIFT;
        val->bufferram =3D atomic_read(&buffermem);
        while (i-- > 0)  {
                if (PageReserved(mem_map+i))
                        continue;
                val->totalram++;
                if (!page_count(mem_map+i))
                        continue;
                val->sharedram +=3D page_count(mem_map+i) - 1;
        }
        val->totalram <<=3D PAGE_SHIFT;
        val->sharedram <<=3D PAGE_SHIFT;
        return;
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
