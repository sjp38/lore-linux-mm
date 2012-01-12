Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 889736B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 16:19:57 -0500 (EST)
Received: by iafj26 with SMTP id j26so4339323iaf.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:19:56 -0800 (PST)
Date: Thu, 12 Jan 2012 13:19:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
In-Reply-To: <CAOJsxLEYY=ZO8QrxiWL6qAxPzsPpZj3RsF9cXY0Q2L44+sn7JQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1201121309340.17287@chino.kir.corp.google.com>
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com> <20120111141219.271d3a97.akpm@linux-foundation.org> <1326355594.1999.7.camel@lappy> <CAOJsxLEYY=ZO8QrxiWL6qAxPzsPpZj3RsF9cXY0Q2L44+sn7JQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tyler Hicks <tyhicks@canonical.com>, Dustin Kirkland <kirkland@canonical.com>, ecryptfs@vger.kernel.org

On Thu, 12 Jan 2012, Pekka Enberg wrote:

> I think you missed Andrew's point. We absolutely want to issue a
> kernel warning here because ecryptfs is misusing the memdup_user()
> API. We must not let userspace processes allocate large amounts of
> memory arbitrarily.
> 

I think it's good to fix ecryptfs like Tyler is doing and, at the same 
time, ensure that the len passed to memdup_user() makes sense prior to 
kmallocing memory with GFP_KERNEL.  Perhaps something like

	if (WARN_ON(len > PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
		return ERR_PTR(-ENOMEM);

in which case __GFP_NOWARN is irrelevant.  I think memdup_user() should 
definitely be taking gfp flags, though, so the caller can specify things 
like __GFP_NORETRY on its own to avoid infinitely looping in the page 
allocator trying reclaim and possibly calling the oom killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
