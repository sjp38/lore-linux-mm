Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3CE6B007E
	for <linux-mm@kvack.org>; Thu,  5 May 2016 13:25:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so179549265pfz.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 10:25:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id f5si12436558pay.191.2016.05.05.10.25.11
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 10:25:11 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: mm: pages are not freed from lru_add_pvecs after process
 termination
Date: Thu, 5 May 2016 17:25:07 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023C3C4B@IRSMSX103.ger.corp.intel.com>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
In-Reply-To: <20160505072122.GA4386@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Thu 05-05-16 09:21:00, Michal Hocko wrote:=20
> OK, it wasn't that tricky afterall. Maybe I have missed something but
> the following should work. Or maybe the async nature of flushing turns
> out to be just impractical and unreliable and we will end up skipping
> THP (or all compound pages) for pcp LRU add cache. Let's see...

Initially this issue was found on RH's 3.10.x kernel, but now I am using=20
4.6-rc6.

In overall it does help and under heavy load it is slightly better than the
second patch. Unfortunately I am still able to hit 10-20% oom kills with it=
 -
(went down from 30-50%) partially due to earlier vmstat_update call
 - it went up to 25-25% with this patch below:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b4359f8..7a5ab0d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3264,17 +3264,17 @@ retry:
        if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
                migration_mode =3D MIGRATE_SYNC_LIGHT;

-       if(!vmstat_updated) {
-               vmstat_updated =3D true;
-               kick_vmstat_update();
-       }
-
        /* Try direct reclaim and then allocating */
        page =3D __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags,=
 ac,
                                                        &did_some_progress)=
;
        if (page)
                goto got_pg;

+       if(!vmstat_updated) {
+               vmstat_updated =3D true;
+               kick_vmstat_update();
+       }

I don't quite see an uninvasive way to make sure that we drain all pvecs
before failing allocation and doing it asynchronously will race allocations
anyway - I guess.

Thanks,
Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
