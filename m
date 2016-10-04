Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C03B6B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 13:34:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so132338422wmg.3
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 10:34:29 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v14si6470320wmv.75.2016.10.04.10.34.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 10:34:28 -0700 (PDT)
Date: Tue, 4 Oct 2016 19:34:25 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: page_cache_tree_insert WARN_ON hit on 4.8+
Message-ID: <20161004173425.GA1223@cmpxchg.org>
References: <20161004170955.n25polpcsotmwcdq@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004170955.n25polpcsotmwcdq@codemonkey.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi Dave,

On Tue, Oct 04, 2016 at 01:09:55PM -0400, Dave Jones wrote:
> Hit this during a trinity run.
> Kernel built from v4.8-1558-g21f54ddae449
> 
> WARNING: CPU: 0 PID: 5670 at ./include/linux/swap.h:276 page_cache_tree_insert+0x198/0x1b0
> CPU: 0 PID: 5670 Comm: trinity-c6 Not tainted 4.8.0-think+ #2
>  ffffc900003a3ab8 ffffffffb03dc311 0000000000000000 0000000000000000
>  ffffffffb0c063d6 ffffffffb018d898 ffffc900003a3af8 ffffffffb008b550
>  00000114003a3b30 ffffffffb0c063d6 0000000000000114 0000000000000000
> Call Trace:
>  [<ffffffffb03dc311>] dump_stack+0x6c/0x9b
>  [<ffffffffb018d898>] ? page_cache_tree_insert+0x198/0x1b0
>  [<ffffffffb008b550>] __warn+0x110/0x130
>  [<ffffffffb008b6dc>] warn_slowpath_null+0x2c/0x40
>  [<ffffffffb018d898>] page_cache_tree_insert+0x198/0x1b0
>  [<ffffffffb01900c4>] __add_to_page_cache_locked+0x1a4/0x3a0
>  [<ffffffffb0190379>] add_to_page_cache_lru+0x79/0x1c0
>  [<ffffffffb0193456>] generic_file_read_iter+0x916/0xce0
>  [<ffffffffb0232090>] do_iter_readv_writev+0x120/0x1c0
>  [<ffffffffb0192b40>] ? wait_on_page_bit_killable+0x100/0x100
>  [<ffffffffb0192b40>] ? wait_on_page_bit_killable+0x100/0x100
>  [<ffffffffb0232e29>] do_readv_writev+0x1f9/0x2e0
>  [<ffffffffb025d44e>] ? __fdget_pos+0x5e/0x70
>  [<ffffffffb025d44e>] ? __fdget_pos+0x5e/0x70
>  [<ffffffffb025d44e>] ? __fdget_pos+0x5e/0x70
>  [<ffffffffb0232f74>] vfs_readv+0x64/0x90
>  [<ffffffffb023300d>] do_readv+0x6d/0x120
>  [<ffffffffb0234907>] SyS_readv+0x27/0x30
>  [<ffffffffb000276f>] do_syscall_64+0x7f/0x200
>  [<ffffffffb09cfa8b>] entry_SYSCALL64_slow_path+0x25/0x25

Thanks for the report.

I've been trying to reproduce this too after Linus got hit by it. Is
there any way to trace back the steps what trinity was doing exactly?
What kind of file(system) this was operating on, file size, what the
/proc/vmstat delta before the operation until the trigger looks like?

The call to WARN() is new, the actual underlying bug could have been
around for a while, making it hard to narrow down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
