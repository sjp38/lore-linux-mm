Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 67B2B6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 05:02:58 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id 6so220360509qgy.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 02:02:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c13si111880174qkb.79.2016.01.06.02.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 02:02:57 -0800 (PST)
Date: Wed, 6 Jan 2016 11:02:48 +0100
From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: [PATCH 1/2] prctl: take mmap sem for writing to protect against
 others
Message-ID: <20160106100247.GB10366@mguzik>
References: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
 <1452056549-10048-2-git-send-email-mguzik@redhat.com>
 <CAKeScWgfg2G6q7ffBLGi2R_xHcp+8NbYEQ7t73pY9oDKWgeqog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKeScWgfg2G6q7ffBLGi2R_xHcp+8NbYEQ7t73pY9oDKWgeqog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.linux@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jarod Wilson <jarod@redhat.com>, Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Jan 06, 2016 at 03:05:09PM +0530, Anshuman Khandual wrote:
> On Wed, Jan 6, 2016 at 10:32 AM, Mateusz Guzik <mguzik@redhat.com> wrote:
> > The code was taking the semaphore for reading, which does not protect
> > against readers nor concurrent modifications.
> 
> (down/up)_read does not protect against concurrent readers ?
> 

Maybe wording could be improved.

The point is, prctl is modifying various fields while having the
semaphore for reading. Other code, presumably wanting to read said
fields, can take semaphore for reading itsef in order to get a stable
copy. Except turns out it does not help here. Since the both the reader
and the writer did that, the reader can read stuff as it is changing.

> >
> > The problem could cause a sanity checks to fail in procfs's cmdline
> > reader, resulting in an OOPS.
> >
> 
> Can you explain this a bit and may be give some examples ?
> 

Given the above, let's consider a program moving around arg_start +
arg_end by few bytes while proc_pid_cmdline_read is being executed.

proc_pid_cmdline_read does:
        down_read(&mm->mmap_sem);
        arg_start = mm->arg_start;
        arg_end = mm->arg_end;
        env_start = mm->env_start;
        env_end = mm->env_end;
        up_read(&mm->mmap_sem);

Since the writer also has the semaphore only for reading, this function
can proceed to read stuff as it is being modified. In particular it can
read arg_start *prior* to modification and arg_end *after*. This trips
up BUG_ON(arg_start > arg_end).

That is, for the sake of argument, if the code is changing the pair from
0x2000 & 0x2020 to 0x1000 & 0x1020, someone else may read arg_start
0x2000 and arg_end 0x1020.

This code should showcase the problem:
http://people.redhat.com/~mguzik/misc/prctl.c

It is somewhat crude, you may ned to adjust hardcoded values for your
binary.

> > Note that some functions perform an unlocked read of various mm fields,
> > but they seem to be fine despite possible modificaton.
> 
> Those need to be fixed as well ?
> 

As stated earlier, these can live without changes, but that does not
look like a good idea.

-- 
Mateusz Guzik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
