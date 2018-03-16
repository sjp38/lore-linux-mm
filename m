Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF1F06B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 19:04:51 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z11-v6so6278968plo.21
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 16:04:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g8sor2293640pgs.154.2018.03.16.16.04.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 16:04:50 -0700 (PDT)
Date: Fri, 16 Mar 2018 16:04:49 -0700
From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] memory-failure: fix section mismatch
Message-ID: <20180316230448.GA37438@google.com>
References: <20180304071613.16899-1-nick.desaulniers@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180304071613.16899-1-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

El Sat, Mar 03, 2018 at 11:16:11PM -0800 Nick Desaulniers ha dit:

> Clang complains when a variable is declared extern twice, but with two
> different sections. num_poisoned_pages is marked extern and __read_mostly
> in include/linux/swapops.h, but only extern in include/linux/mm.h. Some
> c source files must include both, and thus see the conflicting
> declarations.
> 
> Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>
> ---
>  include/linux/mm.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad06d42adb1a..bd4bd59f02c1 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2582,7 +2582,7 @@ extern int get_hwpoison_page(struct page *page);
>  extern int sysctl_memory_failure_early_kill;
>  extern int sysctl_memory_failure_recovery;
>  extern void shake_page(struct page *p, int access);
> -extern atomic_long_t num_poisoned_pages;
> +extern atomic_long_t num_poisoned_pages __read_mostly;
>  extern int soft_offline_page(struct page *page, int flags);

An equivalent patch was posted by Guenter Roeck and has been picked up
by Andrew: https://patchwork.kernel.org/patch/10243919/
