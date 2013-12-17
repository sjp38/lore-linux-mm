Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2692F6B0039
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 02:23:37 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so6640486pbb.9
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 23:23:36 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id ot3si11006115pac.108.2013.12.16.23.23.34
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 23:23:35 -0800 (PST)
Message-ID: <52AFFBE3.8020507@ubuntukylin.com>
Date: Tue, 17 Dec 2013 15:23:15 +0800
From: Li Wang <liwang@ubuntukylin.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] VFS: Directory level cache cleaning
References: <cover.1387205337.git.liwang@ubuntukylin.com> <CAM_iQpUSX1yX9SMvUnbwZ7UkaBMUheOEiZNaSb4m8gWBQzzGDQ@mail.gmail.com> <52AFC020.10403@ubuntukylin.com> <20131217035847.GA10392@parisc-linux.org>
In-Reply-To: <20131217035847.GA10392@parisc-linux.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

If we do wanna equip fadvise() with directory level page cache cleaning,
this could be solved by invoking (inode_permission() || 
capable(CAP_SYS_ADMIN)) before manipulating the page cache of that inode.
We think the current extension to 'drop_caches' has a complete back
compatibility, the old semantics keep unchanged, and with add-on
features to do finer granularity cache cleaning should be also
desirable.

On 2013/12/17 11:58, Matthew Wilcox wrote:
> On Tue, Dec 17, 2013 at 11:08:16AM +0800, Li Wang wrote:
>> As far as we know, fadvise(DONTNEED) does not support metadata
>> cache cleaning. We think that is desirable under massive small files
>> situations. Another thing is that do people accept the behavior
>> of feeding a directory fd to fadvise will recusively clean all
>> page caches of files inside that directory?
>
> I think there's a really good permissions-related question here.
> If that's an acceptable interface, should one have to be CAP_SYS_ADMIN
> to issue the request?  What if some of the files below this directory
> are not owned by the user issuing the request?
>
>> On 2013/12/17 1:45, Cong Wang wrote:
>>> On Mon, Dec 16, 2013 at 7:00 AM, Li Wang <liwang@ubuntukylin.com> wrote:
>>>> This patch extend the 'drop_caches' interface to
>>>> support directory level cache cleaning and has a complete
>>>> backward compatibility. '{1,2,3}' keeps the same semantics
>>>> as before. Besides, "{1,2,3}:DIRECTORY_PATH_NAME" is allowed
>>>> to recursively clean the caches under DIRECTORY_PATH_NAME.
>>>> For example, 'echo 1:/home/foo/jpg > /proc/sys/vm/drop_caches'
>>>> will clean the page caches of the files inside 'home/foo/jpg'.
>>>>
>>>
>>> This interface is ugly...
>>>
>>> And we already have a file-level drop cache, that is,
>>> fadvise(DONTNEED). Can you extend it if it can't
>>> handle a directory fd?
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
