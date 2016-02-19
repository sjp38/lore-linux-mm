Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1E2830C3
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 23:44:49 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id e127so44240828pfe.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:44:49 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id vt4si13920464pab.8.2016.02.18.20.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 20:44:48 -0800 (PST)
Received: by mail-pa0-x22f.google.com with SMTP id fy10so43444073pac.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:44:48 -0800 (PST)
Date: Fri, 19 Feb 2016 13:46:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160219044604.GA16230@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
 <CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
 <20160218095536.GA503@swordfish>
 <20160218101909.GB503@swordfish>
 <CAAmzW4NQt4jD2q92Hh4XFzt5fV=-i3J9eoxS3now6Y4Xw7OqGg@mail.gmail.com>
 <20160219041601.GA820@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160219041601.GA820@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (02/19/16 13:16), Sergey Senozhatsky wrote:
> ok, this sets us on a  "do we need 32 and 48 bytes classes at all"  track?
> 

seems that lz4 defines a minimum length to be at least

 61 #define COPYLENGTH 8
 67 #define MINMATCH        4
 70 #define MFLIMIT         (COPYLENGTH + MINMATCH)
 71 #define MINLENGTH       (MFLIMIT + 1)

bytes.

and 32 bytes class still looks unreachable.

# cat /sys/kernel/debug/zsmalloc/zram0/classes 
  class  size  huge almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage
     0    32             0            0             0          0          0                1
     1    48            26            0         31488      31259        369                3
     2    64             1            0         61760      61756        965                1
     3    80             2            1          2295       2253         45                1
     4    96             4            0          2176       2127         51                3
     5   112             1            1          1387       1358         38                2
     6   128             0            1          1312       1281         41                1
     7   144             1            0          1105       1086         39                3
     8   160             2            2          1173       1137         46                2
     9   176             4            0          1023        995         44                4
    10   192             6            1           960        913         45                3
    11   208             1            1           897        883         46                2
    12   224             1            2           803        735         44                4
    13   240             2            1           799        785         47                1
    14   256             1            1           816        807         51                1
    15   272             1            1           765        758         51                1
    16   288             3            1           840        831         60                1
    17   304             2            1           960        940         72                3
    18   320             1            1          1020        999         80                4
    19   336             2            0          1104       1102         92                1
    20   352             4            1          1265       1247        110                2
    21   368             1            1          1287       1280        117                1
    22   384             2            0          1248       1242        117                3
    23   400             0            0          1380       1380        138                1
    24   416             1            0          1404       1403        144                4
    25   432             0            0          1400       1400        150                3
    26   448             1            0          1278       1277        142                1
    27   464             0            2          1295       1263        148                4
    28   480             4            0          1326       1319        156                2
    29   496             2            2          2343       2311        284                4
    30   512             0            0          1360       1360        170                1
    31   528             0            3          1395       1365        180                4
    32   544             2            1          1320       1306        176                2
    33   560             0            1          1218       1203        168                4
    34   576             0            0          1162       1162        166                1
    35   592             2            1          1053       1033        156                4
    36   608             2            2          1440       1424        216                3
    37   624             0            1          1664       1659        256                2
    38   640             1            1          1197       1186        189                3
    40   672             0            2          2292       2287        382                1
    42   704             3            0          2369       2365        412                4
    43   720             1            1          1207       1198        213                3
    44   736             1            1          1232       1227        224                2
    46   768             1            2          2336       2323        438                3
    49   816             0            0          3615       3615        723                1
    51   848             3            1          2185       2174        460                4
    52   864             1            1          1148       1141        246                3
    54   896             2            2          2889       2881        642                2
    57   944             2            0          3796       3794        876                3
    58   960             2            0          1428       1423        336                4
    62  1024             0            1          5604       5603       1401                1
    66  1088             0            1          6060       6047       1616                4
    67  1104             1            0          1661       1659        453                3
    71  1168             2            0          6440       6438       1840                2
    74  1216             4            0          5120       5115       1536                3
    76  1248             4            0          3536       3531       1088                4
    83  1360             0            1         15282      15281       5094                1
    91  1488             3            1         17897      17887       6508                4
    94  1536             3            1          5768       5762       2163                3
   100  1632             3            1         10275      10270       4110                2
   107  1744             1            1         11676      11673       5004                3
   111  1808             3            0          6714       6711       2984                4
   126  2048             0            2         27758      27756      13879                1
   144  2336             0            5         32823      32807      18756                4
   151  2448             3            2          9650       9642       5790                3
   168  2720             0            8         13341      13326       8894                2
   190  3072             0            3          7804       7799       5853                3
   202  3264             2            0           255        253        204                4
   254  4096 Y           0            0        636960     636960     636960                1

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
