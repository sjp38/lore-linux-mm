Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 572826B0069
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 09:06:12 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w22so4218582pge.10
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:06:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z64si3328910pfa.207.2017.12.14.06.06.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 06:06:11 -0800 (PST)
Date: Thu, 14 Dec 2017 15:06:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Message-ID: <20171214140608.GQ16951@dhcp22.suse.cz>
References: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
 <20171127113341.ldx32qvexqe2224d@dhcp22.suse.cz>
 <20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
 <20171129134159.c9100ea6dacad870d69929b7@linux-foundation.org>
 <20171130065335.zno7peunnl2zpozq@dhcp22.suse.cz>
 <20171130131706.0550cd28ce47aaa976f7db2a@linux-foundation.org>
 <20171201072414.3kc3pbvdbqbxhnfx@dhcp22.suse.cz>
 <20171201111845.iyoua7hhjodpuvoy@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201111845.iyoua7hhjodpuvoy@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: JianKang Chen <chenjiankang1@huawei.com>, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Fri 01-12-17 12:18:45, Michal Hocko wrote:
> On Fri 01-12-17 08:24:14, Michal Hocko wrote:
> > On Thu 30-11-17 13:17:06, Andrew Morton wrote:
> > > On Thu, 30 Nov 2017 07:53:35 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> > > 
> > > > > mm...  So we have a caller which hopes to be getting highmem pages but
> > > > > isn't.  Caller then proceeds to pointlessly kmap the page and wonders
> > > > > why it isn't getting as much memory as it would like on 32-bit systems,
> > > > > etc.
> > > > 
> > > > How he can kmap the page when he gets a _virtual_ address?
> > > 
> > > doh.
> > > 
> > > > > I do think we should help ferret out such bogosity.  A WARN_ON_ONCE
> > > > > would suffice.
> > > > 
> > > > This function has always been about lowmem pages. I seriously doubt we
> > > > have anybody confused and asking for a highmem page in the kernel. I
> > > > haven't checked that but it would already blow up as VM_BUG_ON tends to
> > > > be enabled on many setups.
> > > 
> > > OK.  But silently accepting __GFP_HIGHMEM is a bit weird - callers
> > > shouldn't be doing that in the first place.
> > 
> > Yes, they shouldn't be.
> > 
> > > I wonder what happens if we just remove the WARN_ON and pass any
> > > __GFP_HIGHMEM straight through.  The caller gets a weird address from
> > > page_to_virt(highmem page) and usually goes splat?  Good enough
> > > treatment for something which never happens anyway?
> > 
> > page_address will return NULL so they will blow up and leak the freshly
> > allocated memory.
> 
> let me be more specific. They will blow up and leak if the returned
> address is not checked. If it is then we just leak. None of that sounds
> good to me.

So do we care and I will resend the patch in that case or I just drop
this from my patch queue?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
