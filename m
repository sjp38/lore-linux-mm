Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8BIpTKQ024497
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 14:51:29 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8BIpSK6268044
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 12:51:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8BIpSwa011813
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 12:51:28 -0600
Subject: Re: -mm numa perf regression
From: keith mannthey <kmannth@us.ibm.com>
Reply-To: kmannth@us.ibm.com
In-Reply-To: <450599F4.4050707@shadowen.org>
References: <20060901105554.780e9e78.akpm@osdl.org>
	 <Pine.LNX.4.64.0609011125110.19863@schroedinger.engr.sgi.com>
	 <44F88236.10803@google.com>
	 <Pine.LNX.4.64.0609011231300.20077@schroedinger.engr.sgi.com>
	 <44F8949E.4010308@google.com>
	 <Pine.LNX.4.64.0609011314590.20312@schroedinger.engr.sgi.com>
	 <44F8970F.2050004@google.com>
	 <Pine.LNX.4.64.0609011331240.20357@schroedinger.engr.sgi.com>
	 <44F8BB87.7050402@shadowen.org>
	 <Pine.LNX.4.64.0609020658290.22978@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0609071116290.16838@schroedinger.engr.sgi.com>
	 <45017C95.90502@shadowen.org>
	 <Pine.LNX.4.64.0609081132200.23089@schroedinger.engr.sgi.com>
	 <45057055.7070003@shadowen.org> <20060911093549.a553cfe5.akpm@osdl.org>
	 <450591B2.2080102@shadowen.org>  <450599F4.4050707@shadowen.org>
Content-Type: text/plain
Date: Mon, 11 Sep 2006 11:51:27 -0700
Message-Id: <1158000687.5755.50.camel@keithlap>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Martin Bligh <mbligh@google.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-09-11 at 18:16 +0100, Andy Whitcroft wrote:
> Andy Whitcroft wrote:
> > Andrew Morton wrote:
> >> On Mon, 11 Sep 2006 15:19:01 +0100
> >> Andy Whitcroft <apw@shadowen.org> wrote:
> >>
> >>> Christoph Lameter wrote:
> >>>> On Fri, 8 Sep 2006, Andy Whitcroft wrote:
> >>>>
> >>>>>> I have not heard back from you on this issue. It would be good to have 
> >>>>>> some more data on this one.
> >>>>> Sorry I submitted the tests and the results filtered out to TKO, and
> >>>>> then I forgot to check them.  Looking at the graph backing this out has
> >>>>> had no effect.  As I think we'd expect from what comes below.
> >>>>>
> >>>>> What next?
> >>>> Get me the promised data? /proc/zoneinfo before and after the run. 
> >>>> /proc/meminfo and /sys/devices/system/node/node*/* would be helpful.
> >>> Sorry for the delay, the relevant files wern't all being preserved.
> >>> Fixed that up and reran things.  The results you asked for are available
> >>> here:
> >>>
> >>>     http://www.shadowen.org/~apw/public/debug-moe-perf/47138/
> >>>
> >>> Just having a quick look at the results, it seems that they are saying
> >>> that all of our cpu's are in node 0 which isn't right at all.  The
> >>> machine has 4 processors per node.
> >>>
> >>> I am sure that would account for the performance loss.  Now as to why ...
> >>>
> >>>> Is there a way to remotely access the box?
> >>> Sadly no ... I do have direct access to test on the box but am not able
> >>> to export it.
> >>>
> >>> I've also started a bisection looking for it.  Though that will be some
> >>> time yet as I've only just dropped the cleaver for the first time.
> >>>
> >> I've added linux-mm.  Can we please keep it on-list.  I have a vague suspicion
> >> that your bisection will end up pointing at one Mel Gorman.  Or someone else.
> >> But whoever it is will end up wondering wtf is going on.
> >>
> >> I don't understand what you mean by "all of our cpu's are in node 0"?  
> >> http://www.shadowen.org/~apw/public/debug-moe-perf/47138/sys/devices/system/node.after/node0/
> >> and
> >> http://www.shadowen.org/~apw/public/debug-moe-perf/47138/sys/devices/system/node.before/node0/
> >> look the same..  It depends what "before" and "after" mean, I guess...
> > 
> > What I have noted in this output is that all of the CPU's in this
> > machine have been assigned to node 0, this is incorrect because there
> > are four nodes of four cpus each.
> > 
> > The before and after refer to either side of the test showing the
> > regression.  Of course the cpu these are static and thus the same.

This before data seems to have 4 nodes in both.  Maybe I am missing
context here.  

> For those who missed the history.  We have been tracking a performance
> regression on kernbench on some numa systems.  In the process of
> analysing that we've noticed that all of the cpus in the system are
> being bound to node 0 rather than their home nodes.  This is caused by
> the changes in:

That isn't good. 

> convert-i386-summit-subarch-to-use-srat-info-for-apicid_to_node-calls.patch
> 
> @@ -647,7 +649,7 @@ static void map_cpu_to_logical_apicid(vo
>         int apicid = logical_smp_processor_id();
> 
>         cpu_2_logical_apicid[cpu] = apicid;
> -       map_cpu_to_node(cpu, apicid_to_node(apicid));
> +       map_cpu_to_node(cpu, apicid_to_node(hard_smp_processor_id()));
>  }
> This change moves us this mapping from logical to physical apic id which
> the sub-architectures are not expecting.  I've just booted a machine
> with this patch (and its -tidy) backed out.  The processors are again
> assigned to the right places.


> I am expecting this to help with the performance problem too.  But we'll
> have to wait for the test results to propogate out to TKO to be sure.
> 
> Keith, even if this doens't fix the performance regression there is
> cirtainly an unexpected side effect to this change on our system here.

Hmm, I tested this against on x440,x445 and x460 summit was fine at the
time...  Is there a dmesg around for the failed boot?  Is this from your
16-way x440 or is this a numaq (moe is numaq right?) breakage? 

I can push the map_cpu_to_node setup in the subarch code if this is
numaq breakage. Summit apicid_to_node mapping are in physical (as
defined by the SRAT hence the change in lookup) I am building current -
mm on a multi-node summit system to see if I can work something out. 

Thanks,
 Keith 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
