Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3E926B0003
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:29:44 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f19-v6so4527344plr.23
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 23:29:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2-v6si624719plh.44.2018.03.26.23.29.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 23:29:43 -0700 (PDT)
Date: Tue, 27 Mar 2018 08:29:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180327062939.GV5652@dhcp22.suse.cz>
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, gorcunov@openvz.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 27-03-18 02:20:39, Yang Shi wrote:
[...]
The patch looks reasonable to me. Maybe it would be better to be more
explicit about the purpose of the patch. As others noticed, this alone
wouldn't solve the mmap_sem contention issues. I _think_ that if you
were more explicit about the mmap_sem abuse it would trigger less
questions.

I have just one more question. Now that you are touching this area,
would you be willing to remove the following ugliness?

> diff --git a/kernel/sys.c b/kernel/sys.c
> index f2289de..17bddd2 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1959,7 +1959,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>  			return error;
>  	}
>  
> -	down_write(&mm->mmap_sem);
> +	down_read(&mm->mmap_sem);

Why do we need to hold mmap_sem here and call find_vma, when only
PR_SET_MM_ENV_END: is consuming it? I guess we can replace it wit the
new lock and take the mmap_sem only for PR_SET_MM_ENV_END.

Thanks!
-- 
Michal Hocko
SUSE Labs
