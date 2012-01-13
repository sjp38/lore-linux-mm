Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 1D7506B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 02:31:13 -0500 (EST)
Date: Thu, 12 Jan 2012 23:36:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
Message-Id: <20120112233600.33805bfc.akpm@linux-foundation.org>
In-Reply-To: <20120113071752.GA3802@mwanda>
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com>
	<20120111141219.271d3a97.akpm@linux-foundation.org>
	<1326355594.1999.7.camel@lappy>
	<CAOJsxLEYY=ZO8QrxiWL6qAxPzsPpZj3RsF9cXY0Q2L44+sn7JQ@mail.gmail.com>
	<alpine.DEB.2.00.1201121309340.17287@chino.kir.corp.google.com>
	<20120112135803.1fb98fd6.akpm@linux-foundation.org>
	<20120113071752.GA3802@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Sasha Levin <levinsasha928@gmail.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tyler Hicks <tyhicks@canonical.com>, Dustin Kirkland <kirkland@canonical.com>, ecryptfs@vger.kernel.org

On Fri, 13 Jan 2012 10:17:52 +0300 Dan Carpenter <dan.carpenter@oracle.com> wrote:

> On Thu, Jan 12, 2012 at 01:58:03PM -0800, Andrew Morton wrote:
> > On Thu, 12 Jan 2012 13:19:54 -0800 (PST)
> > David Rientjes <rientjes@google.com> wrote:
> > 
> > > On Thu, 12 Jan 2012, Pekka Enberg wrote:
> > > 
> > > > I think you missed Andrew's point. We absolutely want to issue a
> > > > kernel warning here because ecryptfs is misusing the memdup_user()
> > > > API. We must not let userspace processes allocate large amounts of
> > > > memory arbitrarily.
> > > > 
> > > 
> > > I think it's good to fix ecryptfs like Tyler is doing and, at the same 
> > > time, ensure that the len passed to memdup_user() makes sense prior to 
> > > kmallocing memory with GFP_KERNEL.  Perhaps something like
> > > 
> > > 	if (WARN_ON(len > PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> > > 		return ERR_PTR(-ENOMEM);
> > > 
> > > in which case __GFP_NOWARN is irrelevant.
> > 
> > If someone is passing huge size_t's into kmalloc() and getting failures
> > then that's probably a bug.
> 
> It's pretty common to pass high values to kmalloc().  We've added
> a bunch of integer overflow checks recently where we do:
> 
> 	if (n > ULONG_MAX / size)
> 		return -EINVAL;

It would be cleaner to use kcalloc().  Except kcalloc() zeroes the memory
and we still don't have a non-zeroing kcalloc().

> The problem is that we didn't set a maximum bound before and we
> can't know which maximum will break compatibility.

Except for special cases (what are they?), code shouldn't be checking
for maximum kmalloc() size.  It should be checking the size against the
upper value which makes sense in the context of whatever it is doing at
the time.  This ecryptfs callsite is an example.

wrt any compatibility issues: the maximum amount of memory which can be
allocated by kmalloc() depends on the kernel config (see
kmalloc_sizes.h) so any code which is relying on any particular upper
bound is already busted.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
