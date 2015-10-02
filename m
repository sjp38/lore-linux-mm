Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED0582F92
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 02:23:46 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so19523253wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 23:23:45 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id p8si8041832wiw.2.2015.10.01.23.23.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 23:23:44 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so17417617wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 23:23:44 -0700 (PDT)
Date: Fri, 2 Oct 2015 08:23:40 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20151002062340.GB30051@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <CALCETrWaar55uTv5q3Ym1KEdQjfgjDfwMM=PPnjb9eV+ASS_ig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWaar55uTv5q3Ym1KEdQjfgjDfwMM=PPnjb9eV+ASS_ig@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Kees Cook <keescook@google.com>, Dave Hansen <dave@sr71.net>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>


* Andy Lutomirski <luto@amacapital.net> wrote:

> >> Assuming it boots up fine on a typical distro, i.e. assuming that there are no
> >> surprises where PROT_READ && PROT_EXEC sections are accessed as data.
> >
> > I can't wait to find out what implicitly expects PROT_READ from
> > PROT_EXEC mappings. :)

So what seems to happen is that there are no pure PROT_EXEC mappings in practice - 
they are only omnibus PROT_READ|PROT_EXEC mappings, an unknown proportion of which 
truly relies on PROT_READ:

  $ for C in firefox ls perf libreoffice google-chrome Xorg xterm \
      konsole; do echo; echo "# $C:"; strace -e trace=mmap -f $C -h 2>&1 | cut -d, -f3 | \
      grep PROT | sort | uniq -c; done

# firefox:
     13  PROT_READ
     82  PROT_READ|PROT_EXEC
    184  PROT_READ|PROT_WRITE
      2  PROT_READ|PROT_WRITE|PROT_EXEC

# ls:
      2  PROT_READ
      7  PROT_READ|PROT_EXEC
     17  PROT_READ|PROT_WRITE

# perf:
      1  PROT_READ
     20  PROT_READ|PROT_EXEC
     44  PROT_READ|PROT_WRITE

# libreoffice:
      2  PROT_NONE
     87  PROT_READ
    148  PROT_READ|PROT_EXEC
    339  PROT_READ|PROT_WRITE

# google-chrome:
     39  PROT_READ
    121  PROT_READ|PROT_EXEC
    345  PROT_READ|PROT_WRITE

# Xorg:
      1  PROT_READ
     22  PROT_READ|PROT_EXEC
     39  PROT_READ|PROT_WRITE

# xterm:
      1  PROT_READ
     25  PROT_READ|PROT_EXEC
     46  PROT_READ|PROT_WRITE

# konsole:
      1  PROT_READ
    101  PROT_READ|PROT_EXEC
    175  PROT_READ|PROT_WRITE

So whatever kernel side method we come up with, it's not something that I expect 
to become production quality. "Proper" conversion to pkeys has to be driven from 
the user-space side.

That does not mean we can not try! :-)

> There's one annoying issue at least:
> 
> mprotect_pkey(..., PROT_READ | PROT_EXEC, 0) sets protection key 0.
> mprotect_pkey(..., PROT_EXEC, 0) maybe sets protection key 15 or
> whatever we use for this.  What does mprotect_pkey(..., PROT_EXEC, 0)
> do?  What if the caller actually wants key 0?  What if some CPU vendor
> some day implements --x for real?

That comes from the hardcoded "user-space has 4 bits to itself, not managed by the 
kernel" assumption in the whole design. So no layering between different 
user-space libraries using pkeys in a different fashion, no transparent kernel use 
of pkeys (such as it may be), etc.

I'm not sure it's _worth_ managing these 4 bits, but '16 separate keys' does seem 
to be to me above a certain resource threshold that should be more explicitly 
managed than telling user-space: "it's all yours!".

> Also, how do we do mprotect_pkey and say "don't change the key"?

So if we start managing keys as a resource (i.e. alloc/free up to 16 of them), and 
provide APIs for user-space to do all that, then user-space is not supposed to 
touch keys it has not allocated for itself - just like it's not supposed to write 
to fds it has not opened.

Such an allocation method can still 'mess up', and if the kernel allocates a key 
for its purposes it should not assume that user-space cannot change it, but at 
least for non-buggy code there's no interaction and it would work out fine.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
