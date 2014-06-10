Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id ACD376B00D2
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 20:12:25 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so5554296pbc.40
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 17:12:25 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id hp1si841081pad.83.2014.06.09.17.12.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 17:12:24 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id fp1so5465118pdb.3
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 17:12:24 -0700 (PDT)
Message-ID: <1402359051.22759.7.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
From: Chen Yucong <slaoub@gmail.com>
Date: Tue, 10 Jun 2014 08:10:51 +0800
In-Reply-To: <20140609232459.GA8171@bbox>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
	 <20140609232459.GA8171@bbox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: mgorman@suse.de, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2014-06-10 at 08:24 +0900, Minchan Kim wrote:
> Hello,
> 
> On Mon, Jun 09, 2014 at 09:27:16PM +0800, Chen Yucong wrote:
> > Via https://lkml.org/lkml/2013/4/10/334 , we can find that recording the
> > original scan targets introduces extra 40 bytes on the stack. This patch
> > is able to avoid this situation and the call to memcpy(). At the same time,
> > it does not change the relative design idea.
> > 
> > ratio = original_nr_file / original_nr_anon;
> > 
> > If (nr_file > nr_anon), then ratio = (nr_file - x) / nr_anon.
> >  x = nr_file - ratio * nr_anon;
> > 
> > if (nr_file <= nr_anon), then ratio = nr_file / (nr_anon - x).
> >  x = nr_anon - nr_file / ratio;
> 
> Nice cleanup!
> 
> Below one nitpick.
> 

> 
> If both nr_file and nr_anon are zero, then the nr_anon could be zero
> if HugePage are reclaimed so that it could pass the below check
> 
>         if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> 
> 
The Mel Gorman's patch has already handled this situation you're
describing. It's called:
 
mm: vmscan: use proportional scanning during direct reclaim and full
scan at DEF_PRIORITY

thx!
cyc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
