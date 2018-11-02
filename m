Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF316B000C
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 11:49:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x11-v6so1990246pgp.20
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 08:49:31 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f15-v6si8151986pfn.85.2018.11.02.08.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 08:49:30 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Date: Fri, 2 Nov 2018 15:48:57 +0000
Message-ID: <20181102154844.GA17619@tower.DHCP.thefacebook.com>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102073009.GP23921@dhcp22.suse.cz>
In-Reply-To: <20181102073009.GP23921@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <11F686430097414AA30A58213C8EB530@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dexuan Cui <decui@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel
 Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri, Nov 02, 2018 at 09:03:55AM +0100, Michal Hocko wrote:
> On Fri 02-11-18 02:45:42, Dexuan Cui wrote:
> [...]
> > I totally agree. I'm now just wondering if there is any temporary worka=
round,
> > even if that means we have to run the kernel with some features disable=
d or
> > with a suboptimal performance?
>=20
> One way would be to disable kmem accounting (cgroup.memory=3Dnokmem kerne=
l
> option). That would reduce the memory isolation because quite a lot of
> memory will not be accounted for but the primary source of in-flight and
> hard to reclaim memory will be gone.

In my experience disabling the kmem accounting doesn't really solve the iss=
ue
(without patches), but can lower the rate of the leak.

>=20
> Another workaround could be to use force_empty knob we have in v1 and
> use it when removing a cgroup. We do not have it in cgroup v2 though.
> The file hasn't been added to v2 because we didn't really have any
> proper usecase. Working around a bug doesn't sound like a _proper_
> usecase but I can imagine workloads that bring a lot of metadata objects
> that are not really interesting for later use so something like a
> targeted drop_caches...

This can help a bit too, but even using the system-wide drop_caches knob
unfortunately doesn't return all the memory back.

Thanks!
