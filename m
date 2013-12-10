Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6EC6B0138
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 19:50:48 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so6177215pdj.36
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 16:50:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id q8si8772306pav.173.2013.12.09.16.50.46
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 16:50:47 -0800 (PST)
Date: Mon, 9 Dec 2013 16:50:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
Message-Id: <20131209165044.cf7de2edb8f4205d5ac02ab0@linux-foundation.org>
In-Reply-To: <52935762.1080409@ti.com>
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com>
	<529217C7.6030304@cogentembedded.com>
	<52935762.1080409@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Mon, 25 Nov 2013 08:57:54 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:

> On Sunday 24 November 2013 10:14 AM, Sergei Shtylyov wrote:
> > Hello.
> > 
> > On 24-11-2013 3:28, Santosh Shilimkar wrote:
> > 
> >> Building ARM with NO_BOOTMEM generates below warning. Using min_t
> > 
> >    Where is that below? :-)
> > 
> Damn.. Posted a wrong version of the patch ;-(
> Here is the one with warning message included.
> 
> >From 571dfdf4cf8ac7dfd50bd9b7519717c42824f1c3 Mon Sep 17 00:00:00 2001
> From: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Date: Sat, 23 Nov 2013 18:16:50 -0500
> Subject: [PATCH] mm: nobootmem: avoid type warning about alignment value
> 
> Building ARM with NO_BOOTMEM generates below warning.
> 
> mm/nobootmem.c: In function _____free_pages_memory___:
> mm/nobootmem.c:88:11: warning: comparison of distinct pointer types lacks a cast
> 
> Using min_t to find the correct alignment avoids the warning.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> ---
>  mm/nobootmem.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 2c254d3..8954e43 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -85,7 +85,7 @@ static void __init __free_pages_memory(unsigned long start, unsigned long end)
>  	int order;
>  
>  	while (start < end) {
> -		order = min(MAX_ORDER - 1UL, __ffs(start));
> +		order = min_t(size_t, MAX_ORDER - 1UL, __ffs(start));
>  

size_t makes no sense.  Neither `order', `MAX_ORDER', 1UL nor __ffs()
have that type.

min() warnings often indicate that the chosen types are inappropriate,
and suppressing them with min_t() should be a last resort.

MAX_ORDER-1UL has type `unsigned long' (yes?) and __ffs() should return
unsigned long (except arch/arc which decided to be different).

Why does it warn?  What's the underlying reason?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
