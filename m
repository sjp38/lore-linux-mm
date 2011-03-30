Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 299148D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 08:23:32 -0400 (EDT)
Received: by fxm18 with SMTP id 18so1353085fxm.14
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 05:22:07 -0700 (PDT)
Subject: Re: kmemleak for MIPS
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <AANLkTi=vcn5jHpk0O8XS9XJ8s5k-mCnzUwu70mFTx4=g@mail.gmail.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
	 <AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
	 <1300960540.32158.13.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTim139fpJsMJFLiyUYvFgGMz-Ljgd_yDrks-tqhE@mail.gmail.com>
	 <1301395206.583.53.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTim-4v5Cbp6+wHoXjgKXoS0axk1cgQ5AHF_zot80@mail.gmail.com>
	 <1301399454.583.66.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTin0_gT0E3=oGyfMwk+1quqonYBExeN9a3=v=Lob@mail.gmail.com>
	 <AANLkTi=gMP6jQuQFovfsOX=7p-SSnwXoVLO_DVEpV63h@mail.gmail.com>
	 <1301476505.29074.47.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTi=YB+nBG7BYuuU+rB9TC-BbWcJ6mVfkxq0iUype@mail.gmail.com>
	 <AANLkTi=L0zqwQ869khH1efFUghGeJjoyTaBXs-O2icaM@mail.gmail.com>
	 <AANLkTi=vcn5jHpk0O8XS9XJ8s5k-mCnzUwu70mFTx4=g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 30 Mar 2011 14:22:00 +0200
Message-ID: <1301487720.3283.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Baluta <dbaluta@ixiacom.com>
Cc: Maxin John <maxin.john@gmail.com>, naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>

Le mercredi 30 mars 2011 A  14:24 +0300, Daniel Baluta a A(C)crit :
> We have:
> 
> > UDP hash table entries: 128 (order: 0, 4096 bytes)
> > CONFIG_BASE_SMALL=0
> 
> udp_table_init looks like:
> 
>         if (!CONFIG_BASE_SMALL)
>                 table->hash = alloc_large_system_hash(name, .. &table->mask);
>         /*
>          * Make sure hash table has the minimum size
>          */
> 
> Since CONFIG_BASE_SMALL is 0, we are allocating the hash using
> alloc_large_system
> Then:
>         if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
>                 table->hash = kmalloc();
> 
> table->mask is 127, and UDP_HTABLE_SIZE_MIN is 256, so we are allocating again
> table->hash without freeing already allocated memory.
> 
> We could free table->hash, before allocating the memory with kmalloc.
> I don't fully understand the condition table->mask < UDP_HTABLE_SIZE_MIN - 1.
> 
> Eric?

There is nothing special. UDP algo needs a minimum hash table that
alloc_large_system_hash() was not able to provide (???)

As you spotted, there is no free_large-system_hash(), so we 'leak' the
small hash table.

If machine has not enough memory to provide such a small hash table, I
suggest using CONFIG_BASE_SMALL, since :

#define UDP_HTABLE_SIZE_MIN (CONFIG_BASE_SMALL ? 128 : 256)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
