Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA2D6B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 02:56:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g127so26900364ith.3
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 23:56:16 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d81si15602013itd.44.2016.06.19.23.56.15
        for <linux-mm@kvack.org>;
        Sun, 19 Jun 2016 23:56:16 -0700 (PDT)
Date: Mon, 20 Jun 2016 15:58:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 6/7] mm/page_owner: use stackdepot to store stacktrace
Message-ID: <20160620065841.GC13747@js1304-P5Q-DELUXE>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-6-git-send-email-iamjoonsoo.kim@lge.com>
 <20160606135604.GJ11895@dhcp22.suse.cz>
 <20160617072525.GA810@js1304-P5Q-DELUXE>
 <20160617095559.GC21670@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617095559.GC21670@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 17, 2016 at 11:55:59AM +0200, Michal Hocko wrote:
> On Fri 17-06-16 16:25:26, Joonsoo Kim wrote:
> > On Mon, Jun 06, 2016 at 03:56:04PM +0200, Michal Hocko wrote:
> [...]
> > > I still have troubles to understand your numbers
> > > 
> > > > static allocation:
> > > > 92274688 bytes -> 25165824 bytes
> > > 
> > > I assume that the first numbers refers to the static allocation for the
> > > given amount of memory while the second one is the dynamic after the
> > > boot, right?
> > 
> > No, first number refers to the static allocation before the patch and
> > second one is for after the patch.
> 
> I guess we are both talking about the same thing in different words. All
> the allocations are static before the patch while all are dynamic after

Hmm... maybe no? After the patch, there is two parts, static and dynamic.
Page extension has following fields for page owner.

Before the patch
{
 unsigned int order;
 gfp_t gfp_mask;
 unsigned int nr_entries;
 int last_migrate_reason;
 unsigned long trace_entries[8];
}

After the patch
{
 unsigned int order;
 gfp_t gfp_mask;
 int last_migrate_reason;
 depot_stack_handle_t handle;
}

This structure should be allocated for each page even if the patch is
applied so I said it as static memory usage. There is an amount
difference since 'trace_entries[8]' field is changed to 'handle'
field.

Before the patch, stacktrace is stored to static allocated memory per
page. So, no dynamic usage.

After the patch, handle is returned by stackdepot and stackdepot
consumes some memory for it. I said it as dynamic.

Thanks.

> the patch. Your boot example just shows how much dynamic memory gets
> allocated during your boot. This will depend on the particular
> configuration but it will at least give a picture what the savings might
> be.
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
