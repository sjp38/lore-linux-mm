Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0534F8D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 11:27:49 -0400 (EDT)
Received: by iwg8 with SMTP id 8so3603679iwg.14
        for <linux-mm@kvack.org>; Thu, 07 Apr 2011 08:27:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1302178426.3357.34.camel@edumazet-laptop>
References: <20110315132527.130FB80018F1@mail1005.cent> <20110317001519.GB18911@kroah.com>
 <20110407120112.E08DCA03@pobox.sk> <4D9D8FAA.9080405@suse.cz>
 <BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com> <1302177428.3357.25.camel@edumazet-laptop>
 <1302178426.3357.34.camel@edumazet-laptop>
From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 7 Apr 2011 23:27:26 +0800
Message-ID: <BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
Subject: Re: Regression from 2.6.36
Content-Type: multipart/mixed; boundary=0016368e1b8d65b44804a055c0e9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

--0016368e1b8d65b44804a055c0e9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 7, 2011 at 8:13 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
> Le jeudi 07 avril 2011 =E0 13:57 +0200, Eric Dumazet a =E9crit :
>
>> We had a similar memory problem in fib_trie in the past =A0: We force a
>> synchronize_rcu() every XXX Mbytes allocated to make sure we dont have
>> too much ram waiting to be freed in rcu queues.

I don't think there is too much memory allocated by vmalloc to free.
My patch should reduce the size of the memory allocated by vmalloc().
I think the real problem is kfree always returns the memory, whose
size is aligned to 2^n pages, and more memory are used than before.

>
> This was done in commit c3059477fce2d956
> (ipv4: Use synchronize_rcu() during trie_rebalance())
>
> It was possible in fib_trie because we hold RTNL lock, so managing
> a counter was free.
>
> In fs case, we might use a percpu_counter if we really want to limit the
> amount of space.
>
> Now, I am not even sure we should care that much and could just forget
> about this high order pages use.

In normal cases, only a few fds are used, the ftable isn't larger than
one page, so we should use kmalloc to reduce the memory cost. Maybe we
should set a upper limit for kmalloc() here. One page?

azurlt, would you please test the patch attached? Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)

--0016368e1b8d65b44804a055c0e9
Content-Type: application/octet-stream; name="x.diff"
Content-Disposition: attachment; filename="x.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gm7ubqed0

ZGlmZiAtLWdpdCBhL2ZzL2ZpbGUuYyBiL2ZzL2ZpbGUuYwppbmRleCAwYmUzNDQ3Li45NjZiZjBj
IDEwMDY0NAotLS0gYS9mcy9maWxlLmMKKysrIGIvZnMvZmlsZS5jCkBAIC00Myw5ICs0MywxMSBA
QCBzdGF0aWMgaW5saW5lIHZvaWQgKmFsbG9jX2ZkbWVtKHVuc2lnbmVkIGludCBzaXplKQogewog
CXZvaWQgKmRhdGE7CiAKLQlkYXRhID0ga21hbGxvYyhzaXplLCBHRlBfS0VSTkVMfF9fR0ZQX05P
V0FSTik7Ci0JaWYgKGRhdGEgIT0gTlVMTCkKLQkJcmV0dXJuIGRhdGE7CisJaWYgKHNpemUgPD0g
UEFHRV9TSVpFKSB7CisJCWRhdGEgPSBrbWFsbG9jKHNpemUsIEdGUF9LRVJORUx8X19HRlBfTk9X
QVJOKTsKKwkJaWYgKGRhdGEgIT0gTlVMTCkKKwkJCXJldHVybiBkYXRhOworCX0KIAogCXJldHVy
biB2bWFsbG9jKHNpemUpOwogfQo=
--0016368e1b8d65b44804a055c0e9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
