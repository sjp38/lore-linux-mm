Date: Tue, 5 Feb 2008 19:55:11 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: SLUB: Support for statistics to help analyze allocator behavior
Message-Id: <20080205195511.b396ea4b.dada1@cosmosbay.com>
In-Reply-To: <Pine.LNX.4.64.0802051007270.11705@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0802050923220.14675@sbz-30.cs.Helsinki.FI>
	<47A81513.4010301@cosmosbay.com>
	<Pine.LNX.4.64.0802050952300.16488@sbz-30.cs.Helsinki.FI>
	<Pine.LNX.4.64.0802051007270.11705@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008 10:08:00 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 5 Feb 2008, Pekka J Enberg wrote:
> 
> > Heh, sure, but it's not exported to userspace which is required for 
> > slabinfo to display the statistics.
> 
> Well we could do the same as for numa stats. Output the global count and 
> then add
> 
> c<proc>=count
> 

Yes, or the reverse, to avoid two loops and possible sum errors (Sum of c<proc>=count different than the global count)

Since text##_show is going to be too big, you could use one function instead of several ones ?

(and char *buf is PAGE_SIZE, so you should add a limit ?)

Note I used for_each_possible_cpu() here instead of 'online' variant, or stats might be corrupted when a cpu goes offline.

static ssize_t text_show(struct kmem_cache *s, char *buf, unsigned int si)
{								
	unsigned long val, sum = 0;					
	int cpu;
	size_t off = 0;						
	size_t buflen = PAGE_SIZE;
								
	for_each_possible_cpu(cpu) {				
		val = get_cpu_slab(s, cpu)->stat[si];
#ifdef CONFIG_SMP
		if (val)
			off += snprintf(buf + off, buflen - off, "c%d=%lu ", cpu, val);
#endif
		sum += val;		
        }
	off += snprintf(buf + off, buflen - off, "%lu\n", sum);			
	return off;
}								


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
