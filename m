Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id E21818E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 13:46:41 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u20so25403730qtk.6
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:46:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w11sor104141875qvb.20.2019.01.22.10.46.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 10:46:40 -0800 (PST)
Subject: Re: [PATCH] backing-dev: no need to check return value of
 debugfs_create functions
References: <20190122152151.16139-8-gregkh@linuxfoundation.org>
 <20190122160759.mx3h7gjc23zmrvxc@linutronix.de>
 <20190122162503.GB22548@kroah.com>
 <20190122171908.c7geuvluezkjp3s7@linutronix.de>
 <20190122183348.GA31271@kroah.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <86349002-49d7-7053-b26f-51309e320a04@lca.pw>
Date: Tue, 22 Jan 2019 13:46:38 -0500
MIME-Version: 1.0
In-Reply-To: <20190122183348.GA31271@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org



On 1/22/19 1:33 PM, Greg Kroah-Hartman wrote:
> On Tue, Jan 22, 2019 at 06:19:08PM +0100, Sebastian Andrzej Siewior wrote:
>> On 2019-01-22 17:25:03 [+0100], Greg Kroah-Hartman wrote:
>>>>>  }
>>>>>  
>>>>>  static void bdi_debug_unregister(struct backing_dev_info *bdi)
>>>>>  {
>>>>> -	debugfs_remove(bdi->debug_stats);
>>>>> -	debugfs_remove(bdi->debug_dir);
>>>>> +	debugfs_remove_recursive(bdi->debug_dir);
>>>>
>>>> this won't remove it.
>>>
>>> Which is fine, you don't care.
>>
>> but if you cat the stats file then it will dereference the bdi struct
>> which has been free(), right?
> 
> Maybe, I don't know, your code is long gone, it doesn't matter :)
> 
>>> But step back, how could that original call be NULL?  That only happens
>>> if you pass it a bad parent dentry (which you didn't), or the system is
>>> totally out of memory (in which case you don't care as everything else
>>> is on fire).
>>
>> debugfs_get_inode() could do -ENOMEM and then the directory creation
>> fails with NULL.
> 
> And if that happens, your system has worse problems :)

Well, there are cases that people are running longevity testing on debug kernels
that including OOM and reading all files in sysfs test cases.

Admittedly, the situation right now is not all that healthy as many things are
unable to survive in a low-memory situation, i.e., kmemleak, dma-api debug etc
could just disable themselves.

That's been said, it certainly not necessary to make the situation worse by
triggering a NULL pointer dereferencing or KASAN use-after-free warnings because
of those patches.
