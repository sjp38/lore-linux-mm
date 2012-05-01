Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 117456B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 23:13:46 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so2762563obb.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 20:13:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1204270323000.11866@chino.kir.corp.google.com>
References: <1335516144-3486-1-git-send-email-minchan@kernel.org>
	<alpine.DEB.2.00.1204270323000.11866@chino.kir.corp.google.com>
Date: Tue, 1 May 2012 13:13:44 +1000
Message-ID: <CAPa8GCBN6U_GRaG=GYFByNB4REcVA-yy+kKMMbrGaDKULUXW9w@mail.gmail.com>
Subject: Re: [RFC] vmalloc: add warning in __vmalloc
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@gmail.com, Neil Brown <neilb@suse.de>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Adrian Hunter <adrian.hunter@intel.com>, Steven Whitehouse <swhiteho@redhat.com>, "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@namei.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@newdream.net>

On 27 April 2012 20:36, David Rientjes <rientjes@google.com> wrote:
> On Fri, 27 Apr 2012, Minchan Kim wrote:
>
>> Now there are several places to use __vmalloc with GFP_ATOMIC,
>> GFP_NOIO, GFP_NOFS but unfortunately __vmalloc calls map_vm_area
>> which calls alloc_pages with GFP_KERNEL to allocate page tables.
>> It means it's possible to happen deadlock.
>> I don't know why it doesn't have reported until now.
>>
>> Firstly, I tried passing gfp_t to lower functions to support __vmalloc
>> with such flags but other mm guys don't want and decided that
>> all of caller should be fixed.
>>
>> http://marc.info/?l=3Dlinux-kernel&m=3D133517143616544&w=3D2
>>
>> To begin with, let's listen other's opinion whether they can fix it
>> by other approach without calling __vmalloc with such flags.
>>
>> So this patch adds warning to detect and to be fixed hopely.
>> I Cced related maintainers.
>> If I miss someone, please Cced them.
>>
>> side-note:
>> =A0 I added WARN_ON instead of WARN_ONCE to detect all of callers
>> =A0 and each WARN_ON for each flag to detect to use any flag easily.
>> =A0 After we fix all of caller or reduce such caller, we can merge
>> =A0 a warning with WARN_ONCE.
>>
>
> I disagree with this approach since it's going to violently spam an
> innocent kernel user's log with no ratelimiting and for a situation that
> actually may not be problematic.

With WARN_ON_ONCE, it should be good.

>
> Passing any of these bits (the difference between GFP_KERNEL and
> GFP_ATOMIC) only means anything when we're going to do reclaim. =A0And I'=
m
> suspecting we would have seen problems with this already since
> pte_alloc_kernel() does __GFP_REPEAT on most architectures meaning that i=
t
> will loop infinitely in the page allocator until at least one page is
> freed (since its an order-0 allocation) which would hardly ever happen if
> __GFP_FS or __GFP_IO actually meant something in this context.
>
> In other words, we would already have seen these deadlocks and it would
> have been diagnosed as a vmalloc(GFP_ATOMIC) problem. =A0Where are those =
bug
> reports?

That's not sound logic to disprove a bug.

I think simply most callers are permissive and don't mask out flags.
But for example a filesystem holding an fs lock and then doing
vmalloc(GFP_NOFS) can certainly deadlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
