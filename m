Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 16 Feb 2009 16:22:28 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [mel@csn.ul.ie: Re: [patch] SLQB slab allocator (try 2)]
Message-ID: <20090216212228.GE22867@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Resend -- was truncated earlier due to an line consisting of an unescaped 
".\n"...

		-ben

----- Forwarded message from Mel Gorman <mel@csn.ul.ie> -----

Subject: Re: [patch] SLQB slab allocator (try 2)
From:	Mel Gorman <mel@csn.ul.ie>
To:	Nick Piggin <nickpiggin@yahoo.com.au>
Cc:	Pekka Enberg <penberg@cs.helsinki.fi>,
	Nick Piggin <npiggin@suse.de>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Lin Ming <ming.m.lin@intel.com>,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	Christoph Lameter <cl@linux-foundation.org>
Date:	Mon, 16 Feb 2009 18:42:00 +0000
In-Reply-To: <200902051459.30064.nickpiggin@yahoo.com.au>


Slightly later than hoped for, but here are the results of the profile
run between the different slab allocators. It also includes information on
the performance on SLUB with the allocator pass-thru logic reverted by commit
http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=97a4871761e735b6f1acd3bc7c3bac30dae3eab9
..

All the profiles are in a tar stored at
http://www.csn.ul.ie/~mel/postings/slXb-20090213/ . The layout of it is as
follows

o hydra is the x86-64 machine
o powyah is the ppc64 machine
o the next level of directories is for each benchmark
o speccpu06/profile contains spec config files. gen-m64base.cfg was used
o The result/ directory contains three types of files
	procinfo-before-*	Proc files and slabinfo before a benchmark
	procinfo-after-*	Proc files after
	OP.*			Oprofile output
  The files are indexed 001, 002 etc and are as follows
  	001 slab
	002 slub-default
	003 slub-minorder (max_order=1, min_objects=1)
	004 slqb
	005 slub-revert-passthru
o The sysbench-run2 directories are named based on the allocator tested
o The sysbench contain noprofile, profile and fine-profile directories
  fine-profile is probably of the most interest. There are files named
  oprofile-THREAD_COUNT-report.txt where THREAD_COUNT is in the range 1-16.

I haven't done much digging in here yet. Between the large page bug and
other patches in my inbox, I haven't had the chance yet but that doesn't
stop anyone else taking a look.

I'm reposting the performance as SLUB and SLQB had to be rebuilt with profile
stats enabled which potentially changed the result slightly.

x86-64 speccpu performance ratios
=================================
Integer tests
SPEC test       slab       slub  slub-min slub-rvrt      slqb
400.perlbench   1.0000   1.0472    1.0118    1.0393    1.0000
401.bzip2       1.0000   1.0071    0.9970    1.0041    1.0000
403.gcc         1.0000   0.9579    0.9952    0.9034    0.9588
429.mcf         1.0000   1.0089    0.9933    0.9376    0.9959
445.gobmk       1.0000   0.9881    1.0040    0.9894    0.9947
456.hmmer       1.0000   0.9911    1.1039    0.9911    0.9940
458.sjeng       1.0000   0.9958    0.9622    0.9691    0.9632
462.libquantum  1.0000   1.0576    0.9974    1.0817    1.0547
464.h264ref     1.0000   1.0230    1.0295    1.0165    1.0279
471.omnetpp     1.0000   1.0038    0.9511    0.9626    0.9557
473.astar       1.0000   0.9811    0.9957    0.9989    0.9957
483.xalancbmk   1.0000   1.0889    1.0135    1.0060    1.0715
---------------
specint geomean 1.0000   1.0119    1.0039    0.9907    1.0004

Floating Point Tests
SPEC test       slab       slub  slub-min slub-rvrt      slqb
410.bwaves      1.0000   1.0047    0.8369    0.8366    0.8366
416.gamess      1.0000   1.0038    1.0015    0.9977    1.0046
433.milc        1.0000   1.1416    1.1187    1.0182    1.1329
434.zeusmp      1.0000   1.0847    0.9991    1.0009    0.9974
435.gromacs     1.0000   1.0652    1.0000    1.0652    0.9989
436.cactusADM   1.0000   1.0057    0.9974    1.0979    1.0021
437.leslie3d    1.0000   1.0438    1.0387    1.0034    0.9919
444.namd        1.0000   1.0000    0.9713    0.9947    1.0027
447.dealII      1.0000   1.0000    0.9986    1.0071    0.9986
450.soplex      1.0000   0.9627    0.8958    1.0169    1.0028
453.povray      1.0000   0.9971    0.9457    0.9508    1.0029
454.calculix    1.0000   0.9994    0.9612    1.0012    0.9994
459.GemsFDTD    1.0000   1.0035    0.9094    1.0057    1.0014
465.tonto       1.0000   1.0155    1.0010    1.0000    1.0010
470.lbm         1.0000   1.2551    1.2406    1.2613    1.0008
481.wrf         1.0000   0.9971    0.9514    0.9527    0.9501
482.sphinx3     1.0000   1.0045    0.9994    1.0083    0.9994
---------------
specfp geomean  1.0000   1.0323    0.9886    1.0098    0.9941

x86-64 sysbench performance ratios
==================================
Client      slab     slub  slub-min  slub-rvrt       slqb 
     1    1.0000   1.0390    0.9698     1.0396     0.9803
     2    1.0000   1.0080    1.0008     0.9986     0.9967
     3    1.0000   1.0132    1.0032     0.9904     0.9947
     4    1.0000   1.0222    1.0059     0.9898     0.9914
     5    1.0000   1.0025    1.0144     0.9929     0.9869
     6    1.0000   0.9959    1.0118     1.0082     0.9974
     7    1.0000   1.0008    0.9805     0.9676     0.9829
     8    1.0000   0.9878    0.9875     0.9702     0.9850
     9    1.0000   1.0126    1.0322     0.9894     0.9966
    10    1.0000   0.9984    0.9968     0.9947     1.0265
    11    1.0000   1.0028    1.0086     0.9922     1.0215
    12    1.0000   1.0044    1.0044     0.9910     0.9965
    13    1.0000   0.9940    0.9929     0.9854     0.9849
    14    1.0000   0.9997    1.0127     0.9892     0.9870
    15    1.0000   0.9984    1.0044     0.9905     1.0029
    16    1.0000   0.9912    0.9878     1.0034     0.9912
Geo. mean 1.0000   1.0044    1.0007     0.9932     0.9951

ppc64 speccpu performance ratios
================================
Integer tests
SPEC test       slab       slub  slub-mi  slub-rvrt      slqb
400.perlbench   1.0000   1.0008    0.9954    1.0008    1.0008
401.bzip2       1.0000   0.9993    0.9980    0.9973    1.0000
403.gcc         1.0000   0.9983    0.9991    0.9975    0.9983
429.mcf         1.0000   1.0004    0.9954    1.0000    1.0004
445.gobmk       1.0000   1.0009    1.0028    1.0009    1.0018
456.hmmer       1.0000   1.0054    1.0040    0.9993    0.9987
458.sjeng       1.0000   0.9976    1.0006    1.0006    0.9976
462.libquantum  1.0000   1.0039    1.0051    1.0032    1.0039
464.h264ref     1.0000   0.9958    0.9988    0.9988    0.9994
471.omnetpp     1.0000   0.9935    0.9859    0.9886    0.9913
473.astar       1.0000   0.9978    1.0000    0.9978    1.0022
483.xalancbmk   1.0000   1.0008    1.0017    1.0000    1.0017
---------------
specint geomean 1.0000   0.9995    0.9989    0.9987    0.9997

Floating Point Tests
SPEC test       slab       slub  slub-min slub-rvrt      slqb
410.bwaves      1.0000   0.9135    1.0016    0.9851    0.9439
416.gamess      1.0000   0.9990    0.9956    0.9922    0.9942
433.milc        1.0000   1.0018    1.0030    1.0036    1.0036
434.zeusmp      1.0000   1.0000    1.0008    0.9984    1.0008
435.gromacs     1.0000   0.9992    0.9962    0.9970    0.9985
436.cactusADM   1.0000   0.9914    1.0029    0.9931    0.9931
437.leslie3d    1.0000   1.0016    1.0027    1.0000    1.0019
444.namd        1.0000   0.9834    0.9976    0.9976    0.9904
447.dealII      1.0000   1.0045    1.0018    1.0018    1.0027
450.soplex      1.0000   0.9981    0.9953    0.9943    0.9981
453.povray      1.0000   0.9963    1.0037    0.9927    0.9083
454.calculix    1.0000   0.9980    0.9992    0.9968    0.9988
459.GemsFDTD    1.0000   0.9991    0.9981    0.9994    0.9981
465.tonto       1.0000   1.0024    0.9923    0.9976    1.0000
470.lbm         1.0000   1.0000    0.9988    0.9988    1.0000
481.wrf         1.0000   0.9981    1.0005    0.9971    0.9971
482.sphinx3     1.0000   0.9983    0.9970    0.9970    1.0000
---------------
specfp geomean  1.0000   0.9930    0.9992    0.9966    0.9897

ppc64 sysbench performance ratios
==================================
Client      slab     slub  slub-min  slub-rvrt       slqb 
     1    1.0000   0.9723    0.9876     0.9882     0.9675
     2    1.0000   0.9878    1.0010     0.9901     0.9586
     3    1.0000   0.9732    1.0025     0.9915     0.9492
     4    1.0000   0.9680    1.0021     1.0023     0.9803
     5    1.0000   0.9762    0.9945     0.9861     0.9780
     6    1.0000   0.9773    1.0039     0.9976     0.9774
     7    1.0000   0.9699    1.0051     0.9895     0.9708
     8    1.0000   0.9789    1.0041     0.9864     0.9734
     9    1.0000   0.9622    0.9951     0.9790     0.9627
    10    1.0000   0.9688    1.0024     0.9621     0.9708
    11    1.0000   0.9701    1.0033     0.9872     0.9706
    12    1.0000   0.9698    0.9999     0.9871     0.9728
    13    1.0000   0.9677    0.9978     0.9816     0.9695
    14    1.0000   0.9729    1.0067     0.9903     0.9726
    15    1.0000   0.9756    1.0027     0.9906     0.9730
    16    1.0000   0.9655    0.9975     0.9804     0.9668
Geo. mean 1.0000   0.9722    1.0004     0.9868     0.9696


Cache misses
============

Based on the profiles, here are the cache profiles of speccpu at least. I
ran out of time for writing a reporting script for sysbench but all the
necessary data is in the tar. Remember that the ratios are of improvements
so a ration of 1.0463 implies 4.63% fewer cache misses than SLAB.

x86-64 speccpu cache-miss improvements
======================================
SPEC test         slab     slub slub-min slub-rvrt     slqb
perlbench       1.0000   1.0463   0.9861    1.0539   1.0147
bzip2           1.0000   1.0091   1.0051    1.0110   0.9925
gcc             1.0000   0.9579   0.9610    0.8922   0.9959
mcf             1.0000   1.0069   0.9970    0.9470   0.9786
gobmk           1.0000   0.9873   0.9942    0.9953   1.0032
hmmer           1.0000   0.7456   0.9739    1.0048   0.9373
sjeng           1.0000   1.0289   1.0154    1.1512   0.9695
libquantum      1.0000   1.0348   1.0010    1.0508   0.9971
h264ref         1.0000   1.0600   1.1158    1.1002   1.1486
omnetpp         1.0000   1.0014   0.9650    0.9687   0.9566
astar           1.0000   0.9867   1.0017    1.0045   1.0016
xalancbmk       1.0000   1.0935   1.0834    1.0090   1.0361
---------
specint geomean 1.0000   0.9925   1.0074    1.0136   1.0014

milc            1.0000   1.1239   1.1935    1.1025   1.1002
lbm             1.0000   1.2181   1.0002    1.2219   1.1871
sphinx3         1.0000   1.2743   1.0039    1.0107   1.2692
bwaves          1.0000   1.0145   0.8063    0.8042   0.8041
gamess          1.0000   1.0120   0.9974    0.9685   0.9914
zeusmp          1.0000   1.0769   0.9998    1.0013   1.0032
leslie3d        1.0000   1.0276   0.9558    1.0032   0.9901
GemsFDTD        1.0000   1.0052   1.0044    1.0039   0.9076
tonto           1.0000   0.9967   0.9778    0.9856   0.9887
gromacs         1.0000   1.0570   1.0017    1.0563   1.0008
cactusADM       1.0000   1.0117   1.0060    1.0786   0.9999
calculix        1.0000   1.0049   1.0022    1.0003   0.9469
wrf             1.0000   0.8324   0.9552    0.9675   0.9646
namd            1.0000   0.9892   1.0467    0.9985   0.9930
dealII          1.0000   1.0240   1.0105    1.0268   1.0097
soplex          1.0000   0.9731   1.0088    1.0131   0.9065
povray          1.0000   1.0100   1.0080    0.9757   0.9532
---------
specfp geomean  1.0000   1.0341   0.9962    1.0097   0.9959

ppc64 speccpu cache-miss improvements
=====================================
SPEC test         slab     slub slub-min slub-rvrt     slqb
perlbench       1.0000   1.0168   1.0065    1.0210   0.9777
bzip2           1.0000   1.0053   1.0304    0.9894   0.9885
gcc             1.0000   1.0008   1.0051    0.9974   1.0040
mcf             1.0000   0.9783   1.0045    0.9856   0.9717
gobmk           1.0000   1.0123   1.0197    1.0256   1.0274
hmmer           1.0000   0.9936   0.9741    0.9829   0.9961
sjeng           1.0000   0.9980   0.9839    1.0066   1.0197
libquantum      1.0000   1.0199   1.0020    0.9916   0.9752
h264ref         1.0000   1.0177   1.0064    1.0167   1.0258
omnetpp         1.0000   0.9904   0.9940    1.0002   0.9572
astar           1.0000   0.9926   1.0115    0.9946   0.9900
xalancbmk       1.0000   1.0131   1.0133    1.0090   1.0244
---------
specint geomean 1.0000   1.0032   1.0042    1.0016   0.9962

milc            1.0000   1.0140   1.0307    1.0317   1.0141
lbm             1.0000   0.9966   0.9971    1.0201   0.9811
sphinx3         1.0000   0.9904   0.9844    0.9871   0.9982
bwaves          1.0000   1.0106   1.0380    1.0071   1.0203
gamess          1.0000   1.0475   1.0286    1.0136   1.0194
zeusmp          1.0000   1.0274   1.0152    1.0284   1.0214
leslie3d        1.0000   0.9788   0.9640    1.0118   0.9583
GemsFDTD        1.0000   1.0236   1.0110    1.0201   0.9936
tonto           1.0000   1.0591   0.9458    0.9342   1.0341
gromacs         1.0000   1.0159   1.0037    0.9749   0.9904
cactusADM       1.0000   0.9946   1.0000    0.9914   1.0201
calculix        1.0000   1.0206   1.0313    1.0363   1.0331
wrf             1.0000   1.0222   1.0096    1.0606   1.0253
namd            1.0000   0.9862   0.9773    0.9557   0.9744
dealII          1.0000   1.0135   0.9904    1.0333   1.0205
soplex          1.0000   1.0213   1.0081    0.9998   0.9922
povray          1.0000   1.0201   1.0016    1.0419   1.0575
--------
specfp geomean  1.0000   1.0140   1.0019    1.0082   1.0088

Glancing through, it would appear that slub with default settings is often the
cache-friendlist, but it suffered badly on hmmer on the x86-64, probably an
accident of layout. While its cache usage for lbm and sphinx were drastically
improved for slub, it didn't translate into significantly better performance.
It's difficult to conclude anything from the cache figures other than no
allocator is obviously far worse than slab in terms of cache usage.


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

----- End forwarded message -----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
