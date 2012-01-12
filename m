Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 2A2F96B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 16:58:05 -0500 (EST)
Date: Thu, 12 Jan 2012 13:58:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
Message-Id: <20120112135803.1fb98fd6.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1201121309340.17287@chino.kir.corp.google.com>
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com>
	<20120111141219.271d3a97.akpm@linux-foundation.org>
	<1326355594.1999.7.camel@lappy>
	<CAOJsxLEYY=ZO8QrxiWL6qAxPzsPpZj3RsF9cXY0Q2L44+sn7JQ@mail.gmail.com>
	<alpine.DEB.2.00.1201121309340.17287@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Sasha Levin <levinsasha928@gmail.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tyler Hicks <tyhicks@canonical.com>, Dustin Kirkland <kirkland@canonical.com>, ecryptfs@vger.kernel.org

On Thu, 12 Jan 2012 13:19:54 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 12 Jan 2012, Pekka Enberg wrote:
> 
> > I think you missed Andrew's point. We absolutely want to issue a
> > kernel warning here because ecryptfs is misusing the memdup_user()
> > API. We must not let userspace processes allocate large amounts of
> > memory arbitrarily.
> > 
> 
> I think it's good to fix ecryptfs like Tyler is doing and, at the same 
> time, ensure that the len passed to memdup_user() makes sense prior to 
> kmallocing memory with GFP_KERNEL.  Perhaps something like
> 
> 	if (WARN_ON(len > PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> 		return ERR_PTR(-ENOMEM);
> 
> in which case __GFP_NOWARN is irrelevant.

If someone is passing huge size_t's into kmalloc() and getting failures
then that's probably a bug.  So perhaps we should add a warning to
kmalloc itself if the size_t is out of bounds, and !__GFP_NOWARN.

That might cause problems with those callers who like to call kmalloc()
in a probing loop with decreasing size_t.


But none of this will be very effective.  If someone is passing an
unchecked size_t into kmalloc then normal testing will not reveal the
problem because the testers won't pass stupid numbers into their
syscalls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
