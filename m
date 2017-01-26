Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C63FD6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 19:12:22 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id s10so27277071itb.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:12:22 -0800 (PST)
Received: from mail-it0-x22f.google.com (mail-it0-x22f.google.com. [2607:f8b0:4001:c0b::22f])
        by mx.google.com with ESMTPS id m3si493045ioo.158.2017.01.25.16.12.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 16:12:21 -0800 (PST)
Received: by mail-it0-x22f.google.com with SMTP id c7so120351398itd.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:12:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1485380634.2998.161.camel@decadent.org.uk>
References: <cover.1485377903.git.luto@kernel.org> <9318903980969a0e378dab2de4d803397adcd3cc.1485377903.git.luto@kernel.org>
 <1485380634.2998.161.camel@decadent.org.uk>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Jan 2017 16:12:21 -0800
Message-ID: <CAGXu5jLu6OGkQUgqRcOyQ6DABOwZ9HX3fUQ+-zC7NjLukGKnVw@mail.gmail.com>
Subject: Re: [PATCH 1/2] fs: Check f_cred instead of current's creds in should_remove_suid()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Andy Lutomirski <luto@kernel.org>, "security@kernel.org" <security@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "# 3.4.x" <stable@vger.kernel.org>

On Wed, Jan 25, 2017 at 1:43 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Wed, 2017-01-25 at 13:06 -0800, Andy Lutomirski wrote:
>> If an unprivileged program opens a setgid file for write and passes
>> the fd to a privileged program and the privileged program writes to
>> it, we currently fail to clear the setgid bit.  Fix it by checking
>> f_cred instead of current's creds whenever a struct file is
>> involved.
> [...]
>
> What if, instead, a privileged program passes the fd to an un
> unprivileged program?  It sounds like a bad idea to start with, but at
> least currently the unprivileged program is going to clear the setgid
> bit when it writes.  This change would make that behaviour more
> dangerous.
>
> Perhaps there should be a capability check on both the current
> credentials and file credentials?  (I realise that we've considered
> file credential checks to be sufficient elsewhere, but those cases
> involved virtual files with special semantics, where it's clearer that
> a privileged process should not pass them to an unprivileged process.)

We need a set of self-tests for this whole area. :( There are so many
corner cases. We still have an unfixed corner case with mmap writes
not clearing set*id bits that I tried to solve last year...

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
