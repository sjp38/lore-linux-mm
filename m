Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA20456
	for <linux-mm@kvack.org>; Mon, 30 Nov 1998 18:13:51 -0500
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
References: <199811261236.MAA14785@dax.scot.redhat.com> <Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com> <199811271602.QAA00642@dax.scot.redhat.com> <8767c0q55d.fsf@atlas.CARNet.hr> <199811301115.LAA02884@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 01 Dec 1998 00:13:38 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 30 Nov 1998 11:15:46 GMT"
Message-ID: <87yaossrj1.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 27 Nov 1998 20:58:38 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > Yesterday, I was trying to understand the very same problem you're
> > speaking of. Sometimes kswapd decides to swapout lots of things,
> > sometimes not.
> 
> > I applied your patch, but it didn't solve the problem.
> > To be honest, things are now even slightly worse. :(
> 
> Well, after a few days of running with the patched 2.1.130, I have never
> seen evil cache growth and the performance has been great throughout.
> If you can give me a reproducible way of observing bad worst-case
> behaviour, I'd love to see it, but right now, things like

Be my guest. :)

wc /usr/bin/* never made any problems for me, but:

{atlas} [/image]% ls -al
total 411290
drwxrwxrwt   5 root     root         1024 Dec  1 00:00 .
drwxr-xr-x  22 root     root         1024 Nov 17 03:04 ..
-rw-r--r--   1 zcalusic users    419430400 Nov 30 23:53 400MB
-rwxr-xr-x   1 zcalusic users         438 Dec  1 00:00 testing-mm
{atlas} [/image]% cat testing-mm 
#! /bin/sh
echo "starting vmstat 1 in background" > report-log
vmstat 1 >> report-log &
sleep 5
echo "starting xemacs" >> report-log; xemacs &
sleep 1
echo "starting netscape" >> report-log; netscape &
sleep 1
echo "starting gimp" >> report-log; gimp &
sleep 1
echo "sleep 45 started" >> report-log
sleep 45
echo "sleep 45 done" >> report-log
echo "cp 400MB /dev/null" >> report-log; cp 400MB /dev/null
kill `pidof vmstat`
{atlas} [/image]% ./testing-mm
{atlas} [/image]% cat report-log
starting vmstat 1 in background
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 1 0 0     0 19424  3660 19420  35  65  582  590  166  173   7  10  83
 0 0 0     0 19376  3660 19420   0   0    0    0  105    8   2   2  96
 0 0 0     0 19376  3660 19420   0   0    0    0  104    6   1   2  97
 0 0 0     0 19376  3660 19420   0   0    0    0  106   10   2   1  97
 0 0 0     0 19376  3660 19420   0   0    0    0  104    6   1   2  97
starting xemacs
 1 0 0     0 19120  3660 19500   0   0   62   21  133   37   5   4  91
starting netscape
 2 0 0     0 17680  3660 20312   0   0  806    0  232  243  10  10  81
starting gimp
 5 0 0     0 14448  3660 20896   0   0  546    0  198  694  65  15  19
 5 0 0     0 13308  3660 21388   0   0  412    0  176  829  67  13  20
sleep 45 started
 3 0 0     0 11396  3660 22232   0   0  579    0  247  540  83  17   0
 3 0 0     0  5520  3660 25012   0   0 2667    7  292  318  86  14   0
 3 0 0     0  1752  3276 27040   0   0 2389    0  275  417  85  15   0
 1 1 0     0  1532  3276 24144   0   0 3035    0  320 1460  53  23  24
 2 0 0     0  1620  3276 22872   0   0 1042    1  250  283  29   5  66
 0 3 0     0  1580  3276 22644   0   0  493  118  222  253  15   5  80
 2 0 0     0  1536  3276 22620   0   0  106   53  237  139   2   5  93
 3 0 0     0  1592  3276 22372   0   0  680    0  194  530  62  10  29
 2 0 0     0  1796  3276 21872   0   0  984    0  173  374  66  10  24
 3 0 0     0  1592  3276 21688   0   0  634    8  205 1523  37  13  50
 2 0 0     0  1624  3276 21196   0   0  656    0  209 3495  59  19  22
 2 0 0     0  1588  3276 20808   0   0  407   77  216  287  35   9  57
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 2 0 0     0  1576  3276 20200   0   0  404    0  176 1265  62  11  28
 1 0 0     0  1652  3276 19520   0   0  516    0  190 1833  64  14  21
 2 0 0     0  1576  3276 19344   0   0  507    0  188  864  27  10  63
 0 0 0     0  1572  3276 18112   0   0  152   83  139  452  21   8  71
 0 0 0     0  1572  3276 18112   0   0    0    0  145   14   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   1   2  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   20   1   2  97
 0 0 0     0  1572  3276 18112   0   0    0   19  114   17   2   2  96
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   12   1   2  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    1  105   17   1   2  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   12   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   29   3   1  96
 0 0 0     0  1572  3276 18112   0   0    0    1  105   12   1   2  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   12   1   2  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 0 0 0     0  1572  3276 18112   0   0    0    0  107   14   2   1  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    9  110   14   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  105   12   1   2  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  106   13   1   2  97
 0 0 0     0  1572  3276 18112   0   0    0    0  105   19   1   3  96
 0 0 0     0  1572  3276 18112   0   0    0    0  104   13   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
 0 0 0     0  1572  3276 18112   0   0    0    0  104   10   0   3  97
sleep 45 done
cp 400MB /dev/null
 0 1 1   276  1008  3284 18980   0 276 5711   69  206  120   2  20  78
 1 0 0  1020  1664  3276 19076   4 752 8253  190  270  161   2  40  58
 1 0 1  1028  1464  3276 19296   0   8 12540    2  304  187   1  47  52
 0 1 1  3488  1504  3276 21712   0 2460 5450  615  267  204   1  28  71
 0 1 1  6372   648  3276 25452   0 2892 3766  723  242  186   2  13  85
 1 0 1  9336  1172  3276 27892   0 3016 2502  754  250  208   3  12  85
 1 0 1 12136  1372  3276 30492   0 2848 2658  723  241  170   1  10  89
 0 1 1 15016  1140  3276 33604   0 2912 3153  728  250  220   0  12  88
 0 1 1 18016   644  3276 37100   0 3028 3541  757  247  192   2  13  86
 0 0 2 21316  1664  3276 39380   0 3340 2329  835  257  240   1  13  87
 1 0 1 23916  1204  3276 42440   0 2656 3125  664  244  182   2  14  84
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 0 1 1 26468  1000  3276 45196   0 2612 2827  655  233  173   0  18  82
 0 1 0 29260   776  3276 48212   0 2848 3084  712  244  178   2  15  83
 1 0 1 31692   760  3276 50660   0 2544 2570  636  246  165   0  14  86
 1 0 0 32236  1636  3276 50356   0 648 9547  162  285  182   1  35  64
 1 3 0 32192  1656  3276 50316  88   0 9256    0  263  190   2  30  68
 2 1 0 32140  1668  3276 50244 124   0 4982    0  222  168   1  21  78
 1 0 0 32112  1668  3292 50224  60   0 7761    0  240  158   1  34  65
 1 0 1 32112  1448  3276 50460   0   0 13588    0  322  202   2  54  44
 0 2 0 32104  1664  3300 50212  12   0 12123    0  266  188   3  55  42
 1 0 1 32088  1412  3276 50484  24   0 10550    0  284  181   2  40  58
 1 0 1 32068  1504  3276 50392  32   0 10710    5  282  181   2  40  58
 1 0 1 32068  1408  3276 50488   0   0 13200    0  299  205   3  54  43
 1 0 0 32068  1664  3340 50168   0   0 13107    0  303  184   1  47  52
 2 0 1 32068  1464  3276 50444   0   0 12544    0  299  188   1  52  47
 2 0 1 32068  1412  3276 50496   0   0 12385    1  302  195   2  50  48
 2 0 0 32068  1668  3276 50240   0   0 12337    0  296  171   1  52  47
 2 0 1 32064  1372  3276 50532  24   0 10319    0  276  184   2  41  57
 2 0 1 32064  1412  3276 50492   0   0 11822    0  283  181   1  45  54
 2 0 0 32064  1560  3276 50380   0   0 12336    0  296  178   1  48  51
 0 2 0 32024  1656  3276 50252  56   0 5516    3  216  144   2  20  78
 1 1 0 32016  1656  3276 50244  52   0 5237    0  205  129   1  21  78
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 1 1 0 32012  1544  3276 50352  56   0 5362    0  207  131   0  19  81
 1 1 0 32008  1656  3276 50236  76   0 6091    0  231  166   3  25  72
 1 1 0 32000  1668  3328 50164  36   0 5715    0  213  133   0  25  75
 1 1 0 31992  1668  3276 50208  76   0 5970    0  221  165   1  18  81
 1 1 1 31980  1404  3276 50460  44   0 5532    0  215  140   1  22  77
 0 3 1 31960  1388  3276 50468  72   0 5002    0  219  153   1  18  81
 0 3 0 31916  1644  3276 50172  64   0 5027    0  222  157   2  19  79
 1 1 0 31896  1640  3276 50140  28   0 5783    0  226  155   2  24  74
 1 1 0 31892  1624  3276 50160  64   0 6746    2  220  143   1  25  74
 1 1 0 31888  1568  3276 50212  56   0 7306    0  225  153   2  24  74
 1 1 1 31872  1412  3340 50280  48   0 7168    0  247  186   2  25  73
 1 1 1 31836  1408  3276 50312  56   0 5717    0  216  147   1  20  79
 2 1 0 31820  1640  3276 50080  32   0 10039    0  242  231   1  43  56
 3 0 1 31788  1412  3276 50272  80   0 5964    2  220  158   0  27  73
 1 1 0 31752  1608  3276 50036  48   0 5525    0  218  152   1  23  76
 1 1 0 31736  1664  3276 49964  12   0 4950    0  201  124   1  20  79
 1 1 0 31704  1648  3276 49948  56   0 4997    0  210  128   2  16  82
 1 1 0 31700  1588  3276 50004  64   0 6557    0  227  152   3  27  70
 2 0 0 31660  1656  3340 49840  48   0 6109    1  232  162   2  23  75
 1 1 0 31628  1668  3276 49864  56   0 7531    0  227  150   1  35  64
 1 1 0 31608  1572  3276 49940  16   0 6866    0  224  166   1  27  72
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 1 1 0 31540  1656  3276 49792  48   0 6320    0  237  167   2  28  70
 0 2 0 31536  1668  3276 49772  28   0 7218    2  229  169   1  29  70
 1 1 0 31524  1668  3276 49800  40   0 4933    0  250  121   2  24  74
 2 0 0 31524  1668  3276 49800  12   0 7151    0  252  143   1  28  71
 1 1 0 31512  1656  3276 49800  20   0 6010    0  229  136   1  25  74
 0 3 0 30600  1616  3296 49756 156   0 2573    0  223  206   1  14  85
 1 2 0 30448  1592  3276 49588 308   0  479    2  250  309   2   1  97

Machine in question has 64MB of RAM, which were mostly used by firing
up xemacs, netscape & gimp. Copying 400MB to /dev/null outswapped 32MB
(almost all used memory) in a matter of seconds.

Your patch is applied, of course. :)

Comments?
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
		Oops. My brain just hit a bad sector.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
