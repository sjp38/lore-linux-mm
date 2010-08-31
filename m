Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C9E86B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 17:28:32 -0400 (EDT)
Received: by wyb36 with SMTP id 36so10104350wyb.14
        for <linux-mm@kvack.org>; Tue, 31 Aug 2010 14:28:31 -0700 (PDT)
Subject: Re: [PATCH 03/10] Use percpu stats
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <AANLkTikdhnr12uU8Wp60BygZwH770RBfxyfLNMzUsQje@mail.gmail.com>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	 <1281374816-904-4-git-send-email-ngupta@vflare.org>
	 <alpine.DEB.2.00.1008301114460.10316@router.home>
	 <AANLkTikdhnr12uU8Wp60BygZwH770RBfxyfLNMzUsQje@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 31 Aug 2010 23:28:26 +0200
Message-ID: <1283290106.2198.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Le mardi 31 aoA>>t 2010 A  16:31 -0400, Nitin Gupta a A(C)crit :
> On Mon, Aug 30, 2010 at 12:20 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Mon, 9 Aug 2010, Nitin Gupta wrote:
> >
> >> -static void zram_stat_inc(u32 *v)
> >> +static void zram_add_stat(struct zram *zram,
> >> +                     enum zram_stats_index idx, s64 val)
> >>  {
> >> -     *v = *v + 1;
> >> +     struct zram_stats_cpu *stats;
> >> +
> >> +     preempt_disable();
> >> +     stats = __this_cpu_ptr(zram->stats);
> >> +     u64_stats_update_begin(&stats->syncp);
> >> +     stats->count[idx] += val;
> >> +     u64_stats_update_end(&stats->syncp);
> >> +     preempt_enable();
> >
> > Maybe do
> >
> > #define zram_add_stat(zram, index, val)
> >                this_cpu_add(zram->stats->count[index], val)
> >
> > instead? It creates an add in a single "atomic" per cpu instruction and
> > deals with the fallback scenarios for processors that cannot handle 64
> > bit adds.
> >
> >
> 
> Yes, this_cpu_add() seems sufficient. I can't recall why I used u64_stats_*
> but if it's not required for atomic access to 64-bit then why was it added to
> the mainline in the first place?

Because we wanted to have fast 64bit counters, even on 32bit arches, and
this has litle to do with 'atomic' on one entity, but a group of
counters. (check drivers/net/loopback.c, lines 91-94). No lock prefix
used in fast path.

We also wanted readers to read correct values, not a value being changed
by a writer, with inconsistent 32bit halves. SNMP applications want
monotonically increasing counters.

this_cpu_add()/this_cpu_read() doesnt fit.

Even for single counter, this_cpu_read(64bit) is not using an RMW
(cmpxchg8) instruction, so you can get very strange results when low
order 32bit wraps.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
