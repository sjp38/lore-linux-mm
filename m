Date: Tue, 7 Oct 2008 10:06:56 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm, for adaptive dcache hash table sizing (resend)
Message-ID: <20081007080656.GB16143@wotan.suse.de>
References: <20081007064834.GA5959@wotan.suse.de> <20081007070225.GB5959@wotan.suse.de> <48EB11BB.2060704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <48EB11BB.2060704@cosmosbay.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, netdev@vger.kernel.org, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 07, 2008 at 09:37:31AM +0200, Eric Dumazet wrote:
> Nick Piggin a ecrit :
> >(resending with correct netdev address)
> >
> >With this algorithm, I can fit a whole kernel source and git tree in my 
> >dcache
> >hash table that is still 1/8th the size it would be before the patch.
> >
> >I'm cc'ing netdev because Dave did express some interest in using this for
> >some networking hashes, and network guys in general are pretty cluey when 
> >it
> >comes to hashes and such ;)
> >
> 
> Thanks for reminding us this interesting stuff. And yes, IP route cache 
> could use
> same algo. That is particularly interesting because it has a 
> /proc/net/rt_cache
> accessor that needs to sequentially scan this hash table (potentialy with
> many empty slots), while dcache doesnt have such killer.

Hmm, that is interesting. What are the exact semantics of this rt_cache
file? It might be difficult to retain them over a hash table resize
operation, but it would be worth trying. Big hammer to block access to
the file if a resize is in progress might work (but do we need to hold off
access over multiple calls from userspace? then may need to also avoid
resizing the hash table if the rt_cache file is open).


> >+static struct dcache_hash *alloc_dhash(int size)
> >+{
> >+	struct dcache_hash *dh;
> >+	unsigned long bytes;
> >+	unsigned int shift;
> >+	int i;
> >+
> >+	shift = ilog2(size);
> >+	BUG_ON(size != 1UL << shift);
> >+	bytes = size * sizeof(struct hlist_head *);
> >+
> >+	dh = kmalloc(sizeof(struct dcache_hash), GFP_KERNEL);
> >+	if (!dh)
> >+		return NULL;
> >+
> >+	if (bytes <= PAGE_SIZE) {
> >+		dh->table = kmalloc(bytes, GFP_KERNEL);
> >+	} else {
> >+		dh->table = vmalloc(bytes);
> >+	}
> 
> Here we probably want to use a hashdist/NUMA enabled vmalloc().
> 
> That is, regardless of current numa policy of *this* thread,
> we want to spread hash table on all nodes.

Yeah, it definitely should do. Thanks.

 
> Also, struct dcache_hash being very small, you want to force it to
> use an exclusive cache line, to be sure it wont share it with some 
> higly modified data...
> 
> struct dcache_hash {
> 	struct hlist_head *table;
> 	unsigned int shift;
> 	unsigned int mask;
> } __cacheline_aligned_in_smp;

Yes, good point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
