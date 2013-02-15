Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 6078A6B0073
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 16:27:40 -0500 (EST)
Date: Fri, 15 Feb 2013 13:27:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm: fincore()
Message-Id: <20130215132738.c85c9eda.akpm@linux-foundation.org>
In-Reply-To: <20130215063450.GA24047@cmpxchg.org>
References: <87a9rbh7b4.fsf@rustcorp.com.au>
	<20130211162701.GB13218@cmpxchg.org>
	<20130211141239.f4decf03.akpm@linux-foundation.org>
	<20130215063450.GA24047@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Fri, 15 Feb 2013 01:34:50 -0500
Johannes Weiner <hannes@cmpxchg.org> wrote:

> + * The status is returned in a vector of bytes.  The least significant
> + * bit of each byte is 1 if the referenced page is in memory, otherwise
> + * it is zero.

Also, this is going to be dreadfully inefficient for some obvious cases.

We could address that by returning the info in some more efficient
representation.  That will be run-length encoded in some fashion.

The obvious way would be to populate an array of

struct page_status {
	u32 present:1;
	u32 count:31;
};

or whatever.

Another way would be to define the syscall so it returns "number of
pages present/absent starting at offset `start'".  In other words, one
call to fincore() will return a single `struct page_status'.  Userspace
can then walk through the file and generate the full picture, if needed.


This also gets inefficient in obvious cases, but it's not as obviously
bad?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
