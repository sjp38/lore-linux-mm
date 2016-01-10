Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF7E828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 17:30:50 -0500 (EST)
Received: by mail-lf0-f53.google.com with SMTP id h129so8039515lfh.3
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 14:30:50 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id z205si67684351lfc.218.2016.01.10.14.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 14:30:48 -0800 (PST)
Received: by mail-lf0-x242.google.com with SMTP id c134so3034726lfb.2
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 14:30:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160110211051.GH17997@ZenIV.linux.org.uk>
References: <20160108232727.GA23490@www.outflux.net>
	<CALYGNiOUL7ewU3+5Zoi_9qofYWwF0vpqMy=A0wS=jUFZ11haCg@mail.gmail.com>
	<20160110193044.GG17997@ZenIV.linux.org.uk>
	<CALYGNiOxyXX2dpiPoGQUz0CDsvZtH57CO7gE2rAmTQWLigeL1w@mail.gmail.com>
	<20160110211051.GH17997@ZenIV.linux.org.uk>
Date: Mon, 11 Jan 2016 01:30:48 +0300
Message-ID: <CALYGNiMRhPFZACm6cFVQjUdef6bSSwC=ZZ-=N3fEzDjDrW2_ew@mail.gmail.com>
Subject: Re: [PATCH v6] fs: clear file privilege bits when mmap writing
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-arch@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 11, 2016 at 12:10 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sun, Jan 10, 2016 at 10:51:52PM +0300, Konstantin Khlebnikov wrote:
>> On Sun, Jan 10, 2016 at 10:30 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>> > On Sun, Jan 10, 2016 at 06:48:32PM +0300, Konstantin Khlebnikov wrote:
>> >> I think this should be done in mmap/mprotect. Code in sys_mmap is trivial.
>> >>
>> >> In sys_mprotect you can check file_needs_remove_privs() and VM_SHARED
>> >> under mmap_sem, then if needed grab reference to struct file from vma and
>> >> clear suid after unlocking mmap_sem.
>> >
>> > Which vma?  mprotect(2) can cover more than one mapping...  You'd have to
>> > play interesting games to collect the set of affected struct file; it
>> > _might_ be doable (e.g. by using task_work_add() to have the damn thing
>> > trigger on the way to userland), but it would require some care to avoid
>> > hitting the same file more than once - it might, after all, be mmapped
>> > in more than one process, so racing mprotect() would need to be taken
>> > into account.  Hell knows - might be doable, but I'm not sure it'll be
>> > any prettier.
>>
>> Ok, I didn't thought about that. mprotect don't have to be atomic for whole
>> range -- we could drop mmap_sem, clear suid from one file and restart it
>> for next vma and so on.
>
> Won't be fun.  Even aside of the user-visible behaviour changes, you'll have
> a lot of new corner cases, starting with the fact that you can't hold onto
> vma - virtual address is the best you can do and vma you find after regaining
> mmap_sem might start at lower address than one where you are restarting;
> getting the splitting-related logics right will be interesting, to put it
> mildly.

I don't see any problems here -- in this case mprotect virtually turns
into series of
indendent mprotect calls. Yes, we have to find vma again. Not a big deal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
