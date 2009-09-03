Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CECCC6B0095
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 02:16:08 -0400 (EDT)
Received: by ewy22 with SMTP id 22so1264369ewy.4
        for <linux-mm@kvack.org>; Wed, 02 Sep 2009 23:16:12 -0700 (PDT)
Date: Thu, 3 Sep 2009 15:14:54 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: BUG? misused atomic instructions in mm/swapfile.c
Message-Id: <20090903151454.c0bd1bcd.minchan.kim@barrios-desktop>
In-Reply-To: <2014bcab0909022255i53e9f72t4c131c648fb4754@mail.gmail.com>
References: <2014bcab0909022255i53e9f72t4c131c648fb4754@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?7ZmN7Iug?= shin hong <hongshin@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Sep 2009 14:55:22 +0900
i??i?  shin hong <hongshin@gmail.com> wrote:

> Hello. I am reporting atomic instructions usages
> which are suspected to be misused in mm/swapfile.c
> of Linux 2.6.30.5.
> 
> I do not have much background on mm
> so that I am not certain whether it is correct or not.
> But I hope this report is helpful. Please examine the code.
> 
> In try_to_use(), setup_swap_extents(), and SYSCALL_DEFINE2(),
> there are following codes:

First of all, I can find it only in try_to_use. 
Do I miss somewhere?

> 
>     if (atomic_read(&start_mm->mm_users) == 1) {
>         mmput(start_mm) ;
>         start_mm = &init_mm ;
>         atomic_inc(&init_mm.mm_users) ;
>     }
> 
> It first checks start_mm->mm_users and then increments its value by one.
> 
> If one of these functions is executed in two different threads
> for the same start_mm concurrently,
> mmput(start_mm) can be executed twice as result of race.
Is is a matter? 

I looked over the code. 
Couldn't atomic_dec_and_test avoid your concern?

void mmput(struct mm_struct *mm) 
{
        might_sleep();

        if (atomic_dec_and_test(&mm->mm_users)) {
...


> 
> I think it would be better to combine two atomic operations
> into one atomic operation (e.g. atomic_cmpxchg).
> 
> Thank you.
> 
> Sincerely
> Shin Hong
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
