Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBC16B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 22:18:09 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id w135so1458816oie.11
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 19:18:09 -0800 (PST)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id s89si984804otb.118.2018.02.07.19.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 19:18:08 -0800 (PST)
Date: Thu, 8 Feb 2018 14:18:04 +1100
From: "Tobin C. Harding" <me@tobin.cc>
Subject: Re: [RFC] Warn the user when they could overflow mapcount
Message-ID: <20180208031804.GD3304@eros>
References: <20180208021112.GB14918@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180208021112.GB14918@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Feb 07, 2018 at 06:11:12PM -0800, Matthew Wilcox wrote:
> 
> Kirill and I were talking about trying to overflow page->_mapcount
> the other day and realised that the default settings of pid_max and
> max_map_count prevent it [1].  But there isn't even documentation to
> warn a sysadmin that they've just opened themselves up to the possibility
> that they've opened their system up to a sufficiently-determined attacker.
> 
> I'm not sufficiently wise in the ways of the MM to understand exactly
> what goes wrong if we do wrap mapcount.  Kirill says:
> 
>   rmap depends on mapcount to decide when the page is not longer mapped.
>   If it sees page_mapcount() == 0 due to 32-bit wrap we are screwed;
>   data corruption, etc.
> 
> That seems pretty bad.  So here's a patch which adds documentation to the
> two sysctls that a sysadmin could use to shoot themselves in the foot,
> and adds a warning if they change either of them to a dangerous value.
> It's possible to get into a dangerous situation without triggering this
> warning (already have the file mapped a lot of times, then lower pid_max,
> then raise max_map_count, then map the file a lot more times), but it's
> unlikely to happen.
> 
> Comments?
> 
> [1] map_count counts the number of times that a page is mapped to
> userspace; max_map_count restricts the number of times a process can
> map a page and pid_max restricts the number of processes that can exist.
> So map_count can never be larger than pid_max * max_map_count.
> 
> diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
> index 412314eebda6..ec90cd633e99 100644
> --- a/Documentation/sysctl/kernel.txt
> +++ b/Documentation/sysctl/kernel.txt
> @@ -718,6 +718,8 @@ pid_max:
>  PID allocation wrap value.  When the kernel's next PID value
>  reaches this value, it wraps back to a minimum PID value.
>  PIDs of value pid_max or larger are not allocated.
> +Increasing this value without decreasing vm.max_map_count may
> +allow a hostile user to corrupt kernel memory
>  
>  ==============================================================
>  
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index ff234d229cbb..0ab306ea8f80 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -379,7 +379,8 @@ While most applications need less than a thousand maps, certain
>  programs, particularly malloc debuggers, may consume lots of them,
>  e.g., up to one or two maps per allocation.
>  
> -The default value is 65536.
> +The default value is 65530.  Increasing this value without decreasing
> +pid_max may allow a hostile user to corrupt kernel memory.

Just checking - did you mean the final '0' on this value?

	Tobin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
