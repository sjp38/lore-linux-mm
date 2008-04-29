Date: Tue, 29 Apr 2008 14:57:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Page Faults slower in 2.6.25-rc9 than 2.6.23
In-Reply-To: <d43160c70804290610t2135a271hd9b907529e89e74e@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0804291447040.5058@blonde.site>
References: <d43160c70804290610t2135a271hd9b907529e89e74e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Apr 2008, Ross Biro wrote:
> I don't know if this has been noticed before.  I was benchmarking my
> page table relocation code and I noticed that on 2.6.25-rc9 page
> faults take 10% more time than on 2.6.22.  This is using lmbench
> running on an intel x86_64 system.  The good news is that the page
> table relocation code now only adds a 1.6% slow down to page faults.

Do you have CONFIG_CGROUP_MEM_RES_CTLR=y in 2.6.25?
That added about 20% to my lmbench "Page Fault" tests (with
adverse effect on several others e.g. the fork, exec, sh group).

Try the same kernel with boot option "cgroup_disable=memory",
that should recoup most (but not quite all) of the slowdown;
or rebuild with n to CGROUP_MEM_RES_CTLR.

But your "Mmap Latency" went up 425% ??

Hugh

> 
>     Ross
> 
> 2.6.25-rc9:
> 
> File & VM system latencies in microseconds - smaller is better
> -------------------------------------------------------------------------------
> Host                 OS   0K File      10K File     Mmap    Prot   Page   100fd
>                         Create Delete Create Delete Latency Fault  Fault  selct
> --------- ------------- ------ ------ ------ ------ ------- ----- ------- -----
> ipnn2     Linux 2.6.25-   13.9 7.6111  103.4 9.7453   926.0 0.711 2.14250 2.552
> ipnn2     Linux 2.6.25-   13.7 7.6243  310.7 9.6574   932.0 0.750 2.15970 2.555
> ipnn2     Linux 2.6.25-   13.9 7.6831  192.5   10.0   927.0 0.760 2.21310 2.553
> ipnn2     Linux 2.6.25-   13.9 7.5739   98.4 9.5330   927.0 0.703 2.17610 2.554
> ipnn2     Linux 2.6.25-   14.6 7.6429   39.1   10.8   935.0 0.763 2.17250 2.552
> ipnn2     Linux 2.6.25-   14.1 7.8777  129.8 9.9375   930.0 0.782 2.26460 2.559
> ipnn2     Linux 2.6.25-   14.8 7.9639  623.8 8.2042   927.0 0.773 2.21510 2.557
> ipnn2     Linux 2.6.25-   14.4 7.5842  622.3 8.3272   920.0 0.745 2.22210 2.558
> ipnn2     Linux 2.6.25-   14.2 7.6339   45.7   10.2   935.0 0.675 2.23860 2.554
> ipnn2     Linux 2.6.25-   14.1 7.7175  263.7   10.1   929.0 0.762 2.22350 2.556
> ipnn2     Linux 2.6.25-   13.9 8.1230  378.2 9.4343   975.0 0.752 2.25920 2.554
> 
> 
> 2.6.23:
> File & VM system latencies in microseconds - smaller is better
> -------------------------------------------------------------------------------
> Host                 OS   0K File      10K File     Mmap    Prot   Page   100fd
>                         Create Delete Create Delete Latency Fault  Fault  selct
> --------- ------------- ------ ------ ------ ------ ------- ----- ------- -----
> ipnn2     Linux 2.6.23-                               218.0 0.912 1.94010 2.626
> ipnn2     Linux 2.6.23-                               219.0 1.095 1.96400 2.597
> ipnn2     Linux 2.6.23-                               219.0 0.774 1.96640 2.603
> ipnn2     Linux 2.6.23-                               221.0 0.946 1.99950 2.601
> ipnn2     Linux 2.6.23-                               219.0 0.902 1.99160 2.733
> ipnn2     Linux 2.6.23-                               217.0 0.904 2.04790 2.601
> ipnn2     Linux 2.6.23-                               225.0 0.893 1.99620 2.600

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
