Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 340D76B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 18:23:43 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so7495314pdj.33
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:23:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pg10si6820792pbb.144.2014.02.03.15.23.42
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 15:23:42 -0800 (PST)
Date: Mon, 3 Feb 2014 15:23:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/8] mm/swap: fix race on swap_info reuse between
 swapoff and swapon
Message-Id: <20140203152340.b28bb35698ee75615eb23041@linux-foundation.org>
In-Reply-To: <000d01cf1b47$f12e11f0$d38a35d0$%yang@samsung.com>
References: <000d01cf1b47$f12e11f0$d38a35d0$%yang@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: hughd@google.com, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Seth Jennings' <sjennings@variantweb.net>, 'Heesub Shin' <heesub.shin@samsung.com>, mquzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Mon, 27 Jan 2014 18:03:04 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:

> swapoff clear swap_info's SWP_USED flag prematurely and free its resources
> after that. A concurrent swapon will reuse this swap_info while its previous
> resources are not cleared completely.
> 
> These late freed resources are:
>  - p->percpu_cluster
>  - swap_cgroup_ctrl[type]
>  - block_device setting
>  - inode->i_flags &= ~S_SWAPFILE
> 
> This patch clear SWP_USED flag after all its resources freed, so that swapon
> can reuse this swap_info by alloc_swap_info() safely.
> 
> This patch is just for a rare scenario, aim to correct of code.

I believe that
http://ozlabs.org/~akpm/mmots/broken-out/mm-swap-fix-race-on-swap_info-reuse-between-swapoff-and-swapon.patch
makes this patch redundant?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
