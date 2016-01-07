Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7708A6B0007
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 04:53:01 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id bc4so204147004lbc.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 01:53:01 -0800 (PST)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com. [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id qe8si58506904lbb.207.2016.01.07.01.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 01:53:00 -0800 (PST)
Received: by mail-lb0-x22f.google.com with SMTP id bc4so204146789lbc.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 01:52:59 -0800 (PST)
Date: Thu, 7 Jan 2016 12:52:56 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 0/2] fix up {arg,env}_{start,end} vs prctl
Message-ID: <20160107095256.GA4306@uranus>
References: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Jarod Wilson <jarod@redhat.com>, Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Jan 06, 2016 at 06:02:27AM +0100, Mateusz Guzik wrote:
> An unprivileged user can trigger an oops on a kernel with
> CONFIG_CHECKPOINT_RESTORE.
> 
> proc_pid_cmdline_read takes mmap_sem for reading and obtains args + env
> start/end values. These get sanity checked as follows:
>         BUG_ON(arg_start > arg_end);
>         BUG_ON(env_start > env_end);
> 
> These can be changed by prctl_set_mm. Turns out also takes the semaphore for
> reading, effectively rendering it useless. This results in:

Thanks a lot for catching it! You know I tried to escape taking sem
for writing as long as I could so another option might be simply
zap these BUG_ON and rather exit with -EINVAL. On the other hands
modification under read-lock of course is not correct in terms
of "general approach" but these members are special so I took
a risk. Anyway,

Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

Thanks again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
