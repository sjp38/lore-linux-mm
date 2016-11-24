Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9706B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 09:21:03 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id f8so6270227wje.5
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 06:21:03 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e8si37175118wjh.217.2016.11.24.06.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 06:21:01 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id m203so5089109wma.3
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 06:21:01 -0800 (PST)
Date: Thu, 24 Nov 2016 15:21:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/oom_kill.c: fix initial value of victim_points
 variable
Message-ID: <20161124142100.GA20717@dhcp22.suse.cz>
References: <CAPhj7_CW_X5UuLPUfUFEA0mfPB_6OSO195ZQokckGOZzJevyyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPhj7_CW_X5UuLPUfUFEA0mfPB_6OSO195ZQokckGOZzJevyyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?0JDQtNGL0LPQttGLINCe0L3QtNCw0YA=?= <ondar07@gmail.com>
Cc: linux-mm@kvack.org

On Thu 24-11-16 16:11:53, D?D'N?D3D?N? D?D 1/2 D'D?N? wrote:
> If the initial value of victim_points variable is equal to 0,
> oom killer may choose a victim incorrectly.
> For example, parent points > 0, 0 < child_points < parent points
> (chosen_points).
> In this example, current oom killer chooses this child, not parent.

Which is how the code is supposed to work. We do sacrifice child to save
work done by the parent. So the main point here is to choose the largest
child (if any) of the selected victim. If you think about that any
"child" with points > selected_victim shouldn't be possible because it
would have been child to be selected.

So NAK to this.

> To apply the patch, in the root of a kernel tree use:
> patch -p1 <this_fix.patch
> 
> Signed-off-by: Adygzhy Ondar <ondar07@gmail.com>
> 
> ------------------------------------------------------------------------------------
> --- linux/mm/oom_kill.c.orig 2016-11-24 15:03:43.711235386 +0300
> +++ linux/mm/oom_kill.c 2016-11-24 15:04:00.851942474 +0300
> @@ -812,7 +812,7 @@ static void oom_kill_process(struct oom_
>   struct task_struct *child;
>   struct task_struct *t;
>   struct mm_struct *mm;
> - unsigned int victim_points = 0;
> + unsigned int victim_points = points;
>   static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>        DEFAULT_RATELIMIT_BURST);
>   bool can_oom_reap = true;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
