Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CFFEC6B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 09:55:32 -0400 (EDT)
Date: Mon, 15 Aug 2011 08:55:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] slub: extend slub_debug to handle multiple slabs
In-Reply-To: <1312839019-17987-1-git-send-email-malchev@google.com>
Message-ID: <alpine.DEB.2.00.1108150853170.22335@router.home>
References: <1312839019-17987-1-git-send-email-malchev@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Iliyan Malchev <malchev@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 8 Aug 2011, Iliyan Malchev wrote:

> Extend the slub_debug syntax to "slub_debug=<flags>[,<slub>]*", where <slub>
> may contain an asterisk at the end.  For example, the following would poison
> all kmalloc slabs:
>
> 	slub_debug=P,kmalloc*

The use of the star suggests that general regexps will be working. But
this is only allowing a star at the end. It is explained later. So maybe
that ok.

> +	n = slub_debug_slabs;
> +	while (*n) {
> +		int cmplen;
> +
> +		end = strchr(n, ',');
> +		if (!end)
> +			end = n + strlen(n);
> +
> +		glob = strnchr(n, end - n, '*');
> +		if (glob)
> +			cmplen = glob - n;
> +		else
> +			cmplen = max(len, end - n);
> +
> +		if (!strncmp(name, n, cmplen)) {
> +			flags |= slub_debug;
> +			break;
> +		}
> +
> +		n = *end ? end + 1 : end;

Ugg.. Confusing

How about

		if (!*end)
			break;
		n = end + 1;

or make the while loop into a for loop?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
