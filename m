Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 774D06B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:13:55 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id b16so12645532igk.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 09:13:55 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0133.hostedemail.com. [216.40.44.133])
        by mx.google.com with ESMTP id m5si12384617icr.70.2015.01.12.09.13.53
        for <linux-mm@kvack.org>;
        Mon, 12 Jan 2015 09:13:54 -0800 (PST)
Message-ID: <1421082828.9233.13.camel@perches.com>
Subject: Re: [PATCH 1/5] mm/util: add kstrdup_const
From: Joe Perches <joe@perches.com>
Date: Mon, 12 Jan 2015 09:13:48 -0800
In-Reply-To: <1421054323-14430-2-git-send-email-a.hajda@samsung.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
	 <1421054323-14430-2-git-send-email-a.hajda@samsung.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2015-01-12 at 10:18 +0100, Andrzej Hajda wrote:
> The patch adds alternative version of kstrdup which returns pointer
> to constant char array. The function checks if input string is in
> persistent and read-only memory section, if yes it returns the input string,
> otherwise it fallbacks to kstrdup.
> kstrdup_const is accompanied by kfree_const performing conditional memory
> deallocation of the string.

trivia:

> diff --git a/mm/util.c b/mm/util.c
[]
> +void kfree_const(const void *x)
> +{
> +	if (!is_kernel_rodata((unsigned long)x))
> +		kfree(x);
> +}
> +EXPORT_SYMBOL(kfree_const);
[]
> +const char *kstrdup_const(const char *s, gfp_t gfp)
> +{
> +	if (is_kernel_rodata((unsigned long)s))
> +		return s;
> +
> +	return kstrdup(s, gfp);
> +}
> +EXPORT_SYMBOL(kstrdup_const);

I think it'd be nicer if these used the same form
even if it's a vertical line or 2 longer

void kfree_const(const void *x)
{
	if (is_kernel_rodata((unsigned long)x))
		return;

	kfree(x);
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
