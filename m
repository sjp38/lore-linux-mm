Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39B276B000A
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 20:20:02 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id l92so24201786otc.12
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 17:20:02 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t24si14321740oth.315.2018.10.22.17.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 17:20:00 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Memory management issue in 4.18.15
Date: Mon, 22 Oct 2018 23:44:33 +0000
Message-ID: <20181022234425.GA18716@tower.DHCP.thefacebook.com>
References: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
 <20181022083322.GE32333@dhcp22.suse.cz>
In-Reply-To: <20181022083322.GE32333@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <84C62170042B2E42977CC9963F954C9C@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Spock <dairinin@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <alexander.levin@microsoft.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> On Sat 20-10-18 14:41:40, Spock wrote:
> > Hello,
> >=20
> > I have a workload, which creates lots of cache pages. Before 4.18.15,
> > the behavior was very stable: pagecache is constantly growing until it
> > consumes all the free memory, and then kswapd is balancing it around
> > low watermark. After 4.18.15, once in a while khugepaged is waking up
> > and reclaims almost all the pages from pagecache, so there is always
> > around 2G of 8G unused. THP is enabled only for madvise case and are
> > not used.

Spock, can you, please, check if the following patch solves the problem
for you?

Thank you!

--

diff --git a/fs/inode.c b/fs/inode.c
index 73432e64f874..63aca301a8bc 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -731,7 +731,7 @@ static enum lru_status inode_lru_isolate(struct list_he=
ad *item,
        }
=20
        /* recently referenced inodes get one more pass */
-       if (inode->i_state & I_REFERENCED) {
+       if (inode->i_state & I_REFERENCED || inode->i_data.nrpages > 1) {
                inode->i_state &=3D ~I_REFERENCED;
                spin_unlock(&inode->i_lock);
                return LRU_ROTATE;
