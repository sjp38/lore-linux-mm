Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 209C06B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 09:00:39 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id md12so3627588pbc.33
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 06:00:38 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id os2si10855432pbc.168.2014.06.16.06.00.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 06:00:38 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so4451724pab.2
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 06:00:37 -0700 (PDT)
Message-ID: <1402923474.3958.34.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
From: Chen Yucong <slaoub@gmail.com>
Date: Mon, 16 Jun 2014 20:57:54 +0800
In-Reply-To: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-06-09 at 21:27 +0800, Chen Yucong wrote:
> Via https://lkml.org/lkml/2013/4/10/334 , we can find that recording the
> original scan targets introduces extra 40 bytes on the stack. This patch
> is able to avoid this situation and the call to memcpy(). At the same time,
> it does not change the relative design idea.
> 
> ratio = original_nr_file / original_nr_anon;
> 
> If (nr_file > nr_anon), then ratio = (nr_file - x) / nr_anon.
>  x = nr_file - ratio * nr_anon;
> 
> if (nr_file <= nr_anon), then ratio = nr_file / (nr_anon - x).
>  x = nr_anon - nr_file / ratio;
> 
Hi Andrew Morton,

I think the patch
 
[PATCH]
mm-vmscanc-avoid-recording-the-original-scan-targets-in-shrink_lruvec-fix.patch

which I committed should be discarded. Because It have some critical
defects.
    1) If we want to solve the divide-by-zero and unfair problems, it
needs to two variables for recording the ratios.
 
    2) For "x = nr_file - ratio * nr_anon", the "x" is likely to be a
negative number. we can assume:

      nr[LRU_ACTIVE_FILE] = 30
      nr[LRU_INACTIVE_FILE] = 30
      nr[LRU_ACTIVE_ANON] = 0
      nr[LRU_INACTIVE_ANON] = 40

      ratio = 60/40 = 3/2

When the value of (nr_reclaimed < nr_to_reclaim) become false, there are
the following results:
      nr[LRU_ACTIVE_FILE] = 15
      nr[LRU_INACTIVE_FILE] = 15
      nr[LRU_ACTIVE_ANON] = 0
      nr[LRU_INACTIVE_ANON] = 25
 
      nr_file = 30
      nr_anon = 25

      x = 30 - 25 * (3/2) = 30 - 37.5 = -7.5.

The result is too terrible. 
   
   3) This method is less accurate than the original, especially for the
qualitative difference between FILE and ANON that is very small.

thx!
cyc  
   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
