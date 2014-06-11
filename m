Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BAF746B012E
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 22:10:13 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id fp1so6716348pdb.3
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:10:13 -0700 (PDT)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id rq4si4849407pac.66.2014.06.10.19.10.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 19:10:12 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id rp16so1447005pbb.38
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:10:12 -0700 (PDT)
Message-ID: <1402452521.28433.26.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
From: Chen Yucong <slaoub@gmail.com>
Date: Wed, 11 Jun 2014 10:08:41 +0800
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
> On Mon,  9 Jun 2014 21:27:16 +0800 Chen Yucong <slaoub@gmail.com> wrote:
> 
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
> > 
> > ...
> >
> 
> Are you sure this is an equivalent-to-before change?  If so, then I
> can't immediately see why :(
> 
The relative design idea is to keep

   ratio
	== scan_target[anon] : scan_target[file]
              == really_scanned_num[anon] : really_scanned_num[file]

The original implementation is 
   ratio 
        == (scan_target[anon] * percentage_anon) / 
           (scan_target[file] * percentage_file) 

To keep the original ratio, percentage_anon should equal to
percentage_file. In other word, we need to calculate the difference
value between percentage_anon and percentage_file, we also have to
record the original scan targets for this.

Instead, we can calculate the *ratio* at the beginning of
shrink_lruvec(). As a result, this can avoid introducing the extra 40
bytes.

In short, we have the same goal: keep the same *ratio* from beginning to
end.

thx!
cyc
 
       

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
