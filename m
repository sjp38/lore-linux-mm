Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFF86B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 07:26:29 -0500 (EST)
Received: by wmec201 with SMTP id c201so102689075wme.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:26:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v20si18858670wjq.230.2015.11.23.04.26.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 04:26:28 -0800 (PST)
Date: Mon, 23 Nov 2015 13:26:24 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] fs: clear file set[ug]id when writing via mmap
Message-ID: <20151123122624.GI23418@quack.suse.cz>
References: <20151120001043.GA28204@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151120001043.GA28204@www.outflux.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Michal Hocko <mhocko@suse.cz>, Haggai Eran <haggaie@mellanox.com>, Theodore Tso <tytso@google.com>, Willy Tarreau <w@1wt.eu>, Dirk Steinmetz <public@rsjtdrjgfuzkfg.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Seth Forshee <seth.forshee@canonical.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>, linux-mm@kvack.org

On Thu 19-11-15 16:10:43, Kees Cook wrote:
> Normally, when a user can modify a file that has setuid or setgid bits,
> those bits are cleared when they are not the file owner or a member of the
> group. This is enforced when using write() directly but not when writing
> to a shared mmap on the file. This could allow the file writer to gain
> privileges by changing the binary without losing the setuid/setgid bits.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Cc: stable@vger.kernel.org

So I had another look at this and now I understand why we didn't do it from
the start:

To call file_remove_privs() safely, we need to hold inode->i_mutex since
that operations is going to modify file mode / extended attributes and
i_mutex protects those. However we cannot get i_mutex in the page fault
path as that ranks above mmap_sem which we hold during the whole page
fault.

So calling file_remove_privs() when opening the file is probably as good as
it can get. It doesn't catch the case when suid bits / IMA attrs are set
while the file is already open but I don't see easy way around this.

BTW: This is another example where page fault locking is constraining us
and life would be simpler for filesystems we they get called without
mmap_sem held...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
