Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 5F0BA6B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:13:41 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so2181345eaa.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 12:13:39 -0700 (PDT)
Subject: Re: [Q] Default SLAB allocator
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <507EFCC3.1050304@am.sony.com>
References: 
	 <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	 <m27gqwtyu9.fsf@firstfloor.org>
	 <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
	 <m2391ktxjj.fsf@firstfloor.org>
	 <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
	 <alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com>
	 <CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com>
	 <alpine.DEB.2.00.1210151745400.31712@chino.kir.corp.google.com>
	 <CALF0-+WgfnNOOZwj+WLB397cgGX7YhNuoPXAK5E0DZ5v_BxxEA@mail.gmail.com>
	 <1350392160.3954.986.camel@edumazet-glaptop> <507DA245.9050709@am.sony.com>
	 <CALF0-+VLVqy_uE63_jL83qh8MqBQAE3vYLRX1mRQURZ4a1M20g@mail.gmail.com>
	 <1350414968.3954.1427.camel@edumazet-glaptop>
	 <507EFCC3.1050304@am.sony.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 17 Oct 2012 21:13:37 +0200
Message-ID: <1350501217.26103.852.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Bird <tim.bird@am.sony.com>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "celinux-dev@lists.celinuxforum.org" <celinux-dev@lists.celinuxforum.org>

On Wed, 2012-10-17 at 11:45 -0700, Tim Bird wrote:

> 8G is a small web server?  The RAM budget for Linux on one of
> Sony's cameras was 10M.  We're not merely not in the same ballpark -
> you're in a ballpark and I'm trimming bonsai trees... :-)
> 

Even laptops in 2012 have +4GB of ram.

(Maybe not Sony laptops, I have to double check ?)

Yes, servers do have more ram than laptops.

(Maybe not Sony servers, I have to double check ?)

> > # grep Slab /proc/meminfo
> > Slab:             351592 kB
> > 
> > # egrep "kmalloc-32|kmalloc-16|kmalloc-8" /proc/slabinfo 
> > kmalloc-32         11332  12544     32  128    1 : tunables    0    0    0 : slabdata     98     98      0
> > kmalloc-16          5888   5888     16  256    1 : tunables    0    0    0 : slabdata     23     23      0
> > kmalloc-8          76563  82432      8  512    1 : tunables    0    0    0 : slabdata    161    161      0
> > 
> > Really, some waste on these small objects is pure noise on SMP hosts.
> In this example, it appears that if all kmalloc-8's were pushed into 32-byte slabs,
> we'd lose about 1.8 meg due to pure slab overhead.  This would not be noise
> on my system.


I said :

<quote>
I would remove small kmalloc-XX caches, as sharing a cache line
is sometime dangerous for performance, because of false sharing.

They make sense only for very small hosts
</quote>

I think your 10M cameras are very tiny hosts.

Using SLUB on them might not be the best choice.

First time I ran linux, years ago, it was on 486SX machines with 8M of
memory (or maybe less, I dont remember exactly). But I no longer use
this class of machines with recent kernels.

# size vmlinux
   text	   data	    bss	    dec	    hex	filename
10290631	1278976	1896448	13466055	 cd79c7	vmlinux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
