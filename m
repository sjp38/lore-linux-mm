Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6626B038A
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:50:04 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v66so29141107wrc.4
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:50:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o67si26133635wmo.87.2017.03.02.05.50.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 05:50:02 -0800 (PST)
Date: Thu, 2 Mar 2017 14:50:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302135001.GI1404@dhcp22.suse.cz>
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
 <20170302003731.GB24593@infradead.org>
 <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
 <42eb5d53-5ceb-a9ce-791a-9469af30810c@I-love.SAKURA.ne.jp>
 <20170302103520.GC1404@dhcp22.suse.cz>
 <20170302122426.GA3213@bfoster.bfoster>
 <20170302124909.GE1404@dhcp22.suse.cz>
 <20170302130009.GC3213@bfoster.bfoster>
 <20170302132755.GG1404@dhcp22.suse.cz>
 <20170302134157.GD3213@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302134157.GD3213@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu 02-03-17 08:41:58, Brian Foster wrote:
> On Thu, Mar 02, 2017 at 02:27:55PM +0100, Michal Hocko wrote:
[...]
> > I see your argument about being in sync with other kmem helpers but
> > those are bit different because regular page/slab allocators allow never
> > fail semantic (even though this is mostly ignored by those helpers which
> > implement their own retries but that is a different topic).
> > 
> 
> ... but what I'm trying to understand here is whether this failure
> scenario is specific to vmalloc() or whether the other kmem_*()
> functions are susceptible to the same problem. For example, suppose we
> replaced this kmem_zalloc_greedy() call with a kmem_zalloc(PAGE_SIZE,
> KM_SLEEP) call. Could we hit the same problem if the process is killed?

Well, kmem_zalloc uses kmalloc which can also fail when we are out of
memory but in that case we can expect the OOM killer releasing some
memory which would allow us to make a forward progress on the next
retry. So essentially retrying around kmalloc is much more safe in this
regard. Failing vmalloc might be permanent because there is no vmalloc
space to allocate from or much more likely due to already mentioned
patch. So vmalloc is different, really.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
