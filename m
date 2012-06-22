Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 802206B026B
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 18:03:04 -0400 (EDT)
Date: Fri, 22 Jun 2012 15:03:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugeltb: Mark hugelb_max_hstate __read_mostly
Message-Id: <20120622150302.f0e349e4.akpm@linux-foundation.org>
In-Reply-To: <87pq91m7fz.fsf@skywalker.in.ibm.com>
References: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120614141257.GQ27397@tiehlicka.suse.cz>
	<87pq91m7fz.fsf@skywalker.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com

On Fri, 15 Jun 2012 11:40:24 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Michal Hocko <mhocko@suse.cz> writes:
> 
> > On Thu 14-06-12 19:26:18, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >> 
> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> >> ---
> >>  include/linux/hugetlb.h |    2 +-
> >>  mm/hugetlb.c            |    2 +-
> >>  2 files changed, 2 insertions(+), 2 deletions(-)
> >> 
> >> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> >> index 9650bb1..0f0877e 100644
> >> --- a/include/linux/hugetlb.h
> >> +++ b/include/linux/hugetlb.h
> >> @@ -23,7 +23,7 @@ struct hugepage_subpool {
> >>  };
> >>  
> >>  extern spinlock_t hugetlb_lock;
> >> -extern int hugetlb_max_hstate;
> >> +extern int hugetlb_max_hstate __read_mostly;
> >
> > It should be used only for definition
> >
> I looked at the rest of the source and found multiple place where we
> specify __read_mostly in extern.
> 
> arch/x86/kernel/cpu/perf_event.h extern struct x86_pmu x86_pmu __read_mostly;

We have had one situation in the past where the lack of a section
annotation on a declaration caused an architecture (arm?) to fail to
build.  iirc the compiler emitted some short-mode relative-addressed
opcode to reference the variable, but when the linker came along to
resolve the offset it discovered that it exceeded the short-mode
addressing range, because that variable was in a section which landed
far away from .data.

That's only happened once, and that architecture might have changed,
and we're missing the section annotation on many variables anyway, so
I'd be inclined to just leave it off - if we ever hit significant
problems with this, we have a lot of work to do.

Also, we currently have no automated way of keeping the annotation on
the declaration and definition in sync.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
