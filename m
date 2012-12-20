Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 9E9926B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 05:55:22 -0500 (EST)
From: Roman Gushchin <klamm@yandex-team.ru>
In-Reply-To: <1355984435.1374.3.camel@kernel-VirtualBox>
References: <50C4B4E7.60601@intel.com> <50C6AB45.606@intel.com>
	 <20121216021508.GA3629@dcvr.yhbt.net> <1355984435.1374.3.camel@kernel-VirtualBox>
Subject: Re: resend--[PATCH]  improve read ahead in kernel
MIME-Version: 1.0
Message-Id: <1461356000918@webcorp1g.yandex-team.ru>
Date: Thu, 20 Dec 2012 14:55:18 +0400
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=koi8-r
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>, Eric Wong <normalperson@yhbt.net>
Cc: xtu4 <xiaobing.tu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-tip-commits@vger.kernel.org" <linux-tip-commits@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "di.zhang@intel.com" <di.zhang@intel.com>

Hi Simon,

20.12.2012, 10:21, "Simon Jeons" <simon.jeons@gmail.com>:
> On Sun, 2012-12-16 at 02:15 +0000, Eric Wong wrote:
>
>> ?xtu4 <xiaobing.tu@intel.com> wrote:
>>> ?resend it, due to format error
>>>
>>> ?Subject: [PATCH] when system in low memory scenario, imaging there is a mp3
>>> ??play, ora video play, we need to read mp3 or video file
>>> ??from memory to page cache,but when system lack of memory,
>>> ??page cache of mp3 or video file will be reclaimed.once read
>>> ??in memory, then reclaimed, it will cause audio or video
>>> ??glitch,and it will increase the io operation at the same
>>> ??time.
>> ?To me, this basically describes how POSIX_FADV_NOREUSE should work.
>
> Hi Eric,
>
> But why fadvise POSIX_FADV_NOREUSE almost do nothing? Why not set some
> flag or other things for these use once data?

Because, it's not clear how should it work in some cases.
Do we expect one access? Should we track a page as accessed after any access (even if only one byte was read)?
What should we do with already-cached pages? etc.

IMHO, it will be better to introduce something like POSIX_FADV_DONTCACHE.
Corresponding pages can be added (ratated) to the tail of the inactive LRU after copying data in read() internals,
or after minor/major pagefault.

>
>> ?I would like to have this ability via fadvise (and not CONFIG_).
>>
>> ?Also, I think your patch has too many #ifdefs to be accepted.
>>
>> ?--
>> ?To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> ?the body to majordomo@kvack.org. ?For more info on Linux MM,
>> ?see: http://www.linux-mm.org/ .
>> ?Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. ?For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
