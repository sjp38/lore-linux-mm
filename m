Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 3CB276B0005
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 21:14:23 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id j5so2092383iaf.28
        for <linux-mm@kvack.org>; Fri, 08 Mar 2013 18:14:22 -0800 (PST)
Message-ID: <513A9AF7.4020909@gmail.com>
Date: Sat, 09 Mar 2013 10:14:15 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: Inactive memory keep growing and how to release it?
References: <CAAO_Xo7sEH5W_9xoOjax8ynyjLCx7GBpse+EU0mF=9mEBFhrgw@mail.gmail.com> <51347A6E.8010608@iskon.hr> <CAAO_Xo6bWo4QOvdowLG88NoQr2AEq4jxCWHQXeA8g-VBT4Yk9Q@mail.gmail.com>
In-Reply-To: <CAAO_Xo6bWo4QOvdowLG88NoQr2AEq4jxCWHQXeA8g-VBT4Yk9Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lenky Gao <lenky.gao@gmail.com>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, Greg KH <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Cc experts. Hugh, Johannes,

On 03/04/2013 08:21 PM, Lenky Gao wrote:
> 2013/3/4 Zlatko Calusic <zlatko.calusic@iskon.hr>:
>> The drop_caches mechanism doesn't free dirty page cache pages. And your bash
>> script is creating a lot of dirty pages. Run it like this and see if it
>> helps your case:
>>
>> sync; echo 3 > /proc/sys/vm/drop_caches
> Thanks for your advice.
>
> The inactive memory still cannot be reclaimed after i execute the sync command:
>
> # cat /proc/meminfo | grep Inactive\(file\);
> Inactive(file):   882824 kB
> # sync;
> # echo 3 > /proc/sys/vm/drop_caches
> # cat /proc/meminfo | grep Inactive\(file\);
> Inactive(file):   777664 kB
>
> I find these page becomes orphaned in this function, but do not understand why:
>
> /*
>   * If truncate cannot remove the fs-private metadata from the page, the page
>   * becomes orphaned.  It will be left on the LRU and may even be mapped into
>   * user pagetables if we're racing with filemap_fault().
>   *
>   * We need to bale out if page->mapping is no longer equal to the original
>   * mapping.  This happens a) when the VM reclaimed the page while we waited on
>   * its lock, b) when a concurrent invalidate_mapping_pages got there first and
>   * c) when tmpfs swizzles a page between a tmpfs inode and swapper_space.
>   */
> static int
> truncate_complete_page(struct address_space *mapping, struct page *page)
> {
> ...
>
> My file system type is ext3, mounted with the opteion data=journal and
> it is easy to reproduce.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
