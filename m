Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6B47F900003
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 15:08:38 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so5827394pdb.11
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 12:08:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ex14si41735020pac.42.2014.07.07.12.08.36
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 12:08:37 -0700 (PDT)
Message-ID: <53BAF01C.8010700@intel.com>
Date: Mon, 07 Jul 2014 12:08:12 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 3/3] man2/fincore.2: document general description about
 fincore(2)
References: <1404756006-23794-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1404756006-23794-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404756006-23794-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 07/07/2014 11:00 AM, Naoya Horiguchi wrote:
> +.SH RETURN VALUE
> +On success,
> +.BR fincore ()
> +returns 0.
> +On error, \-1 is returned, and
> +.I errno
> +is set appropriately.

Is this accurate?  From reading the syscall itself, it looked like it
did this:

> + * Return value is the number of pages whose data is stored in fc->buffer.
> + */
> +static long do_fincore(struct fincore_control *fc, int nr_pages)

and:

> +SYSCALL_DEFINE6(fincore, int, fd, loff_t, start, long, nr_pages,
...
> +	while (fc.nr_pages > 0) {
> +		memset(fc.buffer, 0, fc.buffer_size);
> +		ret = do_fincore(&fc, min(step, fc.nr_pages));
> +		/* Reached the end of the file */
> +		if (ret == 0)
> +			break;
> +		if (ret < 0)
> +			break;
...
> +	}
...
> +	return ret;
> +}

Which seems that for a given loop of do_fincore(), you might end up
returning the result of that *single* iteration of do_fincore() instead
of the aggregate of the entire syscall.

So, it can return <0 on failure, 0 on success, or also an essentially
random >0 number on success too.

Why not just use the return value for something useful instead of
hacking in the extras->nr_entries stuff?  Oh, and what if that

> +	if (extra)
> +		__put_user(nr, &extra->nr_entries);

fails?  It seems like we might silently forget to tell userspace how
many entries we filled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
