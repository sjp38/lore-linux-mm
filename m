Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 04EFE8D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 08:27:41 -0400 (EDT)
Received: by wyf19 with SMTP id 19so1365147wyf.14
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 05:27:16 -0700 (PDT)
Subject: Re: kmemleak for MIPS
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <AANLkTikXfVNkyFE2MpW9ZtfX2G=QKvT7kvEuDE-YE5xO@mail.gmail.com>
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
	 <1301485085.29074.61.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTikXfVNkyFE2MpW9ZtfX2G=QKvT7kvEuDE-YE5xO@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 30 Mar 2011 14:27:12 +0200
Message-ID: <1301488032.3283.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin John <maxin.john@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Daniel Baluta <dbaluta@ixiacom.com>, naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Le mercredi 30 mars 2011 A  13:17 +0100, Maxin John a A(C)crit :
> A quick observation from dmesg after placing printks in
> "net/ipv4/udp.c" for MIPS-malta
> 
> CONFIG_BASE_SMALL : 0
> table->mask : 127
> UDP_HTABLE_SIZE_MIN :  256
> 
> dmesg:
> ....
> ...
> TCP: Hash tables configured (established 8192 bind 8192)
> TCP reno registered
> CONFIG_BASE_SMALL : 0
> UDP hash table entries: 128 (order: 0, 4096 bytes)
> table->mask, UDP_HTABLE_SIZE_MIN : 127 256
> CONFIG_BASE_SMALL : 0
> UDP-Lite hash table entries: 128 (order: 0, 4096 bytes)
> table->mask, UDP_HTABLE_SIZE_MIN : 127 256
> NET: Registered protocol family 1
> ....
> ....
> 
> printk(s) are placed in udp.c as listed below:
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 588f47a..ca7f6c6 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2162,7 +2162,7 @@ __setup("uhash_entries=", set_uhash_entries);
>  void __init udp_table_init(struct udp_table *table, const char *name)
>  {
>         unsigned int i;
> -
> +       printk("CONFIG_BASE_SMALL : %d \n", CONFIG_BASE_SMALL);
>         if (!CONFIG_BASE_SMALL)
>                 table->hash = alloc_large_system_hash(name,
>                         2 * sizeof(struct udp_hslot),
> @@ -2175,6 +2175,8 @@ void __init udp_table_init(struct udp_table
> *table, const char *name)
>         /*
>          * Make sure hash table has the minimum size
>          */
> +       printk("table->mask, UDP_HTABLE_SIZE_MIN : %d %d
> \n",table->mask,UDP_HTABLE_SIZE_MIN);
> +
>         if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
>                 table->hash = kmalloc(UDP_HTABLE_SIZE_MIN *
>                                       2 * sizeof(struct udp_hslot), GFP_KERNEL);
> ~


How much memory do you have exactly on this machine ?

alloc_large_system_hash() has no parameter to specify a minimum hash
table, and UDP needs one.

If you care about losing 8192 bytes of memory, you could boot with

"uhash_entries=256"



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
