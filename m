Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6A5830B2
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 14:23:56 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id uo6so63233279pac.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 11:23:56 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 10si9039266pfb.71.2016.02.07.11.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 11:23:55 -0800 (PST)
From: Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 2/2] mm: memcontrol: drop unnecessary lru locking from
 mem_cgroup_migrate()
Date: Sun, 7 Feb 2016 18:57:49 +0000
Message-ID: <28CC6A8F-E642-4DF5-A8E5-DB9BB62DA429@fb.com>
References: <1454616467-8994-1-git-send-email-hannes@cmpxchg.org>
 <1454616467-8994-2-git-send-email-hannes@cmpxchg.org>,<20160207184059.GB19151@esperanza>
In-Reply-To: <20160207184059.GB19151@esperanza>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mateusz Guzik <mguzik@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>

> On Feb 7, 2016, at 1:41 PM, Vladimir Davydov <vdavydov@virtuozzo.com> wro=
te:
>=20
>> On Thu, Feb 04, 2016 at 03:07:47PM -0500, Johannes Weiner wrote:
>> Migration accounting in the memory controller used to have to handle
>> both oldpage and newpage being on the LRU already; fuse's page cache
>> replacement used to pass a recycled newpage that had been uncharged
>> but not freed and removed from the LRU, and the memcg migration code
>> used to uncharge oldpage to "pass on" the existing charge to newpage.
>>=20
>> Nowadays, pages are no longer uncharged when truncated from the page
>> cache, but rather only at free time, so if a LRU page is recycled in
>> page cache replacement it'll also still be charged. And we bail out of
>> the charge transfer altogether in that case. Tell commit_charge() that
>> we know newpage is not on the LRU, to avoid taking the zone->lru_lock
>> unnecessarily from the migration path.
>>=20
>> But also, oldpage is no longer uncharged inside migration. We only use
>> oldpage for its page->mem_cgroup and page size, so we don't care about
>> its LRU state anymore either. Remove any mention from the kernel doc.
>>=20
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> Suggested-by: Hugh Dickins <hughd@google.com>
>=20
> Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks!

> @@ -5483,6 +5483,7 @@ void mem_cgroup_migrate(struct page *oldpage, struc=
t page *newpage)
>    unsigned int nr_pages;
>    bool compound;
>=20
> +    VM_BUG_ON_PAGE(PageLRU(newpage), newpage);

That's actually possible for fuse. But in that case newpage is charged and =
we bail.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
