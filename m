Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73CCB6B026E
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:48:41 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id a88so130169119uaa.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:48:41 -0800 (PST)
Received: from mail-ua0-x22d.google.com (mail-ua0-x22d.google.com. [2607:f8b0:400c:c08::22d])
        by mx.google.com with ESMTPS id j19si6744286uaf.54.2017.01.25.13.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 13:48:40 -0800 (PST)
Received: by mail-ua0-x22d.google.com with SMTP id i68so169081937uad.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:48:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1485380634.2998.161.camel@decadent.org.uk>
References: <cover.1485377903.git.luto@kernel.org> <9318903980969a0e378dab2de4d803397adcd3cc.1485377903.git.luto@kernel.org>
 <1485380634.2998.161.camel@decadent.org.uk>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 25 Jan 2017 13:48:19 -0800
Message-ID: <CALCETrUyWGF7WWVxv5e1tznkdV07YCrOcUeoJE8wUn-qCZMAKw@mail.gmail.com>
Subject: Re: [PATCH 1/2] fs: Check f_cred instead of current's creds in should_remove_suid()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Andy Lutomirski <luto@kernel.org>, "security@kernel.org" <security@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, stable <stable@vger.kernel.org>

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

Hmm.  Although, if a privileged program does something like:

(sudo -u nobody echo blah) >setuid_program

presumably it wanted to make the change.

>
> Perhaps there should be a capability check on both the current
> credentials and file credentials?  (I realise that we've considered
> file credential checks to be sufficient elsewhere, but those cases
> involved virtual files with special semantics, where it's clearer that
> a privileged process should not pass them to an unprivileged process.)
>

I could go either way.

What I really want to do is to write a third patch that isn't for
-stable that just removes the capable() check entirely.  I'm
reasonably confident it won't break things for a silly reason: because
it's capable() and not ns_capable(), anything it would break would
also be broken in an unprivileged container, and I haven't seen any
reports of package managers or similar breaking for this reason.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
