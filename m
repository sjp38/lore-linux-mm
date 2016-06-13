Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EDF526B0005
	for <linux-mm@kvack.org>; Sun, 12 Jun 2016 21:51:22 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u74so52613877lff.0
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 18:51:22 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id i83si12456712wmf.117.2016.06.12.18.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Jun 2016 18:51:21 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id v199so58336101wmv.0
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 18:51:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160608141058.GB498@swordfish>
References: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
 <20160608001625.GB27258@bbox> <CADAEsF_wYQpMP_Hpr2LEnafxteV7aN1kCdAhLWhk13Ed1ueZ+A@mail.gmail.com>
 <20160608051352.GA28155@bbox> <CADAEsF_q0qzk2D_cKMCcvHxF7_eY1cQVKrBp0eM_v05jjOjSOA@mail.gmail.com>
 <20160608141058.GB498@swordfish>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Mon, 13 Jun 2016 09:51:20 +0800
Message-ID: <CADAEsF9zV_ii4QGewpOcnD0oLyi3gbbvs50jEBXYjEqjMsPGtw@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: add trace events for zs_compact
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, rostedt@goodmis.org, mingo@redhat.com

Hi, Sergey:

2016-06-08 22:10 GMT+08:00 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>:
> Hello,
>
> On (06/08/16 14:39), Ganesh Mahendran wrote:
>> >> > On Tue, Jun 07, 2016 at 04:56:44PM +0800, Ganesh Mahendran wrote:
>> >> >> Currently zsmalloc is widely used in android device.
>> >> >> Sometimes, we want to see how frequently zs_compact is
>> >> >> triggered or how may pages freed by zs_compact(), or which
>> >> >> zsmalloc pool is compacted.
>> >> >>
>> >> >> Most of the time, user can get the brief information from
>> >> >> trace_mm_shrink_slab_[start | end], but in some senario,
>> >> >> they do not use zsmalloc shrinker, but trigger compaction manually.
>> >> >> So add some trace events in zs_compact is convenient. Also we
>> >> >> can add some zsmalloc specific information(pool name, total compact
>> >> >> pages, etc) in zsmalloc trace.
>> >> >
>> >> > Sorry, I cannot understand what's the problem now and what you want to
>> >> > solve. Could you elaborate it a bit?
>> >> >
>> >> > Thanks.
>> >>
>> >> We have backported the zs_compact() to our product(kernel 3.18).
>> >> It is usefull for a longtime running device.
>> >> But there is not a convenient way to get the detailed information
>> >> of zs_comapct() which is usefull for  performance optimization.
>> >> Information about how much time zs_compact used, which pool is
>> >> compacted, how many page freed, etc.
>
> sorry, couldn't check my email earlier.

Sorry for the late response. I'm off for a few days annual leave.

>
> zs_compact() is just one of the N sites that are getting called by
> the shrinker; optimization here will "solve" only 1/N of the problems.
> are there any trace events in any other shrinker callbacks?

Yes, there are trace events in ext4 shrinker:
-----
fs/ext4/extents_status.c: ext4_es_scan()
{
        trace_ext4_es_shrink_scan_enter(sbi->s_sb, nr_to_scan, ret);
...
        nr_shrunk = __es_shrink(sbi, nr_to_scan, NULL);

        trace_ext4_es_shrink_scan_exit(sbi->s_sb, nr_shrunk, ret);
}
-----

>
>
> why trace_mm_shrink_slab_start()/trace_mm_shrink_slab_end()/etc. don't work you?

I think trace_mm_shrink_slab_start/end is for general usage. If we
have some specific information(such as pool name,  shrink count
or others in the future), it will be convenient when we have
zs_compact trace event.

Also, if user do manually zs_compact instead of shrinker,
he can get zs_compact information from trace event.

Thanks.

>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
