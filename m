Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 823DF828DF
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 11:04:57 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id z135so217746910iof.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:04:57 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e34si47743165iod.202.2016.02.23.08.04.55
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 08:04:56 -0800 (PST)
Date: Wed, 24 Feb 2016 01:05:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160223160515.GA13851@bbox>
References: <20160222002515.GB21710@bbox>
 <20160222004758.GB4958@swordfish>
 <20160222013442.GB27829@bbox>
 <20160222020113.GB488@swordfish>
 <20160222023432.GC27829@bbox>
 <20160222035954.GC11961@swordfish>
 <20160222044145.GE27829@bbox>
 <20160222104325.GA4859@swordfish>
 <20160223082532.GG27829@bbox>
 <20160223103527.GA5012@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160223103527.GA5012@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 23, 2016 at 07:35:27PM +0900, Sergey Senozhatsky wrote:
> On (02/23/16 17:25), Minchan Kim wrote:
> [..]
> > 
> > That sounds like a plan but at a first glance, my worry is we might need
> > some special handling related to objs_per_zspage and pages_per_zspage
> > because currently, we have assumed all of zspages in a class has same
> > number of subpages so it might make it ugly.
> 
> I did some further testing, and something has showed up that I want
> to discuss before we go with ORDER4 (here and later ORDER4 stands for
> `#define ZS_MAX_HUGE_ZSPAGE_ORDER 4' for simplicity).
> 
> /*
>  * for testing purposes I have extended zsmalloc pool stats with zs_can_compact() value.
>  * see below
>  */
> 
> And the thing is -- quite huge internal class fragmentation. These are the 'normal'
> classes, not affected by ORDER modification in any way:
> 
>  class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage compact
>    107  1744           1           23           196         76         84                3      51
>    111  1808           0            0            63         63         28                4       0
>    126  2048           0          160           568        408        284                1      80
>    144  2336          52          620          8631       5747       4932                4    1648
>    151  2448         123          406         10090       8736       6054                3     810
>    168  2720           0          512         15738      14926      10492                2     540
>    190  3072           0            2           136        130        102                3       3
> 
> 
> so I've been thinking about using some sort of watermaks (well, zsmalloc is an allocator
> after all, allocators love watermarks :-)). we can't defeat this fragmentation, we never
> know in advance which of the pages will be modified or we the size class those pages will
> land after compression. but we know stats for every class -- zs_can_compact(),
> obj_allocated/obj_used, etc. so we can start class compaction if we detect that internal
> fragmentation is too high (e.g. 30+% of class pages can be compacted).

AFAIRC, we discussed about that when I introduced compaction.
Namely, per-class compaction.
I love it and just wanted to do after soft landing of compaction.
So, it's good time to introduce it. ;-)

> 
> on the other hand, we always can wait for the shrinker to come in and do the job for us,
> but that can take some time.

Sure, with the feature, we can remove shrinker itself, I think.
> 
> what's your opinion on this?

I will be very happy.

> 
> 
> 
> The test.
> 
> 1) create 2G zram, ext4, lzo, device
> 2) create 1G of text files, 1G of binary files -- the last part is tricky. binary files
>    in general already imply some sort of compression, so the chances that binary files
>    will just pressure 4096 class are very high. in my test I use vmscan.c as a text file,
>    and vmlinux as a binary file: seems to fit perfect, it warm ups all of the "ex-huge"
>    classes on my system:
> 
>    202  3264           1            0         17820      17819      14256                4       0
>    206  3328           0            1         10096      10087       8203               13       0
>    207  3344           0            1          3212       3206       2628                9       0
>    208  3360           0            1          1785       1779       1470               14       0
>    211  3408           0            0         10662      10662       8885                5       0
>    212  3424           0            1          1881       1876       1584               16       0
>    214  3456           0            1          5174       5170       4378               11       0
>    217  3504           0            0          6181       6181       5298                6       0
>    219  3536           0            1          4410       4406       3822               13       0
>    222  3584           0            1          5224       5220       4571                7       0
>    223  3600           0            1           952        946        840               15       0
>    225  3632           1            0          1638       1636       1456                8       0
>    228  3680           0            1          1410       1403       1269                9       0
>    230  3712           1            0           462        461        420               10       0
>    232  3744           0            1           528        519        484               11       0
>    234  3776           0            1           559        554        516               12       0
>    235  3792           0            1            70         57         65               13       0
>    236  3808           1            0           105        104         98               14       0
>    238  3840           0            1           176        166        165               15       0
>    254  4096           0            0          1944       1944       1944                1       0
> 
> 
> 3) MAIN-test:
>                 for j in {2..10}; do
>                         create_test_files
>                         truncate_bin_files $j
>                         truncate_text_files $j
>                         remove_test_files
>                 done
> 
>   so it creates text and binary files, truncates them, removes, and does the whole thing again.
>   the truncation is 1/2, 1/3 ... 1/10 of then original file size.
>   the order of file modifications is preserved across all of the tests.
> 
> 4) SUB-test (gzipped files pressure 4096 class mostly, but I decided to keep it)
>    `gzip -9' all text files
>    create file copy for every gzipped file "cp FOO.gz FOO", so `gzip -d' later has to overwrite FOO file content
>    `gzip -d' all text files
> 
> 5) goto 1
> 
> 
> 
> I'll just post a shorter version of the results
> (two columns from zram's mm_stat: total_used_mem / max_used_mem)
> 
> #1                             BASE                            ORDER4
> INITIAL STATE           1016832000 / 1016832000          968470528 / 968470528
> TRUNCATE BIN 1/2        715878400 / 1017081856           744165376 / 968691712
> TRUNCATE TEXT 1/2       388759552 / 1017081856           417140736 / 968691712
> REMOVE FILES            6467584 / 1017081856             6754304 / 968691712
> 
> * see below
> 
> 
> #2
> INITIAL STATE           1021116416 / 1021116416          972718080 / 972718080
> TRUNCATE BIN 1/3        683802624 / 1021378560           683589632 / 972955648
> TRUNCATE TEXT 1/3       244162560 / 1021378560           244170752 / 972955648
> REMOVE FILES            12943360 / 1021378560            11587584 / 972955648
> 
> #3
> INITIAL STATE           1023041536 / 1023041536          974557184 / 974557184
> TRUNCATE BIN 1/4        685211648 / 1023049728           685113344 / 974581760
> TRUNCATE TEXT 1/4       189755392 / 1023049728           189194240 / 974581760
> REMOVE FILES            14589952 / 1023049728            13537280 / 974581760
> 
> #4
> INITIAL STATE           1023139840 / 1023139840          974815232 / 974815232
> TRUNCATE BIN 1/5        685199360 / 1023143936           686104576 / 974823424
> TRUNCATE TEXT 1/5       156557312 / 1023143936           156545024 / 974823424
> REMOVE FILES            14704640 / 1023143936            14594048 / 974823424
> 
> 
> #COMPRESS/DECOMPRESS test
> INITIAL STATE           1022980096 / 1023135744          974516224 / 974749696
> COMPRESS TEXT           1120362496 / 1124478976          1072607232 / 1076731904
> DECOMPRESS TEXT         1024786432 / 1124478976          976502784 / 1076731904
> 
> 
> Test #1 suffers from fragmentation, the pool stats for that test are:
> 
>    100  1632           1            6            95         73         38                2       8
>    107  1744           0           18           154         60         66                3      39
>    111  1808           0            1            36         33         16                4       0
>    126  2048           0           41           208        167        104                1      20
>    144  2336          52          588         28637      26079      16364                4    1460
>    151  2448         113          396         37705      36391      22623                3     786
>    168  2720           0          525         69378      68561      46252                2     544
>    190  3072           0          123          1476       1222       1107                3     189
>    202  3264          25           97          1995       1685       1596                4     248
>    206  3328          11          119          2144        786       1742               13    1092
>    207  3344           0           91          1001        259        819                9     603
>    208  3360           0           69          1173        157        966               14     826
>    211  3408          20          114          1758       1320       1465                5     365
>    212  3424           0           63          1197        169       1008               16     864
>    214  3456           5           97          1326        506       1122               11     693
>    217  3504          27          109          1232        737       1056                6     420
>    219  3536           0           92          1380        383       1196               13     858
>    222  3584           4          131          1168        573       1022                7     518
>    223  3600           0           37           629         70        555               15     480
>    225  3632           0           99           891        377        792                8     456
>    228  3680           0           31           310         59        279                9     225
>    230  3712           0            0             0          0          0               10       0
>    232  3744           0           28           336         68        308               11     242
>    234  3776           0           14           182         28        168               12     132
> 
> 
> Note that all of the classes (for example the leader is 2336) are significantly
> fragmented. With ORDER4 we have more classes that just join the "let's fragment
> party" and add up to the numbers.
> 
> 
> 
> So, dynamic page allocation is good, but we also would need a dynamic page
> release. And it sounds to me that class watermark is a much simpler thing
> to do.
> 
> Even if we abandon the idea of having ORDER4, the class fragmentation would
> not go away.

True.

> 
> 
> 
> > As well, please write down why order-4 for MAX_ZSPAGES is best
> > if you resend it as formal patch.
> 
> sure, if it will ever be a formal patch then I'll put more effort into documenting.
> 
> 
> 
> 
> ** The stat patch:
> 
> we have only numbers of FULL and ALMOST_EMPTY classes, but they don't tell
> us how badly the class is fragmented internally.
> 
> so the /sys/kernel/debug/zsmalloc/zram0/classes output now looks as follows:
> 
>  class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage compact
> [..]
>     12   224           0            2           146          5          8                4       4
>     13   240           0            0             0          0          0                1       0
>     14   256           1           13          1840       1672        115                1      10
>     15   272           0            0             0          0          0                1       0
> [..]
>     49   816           0            3           745        735        149                1       2
>     51   848           3            4           361        306         76                4       8
>     52   864          12           14           378        268         81                3      21
>     54   896           1           12           117         57         26                2      12
>     57   944           0            0             0          0          0                3       0
> [..]
>  Total                26          131         12709      10994       1071                      134
> 
> 
> for example, class-896 is heavily fragmented -- it occupies 26 pages, 12 can be
> freed by compaction.
> 
> 
> does it look to you good enough to be committed on its own (off the series)?

I think it's good to have. Firstly, I thought we can get the information
by existing stats with simple math on userspace but changed my mind
because we could change the implementation sometime so such simple math
might not be perfect in future and even, we can expose it easily so yes,
let's do it.

Thanks!

> 
> ====8<====8<====
> 
> From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Subject: [PATCH] mm/zsmalloc: add can_compact to pool stat
> 
> ---
>  mm/zsmalloc.c | 20 +++++++++++++-------
>  1 file changed, 13 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 43e4cbc..046d364 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -494,6 +494,8 @@ static void __exit zs_stat_exit(void)
>  	debugfs_remove_recursive(zs_stat_root);
>  }
>  
> +static unsigned long zs_can_compact(struct size_class *class);
> +
>  static int zs_stats_size_show(struct seq_file *s, void *v)
>  {
>  	int i;
> @@ -501,14 +503,15 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
>  	struct size_class *class;
>  	int objs_per_zspage;
>  	unsigned long class_almost_full, class_almost_empty;
> -	unsigned long obj_allocated, obj_used, pages_used;
> +	unsigned long obj_allocated, obj_used, pages_used, compact;
>  	unsigned long total_class_almost_full = 0, total_class_almost_empty = 0;
>  	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
> +	unsigned long total_compact = 0;
>  
> -	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s\n",
> +	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s %7s\n",
>  			"class", "size", "almost_full", "almost_empty",
>  			"obj_allocated", "obj_used", "pages_used",
> -			"pages_per_zspage");
> +			"pages_per_zspage", "compact");
>  
>  	for (i = 0; i < zs_size_classes; i++) {
>  		class = pool->size_class[i];
> @@ -521,6 +524,7 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
>  		class_almost_empty = zs_stat_get(class, CLASS_ALMOST_EMPTY);
>  		obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
>  		obj_used = zs_stat_get(class, OBJ_USED);
> +		compact = zs_can_compact(class);
>  		spin_unlock(&class->lock);
>  
>  		objs_per_zspage = get_maxobj_per_zspage(class->size,
> @@ -528,23 +532,25 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
>  		pages_used = obj_allocated / objs_per_zspage *
>  				class->pages_per_zspage;
>  
> -		seq_printf(s, " %5u %5u %11lu %12lu %13lu %10lu %10lu %16d\n",
> +		seq_printf(s, " %5u %5u %11lu %12lu %13lu"
> +				" %10lu %10lu %16d %7lu\n",
>  			i, class->size, class_almost_full, class_almost_empty,
>  			obj_allocated, obj_used, pages_used,
> -			class->pages_per_zspage);
> +			class->pages_per_zspage, compact);
>  
>  		total_class_almost_full += class_almost_full;
>  		total_class_almost_empty += class_almost_empty;
>  		total_objs += obj_allocated;
>  		total_used_objs += obj_used;
>  		total_pages += pages_used;
> +		total_compact += compact;
>  	}
>  
>  	seq_puts(s, "\n");
> -	seq_printf(s, " %5s %5s %11lu %12lu %13lu %10lu %10lu\n",
> +	seq_printf(s, " %5s %5s %11lu %12lu %13lu %10lu %10lu %16s %7lu\n",
>  			"Total", "", total_class_almost_full,
>  			total_class_almost_empty, total_objs,
> -			total_used_objs, total_pages);
> +			total_used_objs, total_pages, "", total_compact);
>  
>  	return 0;
>  }
> -- 
> 2.7.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
