Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 003FD6B005A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 14:02:10 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so11578537pbb.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 11:02:10 -0700 (PDT)
Date: Wed, 3 Oct 2012 11:02:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: use %pK for /proc/vmallocinfo
In-Reply-To: <CAGXu5jL4Dd3jCusr+Du4q7tOhcsKaSQbW6u_ZN8ZSBry2AQARg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210031051150.29765@chino.kir.corp.google.com>
References: <20121002234934.GA9194@www.outflux.net> <alpine.DEB.2.00.1210022209070.9523@chino.kir.corp.google.com> <CAGXu5j+ZU_wrqeEYE7GCE6ArFo8z4AO=OW7mOSn0-fp1E9B6+Q@mail.gmail.com> <alpine.DEB.2.00.1210022236370.10573@chino.kir.corp.google.com>
 <CAGXu5jL4Dd3jCusr+Du4q7tOhcsKaSQbW6u_ZN8ZSBry2AQARg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Joe Perches <joe@perches.com>, Kautuk Consul <consul.kautuk@gmail.com>, linux-mm@kvack.org, Brad Spengler <spender@grsecurity.net>

On Wed, 3 Oct 2012, Kees Cook wrote:

> > So root does echo 0 > /proc/sys/kernel/kptr_restrict first.  Again: what
> > are you trying to protect?
> 
> Only CAP_SYS_ADMIN can change the setting. This is, for example, for
> containers, or other situations where a uid 0 process lacking
> CAP_SYS_ADMIN cannot see virtual addresses. It's a very paranoid case,
> yes, but it's part of how this feature was designed. Think of it as
> supporting the recent uid 0 vs ring 0 boundary. :)
> 

The intention of /proc/vmallocinfo being S_IRUSR is obviously to only 
allow root to read this information to begin with, so if root lacks 
CAP_SYS_ADMIN then it seems the best fix would be to return an empty file 
on read()?  Or give permission to everybody to read it but only return a 
positive count when they have CAP_SYS_ADMIN?

There's no need to make this so convoluted that you need to have the right 
combination of uid, kptr_restrict, CAP_SYS_ADMIN, and CAP_SYSLOG to get 
anything valuable out of this file, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
