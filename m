Date: Fri, 9 Jun 2006 09:00:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01/14] Per zone counter functionality
In-Reply-To: <200606090628.57497.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0606090856510.31570@schroedinger.engr.sgi.com>
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com>
 <20060608230244.25121.76440.sendpatchset@schroedinger.engr.sgi.com>
 <200606090628.57497.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jun 2006, Andi Kleen wrote:

> It would be nicer to use some variant of local_t - then you could do that
> without turning off interrupts (which some CPUs like P4 don't like)
> 
> There currently is not 1 byte local_t but it could be added.
> 
> Mind you it would only make sense when most of the calls are not already
> with interrupts disabled.

We have discussed this before and there is a comment in the patch:

+ *
+ * Some processors have inc/dec instructions that are atomic vs an interrupt.
+ * However, the code must first determine the differential location in a zone
+ * based on the processor number and then inc/dec the counter. There is no
+ * guarantee without disabling preemption that the processor will not change
+ * in between and therefore the atomicity vs. interrupt cannot be exploited
+ * in a useful way here.
+ */
+void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
+{
+       struct zone *zone = page_zone(page);
+       s8 *p = diff_pointer(zone, item);
+
+       (*p)++;
+
+       if (unlikely(*p > STAT_THRESHOLD)) {
+               zone_page_state_add(*p, zone, item);
+               *p = 0;
+       }
+}

AFAIK the restrictions on local_t use are such that is barely usable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
