Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF876B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:25:24 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id z39so9944255ita.1
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 07:25:24 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id o87si11165337ioi.189.2018.01.10.07.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 07:25:22 -0800 (PST)
Date: Wed, 10 Jan 2018 09:25:20 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 02/36] usercopy: Include offset in overflow report
In-Reply-To: <1515531365-37423-3-git-send-email-keescook@chromium.org>
Message-ID: <alpine.DEB.2.20.1801100921000.7926@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org> <1515531365-37423-3-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Tue, 9 Jan 2018, Kees Cook wrote:

> -static void report_usercopy(unsigned long len, bool to_user, const char *type)
> +int report_usercopy(const char *name, const char *detail, bool to_user,
> +		    unsigned long offset, unsigned long len)
>  {
> -	pr_emerg("kernel memory %s attempt detected %s '%s' (%lu bytes)\n",
> +	pr_emerg("kernel memory %s attempt detected %s %s%s%s%s (offset %lu, size %lu)\n",
>  		to_user ? "exposure" : "overwrite",
> -		to_user ? "from" : "to", type ? : "unknown", len);
> +		to_user ? "from" : "to",
> +		name ? : "unknown?!",
> +		detail ? " '" : "", detail ? : "", detail ? "'" : "",
> +		offset, len);
>  	/*
>  	 * For greater effect, it would be nice to do do_group_exit(),
>  	 * but BUG() actually hooks all the lock-breaking and per-arch
>  	 * Oops code, so that is used here instead.
>  	 */
>  	BUG();

Should this be a WARN() or so? Or some configuration that changes
BUG() behavior? Otherwise

> +
> +	return -1;

This return code will never be returned.

Why a return code at all? Maybe I will see that in the following patches?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
