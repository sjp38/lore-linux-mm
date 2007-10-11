Received: by py-out-1112.google.com with SMTP id d32so2485625pye
        for <linux-mm@kvack.org>; Thu, 11 Oct 2007 15:12:05 -0700 (PDT)
Message-ID: <cfa94dc20710111512j9b6c038qf89c516ecd605411@mail.gmail.com>
Date: Thu, 11 Oct 2007 15:12:05 -0700
From: "Ryan Finnie" <ryan@finnie.org>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <20071011144740.136b31a8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200710071920.l97JKJX5018871@agora.fsl.cs.sunysb.edu>
	 <20071011144740.136b31a8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/11/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> shit.  That's a nasty bug.  Really userspace should be testing for -1, but
> the msync() library function should only ever return 0 or -1.
>
> Does this fix it?
>
> --- a/mm/page-writeback.c~a
> +++ a/mm/page-writeback.c
> @@ -850,8 +850,10 @@ retry:
>
>                         ret = (*writepage)(page, wbc, data);
>
> -                       if (unlikely(ret == AOP_WRITEPAGE_ACTIVATE))
> +                       if (unlikely(ret == AOP_WRITEPAGE_ACTIVATE)) {
>                                 unlock_page(page);
> +                               ret = 0;
> +                       }
>                         if (ret || (--(wbc->nr_to_write) <= 0))
>                                 done = 1;
>                         if (wbc->nonblocking && bdi_write_congested(bdi)) {
> _
>

Pekka Enberg replied with an identical patch a few days ago, but for
some reason the same condition flows up to msync as -1 EIO instead of
AOP_WRITEPAGE_ACTIVATE with that patch applied.  The last part of the
thread is below.  Thanks.

Ryan

On 10/7/07, Ryan Finnie <ryan@finnie.org> wrote:
> On 10/7/07, Pekka J Enberg <penberg@cs.helsinki.fi> wrote:
> > On 10/7/07, Erez Zadok <ezk@cs.sunysb.edu> wrote:
> > > Anyway, some Ubuntu users of Unionfs reported that msync(2) sometimes
> > > returns AOP_WRITEPAGE_ACTIVATE (decimal 524288) back to userland.
> > > Therefore, some user programs fail, esp. if they're written such as
> > > this:
> >
> ...
> > It's a kernel bug. AOP_WRITEPAGE_ACTIVATE is a hint to the VM to avoid
> > writeback of the page in the near future. I wonder if it's enough that we
> > change the return value to zero from
> > mm/page-writeback.c:write_cache_pages() in case we hit AOP_WRITEPAGE_ACTIVE...
>
> Doesn't appear to be enough.  I can't figure out why (since it appears
> write_cache_pages bubbles up directly to sys_msync), but with that
> patch applied, in my test case[1], msync returns -1 EIO.  However,
> with the exact same kernel without that patch applied, msync returns
> 524288 (AOP_WRITEPAGE_ACTIVATE).  But as your patch specifically flips
> 524288 to 0, I can't figure out how it eventually returns  -1 EIO.
>
> Ryan
>
> [1] "apt-get check" on a unionfs2 mount backed by tmpfs over cdrom,
> standard livecd setup
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
