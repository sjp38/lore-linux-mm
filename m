Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 828496B0008
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 15:26:31 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id i4-v6so2412629oik.5
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 12:26:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 60-v6si5273368otc.197.2018.04.24.12.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 12:26:30 -0700 (PDT)
Subject: Re: vmalloc with GFP_NOFS
References: <20180424162712.GL17484@dhcp22.suse.cz>
From: Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <ce42f323-870c-21df-ac27-1bec6aa7e5d1@redhat.com>
Date: Tue, 24 Apr 2018 20:26:23 +0100
MIME-Version: 1.0
In-Reply-To: <20180424162712.GL17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Artem Bityutskiy <dedekind1@gmail.com>, Richard Weinberger <richard@nod.at>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

Hi,


On 24/04/18 17:27, Michal Hocko wrote:
> Hi,
> it seems that we still have few vmalloc users who perform GFP_NOFS
> allocation:
> drivers/mtd/ubi/io.c
> fs/ext4/xattr.c
> fs/gfs2/dir.c
> fs/gfs2/quota.c
> fs/nfs/blocklayout/extent_tree.c
> fs/ubifs/debug.c
> fs/ubifs/lprops.c
> fs/ubifs/lpt_commit.c
> fs/ubifs/orphan.c
>
> Unfortunatelly vmalloc doesn't suppoer GFP_NOFS semantinc properly
> because we do have hardocded GFP_KERNEL allocations deep inside the
> vmalloc layers. That means that if GFP_NOFS really protects from
> recursion into the fs deadlocks then the vmalloc call is broken.
>
> What to do about this? Well, there are two things. Firstly, it would be
> really great to double check whether the GFP_NOFS is really needed. I
> cannot judge that because I am not familiar with the code. It would be
> great if the respective maintainers (hopefully get_maintainer.sh pointed
> me to all relevant ones). If there is not reclaim recursion issue then
> simply use the standard vmalloc (aka GFP_KERNEL request).
For GFS2, and I suspect for other fs too, it is really needed. We don't 
want to enter reclaim while holding filesystem locks.

> If the use is really valid then we have a way to do the vmalloc
> allocation properly. We have memalloc_nofs_{save,restore} scope api. How
> does that work? You simply call memalloc_nofs_save when the reclaim
> recursion critical section starts (e.g. when you take a lock which is
> then used in the reclaim path - e.g. shrinker) and memalloc_nofs_restore
> when the critical section ends. _All_ allocations within that scope
> will get GFP_NOFS semantic automagically. If you are not sure about the
> scope itself then the easiest workaround is to wrap the vmalloc itself
> with a big fat comment that this should be revisited.
>
> Does that sound like something that can be done in a reasonable time?
> I have tried to bring this up in the past but our speed is glacial and
> there are attempts to do hacks like checking for abusers inside the
> vmalloc which is just too ugly to live.
>
> Please do not hesitate to get back to me if something is not clear.
>
> Thanks!

It would be good to fix this, and it has been known as an issue for a 
long time. We might well be able to make use of the new API though. It 
might be as simple as adding the calls when we get & release glocks, but 
I'd have to check the code to be sure,

Steve.
