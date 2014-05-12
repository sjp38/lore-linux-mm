Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id C65066B0038
	for <linux-mm@kvack.org>; Mon, 12 May 2014 08:46:22 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so4756135eei.28
        for <linux-mm@kvack.org>; Mon, 12 May 2014 05:46:22 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id v2si10469462eel.76.2014.05.12.05.46.20
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 05:46:21 -0700 (PDT)
Date: Mon, 12 May 2014 15:43:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
Message-ID: <20140512124344.GA26865@node.dhcp.inet.fi>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
 <20140508160205.A0EC7E009B@blue.fi.intel.com>
 <CA+55aFw9eiaFtr+c4gcGSWG=pPeqDnX5aPQMVMqX1XkPF30ahg@mail.gmail.com>
 <20140509140536.F06BFE009B@blue.fi.intel.com>
 <CA+55aFz9Yo7OC03tKt2wsdd8cDi00yxvMwszrsOsx0ZVEh6zqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz9Yo7OC03tKt2wsdd8cDi00yxvMwszrsOsx0ZVEh6zqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Armin Rigo <arigo@tunes.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Fri, May 09, 2014 at 08:14:08AM -0700, Linus Torvalds wrote:
> On Fri, May 9, 2014 at 7:05 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > Hm. I'm confused here. Do we have any limit forced per-user?
> 
> Sure we do. See "struct user_struct". We limit max number of
> processes, open files, signals etc.
> 
> > I only see things like rlimits which are copied from parrent.
> > Is it what you want?
> 
> No, rlimits are per process (although in some cases what they limit
> are counted per user despite the _limits_ of those resources then
> being settable per thread).
> 
> So I was just thinking that if we raise the per-mm default limits,
> maybe we should add a global per-user limit to make it harder for a
> user to use tons and toms of vma's.

Here's the first attempt.

I'm not completely happy about current_user(). It means we rely on that
user of mm owner task is always equal to user of current. Not sure if it's
always the case.

Other option is to make MM_OWNER is always on and lookup proper user
through task_cred_xxx(rcu_dereference(mm->owner), user).
