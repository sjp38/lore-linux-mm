Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 831686B029E
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 19:28:56 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t11-v6so83862iog.15
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 16:28:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q26-v6sor1068197jaj.8.2018.07.02.16.28.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 16:28:55 -0700 (PDT)
MIME-Version: 1.0
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1530570880.3179.9.camel@HansenPartnership.com> <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
In-Reply-To: <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Jul 2018 16:28:44 -0700
Message-ID: <CA+55aFwYsq5OVMVizhfis7Jtepj8xQk1Paz=Tqz-HmfhoZ_mfQ@mail.gmail.com>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Mon, Jul 2, 2018 at 4:19 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> Before we go and add a large amount of code to do the shrinker's job
> for it, we should get a full understanding of what's going wrong.  Is
> it because the dentry_lru had a mixture of +ve and -ve dentries?
> Should we have a separate LRU for -ve dentries?  Are we appropriately
> aging the various dentries?  etc.
>
> It could be that tuning/fixing the current code will fix whatever
> problems inspired this patchset.

So I do think that the shrinker is likely the culprit behind the oom
issues. I think it's likely worse when you try to do some kind of
containerization, and dentries are shared.

That said, I think there are likely good reasons to limit excessive
negative dentries even outside the oom issue. Even if we did a perfect
job at shrinking them and took no time at all doing so, the fact that
you can generate an effecitvely infinite amount of negative dentries
and then polluting the dentry hash chains with them _could_ be a
performance problem.

No sane application does that, and we handle the "obvious" cases
already: ie if you create a lot of files in a deep subdirectory and
then do "rm -rf dir", we *will* throw the negative dentries away as we
remove the directories they are in. So it is unlikely to be much of a
problem in practice. But at least in theory you can generate many
millions of negative dentries just to mess with the system, and slow
down good people.

Probably not even remotely to the point of a DoS attack, but certainly
to the point of "we're wasting time".

So I do think that restricting negative dentries is a fine concept.
They are useful, but that doesn't mean that it makes sense to fill
memory with them.
                 Linus
