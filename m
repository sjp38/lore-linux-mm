Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 267FC6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 13:27:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v67so343645285pfv.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:27:52 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id u11si33747737pfj.278.2016.09.19.10.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 10:27:51 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id z123so53012884pfz.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:27:51 -0700 (PDT)
Date: Mon, 19 Sep 2016 10:27:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
In-Reply-To: <20160918144248.GA28476@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1609191015310.1993@eggly.anvils>
References: <20160912111327.GG14524@dhcp22.suse.cz> <57D6B0C4.6040400@huawei.com> <20160912174445.GC14997@dhcp22.suse.cz> <57D7FB71.9090102@huawei.com> <20160913132854.GB6592@dhcp22.suse.cz> <57D8F8AE.1090404@huawei.com> <20160914084219.GA1612@dhcp22.suse.cz>
 <20160914085227.GB1612@dhcp22.suse.cz> <alpine.LSU.2.11.1609161440280.5127@eggly.anvils> <57DE125F.7030508@huawei.com> <20160918144248.GA28476@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Sun, 18 Sep 2016, Michal Hocko wrote:
> On Sun 18-09-16 12:04:47, zhong jiang wrote:
> [...]
> >  index 5048083..72dc475 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -299,7 +299,7 @@ static inline void free_rmap_item(struct rmap_item *rmap_item)
> > 
> >  static inline struct stable_node *alloc_stable_node(void)
> >  {
> > -       return kmem_cache_alloc(stable_node_cache, GFP_KERNEL);
> > +       return kmem_cache_alloc(stable_node_cache, __GFP_HIGH);
> >  }
> 
> I do not want to speak for Hugh but I believe he meant something
> different. The above will grant access to memory reserves but it doesn't
> wake kswapd nor the direct reclaim. I guess he meant GFP_KERNEL | __GFP_HIGH

You speak for me correctly, Michal: sorry I wasn't clear, Zhongjiang, yes,
I meant __GFP_HIGH as a modifier for GFP_KERNEL: GFP_KERNEL | __GFP_HIGH

And after running it past Michal and thinking on it some more, I do
still think that it's the right thing to do for alloc_stable_node().
But please only include that change in your patch if you yourself are
comfortable with it: it is very definitely a much lower order issue
than the alloc_rmap_item() issue, and can always be added later.

(I have no view on whether and how this problem still occurs with
OOM reaper: I leave the thinking on that to you and the experts.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
