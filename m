Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB076B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 19:59:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r136so12888031wmf.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 16:59:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b133si2297729wmc.53.2017.09.26.16.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 16:59:51 -0700 (PDT)
Date: Tue, 26 Sep 2017 16:59:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: introduce validity check on vm dirtiness
 settings
Message-Id: <20170926165949.77e27aea0b92a226e7905060@linux-foundation.org>
In-Reply-To: <1506035552-13010-1-git-send-email-laoar.shao@gmail.com>
References: <1506035552-13010-1-git-send-email-laoar.shao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: linux-mm@kvack.org

On Fri, 22 Sep 2017 07:12:32 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:

> we can find the logic in domain_dirty_limits() that
> when dirty bg_thresh is bigger than dirty thresh,
> bg_thresh will be set as thresh * 1 / 2.
> 	if (bg_thresh >= thresh)
> 		bg_thresh = thresh / 2;
> 
> But actually we can set vm background dirtiness bigger than
> vm dirtiness successfully. This behavior may mislead us.
> We'd better do this validity check at the beginning.
> 
> ...
>
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -156,6 +156,9 @@ read.
>  Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
>  value lower than this limit will be ignored and the old configuration will be
>  retained.
> +Note: the value of dirty_bytes also cannot be set lower than
> +dirty_background_bytes or the amount of memory corresponding to
> +dirty_background_ratio.

I think this means that a script which alters both dirty_bytes and
dirty_background_bytes must alter dirty_background_bytes first if they
are being decreased and must alter dirty_bytes first if they are being
increased.  Or something like that.

And existing scripts which do not do this will cease to work correctly,
no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
