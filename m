Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2CBBC6B0255
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 20:15:59 -0500 (EST)
Received: by wmww144 with SMTP id w144so1739373wmw.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:15:58 -0800 (PST)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id m135si712329wmb.47.2015.11.19.17.15.56
        for <linux-mm@kvack.org>;
        Thu, 19 Nov 2015 17:15:56 -0800 (PST)
Date: Fri, 20 Nov 2015 02:06:24 +0100
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] fs: clear file set[ug]id when writing via mmap
Message-ID: <20151120010624.GA31732@1wt.eu>
References: <20151120001043.GA28204@www.outflux.net> <20151120010016.GB31694@1wt.eu> <CAGXu5jJR1KqLRUmD5_WM51k=v74gRWNA+CjsrL_oO6D494FMog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJR1KqLRUmD5_WM51k=v74gRWNA+CjsrL_oO6D494FMog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Michal Hocko <mhocko@suse.cz>, Haggai Eran <haggaie@mellanox.com>, Theodore Tso <tytso@google.com>, Dirk Steinmetz <public@rsjtdrjgfuzkfg.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Seth Forshee <seth.forshee@canonical.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>, Linux-MM <linux-mm@kvack.org>

On Thu, Nov 19, 2015 at 05:03:15PM -0800, Kees Cook wrote:
> On Thu, Nov 19, 2015 at 5:00 PM, Willy Tarreau <w@1wt.eu> wrote:
> > Hi Kees,
> >
> > On Thu, Nov 19, 2015 at 04:10:43PM -0800, Kees Cook wrote:
> >> Normally, when a user can modify a file that has setuid or setgid bits,
> >> those bits are cleared when they are not the file owner or a member of the
> >> group. This is enforced when using write() directly but not when writing
> >> to a shared mmap on the file. This could allow the file writer to gain
> >> privileges by changing the binary without losing the setuid/setgid bits.
> >>
> >> Signed-off-by: Kees Cook <keescook@chromium.org>
> >> Cc: stable@vger.kernel.org
> >> ---
> >>  mm/memory.c | 1 +
> >>  1 file changed, 1 insertion(+)
> >>
> >> diff --git a/mm/memory.c b/mm/memory.c
> >> index deb679c31f2a..4c970a4e0057 100644
> >> --- a/mm/memory.c
> >> +++ b/mm/memory.c
> >> @@ -2036,6 +2036,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
> >>
> >>               if (!page_mkwrite)
> >>                       file_update_time(vma->vm_file);
> >> +             file_remove_privs(vma->vm_file);
> >
> > I thought you said in one of the early mails of this thread that it
> > didn't work. Or maybe I misunderstood.
> 
> I had a think-o in my earlier attempts. I understood the meaning of
> page_mkwrite incorrectly.
>
> > Also, don't you think we should move that into the if (!page_mkwrite)
> > just like for the time update ?
> 
> Nope, page_mkwrite indicates if there was a vmops call to
> page_mkwrite. In this case, it means "I will update the file time if
> the filesystem driver didn't take care of it like it should". For
> file_remove_privs, we want to always do it, since we should not depend
> on filesystems to do it.

Ah OK, thanks for the explanation, I didn't understand it like this
at all last time I read it.

Cheers,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
