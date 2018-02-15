Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDA346B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:57:40 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id b34so58373plc.2
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 07:57:40 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id w3si2675458pgb.754.2018.02.15.07.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Feb 2018 07:57:39 -0800 (PST)
Message-ID: <1518710257.5399.4.camel@HansenPartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] memory allocation scope
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 15 Feb 2018 07:57:37 -0800
In-Reply-To: <20180215144807.GH7275@dhcp22.suse.cz>
References: <8b9d4170-bc71-3338-6b46-22130f828adb@suse.de>
	 <20180215144807.GH7275@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Thu, 2018-02-15 at 15:48 +0100, Michal Hocko wrote:
> On Wed 14-02-18 16:51:53, Goldwyn Rodrigues wrote:
> > 
> > 
> > Discussion with the memory folks towards scope based allocation
> > I am working on converting some of the GFP_NOFS memory allocation
> > calls to new scope API [1]. While other allocation types (noio,
> > nofs, noreclaim) are covered. Are there plans for identifying scope
> > of GFP_ATOMIC allocations? This should cover most (if not all) of
> > the allocation scope.
> 
> There was no explicit request for that but I can see how some users
> might want it. I would have to double check but maybe this would
> allow vmalloc(GFP_ATOMIC). There were some users but most of them
> could have been changed in some way so the motivation is not very
> large.

We have to be careful about that: most GFP_ATOMIC allocations are in
drivers and may be for DMA'able memory. A We can't currently use vmalloc
memory for DMA to kernel via block because bio_map_kern() uses
virt_to_page() which assumes offset mapping. A The latter is fixable,
obviously, but is it worth fixing? A Very few GFP_ATOMIC allocations in
drivers will be for large chunks.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
