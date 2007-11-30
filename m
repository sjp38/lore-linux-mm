Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAUHeqaP021572
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 12:40:52 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAUIg6xJ039226
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 11:42:08 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAUIg6pR012488
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 11:42:06 -0700
Subject: Re: [RFC PATCH] LTTng instrumentation mm (updated)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071130170516.GA31586@Krystal>
References: <20071115215142.GA7825@Krystal>
	 <1195164977.27759.10.camel@localhost> <20071116143019.GA16082@Krystal>
	 <1195495485.27759.115.camel@localhost> <20071128140953.GA8018@Krystal>
	 <1196268856.18851.20.camel@localhost> <20071129023421.GA711@Krystal>
	 <1196317552.18851.47.camel@localhost> <20071130161155.GA29634@Krystal>
	 <1196444801.18851.127.camel@localhost>  <20071130170516.GA31586@Krystal>
Content-Type: text/plain
Date: Fri, 30 Nov 2007 10:42:02 -0800
Message-Id: <1196448122.19681.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-30 at 12:05 -0500, Mathieu Desnoyers wrote:
> 
> 
> Given a trace including :
> - Swapfiles initially used
> - multiple swapon/swapoff
> - swap in/out events
> 
> We would like to be able to tell which swap file the information has
> been written to/read from at any given time during the trace.

Oh, tracing is expected to be on at all times?  I figured someone would
encounter a problem, then turn it on to dig down a little deeper, then
turn it off.

As for why I care what is in /proc/swaps.  Take a look at this:

struct swap_info_struct *
get_swap_info_struct(unsigned type)
{
        return &swap_info[type];
}

Then, look at the proc functions: 

static void *swap_next(struct seq_file *swap, void *v, loff_t *pos)
{
        struct swap_info_struct *ptr;
        struct swap_info_struct *endptr = swap_info + nr_swapfiles;

        if (v == SEQ_START_TOKEN)
                ptr = swap_info;
...

I guess if that swap_info[] has any holes, we can't relate indexes in
there right back to /proc/swaps, but maybe we should add some
information so that we _can_.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
