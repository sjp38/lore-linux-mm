Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 714C86B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 04:43:59 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so88783551pad.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 01:43:59 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id hm17si18924316pad.218.2015.09.07.01.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 01:43:57 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so90981784pac.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 01:43:57 -0700 (PDT)
Date: Mon, 7 Sep 2015 17:44:37 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150907084437.GA27956@swordfish>
References: <20150903005115.GA27804@redhat.com>
 <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
 <20150903060247.GV1933@devil.localdomain>
 <20150903122949.78ee3c94@redhat.com>
 <20150904063528.GA29320@swordfish>
 <CA+55aFxOR06BiyH9nfFXzidFGr77R_BGp_xypjFQJSnv5c+_-g@mail.gmail.com>
 <20150904075945.GA31503@swordfish>
 <CA+55aFzs78Y0LS2FJG7Mrh6KBFxVnsBGSAySoi7SpR+EmmGpLg@mail.gmail.com>
 <20150905020907.GA1431@swordfish>
 <CA+55aFw609MpnZPdecjxHxLRQsHp2fM+vUj0KtHPC9sTm78FRw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Content-Disposition: inline
In-Reply-To: <CA+55aFw609MpnZPdecjxHxLRQsHp2fM+vUj0KtHPC9sTm78FRw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Dave Chinner <dchinner@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On (09/05/15 13:33), Linus Torvalds wrote:
> > ... And those are sort of interesting. I was expecting to see more
> > diverged behaviours.
> >
> > Attached.


Hello, sorry for long reply.


> So I'm not sure how really conclusive these graphs are, but they are
> certainly fun to look at. So I have a few reactions:
> 
>   - that 'nomerge' spike at roughly 780s is interesting. I wonder why
> it does that.
> 

Please find some stats below (with TOP 5 slabs). ~780s looks like the
time when glibc build script begins to package glibc (gzip, xz...).


>  - it would be interesting to see - for example - which slabs are the
> top memory users, and not _just_ the total (it could clarify the
> spike, for example). That's obviously something that works much better
> for the no-merge case, but could your script be changed to show (say)
> the "top 5 slabs". Showing all of them would probably be too messy,
> but "top 5" could be interesting.


OFFTOP: Capturing is not a problem; visualizing -- is. With a huge number of samples
the graph quickly becomes impossible to read. We have different N `top' slabs
after every measurement, labeling them on a graph is a bit messy. So my script right
now just picks the first slab (most Memory Used or biggest Loss value) per sample
(e.g. every second) and does something like this (in png):

  20 +-+---+------------+------------+------------+---+-+
     |     +            +            +            +     |
     |            +------------+           SIZE +-----+ |
  18 +-+          |            |           LOSS +-----+-+
     |            |            |                        |
     |            |            |                        |
     |            |            |                        |
  16 +-+          |            |                      +-+
     |            |            |                        |
     |------------+            |                        |
  14 +-+          |            |                      +-+
     |            |            |                        |
     |            |            |           +------------|
     |            |            |           |            |
  12 +-+          |------------|           |          +-+
     |            |            |           |            |
     |            |            |           |            |
  10 +-+          |            |-----------+          +-+
     |            |            |           |            |
     |            |            |           |            |
     |            |            |           |            |
   8 +-+----------|            |           |          +-+
     |            |            |           |------------|
     |     +      |     +      |     +     |      +     |
   6 +-+---+------------+------------+------------+---+-+
         slab1        slab2        slab3        slab1
                           samples

          ^            ^            ^            ^
          1s           2s           3s           4s ... (<< not part of the graph)




BACK to spikes.

I modified `slabinfo' tool to report top N (5 in this case) slabs sorted by
Memory usage and by Loss, along with Slab totals (+report everything in bytes,
w/o the dynamic G/M/K scaling. well, techically Loss is `Space - Objects * Objsize'
and can be calculated from the existing output, but I'm lazy. Besides top N biggest
slabs and top N most fragmented ones do not necessarily overlap, so I print both
sets).


Some of the spikes. Samples are separated by "Sample #d".

Test
===============================================================================================
Sample -- 1 second. 98828288 -> 107409408 -> 100171776


Sample #408
Slabcache Totals
----------------
Slabcaches : 140      Aliases  :   0->0   Active: 105
Memory used: 98828288   # Loss   : 3872736   MRatio:     4%
# Objects  : 329484   # PartObj:    484   ORatio:     0%

Per Cache    Average         Min         Max       Total
---------------------------------------------------------
#Objects        3137          16       92313      329484
#Slabs            93           1        2367        9766
#PartSlab          0           0           8          57
%PartSlab         2%          0%         58%          0%
PartObjs           0           0         142         484
% PartObj         0%          0%         38%          0%
Memory        941221        4096    35258368    98828288
Used          904338        4096    33622848    94955552
Loss           36883           0     1635520     3872736

Per Object   Average         Min         Max
---------------------------------------------
Memory           289           8        8192
User             288           8        8192
Loss               1           0          64

Slabs sorted by size (5)
---------------------------------------------------------
Name                   Objects Objsize                Space Slabs/Part/Cpu  O/S O %Fr %Ef Flg
ext4_inode_cache         19368    1736             35258368       1072/0/4   18 3   0  95 a
dentry                   46200     288             13516800      1635/0/15   28 1   0  98 a
inode_cache              12150     864             11059200       665/0/10   18 2   0  94 a
buffer_head              92313     104              9695232       2363/0/4   39 0   0  99 a
radix_tree_node           6832     576              3997696        240/0/4   28 2   0  98 a

Slabs sorted by loss (5)
---------------------------------------------------------
ext4_inode_cache         19368    1736              1635520       1072/0/4   18 3   0  95 a
inode_cache              12150     864               561600       665/0/10   18 2   0  94 a
dentry                   46200     288               211200      1635/0/15   28 1   0  98 a
biovec-256                  46    4096               204800          7/7/5    8 3  58  47 A
task_struct                174    4928               125568        19/3/11    6 3  10  87 

Sample #409
Slabcache Totals
----------------
Slabcaches : 140      Aliases  :   0->0   Active: 105
Memory used: 107409408   # Loss   : 3782600   MRatio:     3%
# Objects  : 335908   # PartObj:    485   ORatio:     0%

Per Cache    Average         Min         Max       Total
---------------------------------------------------------
#Objects        3199          16       92742      335908
#Slabs            96           1        2378       10081
#PartSlab          0           0          39          67
%PartSlab         1%          0%         50%          0%
# Objects  : 335908   # PartObj:    485   ORatio:     0%
# Objects  : 335908   # PartObj:    485   ORatio:     0%

Per Cache    Average         Min         Max       Total
---------------------------------------------------------
#Objects        3199          16       92742      335908
#Slabs            96           1        2378       10081
#PartSlab          0           0          39          67
%PartSlab         1%          0%         50%          0%
PartObjs           0           0         274         485
% PartObj         0%          0%         38%          0%
Memory       1022946        4096    35422208   107409408
Used          986921        4096    33779088   103626808
Loss           36024           0     1643120     3782600

Per Object   Average         Min         Max
---------------------------------------------
Memory           310           8        8192
User             308           8        8192
Loss               1           0          64

Slabs sorted by size (5)
---------------------------------------------------------
Name                   Objects Objsize                Space Slabs/Part/Cpu  O/S O %Fr %Ef Flg
ext4_inode_cache         19458    1736             35422208       1077/0/4   18 3   0  95 a
dentry                   46620     288             13639680       1658/0/7   28 1   0  98 a
inode_cache              12150     864             11059200       665/0/10   18 2   0  94 a
buffer_head              92742     104              9740288      2367/0/11   39 0   0  99 a
biovec-256                2128    4096              8749056        263/0/4    8 3   0  99 A

Slabs sorted by loss (5)
---------------------------------------------------------
ext4_inode_cache         19458    1736              1643120       1077/0/4   18 3   0  95 a
inode_cache              12150     864               561600       665/0/10   18 2   0  94 a
filp                      2169     432               267216      134/39/13   18 1  26  77 A
dentry                   46620     288               213120       1658/0/7   28 1   0  98 a
task_struct                165    4928               104384        18/2/10    6 3   7  88 

Sample #410
Slabcache Totals
----------------
Slabcaches : 140      Aliases  :   0->0   Active: 105
Memory used: 100171776   # Loss   : 3975712   MRatio:     4%
# Objects  : 334759   # PartObj:    633   ORatio:     0%

Per Cache    Average         Min         Max       Total
---------------------------------------------------------
#Objects        3188          16       92859      334759
#Slabs            94           1        2381        9922
#PartSlab          0           0          12          74
%PartSlab         2%          0%         57%          0%
PartObjs           0           0         209         633
% PartObj         0%          0%         38%          0%
Memory        954016        4096    35618816   100171776
Used          916152        4096    33966576    96196064
Loss           37863           0     1652240     3975712

Per Object   Average         Min         Max
---------------------------------------------
Memory           289           8        8192
User             287           8        8192
Loss               1           0          64

Slabs sorted by size (5)
---------------------------------------------------------
Name                   Objects Objsize                Space Slabs/Part/Cpu  O/S O %Fr %Ef Flg
ext4_inode_cache         19566    1736             35618816       1083/0/4   18 3   0  95 a
dentry                   46788     288             13688832      1661/0/10   28 1   0  98 a
inode_cache              12150     864             11059200       665/0/10   18 2   0  94 a
buffer_head              92859     104              9752576      2371/0/10   39 0   0  99 a
radix_tree_node           6888     576              4030464        242/0/4   28 2   0  98 a

Slabs sorted by loss (5)
---------------------------------------------------------
ext4_inode_cache         19566    1736              1652240       1083/0/4   18 3   0  95 a
inode_cache              12150     864               561600       665/0/10   18 2   0  94 a
biovec-256                  54    4096               237568          8/8/6    8 3  57  48 A
dentry                   46788     288               213888      1661/0/10   28 1   0  98 a
task_struct                169    4928               182976        20/5/11    6 3  16  81 





Another test.
===============================================================================================

Sample -- 1 second.   251637760 -> 306782208 -> 252264448


Sample #426
Slabcache Totals
----------------
Slabcaches : 140      Aliases  :   0->0   Active: 107
Memory used: 251637760   # Loss   : 11002192   MRatio:     4%
# Objects  : 528119   # PartObj:   6437   ORatio:     1%

Per Cache    Average         Min         Max       Total
---------------------------------------------------------
#Objects        4935          11      114582      528119
#Slabs           164           1        4718       17594
#PartSlab          3           0         141         394
%PartSlab         4%          0%         65%          2%
PartObjs           1           0        2422        6437
% PartObj         2%          0%         42%          1%
Memory       2351754        4096   154599424   251637760
Used         2248930        3584   147428064   240635568
Loss          102824           0     7171360    11002192

Per Object   Average         Min         Max
---------------------------------------------
Memory           457           8        8192
User             455           8        8192
Loss               2           0          64

Slabs sorted by size (5)
---------------------------------------------------------
Name                   Objects Objsize                Space Slabs/Part/Cpu  O/S O %Fr %Ef Flg
ext4_inode_cache         84924    1736            154599424       4714/0/4   18 3   0  95 a
dentry                  114408     288             33472512       4080/0/6   28 1   0  98 a
buffer_head             114582     104             12034048       2934/0/4   39 0   0  99 a
inode_cache              12186     864             11091968       667/0/10   18 2   0  94 a
radix_tree_node          10388     576              6078464        367/0/4   28 2   0  98 a

Slabs sorted by loss (5)
---------------------------------------------------------
ext4_inode_cache         84924    1736              7171360       4714/0/4   18 3   0  95 a
inode_cache              12186     864               563264       667/0/10   18 2   0  94 a
dentry                  114408     288               523008       4080/0/6   28 1   0  98 a
kmalloc-128               4117     128               353664     160/141/55   32 0  65  59 
kmalloc-2048              1421    2048               202752       80/27/15   16 3  28  93 

Sample #427
Slabcache Totals
----------------
Slabcaches : 140      Aliases  :   0->0   Active: 107
Memory used: 306782208   # Loss   : 11304176   MRatio:     3%
# Objects  : 569050   # PartObj:   6538   ORatio:     1%

Per Cache    Average         Min         Max       Total
---------------------------------------------------------
#Objects        5318          11      114777      569050
#Slabs           187           1        4725       20096
#PartSlab          3           0         141         391
%PartSlab         3%          0%         65%          1%
PartObjs           1           0        2422        6538
% PartObj         1%          0%         42%          1%
Memory       2867123        4096   154828800   306782208
Used         2761476        3584   147646800   295478032
Loss          105646           0     7182000    11304176

Per Object   Average         Min         Max
---------------------------------------------
Memory           521           8        8192
User             519           8        8192
Loss               2           0          64

Slabs sorted by size (5)
---------------------------------------------------------
Name                   Objects Objsize                Space Slabs/Part/Cpu  O/S O %Fr %Ef Flg
ext4_inode_cache         85050    1736            154828800       4721/0/4   18 3   0  95 a
biovec-256               12416    4096             50954240       1550/3/5    8 3   0  99 A
dentry                  114548     288             33513472      4075/0/16   28 1   0  98 a
buffer_head             114777     104             12054528       2939/0/4   39 0   0  99 a
inode_cache              12186     864             11091968       667/0/10   18 2   0  94 a

Slabs sorted by loss (5)
---------------------------------------------------------
ext4_inode_cache         85050    1736              7182000       4721/0/4   18 3   0  95 a
inode_cache              12186     864               563264       667/0/10   18 2   0  94 a
dentry                  114548     288               523648      4075/0/16   28 1   0  98 a
kmalloc-128               4117     128               353664     160/141/55   32 0  65  59 
bio-0                    12852     176               244800       589/0/23   21 0   0  90 A

Sample #428
Slabcache Totals
----------------
Slabcaches : 140      Aliases  :   0->0   Active: 107
Memory used: 252264448   # Loss   : 11537008   MRatio:     4%
# Objects  : 529408   # PartObj:   8649   ORatio:     1%

Per Cache    Average         Min         Max       Total
---------------------------------------------------------
#Objects        4947          11      115947      529408
#Slabs           165           1        4725       17655
#PartSlab          5           0         141         566
%PartSlab         5%          0%         65%          3%
PartObjs           1           0        2422        8649
% PartObj         2%          0%         42%          1%
Memory       2357611        4096   154828800   252264448
Used         2249789        3584   147646800   240727440
Loss          107822           0     7182000    11537008

Per Object   Average         Min         Max
---------------------------------------------
Memory           456           8        8192
User             454           8        8192
Loss               2           0          64

Slabs sorted by size (5)
---------------------------------------------------------
Name                   Objects Objsize                Space Slabs/Part/Cpu  O/S O %Fr %Ef Flg
ext4_inode_cache         85050    1736            154828800       4721/0/4   18 3   0  95 a
dentry                  114660     288             33546240      4075/0/20   28 1   0  98 a
buffer_head             115947     104             12177408      2942/0/31   39 0   0  99 a
inode_cache              12186     864             11091968       667/0/10   18 2   0  94 a
radix_tree_node          10444     576              6111232        369/0/4   28 2   0  98 a

Slabs sorted by loss (5)
---------------------------------------------------------
ext4_inode_cache         85050    1736              7182000       4721/0/4   18 3   0  95 a
inode_cache              12186     864               563264       667/0/10   18 2   0  94 a
dentry                  114660     288               524160      4075/0/20   28 1   0  98 a
filp                      3572     432               447552     227/113/16   18 1  46  77 A
kmalloc-128               4117     128               353664     160/141/55   32 0  65  59 




Attached some graphs for NOMERGE kernel. So far, I haven't seen those spikes
for 'merge' kernel.


>  - assuming the times are comparable, it looks like 'merge' really is
> noticeably faster. But that might just be noise too, so this may not
> be real data.
>
>  - regardless of how meaningful the graphs are, and whether they
> really tell us anything, I do like the concept, and I'd love to see
> people do things like this more often. Visualization to show behavior
> is great.
>
> That last point in particular means that if you scripted this and your
> scripts aren't *too* ugly and not too tied to your particular setup, I
> think it would perhaps not be a bad idea to encourage plots like this
> by making those kinds of scripts available in the kernel tree.  That's
> particularly true if you used something like the tools/testing/ktest/
> scripts to run these things automatically (which can be a *big* issue
> to show that something is actually stable across multiple boots, and
> see the variance).

Oh, that's a good idea. I didn't use tools/testing/ktest/, it's a bit too
massive for my toy script. I have some modifications to slabinfo and a rather
ugly script to parse files and feed them to gnuplot (and yes, I use gnuplot
for plotting). slabinfo patches are not entirely dumb and close to being ready
(well.. except that I need to clean up all those %6s sprintfs that worked fine
for dynamically scalled sizes and do not work so nicely for sizes in bytes). I
can send them out later. Less sure about the script (bash) tho. In a nutshell
it's just a number of
     grep | awk > FOO; gnuplot ... FOO

So I'll finish some plotting improvements first (not ready yet) and then
I'll take a look how quickly I can land it (rewrite in perl) in
tools/testing/ktest/.

> So maybe these graphs are meaningful, and maybe they aren't. But I'd
> still like to see more of them ;)

Thanks.

	-ss

--+HP7ph2BbKc20aGI
Content-Type: image/png
Content-Disposition: attachment; filename="nomerge-mm-loss-usage-1.png"
Content-Transfer-Encoding: base64

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
h5JeNgbvjdPnCF4YteTreblSMCvIft37edTFce64S8ON3/KPUrumPYUmfxYHwYvHiqTdef1z
zFymGH7fTruTjcH7970awp+HyPe+oh4mm+vsYwQvHisWvOdpZoHIFbHb7mRj8P715ZrLLxiz
M7oRsOlX1I1zTTK+7YbJZp/9SoIXj5XIvfP0f1Cy64i3/euI9zqpuwfBm35FMz7Rz8vHqngp
jFPts19K8OKxQsHLhK6cna5AMc/x/m1ZQ+uvgrd/tXqUXY2bfkXlXNW2/cd5Ynla1ZDfI43g
xWOHByBTuqJ2WdVQj8Hb3ppfzX/dOGC9uPfeZdu2XxGmd2uXwfH8UHbcTfDisRcj8OXkJHJV
7XOV4ab//6pzf1rUMM3mXtazmSfw0xB63HZy+xX1nK/NPM6eRrwtI1686ODgJXdl7bI72Twt
2/z1pOGrOd7pIN18cxrNJhv9rl/RzfctCTzOdIT8oJngxWNHBS8XZle3z14NVed909V//8LL
4O1DtPYxwqdxbzeEarOOYdevWPK1Te7yTXPj/DmCF499Pni5RjCisnl0FbzVsqhhGs7GyYY6
2fcmDd52uWtZ1xCjN78cguDFYx8P3jP76yJ6P4+qOv/5M66CN84TtyHExQtjfsYDduncwfoV
62zwjf3ItghePPZiKj7zVefpA7mL0y4nUPj858+4nmqY5yv8PLtQuc3cAcGLD/pw8BK6mLyX
R6HnfJjVfz1z7fapbunEbZqr+amGJ95qnsL4W4HQ8lrwPvNVnCaBwS5B5N2FP26Sczszl4nb
sD2Jbf2KZj249sw4m8TFY58KXk6TwNa+wZvfJuG2u8E7ftI4nwZrdjnZM3FP8OKxzwQvQ11c
2neO968ug7f188YL8zC2cj74ZJI33DmB4n6Zr1cJGfsHL6t1kbPDJjlv7MF7NeJdjqlNp0yE
OM/QJpMN4eqU4fDc9usELx7bO3gJXeTtsBH6G1edSIK3GU57q8blZPU8vTCOZrt1VJ18Rdcn
7/DUp5Kf4MVjLwbvrflbYhc37LEfr69evb5wEqPTwbRqM1tcTXs+rpMN97aFvF/miyVCyb7B
S+7ilj32442rGeqXvvY6eE9tF88+G4+bLdudrZMNm8mJuBG6z17o5xrBi8d2C152YsBdO+RR
qIbsfWfK4QAELx7bJ3jJXDyyTx7FYWo/+LScvQQvHtsleEldPLRbHrXD5pCvT/d+GsGLx94P
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

--+HP7ph2BbKc20aGI
Content-Type: image/png
Content-Disposition: attachment; filename="nomerge-mm-loss-usage-2.png"
Content-Transfer-Encoding: base64

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
O7I7JC529MM83S+ksscb70YZlqaAdca3wbo6nWx15/M7BC+2NU4UI2+/mcbgDWvTvqL30ySz
nLbdkM6+OTK8WEDxEsGLbZG3X09j8K5foWc6p1aWTIQ0zhCbwYbwsGQ4PN3IbIHgxaYI3e+n
MXjNtBuOtem+SzuLpdNtaTqZrcMLuTfbz4MNzZm0fkje8dBPRhoIXmyJ3u4VKAzeYBopcsvJ
tLqCIm+q25Vh4Hmw4dW2kC8RvNgOqXsJCoM3PgneW+zT6rOuHmTrjbW5Y2kjdP9kPto9ghdb
obt7EQqD93BqCsW+SN3rIHj3p6ZQ7InUvRKCd39qCsWOiN1LIXj3p6ZQ7IjgvRSCd39qCsV+
yN1rIXj3p6ZQ7IfgvRaCd39qCsV+CN5rIXj3p6ZQ7IfgvRaCd39qCsV+CN5rIXj3p6ZQ7Ifg
vRaCd39qCsV+CN5rIXj3p6ZQ7IfgvRaCd39qCsV+CN5rIXj3p6ZQ7IfgvRaCd39qCsV+CN5r
IXj3p6ZQ7IfgvRaCd39qCsV+CN5rIXj3p6ZQ7IfgvRaCd39qCsV+CN5rIXj3p6ZQ7IfgvRaC
d39qCsV+CN5rIXj3p6ZQ7IfgvRaCd39qCsV+CN5rIXj3p6ZQ7IfgvZjzvqBq8khNodgPwXsx
BO/u1BSK3ZC7V0Pw7k5NodgNwXs1BO/u1BSK3RC8V0Pw7k5NodgNwXs1BO/u1BSK3RC8V0Pw
7k5NodgNwXs1BO/u1BSK3RC8V0Pw7k5NodgNwXs1BO/u1BSK3RC8V0Pw7k5NodgNwXs1BO/u
1BSK3RC8V0Pw7k5NodgNwXs1BO/u1BSK3RC8V0Pw7k5NodgNwXs1BO/u1BSK3RC8V0Pw7k5N
odgNwXs1BO/u1BSK3RC8l3Pal1RNHqkpFLsheC+H4N2bmkKxG4L3cgjevakpFLsheC+H4N2b
mkKxG4L3cgjevakpFLsheC+H4N2bmkKxG4L3cgjevakpFHshd6+H4N2bmkKxF4L3egjevakp
FHsheK/npzj8jdXkkZpCsReCF5tRk0dqCsVeCF5sRk0eqSkUeyF4sRk1eaSmUOyE3MV21OSR
mkKxE4IX27lUHoXeG9+H1ef+Wmg583nGCVCIwBce27lS8IYhdp03ZjV5zc/f3PLUk9s8AwXK
HPvdjEu7UvD2phv+7Ixbe/JKhQL4blfKI5/7usavPXmlQgF8tyvlUQ7eQPACkO1KeWSNi7fg
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
APhO/wN0dANPG29HhAAAAABJRU5ErkJggg==

--+HP7ph2BbKc20aGI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
