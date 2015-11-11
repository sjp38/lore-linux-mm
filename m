Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEDB6B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 15:34:12 -0500 (EST)
Received: by pasz6 with SMTP id z6so41951669pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 12:34:12 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id yu1si14752651pac.9.2015.11.11.12.34.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 12:34:11 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so40689111pab.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 12:34:11 -0800 (PST)
Date: Wed, 11 Nov 2015 12:34:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] tools/vm: fix Makefile multi-targets
In-Reply-To: <20151111122807.GB654@swordfish>
Message-ID: <alpine.DEB.2.10.1511111232460.3565@chino.kir.corp.google.com>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com> <1447162326-30626-2-git-send-email-sergey.senozhatsky@gmail.com> <20151111122807.GB654@swordfish>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-523955746-1447274049=:3565"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-523955746-1447274049=:3565
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Wed, 11 Nov 2015, Sergey Senozhatsky wrote:

> > This doesn't purport to explain why -O2 was added or why it's needed fora??
> > these tools.
> 
> Hm, that was a sem-automatic action I saw no issues with (besides, I
> considered this to be too small for a separate patch). `slabinfo' can
> be used to collected extended '-X' measurements for gnuplot script
> e.g.
> 	`while [ 1 ]; do slabinfo -X >> stats; sleep 0.1s; done`
> 
> so making it a bit lighter is sort of positive change, though I'm not
> married to this option.
> 
> 
> perf stats:
> 
> -- OLD
> 
>  Performance counter stats for './slabinfo.old -X -B -N 100':
> 
>         197.879348      task-clock (msec)         #    0.969 CPUs utilized          
>                 22      context-switches          #    0.111 K/sec                  
>                  0      cpu-migrations            #    0.000 K/sec                  
>              2,276      page-faults               #    0.012 M/sec                  
>        182,916,015      cycles                    #    0.924 GHz                    
>    <not supported>      stalled-cycles-frontend  
>    <not supported>      stalled-cycles-backend   
>        259,843,733      instructions              #    1.42  insns per cycle        
>         53,949,755      branches                  #  272.640 M/sec                  
>            157,607      branch-misses             #    0.29% of all branches        
> 
>        0.204190648 seconds time elapsed
> 
> 
> -- NEW (-O2)
> 
>  Performance counter stats for './slabinfo.new -X -B -N 100':
> 
>         169.963546      task-clock (msec)         #    0.977 CPUs utilized          
>                  9      context-switches          #    0.053 K/sec                  
>                  0      cpu-migrations            #    0.000 K/sec                  
>              2,276      page-faults               #    0.013 M/sec                  
>        153,582,826      cycles                    #    0.904 GHz                    
>    <not supported>      stalled-cycles-frontend  
>    <not supported>      stalled-cycles-backend   
>        218,505,232      instructions              #    1.42  insns per cycle        
>         45,410,422      branches                  #  267.177 M/sec                  
>            114,126      branch-misses             #    0.25% of all branches        
> 
>        0.173921887 seconds time elapsed
> 
> 
> ./scripts/bloat-o-meter tools/vm/slabinfo.old tools/vm/slabinfo.new
> add/remove: 5/23 grow/shrink: 7/7 up/down: 6434/-9495 (-3061)
> function                                     old     new   delta
> main                                         878    3699   +2821
> output_slabs                                 307    2075   +1768
> report                                       781    1905   +1124
> rename_slabs                                 167     333    +166
> read_slab_obj.isra                             -     131    +131
> ops.isra                                       -     104    +104
> set_obj.isra                                   -     102    +102
> read_obj                                     145     236     +91
> sort_slabs                                   414     478     +64
> slab_empty.part                                -      32     +32
> get_obj.part                                   -      17     +17
> slab_numa                                    542     556     +14
> decode_numa_list                             235     230      -5
> fatal                                        176     160     -16
> usage                                         17       -     -17
> onoff                                         27       -     -27
> show_tracking                                193     162     -31
> get_obj_and_str                              157     124     -33
> slab_size                                     43       -     -43
> slab_mismatch                                 47       -     -47
> get_obj                                       48       -     -48
> slab_waste                                    56       -     -56
> link_slabs                                   226     169     -57
> slab_activity                                 60       -     -60
> slab_validate                                 63       -     -63
> slab_shrink                                   63       -     -63
> slab_empty                                    74       -     -74
> first_line                                    74       -     -74
> store_size                                   271     191     -80
> xtotals                                      142       -    -142
> ops                                          145       -    -145
> set_obj                                      162       -    -162
> read_slab_obj                                182       -    -182
> find_one_alias                               187       -    -187
> sort_aliases                                 288       -    -288
> alias                                        298       -    -298
> debug_opt_scan                               355       -    -355
> slab_debug                                   870       -    -870
> totals                                      4136    3198    -938
> slabcache                                   1289       -   -1289
> read_slab_dir                               1798       -   -1798
> slab_stats                                  2047       -   -2047
> 
> 
> 
> I believe the remaining tools will not `suffer' as well.
> Do you prefer to remove -O2?
> 

No, I have no objection to removing -O2.  I'd prefer that the rationale be 
included in the commit description, however.

Acked-by: David Rientjes <rientjes@google.com>
--397176738-523955746-1447274049=:3565--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
