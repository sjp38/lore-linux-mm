Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D10228D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 07:25:01 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1018830qwa.14
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 04:25:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=L0zqwQ869khH1efFUghGeJjoyTaBXs-O2icaM@mail.gmail.com>
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
Date: Wed, 30 Mar 2011 14:24:59 +0300
Message-ID: <AANLkTi=vcn5jHpk0O8XS9XJ8s5k-mCnzUwu70mFTx4=g@mail.gmail.com>
Subject: Re: kmemleak for MIPS
From: Daniel Baluta <dbaluta@ixiacom.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin John <maxin.john@gmail.com>
Cc: naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Eric Dumazet <eric.dumazet@gmail.com>

We have:

> UDP hash table entries: 128 (order: 0, 4096 bytes)
> CONFIG_BASE_SMALL=0

udp_table_init looks like:

        if (!CONFIG_BASE_SMALL)
                table->hash = alloc_large_system_hash(name, .. &table->mask);
        /*
         * Make sure hash table has the minimum size
         */

Since CONFIG_BASE_SMALL is 0, we are allocating the hash using
alloc_large_system
Then:
        if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
                table->hash = kmalloc();

table->mask is 127, and UDP_HTABLE_SIZE_MIN is 256, so we are allocating again
table->hash without freeing already allocated memory.

We could free table->hash, before allocating the memory with kmalloc.
I don't fully understand the condition table->mask < UDP_HTABLE_SIZE_MIN - 1.

Eric?

thanks,
Daniel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
