Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D3C636B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 10:01:13 -0500 (EST)
Date: Mon, 24 Jan 2011 16:00:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110124150033.GB9506@random.random>
References: <1295841406.1949.953.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1295841406.1949.953.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

eOn Mon, Jan 24, 2011 at 11:56:46AM +0800, Shaohua Li wrote:
> Hi,
> With transparent huge page, min_free_kbytes is set too big.
> Before:
> Node 0, zone    DMA32
>   pages free     1812
>         min      1424
>         low      1780
>         high     2136
>         scanned  0
>         spanned  519168
>         present  511496
> 
> After:
> Node 0, zone    DMA32
>   pages free     482708
>         min      11178
>         low      13972
>         high     16767
>         scanned  0
>         spanned  519168
>         present  511496
> This caused different performance problems in our test. I wonder why we
> set the value so big.

It's to enable Mel's anti-frag that keeps pageblocks with movable and
unmovable stuff separated, same as "hugeadm
--set-recommended-min_free_kbytes".

Now that I checked, I'm seeing quite too much free memory with only 4G
of ram... You can see the difference with a "cp /dev/sda /dev/null" in
background interleaving these two commands:

echo always >/sys/kernel/mm/transparent_hugepage/enabled
echo 1000 > /proc/sys/vm/min_free_kbytes

The setting of min_free_kbytes to 67584 leads to 716MB of memory
free. Setting to 1000 leads to 20MB free. I'm afraid losing 716MB on a
4G system is way excessive regardless of THP... can't we just have a
version of anti-frag that reserves a lot fewers pageblocks? Anti-frag
is quite important to avoid slab to fragment everything. I don't think
we can leave it like this.

For now you can workaround with the above echo 1000 > ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
