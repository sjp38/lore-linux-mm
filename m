Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4EC6B0071
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 12:13:26 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so2500051wiv.2
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 09:13:26 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id yx4si24745729wjc.48.2015.02.09.09.13.24
        for <linux-mm@kvack.org>;
        Mon, 09 Feb 2015 09:13:25 -0800 (PST)
Date: Mon, 9 Feb 2015 19:13:20 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: BUG: non-zero nr_pmds on freeing mm: 1
Message-ID: <20150209171320.GB29522@node.dhcp.inet.fi>
References: <CA+icZUVTVdHc3QYD1LkWn=Xt-Zz6RcXPcjL6Xbpz0FZ6rdA5CQ@mail.gmail.com>
 <20150209164248.GA29522@node.dhcp.inet.fi>
 <CA+icZUU_xYhg1kqbrb+y71EQQWNPk0vf9V2YS4dimXBA5jTYCg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+icZUU_xYhg1kqbrb+y71EQQWNPk0vf9V2YS4dimXBA5jTYCg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Pat Erley <pat-lkml@erley.org>, Linux-Next <linux-next@vger.kernel.org>, kirill.shutemov@linux.intel.com, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Feb 09, 2015 at 06:06:11PM +0100, Sedat Dilek wrote:
> On Mon, Feb 9, 2015 at 5:42 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > On Sat, Feb 07, 2015 at 08:33:02AM +0100, Sedat Dilek wrote:
> >> On Sat, Feb 7, 2015 at 6:12 AM, Pat Erley <pat-lkml@erley.org> wrote:
> >> > I'm seeing the message in $subject on my Xen DOM0 on next-20150204 on
> >> > x86_64.  I haven't had time to bisect it, but have seen some discussion on
> >> > similar topics here recently.  I can trigger this pretty reliably by
> >> > watching Netflix.  At some point (minutes to hours) into it, the netflix
> >> > video goes black (audio keeps going, so it still thinks it's working) and
> >> > the error appears in dmesg.  Refreshing the page gets the video going again,
> >> > and it will continue playing for some indeterminate amount of time.
> >> >
> >> > Kirill, I've CC'd you as looking in the logs, you've patched a false
> >> > positive trigger of this very recently(patch in kernel I'm running).  Am I
> >> > actually hitting a problem, or is this another false positive case? Any
> >> > additional details that might help?
> >> >
> >> > Dmesg from system attached.
> >>
> >> [ CC some mm folks ]
> >>
> >> I have seen this, too.
> >>
> >> root# grep "BUG: non-zero nr_pmds on freeing mm:" /var/log/kern.log | wc -l
> >> 21
> >>
> >> Checking my logs: On next-20150203 and next-20150204.
> >>
> >> I am here not in a VM environment and cannot say what causes these messages.
> >
> > Sorry, my fault.
> >
> > The patch below should fix that.
> >
> > From 11bce596e653302e41f819435912f01ca8cbc27e Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Mon, 9 Feb 2015 18:34:56 +0200
> > Subject: [PATCH] mm: fix race on pmd accounting
> >
> > Do not account the pmd table to the process if other thread allocated it
> > under us.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: Sedat Dilek <sedat.dilek@gmail.com>
> 
> Still building with the fix...
> 
> Please feel free to add Pat as a reporter.
> 
>      Reported-by: Pat Erley <pat-lkml@erley.org>
> 
> Is that fixing...?
> 
> commit daa1b0f29cdccae269123e7f8ae0348dbafdc3a7
> "mm: account pmd page tables to the process"
> 
> If yes, please add a Fixes-tag [2]...
> 
>      Fixes: daa1b0f29cdc ("mm: account pmd page tables to the process")
> 
> I will re-test with LTP/mmap and report.

The commit is not in Linus tree, so the sha1-id is goinging to change.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
