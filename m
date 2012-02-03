Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 9D43E6B002C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 13:34:12 -0500 (EST)
Received: by yenq11 with SMTP id q11so2255435yen.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 10:34:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=qA6EFue2-mNUg9udWV4xSx86XQsnyGV07hfZOUx6_egw@mail.gmail.com>
References: <20120116163106.GC7180@jl-vm1.vm.bytemark.co.uk>
	<1326776095-2629-1-git-send-email-siddhesh.poyarekar@gmail.com>
	<CAAHN_R2g9zaujw30+zLf91AGDHNqE6HDc8Z4yJbrzgJcJYFkXg@mail.gmail.com>
	<4F2B02BC.8010308@gmail.com>
	<CAAHN_R0O7a+RX7BDfas3+vC+mnQpp0h3y4bBa1u4T-Jt=S9J_w@mail.gmail.com>
	<CAHGf_=qA6EFue2-mNUg9udWV4xSx86XQsnyGV07hfZOUx6_egw@mail.gmail.com>
Date: Sat, 4 Feb 2012 00:04:11 +0530
Message-ID: <CAAHN_R0+ExGcdpLM7KwC_KsPOemVOiRrmyWcowiu5_cWW3BPLQ@mail.gmail.com>
Subject: Re: [RESEND][PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Jamie Lokier <jamie@shareable.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org

On Fri, Feb 3, 2012 at 1:31 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> The fact is, now process stack and pthread stack clearly behave
> different dance. libc don't expect pthread stack grow automatically.
> So, your patch will break userland. Just only change display thing.

The change should not make thread stacks (as implemented by glibc)
grow automatically in the general case since it has to implement guard
page(s) at the beginning of the mapped memory for stack using
mprotect(top, size, PROT_NONE). Due to this, the program will crash
before it ever has a chance to cause a page fault to make the stack
grow. This is of course assuming that the program doesn't purposely
jump over the guard page(s) by setting %sp beyond them and then
causing a page fault. So the only case in which a thread stack will
grow automatically is if the stackguard is set to 0:

http://pubs.opengroup.org/onlinepubs/007904975/functions/pthread_attr_setguardsize.html

I have also dropped an email on the libc-alpha list here to solicit
comments from libc maintainers on this:

http://sourceware.org/ml/libc-alpha/2012-02/msg00036.html


-- 
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
