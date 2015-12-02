Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id D93486B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 18:55:02 -0500 (EST)
Received: by igvg19 with SMTP id g19so1648515igv.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:55:02 -0800 (PST)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id m26si8961489ioi.105.2015.12.02.15.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 15:55:02 -0800 (PST)
Received: by ioc74 with SMTP id 74so63697986ioc.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:55:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151123122624.GI23418@quack.suse.cz>
References: <20151120001043.GA28204@www.outflux.net>
	<20151123122624.GI23418@quack.suse.cz>
Date: Wed, 2 Dec 2015 15:55:01 -0800
Message-ID: <CAGXu5jKKuXoUm5jghC7X382C658ayouYuxswYJi6n3nNvmzPaQ@mail.gmail.com>
Subject: Re: [PATCH] fs: clear file set[ug]id when writing via mmap
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Andy Lutomirski <luto@amacapital.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Michal Hocko <mhocko@suse.cz>, Haggai Eran <haggaie@mellanox.com>, Theodore Tso <tytso@google.com>, Willy Tarreau <w@1wt.eu>, Dirk Steinmetz <public@rsjtdrjgfuzkfg.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Seth Forshee <seth.forshee@canonical.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>, Linux-MM <linux-mm@kvack.org>

On Mon, Nov 23, 2015 at 4:26 AM, Jan Kara <jack@suse.cz> wrote:
> On Thu 19-11-15 16:10:43, Kees Cook wrote:
>> Normally, when a user can modify a file that has setuid or setgid bits,
>> those bits are cleared when they are not the file owner or a member of the
>> group. This is enforced when using write() directly but not when writing
>> to a shared mmap on the file. This could allow the file writer to gain
>> privileges by changing the binary without losing the setuid/setgid bits.
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> Cc: stable@vger.kernel.org
>
> So I had another look at this and now I understand why we didn't do it from
> the start:
>
> To call file_remove_privs() safely, we need to hold inode->i_mutex since
> that operations is going to modify file mode / extended attributes and
> i_mutex protects those. However we cannot get i_mutex in the page fault
> path as that ranks above mmap_sem which we hold during the whole page
> fault.

Ah, I see the notation in __generic_file_write_iter about i_mutex.
Should file_remove_privs() get some debug annotation to catch callers
that don't hold that mutex? (That would have alerted me much earlier.)

> So calling file_remove_privs() when opening the file is probably as good as
> it can get. It doesn't catch the case when suid bits / IMA attrs are set
> while the file is already open but I don't see easy way around this.

I agree with Eric: mmap time seems like the right place.

> BTW: This is another example where page fault locking is constraining us
> and life would be simpler for filesystems we they get called without
> mmap_sem held...
>
>                                                                 Honza
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
