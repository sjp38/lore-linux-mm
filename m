Date: Thu, 8 May 2008 07:20:19 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080508052019.GA8276@duo.random>
References: <20080507153103.237ea5b6.akpm@linux-foundation.org> <20080507224406.GI8276@duo.random> <20080507155914.d7790069.akpm@linux-foundation.org> <20080507233953.GM8276@duo.random> <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071809170.14935@schroedinger.engr.sgi.com> <20080508025652.GW8276@duo.random> <Pine.LNX.4.64.0805072009230.15543@schroedinger.engr.sgi.com> <20080508034133.GY8276@duo.random> <alpine.LFD.1.10.0805072109430.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805072109430.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 09:14:45PM -0700, Linus Torvalds wrote:
> IOW, you didn't even look at it, did you?

Actually I looked both at the struct and at the slab alignment just in
case it was changed recently. Now after reading your mail I also
compiled it just in case.

2.6.26-rc1

# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
anon_vma             260    576     24  144    1 : tunables  120   60    8 : slabdata      4      4      0
                                    ^^  ^^^

2.6.26-rc1 + below patch

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -27,6 +27,7 @@ struct anon_vma {
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
+	int flag:1;
 };
 
 #ifdef CONFIG_MMU

# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
anon_vma             250    560     32  112    1 : tunables  120   60    8 : slabdata      5      5      0
                                    ^^  ^^^

Not a big deal sure to grow it 33%, it's so small anyway, but I don't
see the point in growing it. sort() can be interrupted by signals, and
until it can we can cap it to 512 vmas making the worst case taking
dozen usecs, I fail to see what you have against sort().

Again: if a vma bitflag + global lock could have avoided sort and run
O(N) instead of current O(N*log(N)) I would have done that
immediately, infact I was in the process of doing it when you posted
the followup. Nothing personal here, just staying technical. Hope you
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
