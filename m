Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 2CD106B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 21:02:48 -0400 (EDT)
Received: by mail-gh0-f172.google.com with SMTP id r18so18716ghr.31
        for <linux-mm@kvack.org>; Mon, 20 May 2013 18:02:47 -0700 (PDT)
Message-ID: <519AC7B3.5060902@gmail.com>
Date: Mon, 20 May 2013 21:02:43 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 02/02] swapon: add "cluster-discard" support
References: <cover.1369092449.git.aquini@redhat.com> <398ace0dd3ca1283372b3aad3fceeee59f6897d7.1369084886.git.aquini@redhat.com>
In-Reply-To: <398ace0dd3ca1283372b3aad3fceeee59f6897d7.1369084886.git.aquini@redhat.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, kzak@redhat.com, jmoyer@redhat.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de, kosaki.motohiro@gmail.com

> +.B "\-c, \-\-cluster\-discard"
> +Swapping will discard clusters of swap pages in between freeing them
> +and re-writing to them, if the swap device supports that. This option
> +also implies the
> +.I \-d, \-\-discard
> +swapon flag.

I'm not sure this is good idea. Why can't we make these flags orthogonal?


>  /* If true, don't complain if the device/file doesn't exist */
>  static int ifexists;
> @@ -570,8 +574,11 @@ static int do_swapon(const char *orig_special, int prio,
>  			   << SWAP_FLAG_PRIO_SHIFT);
>  	}
>  #endif
> -	if (fl_discard)
> +	if (fl_discard) {
>  		flags |= SWAP_FLAG_DISCARD;
> +		if (fl_discard > 1)
> +			flags |= SWAP_FLAG_DISCARD_CLUSTER;

This is not enough, IMHO. When running this code on old kernel, swapon() return EINVAL.
At that time, we should fall back swapon(0x10000).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
