Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 582D66B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 06:05:34 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id d197so25162415ioe.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 03:05:34 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0124.outbound.protection.outlook.com. [157.56.112.124])
        by mx.google.com with ESMTPS id p54si1417986otp.191.2016.05.24.03.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 03:05:33 -0700 (PDT)
Date: Tue, 24 May 2016 13:05:23 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160524100523.GJ7917@esperanza>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
 <20160523174441.GA32715@dhcp22.suse.cz>
 <20160524084319.GH7917@esperanza>
 <20160524084737.GC8259@dhcp22.suse.cz>
 <20160524090142.GI7917@esperanza>
 <20160524092202.GD8259@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160524092202.GD8259@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 24, 2016 at 11:22:02AM +0200, Michal Hocko wrote:
> On Tue 24-05-16 12:01:42, Vladimir Davydov wrote:
> > On Tue, May 24, 2016 at 10:47:37AM +0200, Michal Hocko wrote:
> > > On Tue 24-05-16 11:43:19, Vladimir Davydov wrote:
> > > > On Mon, May 23, 2016 at 07:44:43PM +0200, Michal Hocko wrote:
> > > > > On Mon 23-05-16 19:02:10, Vladimir Davydov wrote:
> > > > > > mem_cgroup_oom may be invoked multiple times while a process is handling
> > > > > > a page fault, in which case current->memcg_in_oom will be overwritten
> > > > > > leaking the previously taken css reference.
> > > > > 
> > > > > Have you seen this happening? I was under impression that the page fault
> > > > > paths that have oom enabled will not retry allocations.
> > > > 
> > > > filemap_fault will, for readahead.
> > > 
> > > I thought that the readahead is __GFP_NORETRY so we do not trigger OOM
> > > killer.
> > 
> > Hmm, interesting. We do allocate readahead pages with __GFP_NORETRY, but
> > we add them to page cache and hence charge with GFP_KERNEL or GFP_NOFS
> > mask, see __do_page_cache_readahaed -> read_pages.
> 
> I guess we do not want to trigger OOM just because of readahead. What do

I agree this is how it should ideally work. Not sure if anybody would
bother in practice.

> you think about the following? I will cook up a full patch if this
> (untested) looks ok.

It won't work for most filesystems as they define custom ->readpages. I
wonder if it'd be OK to patch them all not to trigger oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
