Date: Fri, 4 Nov 2005 00:02:12 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051104000212.2e0e92bd.akpm@osdl.org>
In-Reply-To: <20051103234530.5fcb2825.pj@sgi.com>
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
	<200511021747.45599.rob@landley.net>
	<43699573.4070301@yahoo.com.au>
	<200511030007.34285.rob@landley.net>
	<20051103163555.GA4174@ccure.user-mode-linux.org>
	<1131035000.24503.135.camel@localhost.localdomain>
	<20051103205202.4417acf4.akpm@osdl.org>
	<20051103213538.7f037b3a.pj@sgi.com>
	<20051103214807.68a3063c.akpm@osdl.org>
	<20051103224239.7a9aee29.pj@sgi.com>
	<20051103231019.488127a6.akpm@osdl.org>
	<20051103234530.5fcb2825.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: bron@bronze.corp.sgi.com, pbadari@gmail.com, jdike@addtoit.com, rob@landley.net, nickpiggin@yahoo.com.au, gh@us.ibm.com, mingo@elte.hu, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, mbligh@mbligh.org, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Paul Jackson <pj@sgi.com> wrote:
>
> A per-task stat requires walking the tasklist, to build a list of the
> tasks to query.

Nope, just task->mm->whatever.

> A raw counter requires repeated polling to determine the recent rate of
> activity.

True.

> The filtered per-cpuset rate avoids any need to repeatedly access
> global resources such as the tasklist, and minimizes the total cpu
> cycles required to get the interesting stat.
> 

Well no.  Because the filtered-whatsit takes two spinlocks and does a bunch
of arith for each and every task, each time it calls try_to_free_pages(). 
The frequency of that could be very high indeed, even when nobody is
interested in the metric which is being maintained(!).

And I'd suggest that only a minority of workloads would be interested in
this metric?

ergo, polling the thing once per five seconds in those situations where we
actually want to poll the thing may well be cheaper, in global terms?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
