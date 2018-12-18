Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D61DE8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:52:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so11993184edi.0
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:52:29 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f20-v6si3213523ejc.222.2018.12.18.01.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 01:52:28 -0800 (PST)
Date: Tue, 18 Dec 2018 10:52:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Fix mm->owner point to a tsk that has been free
Message-ID: <20181218095226.GD17870@dhcp22.suse.cz>
References: <1545110684-8730-1-git-send-email-gchen.guomin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1545110684-8730-1-git-send-email-gchen.guomin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gchen.guomin@gmail.com
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, guominchen@tencent.com, "Eric W. Biederman" <ebiederm@xmission.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 18-12-18 13:24:44, gchen.guomin@gmail.com wrote:
> From: guomin chen <gchen.guomin@gmail.com>
> 
> When mm->owner is modified by exit_mm, if the new owner directly calls
> unuse_mm to exit, it will cause Use-After-Free. Due to the unuse_mm()
> directly sets tsk->mm=NULL.
> 
>  Under normal circumstances,When do_exit exits, mm->owner will
>  be updated on exit_mm(). but when the kernel process calls
>  unuse_mm() and then exits,mm->owner cannot be updated. And it
>  will point to a task that has been released.
> 
> The current issue flow is as follows: (Process A,B,C use the same mm)
> Process C              Process A         Process B
> qemu-system-x86_64:     kernel:vhost_net  kernel: vhost_net
> open /dev/vhost-net
>   VHOST_SET_OWNER   create kthread vhost-%d  create kthread vhost-%d
>   network init           use_mm()          use_mm()
>    ...                   ...
>    Abnormal exited
>    ...
>   do_exit
>   exit_mm()
>   update mm->owner to A
>   exit_files()
>    close_files()
>    kthread_should_stop() unuse_mm()
>     Stop Process A       tsk->mm=NULL
>                          do_exit()
>                          can't update owner
>                          A exit completed  vhost-%d  rcv first package
>                                            vhost-%d build rcv buffer for vq
>                                            page fault
>                                            access mm & mm->owner
>                                            NOW,mm->owner still pointer A
>                                            kernel UAF
>     stop Process B
> 
> Although I am having this issue on vhost_net,But it affects all users of
> unuse_mm.

I am confused. How can we ever assign the owner to a kernel thread. We
skip those explicitly. It simply doesn't make any sense to have an owner
a kernel thread.
-- 
Michal Hocko
SUSE Labs
