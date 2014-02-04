Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 17BB66B0039
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 19:06:54 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so7751732pbc.28
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 16:06:53 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id of8si9536953pbc.133.2014.02.03.16.06.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 16:06:53 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so7681575pab.6
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 16:06:52 -0800 (PST)
Date: Mon, 3 Feb 2014 16:06:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Need help in bug in isolate_migratepages_range
In-Reply-To: <52EFC93D.3030106@suse.cz>
Message-ID: <alpine.DEB.2.02.1402031602060.10778@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1401312037340.6630@diagnostix.dwd.de> <20140203122052.GC2495@dhcp22.suse.cz> <alpine.LRH.2.02.1402031426510.13382@diagnostix.dwd.de> <20140203162036.GJ2495@dhcp22.suse.cz> <52EFC93D.3030106@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>, Holger Kiehl <Holger.Kiehl@dwd.de>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon, 3 Feb 2014, Vlastimil Babka wrote:

> It seems to come from balloon_page_movable() and its test page_count(page) ==
> 1.
> 

Hmm, I think it might be because compound_head() == NULL here.  Holger, 
this looks like a race condition when allocating a compound page, did you 
only see it once or is it actually reproducible?

I think this happens when a new compound page is allocated and PageBuddy 
is cleared before prep_compound_page() and then we see PageTail(p) set but 
p->first_page is not yet initialized.  Is there any way to avoid memory 
barriers in compound_page()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
