Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 570026B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:27:52 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 30-v6so8843757ple.19
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 12:27:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k3si11792320pff.82.2018.03.26.12.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 12:27:51 -0700 (PDT)
Date: Mon, 26 Mar 2018 12:27:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: kmemleak: wait for scan completion before disabling
 free
Message-Id: <20180326122750.a41634c409f29b9d411b5d33@linux-foundation.org>
In-Reply-To: <20180326122611.acbfe1bfe6f7c1792b42a3a7@linux-foundation.org>
References: <1522063429-18992-1-git-send-email-vinmenon@codeaurora.org>
	<20180326154421.obk7ikx3h5ko62o5@armageddon.cambridge.arm.com>
	<20180326122611.acbfe1bfe6f7c1792b42a3a7@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org

On Mon, 26 Mar 2018 12:26:11 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> > 
> > It looks fine to me. Maybe Andrew can pick it up.
> > 
> > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> Well, the comment says:
> 
> /*
>  * Stop the automatic memory scanning thread. This function must be called
>  * with the scan_mutex held.
>  */
> static void stop_scan_thread(void)
> 
> 
> So shouldn't we do it this way?

If "yes" then could someone please runtime test this?

> --- a/mm/kmemleak.c~mm-kmemleak-wait-for-scan-completion-before-disabling-free-fix
> +++ a/mm/kmemleak.c
> @@ -1919,9 +1919,9 @@ static void __kmemleak_do_cleanup(void)
>   */
>  static void kmemleak_do_cleanup(struct work_struct *work)
>  {
> +	mutex_lock(&scan_mutex);
>  	stop_scan_thread();
>  
> -	mutex_lock(&scan_mutex);
>  	/*
>  	 * Once it is made sure that kmemleak_scan has stopped, it is safe to no
>  	 * longer track object freeing. Ordering of the scan thread stopping and
> _
> 
