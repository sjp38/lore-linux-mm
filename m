Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 36D836B0088
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 01:23:54 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id ft15so1726062pdb.2
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:23:53 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id oh6si907359pbb.12.2014.06.12.22.23.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 22:23:53 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so1140997pab.4
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:23:52 -0700 (PDT)
Message-ID: <1402636875.1232.13.camel@debian>
Subject: Re: [PATCH v2] mm/vmscan.c: wrap five parameters into
 shrink_result for reducing the stack consumption
From: Chen Yucong <slaoub@gmail.com>
In-Reply-To: <20140612214016.1beda952.akpm@linux-foundation.org>
References: <1402634191-3442-1-git-send-email-slaoub@gmail.com>
	 <20140612214016.1beda952.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 13 Jun 2014 13:21:15 +0800
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2014-06-12 at 21:40 -0700, Andrew Morton wrote:
> On Fri, 13 Jun 2014 12:36:31 +0800 Chen Yucong <slaoub@gmail.com> wrote:
> 
> > @@ -1148,7 +1146,8 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
> >  		.priority = DEF_PRIORITY,
> >  		.may_unmap = 1,
> >  	};
> > -	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
> > +	unsigned long ret;
> > +	struct shrink_result dummy = { };
> 
> You didn't like the idea of making this static?
Sorry! It's my negligence.
If we make dummy static, it can help us save more stack.

without change:  
0xffffffff810aede8 reclaim_clean_pages_from_list []:	184
0xffffffff810aeef8 reclaim_clean_pages_from_list []:	184

with change: struct shrink_result dummy = {};
0xffffffff810aed6c reclaim_clean_pages_from_list []:	152
0xffffffff810aee68 reclaim_clean_pages_from_list []:	152

with change: static struct shrink_result dummy ={};
0xffffffff810aed69 reclaim_clean_pages_from_list []:	120
0xffffffff810aee4d reclaim_clean_pages_from_list []:	120

thx!
cyc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
