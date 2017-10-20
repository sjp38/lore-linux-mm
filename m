Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1726B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:12:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u5so5474901wrc.5
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 02:12:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si627189wme.5.2017.10.20.02.12.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Oct 2017 02:12:39 -0700 (PDT)
Date: Fri, 20 Oct 2017 11:12:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: swapper/0: page allocation failure: order:0,
 mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
Message-ID: <20171020091239.cfwapdkx5g7afyp7@dhcp22.suse.cz>
References: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
 <20171019035641.GB23773@intel.com>
 <CABXGCsPL0pUHo_M-KxB3mabfdGMSHPC0uchLBBt0JCzF2BYBww@mail.gmail.com>
 <20171020064305.GA13688@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171020064305.GA13688@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Du, Changbin" <changbin.du@intel.com>
Cc: =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, linux-mm@kvack.org

On Fri 20-10-17 14:43:06, Du, Changbin wrote:
> On Thu, Oct 19, 2017 at 11:52:49PM +0500, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> > On 19 October 2017 at 08:56, Du, Changbin <changbin.du@intel.com> wrote:
> > > On Thu, Oct 19, 2017 at 01:16:48AM +0500, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> > > I am curious about this, how can slub try to alloc compound page but the order
> > > is 0? This is wrong.
> > 
> > Nobody seems to know how this could happen. Can any logs shed light on this?
> >
> After checking the code, kernel can handle such case. So please ignore my last
> comment.
> 
> The warning is reporting OOM, first you need confirm if you have enough free
> memory? If that is true, then it is not a programmer error.

The kernel is not OOM. It just failed to allocate for GFP_NOWAIT which
means that no memory reclaim could be used to free up potentially unused
page cache. This means that kswapd is not able to free up memory in the
pace it is allocated. Such an allocation failure shouldn't be critical
and the caller should have means to fall back to a regular allocation or
retry later. You can play with min_free_kbytes and increase it to kick
the background reclaim sooner.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
