Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7016B6B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 06:03:19 -0400 (EDT)
Received: by laat2 with SMTP id t2so60219930laa.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 03:03:19 -0700 (PDT)
Received: from numascale.com (numascale.com. [213.162.240.84])
        by mx.google.com with ESMTPS id jj4si14173349lbb.174.2015.05.14.03.03.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 03:03:17 -0700 (PDT)
Date: Thu, 14 May 2015 18:03:03 +0800
From: Daniel J Blueman <daniel@numascale.com>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-Id: <1431597783.26797.1@cpanel21.proisp.no>
In-Reply-To: <20150513163157.GR2462@suse.de>
References: <20150513163157.GR2462@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, nzimmer <nzimmer@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Thu, May 14, 2015 at 12:31 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, May 13, 2015 at 10:53:33AM -0500, nzimmer wrote:
>>  I am just noticed a hang on my largest box.
>>  I can only reproduce with large core counts, if I turn down the
>>  number of cpus it doesn't have an issue.
>> 
> 
> Odd. The number of core counts should make little a difference as only
> one CPU per node should be in use. Does sysrq+t give any indication 
> how
> or where it is hanging?

I was seeing the same behaviour of 1000ms increasing to 5500ms [1]; 
this suggests either lock contention or O(n) behaviour.

Nathan, can you check with this ordering of patches from Andrew's cache 
[2]? I was getting hanging until I a found them all.

I'll follow up with timing data.

Thanks,
  Daniel

-- [1]

[   73.076117] node 2 initialised, 7732961 pages in 1060ms
[   73.077184] node 38 initialised, 7732961 pages in 1060ms
[   73.079626] node 146 initialised, 7732961 pages in 1050ms
[   73.093488] node 62 initialised, 7732961 pages in 1080ms
[   73.091557] node 3 initialised, 7732962 pages in 1080ms
[   73.100000] node 186 initialised, 7732961 pages in 1040ms
[   73.095731] node 4 initialised, 7732961 pages in 1080ms
[   73.090289] node 50 initialised, 7732961 pages in 1080ms
[   73.094005] node 158 initialised, 7732961 pages in 1050ms
[   73.095421] node 159 initialised, 7732962 pages in 1050ms
[   73.090324] node 52 initialised, 7732961 pages in 1080ms
[   73.099056] node 5 initialised, 7732962 pages in 1080ms
[   73.090116] node 160 initialised, 7732961 pages in 1050ms
[   73.161051] node 157 initialised, 7732962 pages in 1120ms
[   73.193565] node 161 initialised, 7732962 pages in 1160ms
[   73.212456] node 26 initialised, 7732961 pages in 1200ms
[   73.222904] node 0 initialised, 6686488 pages in 1210ms
[   73.242165] node 140 initialised, 7732961 pages in 1210ms
[   73.254230] node 156 initialised, 7732961 pages in 1220ms
[   73.284634] node 1 initialised, 7732962 pages in 1270ms
[   73.305301] node 141 initialised, 7732962 pages in 1280ms
[   73.322845] node 28 initialised, 7732961 pages in 1310ms
[   73.321757] node 142 initialised, 7732961 pages in 1290ms
[   73.327677] node 138 initialised, 7732961 pages in 1300ms
[   73.413597] node 176 initialised, 7732961 pages in 1370ms
[   73.455552] node 139 initialised, 7732962 pages in 1420ms
[   73.475356] node 143 initialised, 7732962 pages in 1440ms
[   73.547202] node 32 initialised, 7732961 pages in 1530ms
[   73.579591] node 104 initialised, 7732961 pages in 1560ms
[   73.618065] node 174 initialised, 7732961 pages in 1570ms
[   73.624918] node 178 initialised, 7732961 pages in 1580ms
[   73.649024] node 175 initialised, 7732962 pages in 1610ms
[   73.654110] node 105 initialised, 7732962 pages in 1630ms
[   73.670589] node 106 initialised, 7732961 pages in 1650ms
[   73.739682] node 102 initialised, 7732961 pages in 1720ms
[   73.769639] node 86 initialised, 7732961 pages in 1750ms
[   73.775573] node 44 initialised, 7732961 pages in 1760ms
[   73.772955] node 177 initialised, 7732962 pages in 1740ms
[   73.804390] node 34 initialised, 7732961 pages in 1790ms
[   73.819370] node 30 initialised, 7732961 pages in 1810ms
[   73.847882] node 98 initialised, 7732961 pages in 1830ms
[   73.867545] node 33 initialised, 7732962 pages in 1860ms
[   73.877964] node 107 initialised, 7732962 pages in 1860ms
[   73.906256] node 103 initialised, 7732962 pages in 1880ms
[   73.945581] node 100 initialised, 7732961 pages in 1930ms
[   73.947024] node 96 initialised, 7732961 pages in 1930ms
[   74.186208] node 116 initialised, 7732961 pages in 2170ms
[   74.220838] node 68 initialised, 7732961 pages in 2210ms
[   74.252341] node 46 initialised, 7732961 pages in 2240ms
[   74.274795] node 118 initialised, 7732961 pages in 2260ms
[   74.337544] node 14 initialised, 7732961 pages in 2320ms
[   74.350819] node 22 initialised, 7732961 pages in 2340ms
[   74.350332] node 69 initialised, 7732962 pages in 2340ms
[   74.362683] node 211 initialised, 7732962 pages in 2310ms
[   74.360617] node 70 initialised, 7732961 pages in 2340ms
[   74.369137] node 66 initialised, 7732961 pages in 2360ms
[   74.378242] node 115 initialised, 7732962 pages in 2360ms
[   74.404221] node 213 initialised, 7732962 pages in 2350ms
[   74.420901] node 210 initialised, 7732961 pages in 2370ms
[   74.430049] node 35 initialised, 7732962 pages in 2420ms
[   74.436007] node 48 initialised, 7732961 pages in 2420ms
[   74.480595] node 71 initialised, 7732962 pages in 2460ms
[   74.485700] node 67 initialised, 7732962 pages in 2480ms
[   74.502627] node 31 initialised, 7732962 pages in 2490ms
[   74.542220] node 16 initialised, 7732961 pages in 2530ms
[   74.547936] node 128 initialised, 7732961 pages in 2520ms
[   74.634374] node 214 initialised, 7732961 pages in 2580ms
[   74.654389] node 88 initialised, 7732961 pages in 2630ms
[   74.722833] node 117 initialised, 7732962 pages in 2700ms
[   74.735002] node 148 initialised, 7732961 pages in 2700ms
[   74.742725] node 12 initialised, 7732961 pages in 2730ms
[   74.749319] node 194 initialised, 7732961 pages in 2700ms
[   74.767979] node 24 initialised, 7732961 pages in 2750ms
[   74.769465] node 114 initialised, 7732961 pages in 2750ms
[   74.796973] node 134 initialised, 7732961 pages in 2770ms
[   74.818164] node 15 initialised, 7732962 pages in 2810ms
[   74.844852] node 18 initialised, 7732961 pages in 2830ms
[   74.866123] node 110 initialised, 7732961 pages in 2850ms
[   74.898255] node 215 initialised, 7730688 pages in 2840ms
[   74.903623] node 136 initialised, 7732961 pages in 2880ms
[   74.911107] node 144 initialised, 7732961 pages in 2890ms
[   74.918757] node 212 initialised, 7732961 pages in 2870ms
[   74.935333] node 182 initialised, 7732961 pages in 2880ms
[   74.958147] node 42 initialised, 7732961 pages in 2950ms
[   74.964989] node 108 initialised, 7732961 pages in 2950ms
[   74.965482] node 112 initialised, 7732961 pages in 2950ms
[   75.034787] node 184 initialised, 7732961 pages in 2980ms
[   75.051242] node 45 initialised, 7732962 pages in 3040ms
[   75.047169] node 152 initialised, 7732961 pages in 3020ms
[   75.062834] node 179 initialised, 7732962 pages in 3010ms
[   75.076528] node 145 initialised, 7732962 pages in 3040ms
[   75.076613] node 25 initialised, 7732962 pages in 3070ms
[   75.073086] node 164 initialised, 7732961 pages in 3040ms
[   75.079674] node 149 initialised, 7732962 pages in 3050ms
[   75.092015] node 113 initialised, 7732962 pages in 3070ms
[   75.096325] node 80 initialised, 7732961 pages in 3080ms
[   75.131380] node 92 initialised, 7732961 pages in 3110ms
[   75.142147] node 10 initialised, 7732961 pages in 3130ms
[   75.151041] node 51 initialised, 7732962 pages in 3140ms
[   75.159074] node 130 initialised, 7732961 pages in 3130ms
[   75.162616] node 166 initialised, 7732961 pages in 3130ms
[   75.193557] node 82 initialised, 7732961 pages in 3170ms
[   75.254801] node 84 initialised, 7732961 pages in 3240ms
[   75.303028] node 64 initialised, 7732961 pages in 3290ms
[   75.299739] node 49 initialised, 7732962 pages in 3290ms
[   75.314231] node 21 initialised, 7732962 pages in 3300ms
[   75.371298] node 53 initialised, 7732962 pages in 3360ms
[   75.394569] node 95 initialised, 7732962 pages in 3380ms
[   75.441101] node 23 initialised, 7732962 pages in 3430ms
[   75.433080] node 19 initialised, 7732962 pages in 3430ms
[   75.446076] node 173 initialised, 7732962 pages in 3410ms
[   75.445816] node 99 initialised, 7732962 pages in 3430ms
[   75.470330] node 87 initialised, 7732962 pages in 3450ms
[   75.502334] node 8 initialised, 7732961 pages in 3490ms
[   75.508300] node 206 initialised, 7732961 pages in 3460ms
[   75.540253] node 132 initialised, 7732961 pages in 3510ms
[   75.615453] node 183 initialised, 7732962 pages in 3560ms
[   75.632576] node 78 initialised, 7732961 pages in 3610ms
[   75.647753] node 85 initialised, 7732962 pages in 3620ms
[   75.688955] node 90 initialised, 7732961 pages in 3670ms
[   75.694522] node 200 initialised, 7732961 pages in 3640ms
[   75.688790] node 43 initialised, 7732962 pages in 3680ms
[   75.694540] node 94 initialised, 7732961 pages in 3680ms
[   75.697149] node 29 initialised, 7732962 pages in 3690ms
[   75.693590] node 111 initialised, 7732962 pages in 3680ms
[   75.715829] node 56 initialised, 7732961 pages in 3700ms
[   75.718427] node 97 initialised, 7732962 pages in 3700ms
[   75.741643] node 147 initialised, 7732962 pages in 3710ms
[   75.773613] node 170 initialised, 7732961 pages in 3740ms
[   75.802874] node 208 initialised, 7732961 pages in 3750ms
[   75.804409] node 58 initialised, 7732961 pages in 3790ms
[   75.853438] node 126 initialised, 7732961 pages in 3830ms
[   75.888167] node 167 initialised, 7732962 pages in 3850ms
[   75.912656] node 172 initialised, 7732961 pages in 3870ms
[   75.956540] node 93 initialised, 7732962 pages in 3940ms
[   75.988819] node 127 initialised, 7732962 pages in 3960ms
[   76.062198] node 201 initialised, 7732962 pages in 4010ms
[   76.091769] node 47 initialised, 7732962 pages in 4080ms
[   76.119749] node 162 initialised, 7732961 pages in 4080ms
[   76.122797] node 6 initialised, 7732961 pages in 4110ms
[   76.225916] node 153 initialised, 7732962 pages in 4190ms
[   76.219855] node 81 initialised, 7732962 pages in 4200ms
[   76.236116] node 150 initialised, 7732961 pages in 4210ms
[   76.245349] node 180 initialised, 7732961 pages in 4190ms
[   76.248827] node 17 initialised, 7732962 pages in 4240ms
[   76.258801] node 13 initialised, 7732962 pages in 4250ms
[   76.259943] node 122 initialised, 7732961 pages in 4240ms
[   76.277480] node 196 initialised, 7732961 pages in 4230ms
[   76.320830] node 41 initialised, 7732962 pages in 4310ms
[   76.351667] node 129 initialised, 7732962 pages in 4320ms
[   76.353488] node 202 initialised, 7732961 pages in 4310ms
[   76.376753] node 165 initialised, 7732962 pages in 4340ms
[   76.381807] node 124 initialised, 7732961 pages in 4350ms
[   76.419952] node 171 initialised, 7732962 pages in 4380ms
[   76.431242] node 168 initialised, 7732961 pages in 4390ms
[   76.441324] node 89 initialised, 7732962 pages in 4420ms
[   76.440720] node 155 initialised, 7732962 pages in 4400ms
[   76.459715] node 120 initialised, 7732961 pages in 4440ms
[   76.483986] node 205 initialised, 7732962 pages in 4430ms
[   76.493284] node 151 initialised, 7732962 pages in 4460ms
[   76.491437] node 60 initialised, 7732961 pages in 4480ms
[   76.526620] node 74 initialised, 7732961 pages in 4510ms
[   76.543761] node 131 initialised, 7732962 pages in 4510ms
[   76.549562] node 39 initialised, 7732962 pages in 4540ms
[   76.563861] node 11 initialised, 7732962 pages in 4550ms
[   76.598775] node 54 initialised, 7732961 pages in 4590ms
[   76.602006] node 123 initialised, 7732962 pages in 4570ms
[   76.619856] node 76 initialised, 7732961 pages in 4600ms
[   76.631418] node 198 initialised, 7732961 pages in 4580ms
[   76.665415] node 188 initialised, 7732961 pages in 4610ms
[   76.669178] node 63 initialised, 7732962 pages in 4660ms
[   76.683646] node 101 initialised, 7732962 pages in 4670ms
[   76.710780] node 192 initialised, 7732961 pages in 4660ms
[   76.736743] node 121 initialised, 7732962 pages in 4720ms
[   76.743800] node 199 initialised, 7732962 pages in 4700ms
[   76.750663] node 20 initialised, 7732961 pages in 4740ms
[   76.763045] node 135 initialised, 7732962 pages in 4730ms
[   76.768216] node 137 initialised, 7732962 pages in 4740ms
[   76.800135] node 181 initialised, 7732962 pages in 4750ms
[   76.811215] node 27 initialised, 7732962 pages in 4800ms
[   76.857405] node 125 initialised, 7732962 pages in 4820ms
[   76.853750] node 163 initialised, 7732962 pages in 4820ms
[   76.882975] node 59 initialised, 7732962 pages in 4870ms
[   76.920121] node 9 initialised, 7732962 pages in 4910ms
[   76.934824] node 189 initialised, 7732962 pages in 4880ms
[   76.951223] node 154 initialised, 7732961 pages in 4920ms
[   76.953897] node 203 initialised, 7732962 pages in 4900ms
[   76.952558] node 75 initialised, 7732962 pages in 4930ms
[   76.985480] node 119 initialised, 7732962 pages in 4970ms
[   77.036089] node 195 initialised, 7732962 pages in 4980ms
[   77.039996] node 55 initialised, 7732962 pages in 5030ms
[   77.067989] node 109 initialised, 7732962 pages in 5040ms
[   77.066236] node 7 initialised, 7732962 pages in 5060ms
[   77.068709] node 65 initialised, 7732962 pages in 5060ms
[   77.097859] node 79 initialised, 7732962 pages in 5080ms
[   77.096219] node 169 initialised, 7732962 pages in 5060ms
[   77.125113] node 83 initialised, 7732962 pages in 5110ms
[   77.139507] node 37 initialised, 7732962 pages in 5130ms
[   77.143280] node 77 initialised, 7732962 pages in 5120ms
[   77.226494] node 73 initialised, 7732962 pages in 5200ms
[   77.281584] node 190 initialised, 7732961 pages in 5230ms
[   77.314794] node 204 initialised, 7732961 pages in 5260ms
[   77.328577] node 72 initialised, 7732961 pages in 5310ms
[   77.335743] node 36 initialised, 7732961 pages in 5320ms
[   77.360573] node 40 initialised, 7732961 pages in 5350ms
[   77.368712] node 207 initialised, 7732962 pages in 5320ms
[   77.387708] node 91 initialised, 7732962 pages in 5370ms
[   77.385143] node 57 initialised, 7732962 pages in 5380ms
[   77.391785] node 191 initialised, 7732962 pages in 5340ms
[   77.479970] node 185 initialised, 7732962 pages in 5430ms
[   77.491865] node 61 initialised, 7732962 pages in 5480ms
[   77.489255] node 133 initialised, 7732962 pages in 5460ms
[   77.502111] node 197 initialised, 7732962 pages in 5450ms
[   77.507136] node 193 initialised, 7732962 pages in 5460ms
[   77.523739] node 209 initialised, 7732962 pages in 5470ms
[   77.537131] node 187 initialised, 7732962 pages in 5490ms

-- [2]

http://ozlabs.org/~akpm/mmots/broken-out/memblock-introduce-a-for_each_reserved_mem_region-iterator.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-move-page-initialization-into-a-separate-function.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-only-set-page-reserved-in-the-memblock-region.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-page_alloc-pass-pfn-to-__free_pages_bootmem.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-make-__early_pfn_to_nid-smp-safe-and-introduce-meminit_pfn_in_nid.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-inline-some-helper-functions.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-inline-some-helper-functions-fix.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-initialise-a-subset-of-struct-pages-if-config_deferred_struct_page_init-is-set.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-initialise-remaining-struct-pages-in-parallel-with-kswapd.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-minimise-number-of-pfn-page-lookups-during-initialisation.patch
http://ozlabs.org/~akpm/mmots/broken-out/x86-mm-enable-deferred-struct-page-initialisation-on-x86-64.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-free-pages-in-large-chunks-where-possible.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-reduce-number-of-times-pageblocks-are-set-during-struct-page-init.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-remove-mminit_verify_page_links.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-initialise-a-subset-of-struct-pages-if-config_deferred_struct_page_init-is-set-fix.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-reduce-number-of-times-pageblocks-are-set-during-struct-page-init-fix.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-inline-some-helper-functions-fix2.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
