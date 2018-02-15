Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 458B56B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 11:02:47 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id a61so48688pla.22
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:02:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c83si2813644pfd.185.2018.02.15.08.02.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Feb 2018 08:02:45 -0800 (PST)
Date: Thu, 15 Feb 2018 17:02:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] memory allocation scope
Message-ID: <20180215160241.GI7275@dhcp22.suse.cz>
References: <8b9d4170-bc71-3338-6b46-22130f828adb@suse.de>
 <20180215144807.GH7275@dhcp22.suse.cz>
 <1518710257.5399.4.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1518710257.5399.4.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Goldwyn Rodrigues <rgoldwyn@suse.de>, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Thu 15-02-18 07:57:37, James Bottomley wrote:
> On Thu, 2018-02-15 at 15:48 +0100, Michal Hocko wrote:
> > On Wed 14-02-18 16:51:53, Goldwyn Rodrigues wrote:
> > > 
> > > 
> > > Discussion with the memory folks towards scope based allocation
> > > I am working on converting some of the GFP_NOFS memory allocation
> > > calls to new scope API [1]. While other allocation types (noio,
> > > nofs, noreclaim) are covered. Are there plans for identifying scope
> > > of GFP_ATOMIC allocations? This should cover most (if not all) of
> > > the allocation scope.
> > 
> > There was no explicit request for that but I can see how some users
> > might want it. I would have to double check but maybe this would
> > allow vmalloc(GFP_ATOMIC). There were some users but most of them
> > could have been changed in some way so the motivation is not very
> > large.
> 
> We have to be careful about that: most GFP_ATOMIC allocations are in
> drivers and may be for DMA'able memory.  We can't currently use vmalloc
> memory for DMA to kernel via block because bio_map_kern() uses
> virt_to_page() which assumes offset mapping.  The latter is fixable,
> obviously, but is it worth fixing?  Very few GFP_ATOMIC allocations in
> drivers will be for large chunks.

Yes this might be not worth bothering. But from the conceptual POV
GFP_ATOMIC resp. GFP_NOWAIT is very often a scope context - IRQs,
preemption or RCU. So protecting all allocations from that context makes
some sense. Not sure this is really worth spending another context bit
though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
