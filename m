Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E1BD76B0216
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 01:30:39 -0400 (EDT)
Date: Mon, 5 Apr 2010 07:30:26 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: why are some low-level MM routines being exported?
Message-ID: <20100405053026.GA23515@logfs.org>
References: <alpine.LFD.2.00.1004041125350.5617@localhost> <1270396784.1814.92.camel@barrios-desktop> <20100404160328.GA30540@ioremap.net> <1270398112.1814.114.camel@barrios-desktop> <20100404195533.GA8836@logfs.org> <p2g28c262361004041759n52f5063dhb182663321d918bb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <p2g28c262361004041759n52f5063dhb182663321d918bb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 April 2010 09:59:18 +0900, Minchan Kim wrote:
> On Mon, Apr 5, 2010 at 4:55 AM, JA?rn Engel <joern@logfs.org> wrote:
> > On Mon, 5 April 2010 01:21:52 +0900, Minchan Kim wrote:
> >> >
> >> Until now, other file system don't need it.
> >> Why do you need?
> >
> > To avoid deadlocks. A You tell logfs to write out some locked page, logfs
> > determines that it needs to run garbage collection first. A Garbage
> > collection can read any page. A If it called find_or_create_page() for
> > the locked page, you have a deadlock.
> 
> Could you do it with add_to_page_cache and pagevec_lru_add_file?

Maybe.  But how would that be an improvement?

As I see it, logfs needs a variant of find_or_create_page() that does
not block on any pages waiting for logfs GC.  Currently that variant
lives under fs/logfs/ and uses add_to_page_cache_lru().  If there are
valid reasons against exporting add_to_page_cache_lru(), the right
solution is to move the logfs variant to mm/, not to rewrite it.

If you want to change the implementation from using
add_to_page_cache_lru() to using add_to_page_cache() and
pagevec_lru_add_file(), then you should have a better reason than not
exporting add_to_page_cache_lru().  If the new implementation was any
better, I would gladly take it.

JA?rn

-- 
Money can buy bandwidth, but latency is forever.
-- John R. Mashey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
