Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 16BD76B0007
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 02:19:47 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id er20so65043lab.18
        for <linux-mm@kvack.org>; Mon, 28 Jan 2013 23:19:45 -0800 (PST)
Date: Tue, 29 Jan 2013 09:11:08 +0200
From: Pekka Enberg <penberg@kernel.org>
Message-ID: <5107760ca0614_5bf811b9fe4132b@golgotha.mail>
In-Reply-To: <20130128232145.GA2666@blaptop>
References: <1359333506-13599-1-git-send-email-minchan@kernel.org> <CAOJsxLFg_5uhZsvPmVVC0nnsZLGpkJ0W6mHa=aavmguLGuTTnA@mail.gmail.com> <20130128232145.GA2666@blaptop>
Subject: Re: [RESEND PATCH v5 1/4] zram: Fix deadlock bug in partial write
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, stable@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>

On Tue, Jan 29, 2013 at 1:21 AM, Minchan Kim <minchan@kernel.org> wrote:
> How about this?
> ------------------------- >8 -------------------------------
> 
> From 9f8756ae0b0f2819f93cb94dcd38da372843aa12 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Mon, 21 Jan 2013 13:58:52 +0900
> Subject: [RESEND PATCH v5 1/4] zram: Fix deadlock bug in partial read/write
> 
> Now zram allocates new page with GFP_KERNEL in zram I/O path
> if IO is partial. Unfortunately, It may cause deadlock with
> reclaim path like below.
> 
> write_page from fs
> fs_lock
> allocation(GFP_KERNEL)
> reclaim
> pageout
> 				write_page from fs
> 				fs_lock <-- deadlock
> 
> This patch fixes it by using GFP_ATOMIC and GFP_NOIO.
> In read path, we called kmap_atomic so that we need GFP_ATOMIC
> while we need GFP_NOIO in write path.

The patch description makes sense now. Thanks!

On Tue, Jan 29, 2013 at 1:21 AM, Minchan Kim <minchan@kernel.org> wrote:
> We could use GFP_IO instead of GFP_ATOMIC in zram_bvec_read with
> some modification related to buffer allocation in case of partial IO.
> But it needs more churn and prevent merge this patch into stable
> if we should send this to stable so I'd like to keep it as simple
> as possbile. GFP_IO usage could be separate patch after we merge it.

I don't see why something like below couldn't be merged for stable.
Going for GFP_ATOMIC might seem like the simplest thing to go for but
usually bites you in the end.

			Pekka

------------------------- >8 -------------------------------
