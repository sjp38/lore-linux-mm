Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 005506B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:04:12 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y7so3046380wrc.7
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:04:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v130si12472413wmd.161.2017.02.07.07.04.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 07:04:10 -0800 (PST)
Date: Tue, 7 Feb 2017 16:04:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
Message-ID: <20170207150408.GU5065@dhcp22.suse.cz>
References: <20170201140530.1325-1-mhocko@kernel.org>
 <772f9b64-8f03-a4ce-e56b-779d081ebb6d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <772f9b64-8f03-a4ce-e56b-779d081ebb6d@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-02-17 15:24:14, Vlastimil Babka wrote:
> On 02/01/2017 03:05 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __vmalloc* allows users to provide gfp flags for the underlying
> > allocation. This API is quite popular
> > $ git grep "=[[:space:]]__vmalloc\|return[[:space:]]*__vmalloc" | wc -l
> > 77
> > 
> > the only problem is that many people are not aware that they really want
> > to give __GFP_HIGHMEM along with other flags because there is really no
> > reason to consume precious lowmemory on CONFIG_HIGHMEM systems for pages
> > which are mapped to the kernel vmalloc space. About half of users don't
> > use this flag, though. This signals that we make the API unnecessarily
> > too complex.
> > 
> > This patch simply uses __GFP_HIGHMEM implicitly when allocating pages to
> > be mapped to the vmalloc space. Current users which add __GFP_HIGHMEM
> > are simplified and drop the flag.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > Hi,
> > this is based on top of [1]. I believe it was Al who has brought this
> > up quite some time ago (or maybe I just misremember). The explicit
> > usage of __GFP_HIGHMEM in __vmalloc* seems to be too much to ask from
> > users. I believe there is no user which doesn't want vmalloc pages be
> > in the highmem but I might be missing something. There is vmalloc_32*
> > API but that uses GFP_DMA* explicitly which overrides __GFP_HIGHMEM. So
> > all current users _should_ be safe to use __GFP_HIGHMEM unconditionally.
> > This patch should simplify things and fix many users which consume
> > lowmem for no good reason.
> > 
> > I am sending this as an RFC to get some feedback, I even haven't compile
> > tested it yet.
> > 
> > Any comments are welcome.
> 
> The idea sounds good. What are the potential dangers? That somebody of the
> current callers without __GFP_HIGHMEM would take a physical address of the
> page and then tried to access it via direct mapping?

Yes, that wouldn't work but I do not think anybody would want to do
something like that. Another risk would be that somebody really wanted
to use vmalloc_32* but didn't use the proper API. The physically
allocated page would then be used for a device which wouldn't be able to
access it because it would be out of its addressable space.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
