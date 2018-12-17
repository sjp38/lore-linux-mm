Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3C7A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 04:33:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t2so8032360edb.22
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 01:33:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p10si4807311edh.181.2018.12.17.01.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 01:33:39 -0800 (PST)
Date: Mon, 17 Dec 2018 10:33:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
Message-ID: <20181217093337.GC30879@dhcp22.suse.cz>
References: <20181204020840.49576-1-houtao1@huawei.com>
 <20181215143824.GJ10600@bombadil.infradead.org>
 <69457a5a-79c9-4950-37ae-eff7fa4f949a@huawei.com>
 <20181217035157.GK10600@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217035157.GK10600@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hou Tao <houtao1@huawei.com>, phillip@squashfs.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun 16-12-18 19:51:57, Matthew Wilcox wrote:
[...]
> Ah, yes, that makes perfect sense.  Thank you for the explanation.
> 
> I wonder if the correct fix, however, is not to move the check for
> GFP_NOFS in out_of_memory() down to below the check whether to kill
> the current task.  That would solve your problem, and I don't _think_
> it would cause any new ones.  Michal, you touched this code last, what
> do you think?

What do you mean exactly? Whether we kill a current task or something
else doesn't change much on the fact that NOFS is a reclaim restricted
context and we might kill too early. If the fs can do GFP_FS then it is
obviously a better thing to do because FS metadata can be reclaimed as
well and therefore there is potentially less memory pressure on
application data.
-- 
Michal Hocko
SUSE Labs
