Date: Tue, 2 Sep 2008 19:57:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080902195717.224b0822.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48BD119B.8020605@linux.vnet.ibm.com>
References: <20080831174756.GA25790@balbir.in.ibm.com>
	<200809011656.45190.nickpiggin@yahoo.com.au>
	<20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
	<200809011743.42658.nickpiggin@yahoo.com.au>
	<48BD0641.4040705@linux.vnet.ibm.com>
	<20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD0E4A.5040502@linux.vnet.ibm.com>
	<20080902190723.841841f0.kamezawa.hiroyu@jp.fujitsu.com>
	<48BD119B.8020605@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 02 Sep 2008 15:42:43 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >>>> Kamezawa-San, I would like to integrate the radix tree patches after review and
> >>>> some more testing then integrate your patchset on top of it. Do you have any
> >>>> objections/concerns with the suggested approach?
> >>>>
> >>> please show performance number first.
> >> Yes, that is why said some more testing. I am running lmbench and kernbench on
> >> it and some other tests, I'll get back with numbers.
> >>
> > A test which is not suffer much from I/O is better.
> > And please don't worry about my patches. I'll reschedule if yours goes first.
> > 
> Thanks, I'll try and find the right set of tests.

Maybe it's good time to share my concerns.

IMHO, the memory resource controller is for dividing memory into groups.

We have following choices to divide memory into groups, now.
  - cpuset(+ fake NUMA)
  - VM (kvm, Xen, etc...)
  - memory resource controller. (memcg)

Considering 3 aspects peformance, flexibility, isolation(security).
My expectaion is

peroformance   : cpuset > memcg >> VMs
flexibility    : memcg  > VMs >> cpuset.
isolation      : VMs >> cpuset >= memcg

The word 'flexibility' sounds sweet *but* it's just one of aspects.
If the peformance is cpuset > VMs > memcg, I'll advise users to use VMs.

I think VMs are getting faster and faster. memcg will be slower when we add new
'fancy' feature more. (I think we need some more features.)
So, I want to keep memcg fast as much as possible at this stage.

But yes, memory usage overhead of page->page_cgroup, struct page_cgroup is big
on 32bit arch. I'll say users to use VMs, maybe ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
