Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7200C6B0003
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 19:03:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id h11so345949pfn.0
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 16:03:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p19sor124447pfh.49.2018.02.27.16.03.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Feb 2018 16:03:25 -0800 (PST)
Date: Wed, 28 Feb 2018 09:03:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: strength reduce zspage_size calculation
Message-ID: <20180228000319.GD168047@rodete-desktop-imager.corp.google.com>
References: <20180226122126.coxtwkv5bqifariz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180226122126.coxtwkv5bqifariz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joey Pabalinas <joeypabalinas@gmail.com>
Cc: linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org

Hi Joey,

On Mon, Feb 26, 2018 at 02:21:26AM -1000, Joey Pabalinas wrote:
> Replace the repeated multiplication in the main loop
> body calculation of zspage_size with an equivalent
> (and cheaper) addition operation.
> 
> Signed-off-by: Joey Pabalinas <joeypabalinas@gmail.com>
> 
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index c3013505c30527dc42..647a1a2728634b5194 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -821,15 +821,15 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
>   */
>  static int get_pages_per_zspage(int class_size)
>  {
> +	int zspage_size = 0;
>  	int i, max_usedpc = 0;
>  	/* zspage order which gives maximum used size per KB */
>  	int max_usedpc_order = 1;
>  
>  	for (i = 1; i <= ZS_MAX_PAGES_PER_ZSPAGE; i++) {
> -		int zspage_size;
>  		int waste, usedpc;
>  
> -		zspage_size = i * PAGE_SIZE;
> +		zspage_size += PAGE_SIZE;
>  		waste = zspage_size % class_size;
>  		usedpc = (zspage_size - waste) * 100 / zspage_size;
>  

Thanks for the patch! However, it's used only zs_create_pool which
is really cold path so I don't feel it would improve for real practice.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
