Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 65D5C9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 21:29:01 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p8N1SvPP011137
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 18:28:57 -0700
Received: from qyc1 (qyc1.prod.google.com [10.241.81.129])
	by hpaq1.eem.corp.google.com with ESMTP id p8N1LN4l017570
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 18:23:28 -0700
Received: by qyc1 with SMTP id 1so19333948qyc.18
        for <linux-mm@kvack.org>; Thu, 22 Sep 2011 18:23:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110922161325.f94f9c9e.akpm@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<20110922161325.f94f9c9e.akpm@google.com>
Date: Thu, 22 Sep 2011 18:23:27 -0700
Message-ID: <CANN689Gpn6hx0jXx1bzf_m_x9-ZQ4Uienfxcsyr=wV7ucZQXnQ@mail.gmail.com>
Subject: Re: [PATCH 0/8] idle page tracking / working set estimation
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 22, 2011 at 4:13 PM, Andrew Morton <akpm@google.com> wrote:
> On Fri, 16 Sep 2011 20:39:05 -0700
> Michel Lespinasse <walken@google.com> wrote:
>
>> Please comment on the following patches (which are against the v3.0 kern=
el).
>> We are using these to collect memory utilization statistics for each cgr=
oup
>> accross many machines, and optimize job placement accordingly.
>
> Please consider updating /proc/kpageflags with the three new page
> flags. =A0If "yes": update. =A0If "no": explain/justify.

The PG_stale flag should probably be exported that way. I'll make sure
to add this, thanks for the suggestion!

I am not sure about PG_young and PG_idle since they indicate young
bits have been cleared in PTE(s) pointing to the page since the last
page_referenced() call. This seems rather internal - we don't export
PTE young bits in kpageflags currently, nor do we export anything that
would depend on when page_referenced() was last called.

> Which prompts the obvious: the whole feature could have been mostly
> implemented in userspace, using kpageflags. =A0Some additional kernel
> support would presumably be needed, but I'm not sure how much.
>
> If you haven't already done so, please sketch down what that
> infrastructure would look like and have a think about which approach is
> preferable?

kpageflags does not currently do a page_referenced() call to export
PTE young flags. For a userspace approach, we would have to add that.
Also we would want to actually clear the PTE young bits so that the
page doesn't show up as young again on the next kpageflags read - and,
we wouldn't want to affect the normal LRU algorithms while doing this,
so we'd end up introducing the same PG_young and PG_idle flags. The
next issue would be to find out which cgroup an idle page belongs to -
this could be done by adding a new kpagecgroup file, I suppose. Given
the above, we'd have the necessary components for a userspace approach
- but, the only part that we would really be able to remove from the
kernel side is the loop that scans physical pages and tallies the idle
ones into a per-cgroup count.

> What bugs me a bit about the proposal is its cgroups-centricity. =A0The
> question "how much memory is my application really using" comes up
> again and again. =A0It predates cgroups. =A0One way to answer that questi=
on
> is to force a massive amount of swapout on the entire machine, then let
> the system recover and take a look at your app's RSS two minutes later.
> This is very lame.
>
> It's a legitimate requirement, and the kstaled infrastructure puts a
> lot of things in place to answer it well. =A0But as far as I can tell it
> doesn't quite get over the line. =A0Then again, maybe it _does_ get
> there: put the application into a memcg all of its own, just for
> instrumentation purposes and then use kstaled to monitor it?

Yes, this is what I would recomment in this situation - create a
memory cgroup to move the application in, and see what kstaled
reports.

> <later> OK, I'm surprised to discover that kstaled is doing a physical
> scan and not a virtual one. =A0I assume it works, but I don't know why.
> But it makes the above requirement harder, methinks.

The reason for the physical scan is that a virtual scan would have
some limitations:
- it would only report memory that's virtually mapped - we do want
file pages to be classified as idle or not, regardless of how the file
gets accessed
- it may not work well with jobs that involve short lived processes.

> How does all this code get along with hugepages, btw?

They should get along now that Andreas updated get_page and
get_page_unless_zero to avoid the race with THP tail page splitting.

However, you're reminding me that I forgot to include the patch that
would make the accounting correct when we encounter a THP page (we
want to report the entire page as idle rather than just the first 4K,
and increment pfn appropriately for the page size)...

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
