Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id D2F126B0033
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 09:32:13 -0400 (EDT)
Received: by mail-da0-f47.google.com with SMTP id p1so344456dad.20
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 06:32:13 -0700 (PDT)
Date: Tue, 23 Apr 2013 21:49:35 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: [question] call mark_page_accessed() in minor fault
Message-ID: <20130423134935.GA10138@gmail.com>
References: <20130423122542.GA5638@gmail.com>
 <5176866A.2060400@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5176866A.2060400@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, muming.wq@taobao.com

Hi Konstantin,

On Tue, Apr 23, 2013 at 05:02:34PM +0400, Konstantin Khlebnikov wrote:
> Zheng Liu wrote:
> >Hi all,
> >
> >Recently we meet a performance regression about mmaped page.  When we upgrade
> >our product system from 2.6.18 kernel to a latest kernel, such as 2.6.32 kernel,
> >we will find that mmaped pages are reclaimed very quickly.  We found that when
> >we hit a minor fault mark_page_accessed() is called in 2.6.18 kernel, but in
> >2.6.32 kernel we don't call mark_page_accesed().  This means that mmaped pages
> >in 2.6.18 kernel are activated and moved into active list.  While in 2.6.32
> >kernel mmaped pages are still kept in inactive list.
> >
> >So my question is why we call mark_page_accessed() in 2.6.18 kernel, but don't
> >call it in 2.6.32 kernel.  Has any reason here?
> 
> Behavior was changed in commit
> v2.6.28-6130-gbf3f3bc "mm: don't mark_page_accessed in fault path"

Thanks for pointing it out.

> 
> Please see also commits
> v3.2-4876-g34dbc67 "vmscan: promote shared file mapped pages" and

Yes, I will give it try.  If I understand correctly, this commit is
useful for multi-processes program that access a shared mmaped page,
but that could not be useful for us because our program is multi-thread.

> v3.2-4877-gc909e99 "vmscan: activate executable pages after first usage".

We have backported this patch, but it is useless.  This commit only
tries to activate a executable page, but our mmaped pages aren't with
this flag.

Additional question is that currently mmaped page is reclaimed too
quickly.  I think maybe we need to adjust our page reclaim strategy to
balance number of pages between mmaped page and file page cache.  Now
every time we access a page using read(2)/write(2), this page will be
touched.  But after first time we touch a mmaped page, we never touch it
again except that this page is evicted.

Regards,
                                                - Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
