Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 764788D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 14:39:11 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p26Jd8DW031017
	for <linux-mm@kvack.org>; Sun, 6 Mar 2011 11:39:09 -0800
Received: from gyb13 (gyb13.prod.google.com [10.243.49.77])
	by hpaq11.eem.corp.google.com with ESMTP id p26Jd57U012611
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 6 Mar 2011 11:39:07 -0800
Received: by gyb13 with SMTP id 13so1850377gyb.0
        for <linux-mm@kvack.org>; Sun, 06 Mar 2011 11:39:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1103020625290.10180@router.home>
References: <4D6CA852.3060303@cn.fujitsu.com>
	<AANLkTimXy2Yaj+NTDMNTWuLqHHfKZJhVDpeXj3CfMvBf@mail.gmail.com>
	<alpine.DEB.2.00.1103010909320.6253@router.home>
	<AANLkTim0Zjc7c9-7LCnEaYpV5PVN=5fNQpjMYqtZe-fk@mail.gmail.com>
	<alpine.DEB.2.00.1103020625290.10180@router.home>
Date: Sun, 6 Mar 2011 11:39:04 -0800
Message-ID: <AANLkTikk02f6kLiPFqqAGroJErQkHbJFfHzpHy4Y5P8Y@mail.gmail.com>
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Mar 2, 2011 at 4:32 AM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 1 Mar 2011, Hugh Dickins wrote:
>
>> > Struct page may be larger for debugging purposes already because of th=
e
>> > need for extended spinlock data.
>>
>> That was so for a long time, but I stopped it just over a year ago
>> with commit a70caa8ba48f21f46d3b4e71b6b8d14080bbd57a, stop ptlock
>> enlarging struct page.
>
> Strange. I just played around with in in January and the page struct size
> changes when I build kernels with full debugging. I have some
> cmpxchg_double patches here that depend on certain alignment in the page
> struct. Debugging causes all that stuff to get out of whack so that I had
> to do some special patches to make sure fields following the spinlock are
> properly aligned when the sizes change.

That puzzles me, it's not my experience and I don't have an
explanation: do you have time to investigate?

Uh oh, you're going to tell me you're working on an out-of-tree
architecture with a million cpus ;)  In that case, yes, I'm afraid
I'll have to update the SPLIT_PTLOCK_CPUS defaulting (for a million -
1 even).

>
>> If a union leads to "random junk" overwriting the page->mapping field
>> when the page is reused, and that junk could resemble the pointer in
>> question, then KSM would mistakenly think it still owned the page.
>> Very remote chance, and maybe it amounts to no more than a leak. =C2=A0B=
ut
>> I'd still prefer we keep page->mapping for pointers (sometimes with
>> lower bits set as flags).
>
> DESTROY BY RCU uses the lru field which follows the mapping field in page
> struct. Why would random junk overwrite the mapping field?

Random junk does not overwrite the mapping field with the current
implementation of DESTROY_BY_RCU.  But you and Jiangshan were
discussing how to change it, so I was warning of this issue with
page->mapping.

But I would anyway agree with Jiangshan, that it's preferable not to
bloat struct page size just for this DESTROY_BY_RCU issue, even if it
is only an issue when debugging.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
