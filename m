Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0506B025E
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 09:29:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so82292631wmz.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 06:29:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kc2si20839393wjc.61.2016.09.13.06.29.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Sep 2016 06:29:01 -0700 (PDT)
Date: Tue, 13 Sep 2016 15:28:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
Message-ID: <20160913132854.GB6592@dhcp22.suse.cz>
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com>
 <20160909114410.GG4844@dhcp22.suse.cz>
 <57D67A8A.7070500@huawei.com>
 <20160912111327.GG14524@dhcp22.suse.cz>
 <57D6B0C4.6040400@huawei.com>
 <20160912174445.GC14997@dhcp22.suse.cz>
 <57D7FB71.9090102@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57D7FB71.9090102@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Tue 13-09-16 21:13:21, zhong jiang wrote:
> On 2016/9/13 1:44, Michal Hocko wrote:
[...]
> > If you want to solve this problem properly then you would have to give
> > tasks which are looping in the page allocator access to some portion of
> > memory reserves. This is quite tricky to do right, though.
>
> To use some portion of memory reserves is almost no effect in a so
> starvation scenario.  I think the hungtask still will occur. it can
> not solve the problem primarily.

Granting an access to memory reserves is of course no full solution but
it raises chances for a forward progress. Other solutions would have to
guarantee that the memory reclaimed on behalf of the requester will be
given to the requester. Not an easy task

> > Retry counters with the fail path have been proposed in the past and not
> > accepted.
>
> The above patch have been tested by runing the trinity.  The question
> is fixed.  Is there any reasonable reason oppose to the patch ? or it
> will bring in any side-effect.

Sure there is. Low order allocations have been traditionally non failing
and changing that behavior is a major obstacle because it opens up a
door to many bugs. I've tried to do something similar in the past and
there was a strong resistance against it. Believe me been there done
that...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
