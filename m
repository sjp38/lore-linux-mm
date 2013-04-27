Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 2E19B6B0034
	for <linux-mm@kvack.org>; Sat, 27 Apr 2013 03:10:38 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so2425057pdi.33
        for <linux-mm@kvack.org>; Sat, 27 Apr 2013 00:10:37 -0700 (PDT)
Message-ID: <517B79E6.5050204@gmail.com>
Date: Sat, 27 Apr 2013 15:10:30 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [question] call mark_page_accessed() in minor fault
References: <20130423122542.GA5638@gmail.com> <5176866A.2060400@openvz.org> <20130423134935.GA10138@gmail.com>
In-Reply-To: <20130423134935.GA10138@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, muming.wq@taobao.com

Hi Zheng,
On 04/23/2013 09:49 PM, Zheng Liu wrote:
> Hi Konstantin,
>
> On Tue, Apr 23, 2013 at 05:02:34PM +0400, Konstantin Khlebnikov wrote:
>> Zheng Liu wrote:
>>> Hi all,
>>>
>>> Recently we meet a performance regression about mmaped page.  When we upgrade
>>> our product system from 2.6.18 kernel to a latest kernel, such as 2.6.32 kernel,
>>> we will find that mmaped pages are reclaimed very quickly.  We found that when
>>> we hit a minor fault mark_page_accessed() is called in 2.6.18 kernel, but in
>>> 2.6.32 kernel we don't call mark_page_accesed().  This means that mmaped pages
>>> in 2.6.18 kernel are activated and moved into active list.  While in 2.6.32
>>> kernel mmaped pages are still kept in inactive list.
>>>
>>> So my question is why we call mark_page_accessed() in 2.6.18 kernel, but don't
>>> call it in 2.6.32 kernel.  Has any reason here?
>> Behavior was changed in commit
>> v2.6.28-6130-gbf3f3bc "mm: don't mark_page_accessed in fault path"
> Thanks for pointing it out.
>
>> Please see also commits
>> v3.2-4876-g34dbc67 "vmscan: promote shared file mapped pages" and
> Yes, I will give it try.  If I understand correctly, this commit is
> useful for multi-processes program that access a shared mmaped page,
> but that could not be useful for us because our program is multi-thread.

What's the difference behavior between multi-processes and multi-thread 
in this case?

>
>> v3.2-4877-gc909e99 "vmscan: activate executable pages after first usage".
> We have backported this patch, but it is useless.  This commit only
> tries to activate a executable page, but our mmaped pages aren't with
> this flag.
>
> Additional question is that currently mmaped page is reclaimed too
> quickly.  I think maybe we need to adjust our page reclaim strategy to
> balance number of pages between mmaped page and file page cache.  Now
> every time we access a page using read(2)/write(2), this page will be
> touched.  But after first time we touch a mmaped page, we never touch it
> again except that this page is evicted.
>
> Regards,
>                                                  - Zheng
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
