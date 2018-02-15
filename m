Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 124026B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 11:06:12 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id w24so69840plq.11
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:06:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2-v6si1582975plt.418.2018.02.15.08.06.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Feb 2018 08:06:11 -0800 (PST)
Date: Thu, 15 Feb 2018 17:06:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] memory allocation scope
Message-ID: <20180215160609.GJ7275@dhcp22.suse.cz>
References: <8b9d4170-bc71-3338-6b46-22130f828adb@suse.de>
 <20180215144807.GH7275@dhcp22.suse.cz>
 <1518710257.5399.4.camel@HansenPartnership.com>
 <20180215160241.GI7275@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180215160241.GI7275@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Goldwyn Rodrigues <rgoldwyn@suse.de>, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Thu 15-02-18 17:02:41, Michal Hocko wrote:
> On Thu 15-02-18 07:57:37, James Bottomley wrote:
> > On Thu, 2018-02-15 at 15:48 +0100, Michal Hocko wrote:
> > > On Wed 14-02-18 16:51:53, Goldwyn Rodrigues wrote:
> > > > 
> > > > 
> > > > Discussion with the memory folks towards scope based allocation
> > > > I am working on converting some of the GFP_NOFS memory allocation
> > > > calls to new scope API [1]. While other allocation types (noio,
> > > > nofs, noreclaim) are covered. Are there plans for identifying scope
> > > > of GFP_ATOMIC allocations? This should cover most (if not all) of
> > > > the allocation scope.
> > > 
> > > There was no explicit request for that but I can see how some users
> > > might want it. I would have to double check but maybe this would
> > > allow vmalloc(GFP_ATOMIC). There were some users but most of them
> > > could have been changed in some way so the motivation is not very
> > > large.
> > 
> > We have to be careful about that: most GFP_ATOMIC allocations are in
> > drivers and may be for DMA'able memory.  We can't currently use vmalloc
> > memory for DMA to kernel via block because bio_map_kern() uses
> > virt_to_page() which assumes offset mapping.  The latter is fixable,
> > obviously, but is it worth fixing?  Very few GFP_ATOMIC allocations in
> > drivers will be for large chunks.
> 
> Yes this might be not worth bothering. But from the conceptual POV
> GFP_ATOMIC resp. GFP_NOWAIT is very often a scope context - IRQs,
> preemption or RCU. So protecting all allocations from that context makes
> some sense. Not sure this is really worth spending another context bit
> though.

And just to clarify why I've mentioned vmalloc explicitly. vmalloc
simply ignores the given gfp flags for pte allocations (those are
hardcoded GFP_KERNEL) and that is why it is not generally suitable for
atomic contexts. Maybe there are other obstacles (sleeping locks) but
scope gfp would solve at least the pte allocation side.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
