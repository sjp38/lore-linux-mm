Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 55ACC8D0039
	for <linux-mm@kvack.org>; Sat, 19 Mar 2011 10:55:39 -0400 (EDT)
Received: by yws5 with SMTP id 5so2512911yws.14
        for <linux-mm@kvack.org>; Sat, 19 Mar 2011 07:55:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1103181448100.2092@sister.anvils>
References: <201102262256.31565.nai.xia@gmail.com>
	<20110302143142.a3c0002b.akpm@linux-foundation.org>
	<201103181529.43659.nai.xia@gmail.com>
	<alpine.LSU.2.00.1103181448100.2092@sister.anvils>
Date: Sat, 19 Mar 2011 22:55:36 +0800
Message-ID: <AANLkTimZsGCTJoea-uK9Box5WCXHziGBH7+qFq7yy=PN@mail.gmail.com>
Subject: Re: [PATCH] ksm: add vm_stat and meminfo entry to reflect pte mapping
 to ksm pages
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Sat, Mar 19, 2011 at 6:40 AM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 18 Mar 2011, Nai Xia wrote:
>> >On Thursday 03 March 2011, at 06:31:42, <Andrew Morton <akpm@linux-foun=
dation.org>> wrote
>> > This patch obviously wasn't tested with CONFIG_KSM=3Dn, which was a
>> > pretty basic patch-testing failure :(
>>
>> Oops, I will be careful to avoid similar mistakes next time.
>>
>> >
>> > I fixed up my tree with the below, but really the amount of ifdeffing
>> > is unacceptable - please find a cleaner way to fix up this patch.
>>
>> Ok, I will have a try in my next patch submit.
>
> A couple of notes on that.
>
> akpm's fixup introduced an #ifdef CONFIG_KSM in mm/ksm.c: that should
> be, er, unnecessary - since ksm.c is only compiled when CONFIG_KSM=3Dy.

This was lately pointed out by me and canceled by another patch in
mm-commits@vger.kernel.org and CCed to your obsolete email
address: hugh.dickins@tiscali.co.uk I think.

>
> And PageKsm(page) evaluates to 0 when CONFIG_KSM is not set, so the
> optimizer should eliminate code from most places without #ifdef:
> though you need to keep the #ifdef around display in /proc/meminfo
> itself, so as not to annoy non-KSM people with an always 0kB line.

This is just what I thought before I introduced NR_KSM_PAGES_SHARING,
which then did break the compiling. My mistake.

>
> But I am uncomfortable with the whole patch.
>
> Can you make a stronger case for it? =A0KSM is designed to have its own
> cycle, and to keep out of the way of the rest of mm as much as possible
> (not as much as originally hoped, I admit). =A0Do we really want to show
> its statistics in /proc/meminfo now? =A0And do we really care that they
> don't keep up with exiting processes when the scan rate is low?

OK, I have to explain, here.
This patch is actually a tiny part of a bunch of code I wrote to improve ks=
m
in several aspects(This is somewhat off the topic but if you are interested=
,
please take at look at  http://code.google.com/p/uksm/, It's still on
very early
stage).

In my code, the inconsistency is amplified by non-uniform
scan speed for different VMAs and significantly improved max scan speed.
Then I think this patch may also be helpful to ksm itself.  Just as you sai=
d,
I had thought it at least improves the accuracy.

>
> I am not asserting that we don't, nor am I nacking your patch:
> but I would like to hear more support for it, before it adds
> yet another line to our user interface in /proc/meminfo.

Then how about not touching the sexy meminfo and adding a new
interface file in /sys/kernel/mm/ksm/ ?  OK, on condition that the bug
below can be properly solved.

>
> And there is an awkward little bug in your patch, which amplifies
> a more significant and shameful pair of bugs of mine in KSM itself -
> no wonder that I'm anxious about your patch going in!
>
> Your bug is precisely where akpm added the #ifdef in ksm.c. =A0The
> problem is that page_mapcount() is maintained atomically, generally
> without spinlock or pagelock: so the value of mapcount there, unless
> it is 1, can go up or down racily (as other processes sharing that
> anonymous page fork or unmap at the same time).

You are right,  copy_one_pte does not take page lock. So it's definitely a
bug in my patch, although it did not appear in my tests.  Actually, there i=
s
another issue in my patch: It tries to count all the ptes, while actually o=
nly
those changed by ksmd really matter, those added by fork does not mean
memory savings. I had thought not taking the mapcount
, instead, only increase the count by one each time a pte is changed by ksm=
d,
but It seems also hard to tell a pte mapped to ksm page was previously
changed by ksmd or by fork when it gets unmapped.

So indeed, I have no idea to fix this bug for the time being.


>
> I could hardly complain about that, while suggesting above that more
> approximate numbers are good enough! =A0Except that, when KSM is turned
> off, there's a chance that you'd be left showing a non-0 kB in
> /proc/meminfo. =A0Then people will want a fix, and I don't yet know
> what that fix will be.
>
> My first bug is in the break_cow() technique used to get back to
> normal, when merging into a KSM page fails for one reason or another:
> that technique misses other mappings of the page. =A0I did have a patch
> in progress to fix that a few months ago, but it wasn't quite working,
> and then I realized the second bug: that even when successful, if
> VM_UNMERGEABLE has been used in forked processes, then we could end up
> with a KSM page in a VM_UNMERGEABLE area, which is against the spec.
>
> A solution to all three problems would be to revert to allocating a
> separate KSM page, instead of using one of the pages already there.
> But that feels like a regression, and I don't think anybody is really
> hurting from the current situation, so I've not jumped to fix it yet.
>
> Hugh
>

Yes, I agree on your point. Let's hope there is an efficient and
simple solution.
But for now,  please drop this patch, Andrew.

Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
