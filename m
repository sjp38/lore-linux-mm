Date: Thu, 22 Nov 2007 15:47:36 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] mem notifications v2
Message-ID: <20071122154736.02325eca@bree.surriel.com>
In-Reply-To: <cfd9edbf0711220323v71c1dc84v1d10bda0de93fe51@mail.gmail.com>
References: <20071121195316.GA21481@dmt>
	<cfd9edbf0711220323v71c1dc84v1d10bda0de93fe51@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel =?UTF-8?B?U3DDpW5n?= <daniel.spang@gmail.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Nov 2007 12:23:55 +0100
"Daniel SpAJPYng" <daniel.spang@gmail.com> wrote:

> When the page cache is filled, the notification is a bit early as the
> following example shows on a small system with 64 MB ram and no swap.
> On the first run the application can use 58 MB of anonymous pages
> before notification is sent. Then after the page cache is filled the
> test application is runned again and is only able to use 49 MB before
> being notified.

Excellent.  Throwing away useless memory when three is still
useful memory available sounds like a good idea.

> I see it as a feature to be able to throw out inactive binaries and
> mmaped files before getting notified about low memory.

I think that once you get low on memory, you want a bit of
both.  Inactive binaries and mmaped files are potentially
useful; in-process free()d memory and caches are just as
potentially (dubiously) useful.

Freeing a bit of both will probably provide a good compromise
between CPU and memory efficiency.

> I suggest we add both this notification and my priority threshold 
> based approach, then the users can chose which one to use.

That sounds like a horribly bad idea, because we run the
danger of ending up with two sets of applications, both of
which expect another notification type.

One type of application can cause the other to receive
unfair amounts of memory pressure.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
