Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 43F8C6B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 19:21:02 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so6809844pbc.25
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:21:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id yd9si29098208pab.321.2013.11.25.16.21.00
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 16:21:00 -0800 (PST)
Date: Mon, 25 Nov 2013 16:20:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm] mm, mempolicy: silence gcc warning
Message-Id: <20131125162059.6989ef1680d43ed7a0a042ff@linux-foundation.org>
In-Reply-To: <5293E66F.8090000@jp.fujitsu.com>
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>
	<20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org>
	<CAHGf_=ooNHx=2HeUDGxrZFma-6YRvL42ViDMkSOqLOffk8MVsw@mail.gmail.com>
	<20131125123108.79c80eb59c2b1bc41c879d9e@linux-foundation.org>
	<5293E66F.8090000@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: rientjes@google.com, fengguang.wu@intel.com, keescook@chromium.org, riel@redhat.com, linux-mm@kvack.org

On Mon, 25 Nov 2013 19:08:15 -0500 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> >>> It worries me that the CONFIG_NUMA=n version of mpol_to_str() doesn't
> >>> stick a '\0' into *buffer.  Hopefully it never gets called...
> >>
> >> Don't worry. It never happens. Currently, all of caller depend on CONFIG_NUMA.
> >> However it would be nice if CONFIG_NUMA=n version of mpol_to_str() is
> >> implemented
> >> more carefully. I don't know who's mistake.
> > 
> > Put a BUG() in there?
> 
> I think this is enough. What do you think?
> 
> 
> commit 5691f7f336c511d39fc05821d204a8f7ba18c0cf
> Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date:   Mon Nov 25 18:38:25 2013 -0500
> 
>     mempolicy: implement mpol_to_str() fallback implementation when !CONFIG_NUMA
> 
>     Andrew Morton pointed out mpol_to_str() has no fallback implementation
>     for !CONFIG_NUMA and it could be dangerous because callers might assume
>     buffer is filled zero terminated string. Fortunately there is no such
>     caller. But it would be nice to provide default safe implementation.
> 
>     Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 9fe426b..eee0597 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -309,6 +309,8 @@ static inline int mpol_parse_str(char *str, struct mempolicy **mpol)
> 
>  static inline void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
>  {
> +	strncpy(buffer, "default", maxlen-1);
> +	buffer[maxlen-1] = '\0';
>  }
> 

Well, as David said, BUILD_BUG() would be the preferred cleanup.  I'll
stick one in there and see what the build bot has to say?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
