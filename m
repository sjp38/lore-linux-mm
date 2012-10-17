Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id EAAEA6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 21:53:22 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so8363891obc.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 18:53:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210161847060.20503@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
 <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com>
 <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
 <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <CAHGf_=qSy63-H0ZgdYBtUmdDpxacmAcK=L7X+Ajgr8Yboztqig@mail.gmail.com> <alpine.DEB.2.00.1210161847060.20503@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 16 Oct 2012 21:53:02 -0400
Message-ID: <CAHGf_=pVx=7nCZ1+e2M+bKH=SUGJa585+QxFbNboaq7_vy4MVw@mail.gmail.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in numa_maps
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@redhat.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 16, 2012 at 9:49 PM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 16 Oct 2012, KOSAKI Motohiro wrote:
>
>> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> > index 0b78fb9..d04a8a5 100644
>> > --- a/mm/mempolicy.c
>> > +++ b/mm/mempolicy.c
>> > @@ -1536,9 +1536,8 @@ asmlinkage long compat_sys_mbind(compat_ulong_t start, compat_ulong_t len,
>> >   *
>> >   * Returns effective policy for a VMA at specified address.
>> >   * Falls back to @task or system default policy, as necessary.
>> > - * Current or other task's task mempolicy and non-shared vma policies
>> > - * are protected by the task's mmap_sem, which must be held for read by
>> > - * the caller.
>> > + * Current or other task's task mempolicy and non-shared vma policies must be
>> > + * protected by task_lock(task) by the caller.
>>
>> This is not correct. mmap_sem is needed for protecting vma. task_lock()
>> is needed to close vs exit race only when task != current. In other word,
>> caller must held both mmap_sem and task_lock if task != current.
>
> The comment is specifically addressing non-shared vma policies, you do not
> need to hold mmap_sem to access another thread's mempolicy.

I didn't say old comment is true. I just only your new comment also false.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
