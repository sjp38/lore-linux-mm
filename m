Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 950ED6B0259
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 23:14:46 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id yy13so43015621pab.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:14:46 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id vt4si13746122pab.8.2016.02.18.20.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 20:14:45 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id q63so43777662pfb.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:14:45 -0800 (PST)
Date: Fri, 19 Feb 2016 13:16:01 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160219041601.GA820@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
 <CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
 <20160218095536.GA503@swordfish>
 <20160218101909.GB503@swordfish>
 <CAAmzW4NQt4jD2q92Hh4XFzt5fV=-i3J9eoxS3now6Y4Xw7OqGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4NQt4jD2q92Hh4XFzt5fV=-i3J9eoxS3now6Y4Xw7OqGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello Joonsoo,


On (02/19/16 10:19), Joonsoo Kim wrote:
[..]
> Where does 4096-3072/32 calculation comes from? I'm not familiar to recent
> change on zsmalloc such as huge class so can't understand this calculation.

I'm very sorry, it's utterly wrong. I got lost in translations,
0001/0002 zram-zsmalloc changes, and so on. no excuse, my bad.


> > well, patches 0001/0002 are trying to address this a bit, but the biggest
> > problem is still there: we have too many ->huge classes and they are a bit
> > far from good.
> 
> Agreed. And I agree your patchset, too.

thanks. I'll scratch 0003 for now and do more tests. the observation so far is that 'bad'
(from zram point of view, and zram should stop having opinion on that) compressions are
happening way more often than I'd though, and zram is taking extra step to make zsmalloc
worse.

so there are some questions now. why 32 byte was considered to be good enough as
MIN alloc, were "32 - 2 * ZS_SIZE_CLASS_DELTA" or "32 - 1 * ZS_SIZE_CLASS_DELTA" way
to rare to consider the K * ZS_SIZE_CLASS_DELTA memory waste there? etc., etc.


every "unleashed" ->huge class_size will give us a PAGE_SIZE memory saving every time
we store (class_size / (PAGE_SIZE - class_size_idx * ZS_SIZE_CLASS_DELTA) objects, and
every abandoned MIN alloc size will give us ZS_SIZE_CLASS_DELTA memory wastage every
time we store an object of that class. so the question is what's the ratio, X huge objects
that result in PAGE_SIZE saved or Y small objects that result in PAGE_SIZE wasted, because
we abandoned the class_size those objects used to belong to and now zsmalloc stores
those objects in available MIN class (which can be size + K * ZS_SIZE_CLASS_DELTA away).
well, object of smaller than 32 bytes sizes do this already.


I agree that having a MIN alloc of 128 or 192 or more bytes is a bad thing to do, sure.
... so we need to have some limit here. but that'll will take more time to settle down.


> Anyway, could you answer my other questions on original reply?

sorry, what questions? I certainly would love to answer. there is only one email in my
inbox, with the message-id CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com
is there an email that I missed or I misread your previous email and overlooked some
questions in there? I think we don't have too many spare bits left, so raising MIN alloc
seems to be the easiest option here.


... and *may be* losing 32 byte size is not so bad. we don't deal with random data size
compressions, it's PAGE_SIZE buffers that we compress (excluding partial IO case, which
is rarely seen, I believe, well unless you use FAT fs and may be some other). so can we
generally expect PAGE_SIZE buffer to be compressed to 32 bytes? taking a look at compression
ratios
http://catchchallenger.first-world.info/wiki/Quick_Benchmark:_Gzip_vs_Bzip2_vs_LZMA_vs_XZ_vs_LZ4_vs_LZO

I'd say that more likely it'll be in XXX-XXXX bytes range. not in 32-XX range, probably.
(well, it's questionable of course, depends on the data, etc. etc.)

more over, isn't it the case, that compression algorithm store headers in the compression
buffers (like the number of mathces, etc.), checksums, etc. etc.. looking at lzo1x_1_do_compress.

 20 static noinline size_t
 21 lzo1x_1_do_compress(const unsigned char *in, size_t in_len,
 22                     unsigned char *out, size_t *out_len,
 23                     size_t ti, void *wrkmem)
 24 {
 25         const unsigned char *ip;
 26         unsigned char *op;
 27         const unsigned char * const in_end = in + in_len;
 28         const unsigned char * const ip_end = in + in_len - 20;
 29         const unsigned char *ii;
 30         lzo_dict_t * const dict = (lzo_dict_t *) wrkmem;


what's that "in_len - 20"? a header size of 20 bytes? so to hit a class_size of 32 we
need to compress 4096 bytes to 12 bytes? that's quite unlikely...

hm...
http://cyan4973.github.io/lz4/lz4_Block_format.html
http://cyan4973.github.io/lz4/lz4_Frame_format.html



I extended zsmalloc stats reporting with "huge" column (jsut in case), and did some tests.
copy linux, run iozone, copy text files, etc. etc.

and the results are...

# cat /sys/kernel/debug/zsmalloc/zram0/classes 
  class  size  huge almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage
     0    32             0            0             0          0          0                1
     1    48             0            0             0          0          0                3
     2    64             3            0         31360      31355        490                1
     3    80             1            1         62781      62753       1231                1
     4    96             2            0          2176       2142         51                3
     5   112             0            2          1460       1413         40                2
     6   128             1            0          1312       1311         41                1
     7   144             2            2          1275       1191         45                3
     8   160             0            2          1020        991         40                2
     9   176             4            1          1209       1156         52                4
    10   192             2            0           960        938         45                3
    11   208             1            0           858        853         44                2
    12   224             3            0           949        940         52                4
    13   240             1            1           799        793         47                1
    14   256             1            0           944        941         59                1
    15   272             0            1          1005        994         67                1
    16   288             0            0          1036       1036         74                1
    17   304             1            0          1160       1156         87                3
    18   320             2            0          1479       1468        116                4
    19   336             0            1          1728       1720        144                1
    20   352             2            1          1863       1851        162                2
    21   368             1            1          2079       2072        189                1
    22   384             1            0          2240       2237        210                3
    23   400             1            1          2030       2022        203                1
    24   416             3            0          2028       2019        208                4
    25   432             2            0          1960       1955        210                3
    26   448             0            1          1881       1873        209                1
    27   464             2            0          1820       1813        208                4
    28   480             2            2          2023       1994        238                2
    29   496             3            2          1650       1620        200                4
    30   512             1            1          1544       1536        193                1
    31   528             0            1          1426       1416        184                4
    32   544             2            0          1200       1198        160                2
    33   560             1            0          1218       1217        168                4
    34   576             1            1          1197       1191        171                1
    35   592             0            1          1080       1069        160                4
    36   608             0            2          1220       1207        183                3
    37   624             0            1          1326       1316        204                2
    38   640             0            3          1520       1493        240                3
    40   672             1            1          2790       2785        465                1
    42   704             1            0          2852       2849        496                4
    43   720             1            0          1530       1529        270                3
    44   736             0            1          1463       1459        266                2
    46   768             0            1          2832       2827        531                3
    49   816             0            1          3820       3818        764                1
    51   848             1            1          2527       2521        532                4
    52   864             2            1          1316       1310        282                3
    54   896             3            1          2781       2775        618                2
    57   944             1            0          4381       4380       1011                3
    58   960             1            2          1530       1514        360                4
    62  1024             0            3          6576       6573       1644                1
    66  1088             1            1          7140       7131       1904                4
    67  1104             2            1          1859       1851        507                3
    71  1168             1            1          7245       7239       2070                2
    74  1216             1            0          5970       5969       1791                3
    76  1248             1            2          3796       3785       1168                4
    83  1360             0            3         18828      18824       6276                1
    91  1488             1            1         16456      16451       5984                4
    94  1536             0            0          4840       4840       1815                3
   100  1632             2            0          9665       9663       3866                2
   107  1744             2            4         12201      12187       5229                3
   111  1808             1            1          6822       6816       3032                4
   126  2048             0           13         29624      29611      14812                1
   144  2336             6           12         29302      29241      16744                4
   151  2448             1            9          7115       7087       4269                3
   168  2720             0           34          8547       8495       5698                2
   190  3072             0            9          6344       6332       4758                3
   202  3264             0            3           155        146        124                4
   254  4096 Y           0            0        632586     632586     632586                1



so BAD classes are 10 times more often than 64 bytes objects for example. and not all of 4096
objects actually deserve a full PAGE_SIZE (the test is with out 0001/0002 applied).



ok, this sets us on a  "do we need 32 and 48 bytes classes at all"  track?


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
