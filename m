Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E822B6B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:43:32 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w143so16367004oiw.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:43:32 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0125.outbound.protection.outlook.com. [104.47.0.125])
        by mx.google.com with ESMTPS id x53si1223609otx.167.2016.05.24.01.43.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 01:43:29 -0700 (PDT)
Date: Tue, 24 May 2016 11:43:19 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160524084319.GH7917@esperanza>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
 <20160523174441.GA32715@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160523174441.GA32715@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 23, 2016 at 07:44:43PM +0200, Michal Hocko wrote:
> On Mon 23-05-16 19:02:10, Vladimir Davydov wrote:
> > mem_cgroup_oom may be invoked multiple times while a process is handling
> > a page fault, in which case current->memcg_in_oom will be overwritten
> > leaking the previously taken css reference.
> 
> Have you seen this happening? I was under impression that the page fault
> paths that have oom enabled will not retry allocations.

filemap_fault will, for readahead.

This is rather unlikely, just like the whole oom scenario, so I haven't
faced this leak in production yet, although it's pretty easy to
reproduce using a contrived test. However, even if this leak happened on
my host, I would probably not notice, because currently we have no clear
means of catching css leaks. I'm thinking about adding a file to debugfs
containing brief information about all memory cgroups, including dead
ones, so that we could at least see how many dead memory cgroups are
dangling out there.

>  
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> That being said I do not have anything against the patch. It is a good
> safety net I am just not sure this might happen right now and so the
> patch is not stable candidate.
> 
> After clarification
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
