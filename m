Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F2F236B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 03:15:37 -0400 (EDT)
Date: Wed, 11 Mar 2009 15:14:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311071445.GA13584@localhost>
References: <20090309142241.GA4437@localhost> <20090309160216.2048e898@mjolnir.ossman.eu> <20090310024135.GA6832@localhost> <20090310081917.GA28968@localhost> <20090310105523.3dfd4873@mjolnir.ossman.eu> <20090310122210.GA8415@localhost> <20090310131155.GA9654@localhost> <20090310212118.7bf17af6@mjolnir.ossman.eu> <20090311013739.GA7078@localhost> <20090311075703.35de2488@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311075703.35de2488@mjolnir.ossman.eu>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 08:57:03AM +0200, Pierre Ossman wrote:
> On Wed, 11 Mar 2009 09:37:40 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > 
> > This 80MB noflags pages together with the below 80MB lru pages are
> > very close to the missing page numbers :-) Could you run the following
> > commands on fresh booted 2.6.27 and post the output files? Thank you!
> > 
> >         dd if=/dev/zero of=/tmp/s bs=1M count=1 seek=1024
> >         cp /tmp/s /dev/null
> > 
> >         ./page-flags > flags
> >         ./page-areas =0x20000 > areas-noflags
> >         ./page-areas =0x00020 > areas-lru
> > 
> 
> Attached.

Thank you very much!

> I have to say, the patterns look very much like some kind of leak.

Wow it looks really interesting.  The lru pages and noflags pages make
perfect 1-page interleaved pattern...

Thanks,
Fengguang

areas-lru
>     offset      len         KB
>      86016        1        4KB
>      86018        1        4KB
>      86020        1        4KB
>      86022        1        4KB
>      86024        1        4KB
>      86026        1        4KB
>      86028        1        4KB
>      86030        1        4KB
>      86032        1        4KB
>      86034        1        4KB
>      86036        1        4KB
>      86038        1        4KB
>      86040        1        4KB
>      86042        1        4KB
>      86044        1        4KB
>      86046        1        4KB
>      86048        1        4KB
>      86050        1        4KB
>      86052        1        4KB
>      86054        1        4KB
>      86056        1        4KB
>      86058        1        4KB
>      86060        1        4KB
>      86062        1        4KB
>      86064        1        4KB
>      86066        1        4KB
>      86068        1        4KB
>      86070        1        4KB
>      86072        1        4KB
>      86074        1        4KB
>      86076        1        4KB
>      86078        1        4KB
>      86080        1        4KB
>      86082        1        4KB
>      86084        1        4KB
>      86086        1        4KB
>      86088        1        4KB
>      86090        1        4KB
>      86092        1        4KB
>      86094        1        4KB
>      86096        1        4KB
>      86098        1        4KB
>      86100        1        4KB
>      86102        1        4KB
>      86104        1        4KB

areas-noflags
>      86017        1        4KB
>      86019        1        4KB
>      86021        1        4KB
>      86023        1        4KB
>      86025        1        4KB
>      86027        1        4KB
>      86029        1        4KB
>      86031        1        4KB
>      86033        1        4KB
>      86035        1        4KB
>      86037        1        4KB
>      86039        1        4KB
>      86041        1        4KB
>      86043        1        4KB
>      86045        1        4KB
>      86047        1        4KB
>      86049        1        4KB
>      86051        1        4KB
>      86053        1        4KB
>      86055        1        4KB
>      86057        1        4KB
>      86059        1        4KB
>      86061        1        4KB
>      86063        1        4KB
>      86065        1        4KB
>      86067        1        4KB
>      86069        1        4KB
>      86071        1        4KB
>      86073        1        4KB
>      86075        1        4KB
>      86077        1        4KB
>      86079        1        4KB
>      86081        1        4KB
>      86083        1        4KB
>      86085        1        4KB
>      86087        1        4KB
>      86089        1        4KB
>      86091        1        4KB
>      86093        1        4KB
>      86095        1        4KB
>      86097        1        4KB
>      86099        1        4KB
>      86101        1        4KB
>      86103        1        4KB

>   flags	page-count       MB    symbolic-flags    long-symbolic-flags
> 0x00000	      1892        7  __________________  
> 0x00004	         1        0  __R_______________  referenced
> 0x00008	       454        1  ___U______________  uptodate
> 0x0000c	        94        0  __RU______________  referenced,uptodate
> 0x00020	     20576       80  _____l____________  lru
> 0x00028	       226        0  ___U_l____________  uptodate,lru
> 0x0002c	     67911      265  __RU_l____________  referenced,uptodate,lru
> 0x00068	      6621       25  ___U_lA___________  uptodate,lru,active
> 0x0006c	      1222        4  __RU_lA___________  referenced,uptodate,lru,active
> 0x00078	         1        0  ___UDlA___________  uptodate,dirty,lru,active
> 0x00080	      3523       13  _______S__________  slab
> 0x000c0	        55        0  ______AS__________  active,slab
> 0x00228	         5        0  ___U_l___x________  uptodate,lru,reclaim
> 0x0022c	         1        0  __RU_l___x________  referenced,uptodate,lru,reclaim
> 0x00268	        23        0  ___U_lA__x________  uptodate,lru,active,reclaim
> 0x0026c	        52        0  __RU_lA__x________  referenced,uptodate,lru,active,reclaim
> 0x00400	         9        0  __________B_______  buddy
> 0x00408	        60        0  ___U______B_______  uptodate,buddy
> 0x00800	      4042       15  ___________r______  reserved
> 0x04020	         9        0  _____l________P___  lru,private
> 0x04024	        14        0  __R__l________P___  referenced,lru,private
> 0x04028	         4        0  ___U_l________P___  uptodate,lru,private
> 0x0402c	         1        0  __RU_l________P___  referenced,uptodate,lru,private
> 0x04060	        10        0  _____lA_______P___  lru,active,private
> 0x04064	         7        0  __R__lA_______P___  referenced,lru,active,private
> 0x04068	        16        0  ___U_lA_______P___  uptodate,lru,active,private
> 0x20000	     24227       94  _________________n  noflags
>   total	    131056      511

> MemTotal:       508056 kB
> MemFree:          7716 kB
> Buffers:           220 kB
> Cached:         280468 kB
> SwapCached:          0 kB
> Active:          31184 kB
> Inactive:       271508 kB
> SwapTotal:      524280 kB
> SwapFree:       524232 kB
> Dirty:            1284 kB
> Writeback:           0 kB
> AnonPages:       22044 kB
> Mapped:           8652 kB
> Slab:            21508 kB
> SReclaimable:     4212 kB
> SUnreclaim:      17296 kB
> PageTables:       3036 kB
> NFS_Unstable:        0 kB
> Bounce:              0 kB
> WritebackTmp:        0 kB
> CommitLimit:    778308 kB
> Committed_AS:    80544 kB
> VmallocTotal: 34359738367 kB
> VmallocUsed:      1740 kB
> VmallocChunk: 34359736619 kB
> HugePages_Total:     0
> HugePages_Free:      0
> HugePages_Rsvd:      0
> HugePages_Surp:      0
> Hugepagesize:     2048 kB
> DirectMap4k:      8128 kB
> DirectMap2M:    516096 kB



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
