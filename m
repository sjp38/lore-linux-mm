Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3477C6B0294
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 18:31:43 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id t23-v6so1817992ioa.9
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 15:31:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v62-v6sor5971595ioe.128.2018.07.02.15.31.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 15:31:42 -0700 (PDT)
MIME-Version: 1.0
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org> <20180702222105.GA2438@bombadil.infradead.org>
In-Reply-To: <20180702222105.GA2438@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Jul 2018 15:31:30 -0700
Message-ID: <CA+55aFxcNUGJoe17YsCAgQE-42UDFKLuXg=Wox7SRzR2=xx3GA@mail.gmail.com>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Mon, Jul 2, 2018 at 3:21 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Mon, Jul 02, 2018 at 02:18:11PM -0700, Andrew Morton wrote:
> >
> > Dumb question: do we know that negative dentries are actually
> > worthwhile?  Has anyone checked in the past couple of decades?  Perhaps
> > our lookups are so whizzy nowadays that we don't need them?
>
> I can't believe that's true.

Yeah, I'm with Matthew.

Negative dentries are absolutely *critical*. We have a shit-ton of
stuff that walks various PATH-like things, trying to open a file in
one directory after another.

They also happen to be really fundamental to how the dentry cache
itself works, with operations like "rename()" fundamentally depending
on negative dentries.

Sure, that "fundamental to rename()" could still be something that
isn't actually ever *cached*, but the thing about many filesystems is
that it's actually much more expensive to look up a file that doesn't
exist than it is to look up one that does.

That can be true even with things like hashed lookups, although it's
more obviously true with legacy filesystems.

Calling down to the filesystem every time you wonder "do I have a
/usr/local/bin/cat" binary would be absolutely horrid.

Also, honestly, I think the oom-killing thing says more about the
issues we've had with the memory freeing code than about negative
dentries. But the one problem with negative dentries is that it's
fairly easy to create a shit-ton of them, so while we absolutely don't
want to get rid of the concept, I do agree that having a limiter is a
fine fine idea.

                Linus
