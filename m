Received: from toip6.srvr.bell.ca ([209.226.175.125])
          by tomts36-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080716150548.GQYQ1669.tomts36-srv.bellnexxia.net@toip6.srvr.bell.ca>
          for <linux-mm@kvack.org>; Wed, 16 Jul 2008 11:05:48 -0400
Date: Wed, 16 Jul 2008 11:00:46 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 10/17] LTTng instrumentation - swap
Message-ID: <20080716150046.GI24546@Krystal>
References: <20080715222604.331269462@polymtl.ca> <20080715222748.214360024@polymtl.ca> <1216197576.5232.27.camel@twins> <20080716144008.GG24546@Krystal> <1216219654.5232.55.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1216219654.5232.55.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Masami Hiramatsu <mhiramat@redhat.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, "Frank Ch. Eigler" <fche@redhat.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra (peterz@infradead.org) wrote:
> On Wed, 2008-07-16 at 10:40 -0400, Mathieu Desnoyers wrote:
> > * Peter Zijlstra (peterz@infradead.org) wrote:
> > > On Tue, 2008-07-15 at 18:26 -0400, Mathieu Desnoyers wrote:
> 
> > > > @@ -1796,6 +1799,7 @@ get_swap_info_struct(unsigned type)
> > > >  {
> > > >  	return &swap_info[type];
> > > >  }
> > > > +EXPORT_SYMBOL_GPL(get_swap_info_struct);
> > > 
> > > I'm not too happy with this export.
> > > 
> > 
> > Would it make more sense to turn get_swap_info_struct into a static
> > inline in swap.h ?
> 
> Seeing a consumer of it would go a long way towards discussing it ;-)
> 

The LTTng probe which connects to this tracepoint looks like :

+static void probe_swap_out(struct page *page)
+{
+       trace_mark(mm_swap_out, "pfn %lu filp %p offset %lu",
+               page_to_pfn(page),
+               get_swap_info_struct(swp_type(
+                       page_swp_entry(page)))->swap_file,
+               swp_offset(page_swp_entry(page)));
+}

So, I need get_swap_info_struct to extract the swap file pointer from
the swap entry.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
