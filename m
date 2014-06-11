Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id BDC6E6B013E
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 23:23:04 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so6721017pde.18
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 20:23:04 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id ky7si36461125pbc.146.2014.06.10.20.23.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 20:23:03 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id v10so6736424pde.37
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 20:23:03 -0700 (PDT)
Message-ID: <1402456897.28433.46.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
From: Chen Yucong <slaoub@gmail.com>
Date: Wed, 11 Jun 2014 11:21:37 +0800
In-Reply-To: <20140610163338.5b463c5884c4c7e3f1b948e2@linux-foundation.org>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
	 <20140610163338.5b463c5884c4c7e3f1b948e2@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@suse.de, mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2014-06-10 at 16:33 -0700, Andrew Morton wrote:
> >                       break;
> >  
> >               if (nr_file > nr_anon) {
> > -                     unsigned long scan_target =
> targets[LRU_INACTIVE_ANON] +
> >
> -                                             targets[LRU_ACTIVE_ANON]
> + 1;
> > +                     nr_to_scan = nr_file - ratio * nr_anon;
> > +                     percentage = nr[LRU_FILE] * 100 / nr_file;
> 
> here, nr_file and nr_anon are derived from the contents of nr[].  But
> nr[] was modified in the for_each_evictable_lru() loop, so its
> contents
> now may differ from what was in targets[]? 

nr_to_scan is used for recording the number of pages that should be
scanned to keep original *ratio*.

We can assume that the value of (nr_file > nr_anon) is true, nr_to_scan
should be distribute to nr[LRU_ACTIVE_FILE] and nr[LRU_INACTIVE_FILE] in
proportion.

    nr_file = nr[LRU_ACTIVE_FILE] + nr[LRU_INACTIVE_FILE];
    percentage = nr[LRU_FILE] / nr_file;

Note that in comparison with *old* percentage, the "new" percentage has
the different meaning. It is just used to divide nr_so_scan pages
appropriately.

thx!
cyc     

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
