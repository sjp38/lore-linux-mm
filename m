Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4629C6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 14:41:32 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id d68so228787993ywe.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:41:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l74si34343934qhb.68.2016.04.15.11.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 11:41:31 -0700 (PDT)
Date: Fri, 15 Apr 2016 14:41:29 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH 17/19] dm: get rid of superfluous gfp flags
In-Reply-To: <20160415130839.GJ32377@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1604151437500.3288@file01.intranet.prod.int.rdu2.redhat.com>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org> <1460372892-8157-18-git-send-email-mhocko@kernel.org> <alpine.LRH.2.02.1604150826280.16981@file01.intranet.prod.int.rdu2.redhat.com> <20160415130839.GJ32377@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Shaohua Li <shli@kernel.org>



On Fri, 15 Apr 2016, Michal Hocko wrote:

> On Fri 15-04-16 08:29:28, Mikulas Patocka wrote:
> > 
> > 
> > On Mon, 11 Apr 2016, Michal Hocko wrote:
> > 
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > copy_params seems to be little bit confused about which allocation flags
> > > to use. It enforces GFP_NOIO even though it uses
> > > memalloc_noio_{save,restore} which enforces GFP_NOIO at the page
> > 
> > memalloc_noio_{save,restore} is used because __vmalloc is flawed and 
> > doesn't respect GFP_NOIO properly (it doesn't use gfp flags when 
> > allocating pagetables).
> 
> Yes and there are no plans to change __vmalloc to properly propagate gfp
> flags through the whole call chain and that is why we have
> memalloc_noio thingy. If that ever changes later the GFP_NOIO can be
> added in favor of memalloc_noio API. Both are clearly redundant.
> -- 
> Michal Hocko
> SUSE Labs

You could move memalloc_noio_{save,restore} to __vmalloc. Something like

if (!(gfp_mask & __GFP_IO))
	noio_flag = memalloc_noio_save();
...
if (!(gfp_mask & __GFP_IO))
	memalloc_noio_restore(noio_flag);

That would be better than repeating this hack in every __vmalloc caller 
that need GFP_NOIO.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
