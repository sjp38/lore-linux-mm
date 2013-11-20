Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id DF1C36B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 17:15:37 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so7467547pad.12
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 14:15:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id z1si15185772pbn.241.2013.11.20.14.15.36
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 14:15:36 -0800 (PST)
Date: Wed, 20 Nov 2013 14:15:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm] mm, mempolicy: silence gcc warning
Message-Id: <20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Kees Cook <keescook@chromium.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Tue, 12 Nov 2013 18:12:32 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> Fengguang Wu reports that compiling mm/mempolicy.c results in a warning:
> 
> 	mm/mempolicy.c: In function 'mpol_to_str':
> 	mm/mempolicy.c:2878:2: error: format not a string literal and no format arguments
> 
> Kees says this is because he is using -Wformat-security.
> 
> Silence the warning.
> 
> ...
>
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2950,7 +2950,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
>  		return;
>  	}
>  
> -	p += snprintf(p, maxlen, policy_modes[mode]);
> +	p += snprintf(p, maxlen, "%s", policy_modes[mode]);
>  
>  	if (flags & MPOL_MODE_FLAGS) {
>  		p += snprintf(p, buffer + maxlen - p, "=");

mutter.  There are no '%'s in policy_modes[].  Maybe we should only do
this #ifdef CONFIG_KEES.

mpol_to_str() would be simpler (and slower) if it was switched to use
strncat().

It worries me that the CONFIG_NUMA=n version of mpol_to_str() doesn't
stick a '\0' into *buffer.  Hopefully it never gets called...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
