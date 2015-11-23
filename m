Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 053CB6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 07:55:02 -0500 (EST)
Received: by padhx2 with SMTP id hx2so190613797pad.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:55:01 -0800 (PST)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id 4si19291861pfq.125.2015.11.23.04.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 04:55:01 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20151120001043.GA28204@www.outflux.net>
	<20151123122624.GI23418@quack.suse.cz>
Date: Mon, 23 Nov 2015 06:34:06 -0600
In-Reply-To: <20151123122624.GI23418@quack.suse.cz> (Jan Kara's message of
	"Mon, 23 Nov 2015 13:26:24 +0100")
Message-ID: <87lh9odhdt.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH] fs: clear file set[ug]id when writing via mmap
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Andy Lutomirski <luto@amacapital.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Michal Hocko <mhocko@suse.cz>, Haggai Eran <haggaie@mellanox.com>, Theodore Tso <tytso@google.com>, Willy Tarreau <w@1wt.eu>, Dirk Steinmetz <public@rsjtdrjgfuzkfg.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Seth Forshee <seth.forshee@canonical.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Serge Hallyn <serge.hallyn@canonical.com>, linux-mm@kvack.org

Jan Kara <jack@suse.cz> writes:

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
>
> So calling file_remove_privs() when opening the file is probably as good as
> it can get. It doesn't catch the case when suid bits / IMA attrs are set
> while the file is already open but I don't see easy way around this.

Could we perhaps do this on mmap MAP_WRITE instead of open, and simply
deny adding these attributes if a file is mapped for write?

That would seem to be a little more compatible with what we already do,
and guards against the races you mention as well.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
