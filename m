Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 393276B0038
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 16:40:27 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so44810831pdb.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 13:40:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rt8si15495407pbb.199.2015.06.10.13.40.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 13:40:26 -0700 (PDT)
Date: Wed, 10 Jun 2015 13:40:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] panic when reboot the system
Message-Id: <20150610134025.48f0d6b73dcddae081202cc7@linux-foundation.org>
In-Reply-To: <5577E483.7060500@huawei.com>
References: <5577E483.7060500@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@suse.de>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Rafael Aquini <aquini@redhat.com>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Wed, 10 Jun 2015 15:17:23 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:

> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000007
> 
> Pid: 1, comm: init Tainted: G  R        O 3.4.24.19-0.11-default #1
> Call Trace:
>  [<ffffffff8144dd24>] panic+0xc1/0x1e2
>  [<ffffffff8104483b>] do_exit+0x7db/0x8d0
>  [<ffffffff81044c7a>] do_group_exit+0x3a/0xa0
>  [<ffffffff8105394b>] get_signal_to_deliver+0x1ab/0x5e0
>  [<ffffffff81002270>] do_signal+0x60/0x5f0
>  [<ffffffff8145bf97>] ? do_page_fault+0x4a7/0x4d0
>  [<ffffffff81170d2c>] ? poll_select_copy_remaining+0xec/0x140
>  [<ffffffff81002885>] do_notify_resume+0x65/0x80
>  [<ffffffff8124ca7e>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff814587ab>] retint_signal+0x4d/0x92
> 
> 
> The system has a little memory left, then reboot it, and get the panic.
> Perhaps this is a bug and trigger it like this and the latest kernel maybe
> also have the problem.
> 
> use a lot of memory
>   wake up kswapd()
>     reclaim some pages from init thread (pid=1)
>       reboot
>         shutdown the disk
>           init thread read data from disk
>             page fault, because the page has already reclaimed
>               receive SIGBUS, and init thread exit
>                 trigger the panic
> 
> 

Interesting.  3.4 is a pretty old kernel but I expect at least some of
this remains.

- Why the heck did the disk get shut down while init still had pages
  on it?  We shouldn't be able to get that far without having done a
  swapoff.

- Ignoring the above, as far as I can tell a regular old I/O error
  during pagein of one of init's pages (anon or file-backed) will
  result in the delivery of SIGBUS to init.  If init isn't catching
  SIGBUS (or if init's signal-handling code is also swapped out to a
  bad sector??) then we're going to kill init and the system will panic
  as above.

  I'm not sure what we can do in this situation - init has
  permanently lost some text or data and is hence dead.  But panicing
  the system doesn't seem the correct response.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
