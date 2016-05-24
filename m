Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 459E86B0253
	for <linux-mm@kvack.org>; Tue, 24 May 2016 05:01:54 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id yu3so14377816obb.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 02:01:54 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0109.outbound.protection.outlook.com. [104.47.2.109])
        by mx.google.com with ESMTPS id t63si1303890oit.20.2016.05.24.02.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 02:01:53 -0700 (PDT)
Date: Tue, 24 May 2016 12:01:42 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160524090142.GI7917@esperanza>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
 <20160523174441.GA32715@dhcp22.suse.cz>
 <20160524084319.GH7917@esperanza>
 <20160524084737.GC8259@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160524084737.GC8259@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 24, 2016 at 10:47:37AM +0200, Michal Hocko wrote:
> On Tue 24-05-16 11:43:19, Vladimir Davydov wrote:
> > On Mon, May 23, 2016 at 07:44:43PM +0200, Michal Hocko wrote:
> > > On Mon 23-05-16 19:02:10, Vladimir Davydov wrote:
> > > > mem_cgroup_oom may be invoked multiple times while a process is handling
> > > > a page fault, in which case current->memcg_in_oom will be overwritten
> > > > leaking the previously taken css reference.
> > > 
> > > Have you seen this happening? I was under impression that the page fault
> > > paths that have oom enabled will not retry allocations.
> > 
> > filemap_fault will, for readahead.
> 
> I thought that the readahead is __GFP_NORETRY so we do not trigger OOM
> killer.

Hmm, interesting. We do allocate readahead pages with __GFP_NORETRY, but
we add them to page cache and hence charge with GFP_KERNEL or GFP_NOFS
mask, see __do_page_cache_readahaed -> read_pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
