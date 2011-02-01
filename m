Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B6E5A8D0039
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 01:36:23 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p116aIB7015073
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 22:36:20 -0800
Received: from yxe42 (yxe42.prod.google.com [10.190.2.42])
	by kpbe19.cbf.corp.google.com with ESMTP id p116aGam016636
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 22:36:17 -0800
Received: by yxe42 with SMTP id 42so2376844yxe.9
        for <linux-mm@kvack.org>; Mon, 31 Jan 2011 22:36:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTinG7eHR1_kfEyvJYw52ngyvqv5UzigEOddsi9ye@mail.gmail.com>
References: <20110201010341.GA21676@google.com>
	<AANLkTinG7eHR1_kfEyvJYw52ngyvqv5UzigEOddsi9ye@mail.gmail.com>
Date: Mon, 31 Jan 2011 22:36:16 -0800
Message-ID: <AANLkTinjoq1bdDLSbTaSi4eJZ73jbdAsvJOyZy93xYQT@mail.gmail.com>
Subject: Re: [PATCH] mlock: operate on any regions with protection != PROT_NONE
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tao Ma <tm@tao.ma>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 9:59 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Feb 1, 2011 at 11:03 AM, Michel Lespinasse <walken@google.com> wrote:
>>
>> I am proposing to let mlock ignore vma protection in all cases except
>> PROT_NONE.
>
> What's so special about PROT_NONE? If you want to mlock something
> without actually being able to then fault that in, why not?
>
> IOW, why wouldn't it be right to just make FOLL_FORCE be unconditional in mlock?

I agree this would be the most logical thing to do, but I'm afraid
people would complain about it as it'd be yet another behavior change.

I don't have the entire context here, but PROT_NONE regions are
actually common in modern userspace. It seems that for most shared
libraries, ld.so creates 4 vmas, one of them being just under 2MB and
with PROT_NONE protection. From my shell, if I do cat /proc/$$/maps, I
see:
[...]
7f41ebdb5000-7f41ebdc5000 r-xp 00000000 fc:03 669498
  /usr/lib/zsh/4.3.10/zsh/computil.so
7f41ebdc5000-7f41ebfc4000 ---p 00010000 fc:03 669498
  /usr/lib/zsh/4.3.10/zsh/computil.so
7f41ebfc4000-7f41ebfc5000 r--p 0000f000 fc:03 669498
  /usr/lib/zsh/4.3.10/zsh/computil.so
7f41ebfc5000-7f41ebfc6000 rw-p 00010000 fc:03 669498
  /usr/lib/zsh/4.3.10/zsh/computil.so
7f41ebfc6000-7f41ebfce000 r-xp 00000000 fc:03 669508
  /usr/lib/zsh/4.3.10/zsh/parameter.so
7f41ebfce000-7f41ec1ce000 ---p 00008000 fc:03 669508
  /usr/lib/zsh/4.3.10/zsh/parameter.so
7f41ec1ce000-7f41ec1cf000 r--p 00008000 fc:03 669508
  /usr/lib/zsh/4.3.10/zsh/parameter.so
7f41ec1cf000-7f41ec1d0000 rw-p 00009000 fc:03 669508
  /usr/lib/zsh/4.3.10/zsh/parameter.so
[...]

I don't know why userspace does that, but these regions currently
never get any page into RSS, even when processes call mlockall(). I am
told that we need to preserve this property.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
