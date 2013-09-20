Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4383C6B0031
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 07:21:37 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id lb1so581106pab.40
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 04:21:36 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id y10so339499wgg.0
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 04:21:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBD_6FMHS3Dg_Zqugs4YCHHDeCgrxypANpPP5K2xTLE0bA@mail.gmail.com>
References: <CAJd=RBBbJMWox5yJaNzW_jUdDfKfWe-Y7d1riYdN6huQStxzcA@mail.gmail.com>
 <CAOMqctQyS2SFraqJpzE0sRFcihFpMHRhT+3QuZhxft=SUXYVDw@mail.gmail.com>
 <CAOMqctQ+XchmXk_Xno6ViAoZF-tHFPpDWoy7LVW1nooa+ywbmg@mail.gmail.com>
 <CAOMqctT2u7E0kwpm052B9pkNo4D=sYHO+Vk=P_TziUb5KvTMKA@mail.gmail.com>
 <20130917211317.GB6537@quack.suse.cz> <CAOMqctT5Wi_Y9ODAnoG-RQiO1oJ+yKR=LnF21swuupyLShL=+w@mail.gmail.com>
 <CAJd=RBD_6FMHS3Dg_Zqugs4YCHHDeCgrxypANpPP5K2xTLE0bA@mail.gmail.com>
From: Michal Suchanek <hramrach@gmail.com>
Date: Fri, 20 Sep 2013 13:20:53 +0200
Message-ID: <CAOMqctSyovsfff++g=cUfRLmyBM9nHrQ7RB4R7z96-aXr9QcEw@mail.gmail.com>
Subject: Re: doing lots of disk writes causes oom killer to kill processes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

Hello,

On 19 September 2013 10:07, Hillf Danton <dhillf@gmail.com> wrote:
> Hello Michal
>
> Take it easy please, the kernel is made by human hands.
>
> Can you please try the diff(and sorry if mail agent reformats it)?
>
> Best Regards
> Hillf
>
>
> --- a/mm/vmscan.c Wed Sep 18 08:44:08 2013
> +++ b/mm/vmscan.c Wed Sep 18 09:31:34 2013
> @@ -1543,8 +1543,11 @@ shrink_inactive_list(unsigned long nr_to
>   * implies that pages are cycling through the LRU faster than
>   * they are written so also forcibly stall.
>   */
> - if (nr_unqueued_dirty == nr_taken || nr_immediate)
> + if (nr_unqueued_dirty == nr_taken || nr_immediate) {
> + if (current_is_kswapd())
> + wakeup_flusher_threads(0, WB_REASON_TRY_TO_FREE_PAGES);
>   congestion_wait(BLK_RW_ASYNC, HZ/10);
> + }
>   }
>
>   /*
> --

I applied the patch and raised the dirty block ratios to 30/10 and the
default 60/40 while imaging a VM and did not observe any problems so I
guess this solves it.

Thanks

Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
