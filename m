Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8D56B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 06:44:58 -0500 (EST)
Date: Fri, 27 Nov 2009 11:44:50 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
Message-ID: <20091127114450.GK13095@csn.ul.ie>
References: <20091126121945.GB13095@csn.ul.ie> <4e5e476b0911260547r33424098v456ed23203a61dd@mail.gmail.com> <20091126141738.GE13095@csn.ul.ie> <4e5e476b0911260718h35fab3b1hc63587b23c02d43f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4e5e476b0911260718h35fab3b1hc63587b23c02d43f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Corrado Zoccolo <czoccolo@gmail.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 26, 2009 at 04:18:18PM +0100, Corrado Zoccolo wrote:
> > <SNIP>
> >
> > In case you mean a partial disabling of cfq_latency, I'm try the
> > following patch. The intention is to disable the low_latency logic if
> > kswapd is at work and presumably needs clean pages. Alternative
> > suggestions welcome.

As it turned out, that patch sucked so I aborted the test and I need to
think about it a lot more.

> Yes, I meant exactly to disable that part, and doing it when kswapd is
> active is probably a good choice.
> I have a different idea for 2.6.33, though.
> If you have a reliable reproducer of the issue, can you test it on
> git://git.kernel.dk/linux-2.6-block.git branch for-2.6.33?
> It may already be unaffected, since we had various performance
> improvements there, but I think a better way to boost writeback is
> possible.
> 

I haven't tested the high-order allocation scenario yet but the results
as thing stands are below. There are four kernels being compared

1. with-low-latency               is 2.6.32-rc8 vanilla
2. with-low-latency-block-2.6.33  is with the for-2.6.33 from linux-block applied
3. with-low-latency-async-rampup  is with "[RFC,PATCH] cfq-iosched: improve async queue ramp up formula"
4. without-low-latency            is with low_latency disabled

SYSBENCH
                 sysbench-with       low-latency       low-latency  sysbench-without
                   low-latency      block-2.6.33      async-rampup       low-latency
           1  1266.02 ( 0.00%)   824.08 (-53.63%)  1265.15 (-0.07%)  1278.55 ( 0.98%)
           2  1182.58 ( 0.00%)  1226.42 ( 3.57%)  1223.03 ( 3.31%)  1379.25 (14.26%)
           3  1218.64 ( 0.00%)  1271.38 ( 4.15%)  1246.42 ( 2.23%)  1580.08 (22.87%)
           4  1212.11 ( 0.00%)  1257.84 ( 3.64%)  1325.17 ( 8.53%)  1534.17 (20.99%)
           5  1046.77 ( 0.00%)   981.71 (-6.63%)  1008.44 (-3.80%)  1552.48 (32.57%)
           6  1187.14 ( 0.00%)  1132.89 (-4.79%)  1147.18 (-3.48%)  1661.19 (28.54%)
           7  1179.37 ( 0.00%)  1183.61 ( 0.36%)  1202.49 ( 1.92%)   790.26 (-49.24%)
           8  1164.62 ( 0.00%)  1143.54 (-1.84%)  1184.56 ( 1.68%)   854.10 (-36.36%)
           9  1095.22 ( 0.00%)  1178.72 ( 7.08%)  1002.42 (-9.26%)  1655.04 (33.83%)
          10  1147.52 ( 0.00%)  1153.46 ( 0.52%)  1151.73 ( 0.37%)  1653.89 (30.62%)
          11   823.38 ( 0.00%)   820.64 (-0.33%)   754.15 (-9.18%)  1627.45 (49.41%)
          12   813.73 ( 0.00%)   791.44 (-2.82%)   848.32 ( 4.08%)  1494.63 (45.56%)
          13   898.22 ( 0.00%)   789.63 (-13.75%)   931.47 ( 3.57%)  1521.64 (40.97%)
          14   873.50 ( 0.00%)   938.90 ( 6.97%)   875.75 ( 0.26%)  1311.09 (33.38%)
          15   808.32 ( 0.00%)   979.88 (17.51%)   877.87 ( 7.92%)  1009.70 (19.94%)
          16   758.17 ( 0.00%)  1096.81 (30.87%)   881.23 (13.96%)   725.17 (-4.55%)

sysbench is helped by both both block-2.6.33 and async-rampup to some
extent. For many of the results, plain old disabling low_latency still
helps the most.

desktop-net-gitk
                     gitk-with       low-latency       low-latency      gitk-without
                   low-latency      block-2.6.33      async-rampup       low-latency
min            954.46 ( 0.00%)   570.06 (40.27%)   796.22 (16.58%)   640.65 (32.88%)
mean           964.79 ( 0.00%)   573.96 (40.51%)   798.01 (17.29%)   655.57 (32.05%)
stddev          10.01 ( 0.00%)     2.65 (73.55%)     1.91 (80.95%)    13.33 (-33.18%)
max            981.23 ( 0.00%)   577.21 (41.17%)   800.91 (18.38%)   675.65 (31.14%)

The changes for block in 2.6.33 make a massive difference here, notably
beating the disabling of low_latency.

IOZone
                           iozone-with           low-latency           low-latency        iozone-without
                           low-latency          block-2.6.33          async-rampup           low-latency
write-64               151212 ( 0.00%)       163359 ( 7.44%)       163359 ( 7.44%)       159856 ( 5.41%)
write-128              189357 ( 0.00%)       184922 (-2.40%)       202805 ( 6.63%)       206233 ( 8.18%)
write-256              219883 ( 0.00%)       211232 (-4.10%)       189867 (-15.81%)       223174 ( 1.47%)
write-512              224932 ( 0.00%)       222601 (-1.05%)       204459 (-10.01%)       220227 (-2.14%)
write-1024             227738 ( 0.00%)       226728 (-0.45%)       216009 (-5.43%)       226155 (-0.70%)
write-2048             227564 ( 0.00%)       224167 (-1.52%)       229387 ( 0.79%)       224848 (-1.21%)
write-4096             208556 ( 0.00%)       227707 ( 8.41%)       216908 ( 3.85%)       223430 ( 6.66%)
write-8192             219484 ( 0.00%)       222365 ( 1.30%)       217737 (-0.80%)       219389 (-0.04%)
write-16384            206670 ( 0.00%)       209355 ( 1.28%)       204146 (-1.24%)       206295 (-0.18%)
write-32768            203023 ( 0.00%)       205097 ( 1.01%)       199766 (-1.63%)       201852 (-0.58%)
write-65536            162134 ( 0.00%)       196670 (17.56%)       189975 (14.66%)       189173 (14.29%)
write-131072            68534 ( 0.00%)        69145 ( 0.88%)        64519 (-6.22%)        67417 (-1.66%)
write-262144            32936 ( 0.00%)        28587 (-15.21%)        31470 (-4.66%)        27750 (-18.69%)
write-524288            24044 ( 0.00%)        23560 (-2.05%)        23116 (-4.01%)        23759 (-1.20%)
rewrite-64             755681 ( 0.00%)       800767 ( 5.63%)       469931 (-60.81%)       755681 ( 0.00%)
rewrite-128            581518 ( 0.00%)       639723 ( 9.10%)       591774 ( 1.73%)       799840 (27.30%)
rewrite-256            639427 ( 0.00%)       710511 (10.00%)       666414 ( 4.05%)       659861 ( 3.10%)
rewrite-512            669577 ( 0.00%)       743788 ( 9.98%)       692017 ( 3.24%)       684954 ( 2.24%)
rewrite-1024           680960 ( 0.00%)       755195 ( 9.83%)       701422 ( 2.92%)       686182 ( 0.76%)
rewrite-2048           685263 ( 0.00%)       743123 ( 7.79%)       703445 ( 2.58%)       692780 ( 1.09%)
rewrite-4096           631352 ( 0.00%)       686776 ( 8.07%)       640007 ( 1.35%)       643266 ( 1.85%)
rewrite-8192           442146 ( 0.00%)       474089 ( 6.74%)       457768 ( 3.41%)       442624 ( 0.11%)
rewrite-16384          428641 ( 0.00%)       454857 ( 5.76%)       442896 ( 3.22%)       432613 ( 0.92%)
rewrite-32768          425361 ( 0.00%)       444206 ( 4.24%)       434472 ( 2.10%)       430568 ( 1.21%)
rewrite-65536          405183 ( 0.00%)       433898 ( 6.62%)       419843 ( 3.49%)       389242 (-4.10%)
rewrite-131072          66110 ( 0.00%)        58370 (-13.26%)        54342 (-21.66%)        58472 (-13.06%)
rewrite-262144          29254 ( 0.00%)        24665 (-18.61%)        25710 (-13.78%)        29306 ( 0.18%)
rewrite-524288          23812 ( 0.00%)        20742 (-14.80%)        22490 (-5.88%)        24543 ( 2.98%)
read-64                934589 ( 0.00%)      1160938 (19.50%)      1004538 ( 6.96%)       840903 (-11.14%)
read-128              1601534 ( 0.00%)      1869179 (14.32%)      1681806 ( 4.77%)      1280633 (-25.06%)
read-256              1255511 ( 0.00%)      1526887 (17.77%)      1304314 ( 3.74%)      1310683 ( 4.21%)
read-512              1291158 ( 0.00%)      1377278 ( 6.25%)      1336145 ( 3.37%)      1319723 ( 2.16%)
read-1024             1319408 ( 0.00%)      1306564 (-0.98%)      1368162 ( 3.56%)      1347557 ( 2.09%)
read-2048             1316016 ( 0.00%)      1394645 ( 5.64%)      1339827 ( 1.78%)      1347393 ( 2.33%)
read-4096             1253710 ( 0.00%)      1307525 ( 4.12%)      1247519 (-0.50%)      1251882 (-0.15%)
read-8192              995149 ( 0.00%)      1033337 ( 3.70%)      1016944 ( 2.14%)      1011794 ( 1.65%)
read-16384             883156 ( 0.00%)       905213 ( 2.44%)       905213 ( 2.44%)       897458 ( 1.59%)
read-32768             844368 ( 0.00%)       855213 ( 1.27%)       849609 ( 0.62%)       856364 ( 1.40%)
read-65536             816099 ( 0.00%)       839262 ( 2.76%)       835019 ( 2.27%)       826473 ( 1.26%)
read-131072            818055 ( 0.00%)       837369 ( 2.31%)       828230 ( 1.23%)       824351 ( 0.76%)
read-262144            827225 ( 0.00%)       839635 ( 1.48%)       840538 ( 1.58%)       835693 ( 1.01%)
read-524288             24653 ( 0.00%)        21387 (-15.27%)        20602 (-19.66%)        22519 (-9.48%)
reread-64             2329708 ( 0.00%)      2251544 (-3.47%)      1985134 (-17.36%)      1985134 (-17.36%)
reread-128            1446222 ( 0.00%)      1979446 (26.94%)      2009076 (28.02%)      2137031 (32.33%)
reread-256            1828508 ( 0.00%)      2006158 ( 8.86%)      1892980 ( 3.41%)      1879725 ( 2.72%)
reread-512            1521718 ( 0.00%)      1642783 ( 7.37%)      1508887 (-0.85%)      1579934 ( 3.68%)
reread-1024           1347557 ( 0.00%)      1422540 ( 5.27%)      1384034 ( 2.64%)      1375171 ( 2.01%)
reread-2048           1340664 ( 0.00%)      1413929 ( 5.18%)      1372364 ( 2.31%)      1350783 ( 0.75%)
reread-4096           1259592 ( 0.00%)      1324868 ( 4.93%)      1273788 ( 1.11%)      1284839 ( 1.96%)
reread-8192           1007285 ( 0.00%)      1033710 ( 2.56%)      1027159 ( 1.93%)      1011317 ( 0.40%)
reread-16384           891404 ( 0.00%)       910828 ( 2.13%)       916562 ( 2.74%)       905022 ( 1.50%)
reread-32768           850492 ( 0.00%)       859341 ( 1.03%)       856385 ( 0.69%)       862772 ( 1.42%)
reread-65536           836565 ( 0.00%)       852664 ( 1.89%)       852315 ( 1.85%)       847020 ( 1.23%)
reread-131072          844516 ( 0.00%)       862590 ( 2.10%)       854067 ( 1.12%)       853155 ( 1.01%)
reread-262144          851524 ( 0.00%)       860559 ( 1.05%)       864921 ( 1.55%)       860653 ( 1.06%)
reread-524288           24927 ( 0.00%)        21300 (-17.03%)        19748 (-26.23%)        22487 (-10.85%)
randread-64           1605256 ( 0.00%)      1605256 ( 0.00%)      1605256 ( 0.00%)      1775099 ( 9.57%)
randread-128          1179358 ( 0.00%)      1582649 (25.48%)      1511363 (21.97%)      1528576 (22.85%)
randread-256          1421755 ( 0.00%)      1599680 (11.12%)      1460430 ( 2.65%)      1310683 (-8.47%)
randread-512          1306873 ( 0.00%)      1278855 (-2.19%)      1243315 (-5.11%)      1281909 (-1.95%)
randread-1024         1201314 ( 0.00%)      1254656 ( 4.25%)      1190657 (-0.90%)      1231629 ( 2.46%)
randread-2048         1179413 ( 0.00%)      1227971 ( 3.95%)      1185272 ( 0.49%)      1190529 ( 0.93%)
randread-4096         1107005 ( 0.00%)      1160862 ( 4.64%)      1110727 ( 0.34%)      1116792 ( 0.88%)
randread-8192          894337 ( 0.00%)       924264 ( 3.24%)       912676 ( 2.01%)       899487 ( 0.57%)
randread-16384         783760 ( 0.00%)       800299 ( 2.07%)       793351 ( 1.21%)       791341 ( 0.96%)
randread-32768         740498 ( 0.00%)       743720 ( 0.43%)       741233 ( 0.10%)       743511 ( 0.41%)
randread-65536         721640 ( 0.00%)       727692 ( 0.83%)       726984 ( 0.74%)       728139 ( 0.89%)
randread-131072        715284 ( 0.00%)       722094 ( 0.94%)       717746 ( 0.34%)       720825 ( 0.77%)
randread-262144        709855 ( 0.00%)       706770 (-0.44%)       709133 (-0.10%)       714943 ( 0.71%)
randread-524288           394 ( 0.00%)          421 ( 6.41%)          418 ( 5.74%)          431 ( 8.58%)
randwrite-64           730988 ( 0.00%)       764288 ( 4.36%)       723111 (-1.09%)       730988 ( 0.00%)
randwrite-128          746459 ( 0.00%)       799840 ( 6.67%)       746459 ( 0.00%)       742331 (-0.56%)
randwrite-256          695778 ( 0.00%)       752329 ( 7.52%)       720041 ( 3.37%)       727850 ( 4.41%)
randwrite-512          666253 ( 0.00%)       722760 ( 7.82%)       667081 ( 0.12%)       691126 ( 3.60%)
randwrite-1024         651223 ( 0.00%)       697776 ( 6.67%)       663292 ( 1.82%)       659625 ( 1.27%)
randwrite-2048         655558 ( 0.00%)       691887 ( 5.25%)       665720 ( 1.53%)       664073 ( 1.28%)
randwrite-4096         635556 ( 0.00%)       662721 ( 4.10%)       643170 ( 1.18%)       642400 ( 1.07%)
randwrite-8192         467357 ( 0.00%)       491364 ( 4.89%)       476720 ( 1.96%)       469734 ( 0.51%)
randwrite-16384        413188 ( 0.00%)       427521 ( 3.35%)       417353 ( 1.00%)       417282 ( 0.98%)
randwrite-32768        404161 ( 0.00%)       411721 ( 1.84%)       404942 ( 0.19%)       407580 ( 0.84%)
randwrite-65536        379372 ( 0.00%)       397312 ( 4.52%)       386853 ( 1.93%)       381273 ( 0.50%)
randwrite-131072        21780 ( 0.00%)        16924 (-28.69%)        21177 (-2.85%)        19758 (-10.23%)
randwrite-262144         6249 ( 0.00%)         5548 (-12.64%)         6370 ( 1.90%)         6316 ( 1.06%)
randwrite-524288         2915 ( 0.00%)         2582 (-12.90%)         2871 (-1.53%)         2859 (-1.96%)
bkwdread-64           1141196 ( 0.00%)      1141196 ( 0.00%)      1004538 (-13.60%)      1141196 ( 0.00%)
bkwdread-128          1066865 ( 0.00%)      1386465 (23.05%)      1400936 (23.85%)      1101900 ( 3.18%)
bkwdread-256           877797 ( 0.00%)      1105556 (20.60%)      1105556 (20.60%)      1105556 (20.60%)
bkwdread-512          1133103 ( 0.00%)      1162547 ( 2.53%)      1175271 ( 3.59%)      1162547 ( 2.53%)
bkwdread-1024         1163562 ( 0.00%)      1206714 ( 3.58%)      1213534 ( 4.12%)      1195962 ( 2.71%)
bkwdread-2048         1163439 ( 0.00%)      1218910 ( 4.55%)      1204552 ( 3.41%)      1204552 ( 3.41%)
bkwdread-4096         1116792 ( 0.00%)      1175477 ( 4.99%)      1159922 ( 3.72%)      1150600 ( 2.94%)
bkwdread-8192          912288 ( 0.00%)       935233 ( 2.45%)       944695 ( 3.43%)       934724 ( 2.40%)
bkwdread-16384         817707 ( 0.00%)       824140 ( 0.78%)       832527 ( 1.78%)       829152 ( 1.38%)
bkwdread-32768         775898 ( 0.00%)       773714 (-0.28%)       785494 ( 1.22%)       787691 ( 1.50%)
bkwdread-65536         759643 ( 0.00%)       769924 ( 1.34%)       778780 ( 2.46%)       772174 ( 1.62%)
bkwdread-131072        763215 ( 0.00%)       769634 ( 0.83%)       773707 ( 1.36%)       773816 ( 1.37%)
bkwdread-262144        765491 ( 0.00%)       768992 ( 0.46%)       780876 ( 1.97%)       780021 ( 1.86%)
bkwdread-524288          3688 ( 0.00%)         3595 (-2.59%)         3577 (-3.10%)         3724 ( 0.97%)

The upcoming changes for 2.6.33 also help iozone in many cases, often by more
than just disabling low_latency. It has the occasional massive gain or loss
for the larger file sizes. I don't know why this is but as the big losses
appear to be mostly in the write-tests, I would guess that it's differences
in heavy-writer-throttling.

The only downside with block-2.6.33 is that there are a lot of patches in
there and doesn't help with the 2.6.32 release as such. I could do a reverse
bisect to see what helps the most in there but under ideal conditions, it'll
take 3 days to complete and I wouldn't be able to start until Monday as I'm
out of the country for the weekend. That's a bit late.

p.s. As a consequence of being out of the country, I also won't be able to
     respond to mail over the weekend.

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
