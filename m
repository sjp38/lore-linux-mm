Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEF06B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:42:09 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so53021452pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:42:09 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id qn10si13798135pdb.256.2015.01.30.06.42.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 06:42:07 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id et14so53107772pad.4
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:42:07 -0800 (PST)
Date: Fri, 30 Jan 2015 23:41:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150130144145.GA2840@blaptop>
References: <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <20150128145651.GB965@swordfish>
 <20150128233343.GC4706@blaptop>
 <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
 <20150129020139.GB9672@blaptop>
 <20150129022241.GA2555@swordfish>
 <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150129070835.GD2555@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

Hello, Sergey

On Thu, Jan 29, 2015 at 04:08:35PM +0900, Sergey Senozhatsky wrote:
> On (01/29/15 15:35), Minchan Kim wrote:
> >
> > As you told, the data was not stable.
> >
> yes. fread test was always slower, and the rest was mostly slower.
> 
> 
> > Anyway, when I read down_read implementation, it's one atomic instruction.
> > Hmm, it seems te be better for srcu_read_lock which does more things.
> >
> srcu looks havier, agree.

ffffffff8172c350 <down_read>:
ffffffff8172c350:       e8 7b 3f 00 00          callq  ffffffff817302d0 <__fentry__>
ffffffff8172c355:       55                      push   %rbp
ffffffff8172c356:       48 89 e5                mov    %rsp,%rbp
ffffffff8172c359:       53                      push   %rbx
ffffffff8172c35a:       48 89 fb                mov    %rdi,%rbx
ffffffff8172c35d:       48 83 ec 08             sub    $0x8,%rsp
ffffffff8172c361:       e8 9a e0 ff ff          callq  ffffffff8172a400 <_cond_resched>
ffffffff8172c366:       48 89 d8                mov    %rbx,%rax
ffffffff8172c369:       f0 48 ff 00             lock incq (%rax)
ffffffff8172c36d:       79 05                   jns    ffffffff8172c374 <down_read+0x24>
ffffffff8172c36f:       e8 5c e7 c4 ff          callq  ffffffff8137aad0 <call_rwsem_down_read_failed>
ffffffff8172c374:       48 83 c4 08             add    $0x8,%rsp
ffffffff8172c378:       5b                      pop    %rbx
ffffffff8172c379:       5d                      pop    %rbp
ffffffff8172c37a:       c3                      retq   


ffffffff810eeec0 <__srcu_read_lock>:
ffffffff810eeec0:       e8 0b 14 64 00          callq  ffffffff817302d0 <__fentry__>
ffffffff810eeec5:       48 8b 07                mov    (%rdi),%rax
ffffffff810eeec8:       55                      push   %rbp
ffffffff810eeec9:       48 89 e5                mov    %rsp,%rbp
ffffffff810eeecc:       83 e0 01                and    $0x1,%eax
ffffffff810eeecf:       48 63 d0                movslq %eax,%rdx
ffffffff810eeed2:       48 8b 4f 08             mov    0x8(%rdi),%rcx
ffffffff810eeed6:       65 48 ff 04 d1          incq   %gs:(%rcx,%rdx,8)
ffffffff810eeedb:       0f ae f0                mfence 
ffffffff810eeede:       48 83 c2 02             add    $0x2,%rdx
ffffffff810eeee2:       48 8b 4f 08             mov    0x8(%rdi),%rcx
ffffffff810eeee6:       65 48 ff 04 d1          incq   %gs:(%rcx,%rdx,8)
ffffffff810eeeeb:       5d                      pop    %rbp
ffffffff810eeeec:       c3                      retq   

Yes, __srcu_read_lock is a little bit heavier but the number of instruction
are not too much difference to make difference 10%. A culprit is
__cond_resched but I don't think, either because our test was CPU intensive
soS I don't think schedule latency affects total bandwidth.

More cuprit is your data pattern.
It seems you didn't use scramble_buffers=0, zero_buffers in fio so that
fio fills random data pattern so zram bandwidth could be different by
compression/decompression ratio.

I did test your fio script adding above options with my 4 CPU real machine
(NOTE, ubuntu fio is old so that it doesn't work well above two options
so I should update fio recently which solves it perfectly)

Another thing about fio is it seems loops option works with write test
with overwrite=1 options while read test doesn't work so that I should
use perf stat -r options to verify stdev.

In addition, I passed first test to remove noise as creating files
and increased testsize as 1G from 400m

1) randread

= vanilla =

 Performance counter stats for 'fio test-fio-randread.txt' (10 runs):

       4713.879241      task-clock (msec)         #    3.160 CPUs utilized            ( +-  0.62% )
             1,131      context-switches          #    0.240 K/sec                    ( +-  2.83% )
                23      cpu-migrations            #    0.005 K/sec                    ( +-  4.40% )
            15,767      page-faults               #    0.003 M/sec                    ( +-  0.03% )
    15,134,497,088      cycles                    #    3.211 GHz                      ( +-  0.15% ) [83.36%]
    10,763,665,604      stalled-cycles-frontend   #   71.12% frontend cycles idle     ( +-  0.22% ) [83.34%]
     6,896,294,076      stalled-cycles-backend    #   45.57% backend  cycles idle     ( +-  0.29% ) [66.67%]
     9,898,608,791      instructions              #    0.65  insns per cycle        
                                                  #    1.09  stalled cycles per insn  ( +-  0.07% ) [83.33%]
     1,852,167,485      branches                  #  392.918 M/sec                    ( +-  0.07% ) [83.34%]
        14,864,143      branch-misses             #    0.80% of all branches          ( +-  0.16% ) [83.34%]

       1.491813361 seconds time elapsed                                          ( +-  0.62% )

= srcu =

 Performance counter stats for 'fio test-fio-randread.txt' (10 runs):

       4752.790715      task-clock (msec)         #    3.166 CPUs utilized            ( +-  0.48% )
             1,179      context-switches          #    0.248 K/sec                    ( +-  1.56% )
                26      cpu-migrations            #    0.005 K/sec                    ( +-  3.91% )
            15,764      page-faults               #    0.003 M/sec                    ( +-  0.02% )
    15,263,869,915      cycles                    #    3.212 GHz                      ( +-  0.25% ) [83.32%]
    10,935,658,177      stalled-cycles-frontend   #   71.64% frontend cycles idle     ( +-  0.38% ) [83.33%]
     7,067,290,320      stalled-cycles-backend    #   46.30% backend  cycles idle     ( +-  0.46% ) [66.64%]
     9,896,513,423      instructions              #    0.65  insns per cycle        
                                                  #    1.11  stalled cycles per insn  ( +-  0.07% ) [83.33%]
     1,847,612,285      branches                  #  388.743 M/sec                    ( +-  0.07% ) [83.38%]
        14,814,815      branch-misses             #    0.80% of all branches          ( +-  0.24% ) [83.37%]

       1.501284082 seconds time elapsed                                          ( +-  0.50% )

srcu is worse as 0.63% but the difference is really marginal.

2) randwrite

= vanilla =

 Performance counter stats for 'fio test-fio-randwrite.txt' (10 runs):

       6283.823490      task-clock (msec)         #    3.332 CPUs utilized            ( +-  0.44% )
             1,536      context-switches          #    0.245 K/sec                    ( +-  2.10% )
                25      cpu-migrations            #    0.004 K/sec                    ( +-  3.79% )
            15,914      page-faults               #    0.003 M/sec                    ( +-  0.02% )
    20,408,942,915      cycles                    #    3.248 GHz                      ( +-  0.40% ) [83.34%]
    14,398,424,739      stalled-cycles-frontend   #   70.55% frontend cycles idle     ( +-  0.62% ) [83.36%]
     9,513,822,555      stalled-cycles-backend    #   46.62% backend  cycles idle     ( +-  0.62% ) [66.65%]
    13,507,376,783      instructions              #    0.66  insns per cycle        
                                                  #    1.07  stalled cycles per insn  ( +-  0.05% ) [83.36%]
     3,155,423,934      branches                  #  502.150 M/sec                    ( +-  0.05% ) [83.34%]
        18,381,090      branch-misses             #    0.58% of all branches          ( +-  0.16% ) [83.34%]

       1.885926070 seconds time elapsed                                          ( +-  0.61% )

= srcu =

 Performance counter stats for 'fio test-fio-randwrite.txt' (10 runs):

       6152.997119      task-clock (msec)         #    3.304 CPUs utilized            ( +-  0.29% )
             1,422      context-switches          #    0.231 K/sec                    ( +-  3.45% )
                28      cpu-migrations            #    0.004 K/sec                    ( +-  7.47% )
            15,921      page-faults               #    0.003 M/sec                    ( +-  0.02% )
    19,862,315,430      cycles                    #    3.228 GHz                      ( +-  0.09% ) [83.33%]
    13,872,541,761      stalled-cycles-frontend   #   69.84% frontend cycles idle     ( +-  0.12% ) [83.34%]
     9,074,883,552      stalled-cycles-backend    #   45.69% backend  cycles idle     ( +-  0.19% ) [66.71%]
    13,494,854,651      instructions              #    0.68  insns per cycle        
                                                  #    1.03  stalled cycles per insn  ( +-  0.03% ) [83.37%]
     3,148,938,955      branches                  #  511.773 M/sec                    ( +-  0.04% ) [83.33%]
        17,701,249      branch-misses             #    0.56% of all branches          ( +-  0.23% ) [83.34%]

       1.862543230 seconds time elapsed                                          ( +-  0.35% )

srcu is better as 1.24% is better.

3) randrw

= vanilla =

 Performance counter stats for 'fio test-fio-randrw.txt' (10 runs):

       5609.976477      task-clock (msec)         #    3.249 CPUs utilized            ( +-  0.34% )
             1,407      context-switches          #    0.251 K/sec                    ( +-  0.96% )
                25      cpu-migrations            #    0.004 K/sec                    ( +-  5.37% )
            15,906      page-faults               #    0.003 M/sec                    ( +-  0.05% )
    18,090,560,346      cycles                    #    3.225 GHz                      ( +-  0.35% ) [83.36%]
    12,885,393,954      stalled-cycles-frontend   #   71.23% frontend cycles idle     ( +-  0.53% ) [83.33%]
     8,570,185,547      stalled-cycles-backend    #   47.37% backend  cycles idle     ( +-  0.59% ) [66.67%]
    11,771,620,352      instructions              #    0.65  insns per cycle        
                                                  #    1.09  stalled cycles per insn  ( +-  0.05% ) [83.35%]
     2,508,014,871      branches                  #  447.063 M/sec                    ( +-  0.05% ) [83.34%]
        18,585,638      branch-misses             #    0.74% of all branches          ( +-  0.23% ) [83.35%]

       1.726691239 seconds time elapsed                                          ( +-  0.40% )

= srcu =

       5475.312828      task-clock (msec)         #    3.246 CPUs utilized            ( +-  0.59% )
             1,399      context-switches          #    0.255 K/sec                    ( +-  1.46% )
                24      cpu-migrations            #    0.004 K/sec                    ( +-  6.27% )
            15,916      page-faults               #    0.003 M/sec                    ( +-  0.04% )
    17,583,197,041      cycles                    #    3.211 GHz                      ( +-  0.11% ) [83.33%]
    12,352,657,985      stalled-cycles-frontend   #   70.25% frontend cycles idle     ( +-  0.16% ) [83.33%]
     8,173,164,212      stalled-cycles-backend    #   46.48% backend  cycles idle     ( +-  0.19% ) [66.70%]
    11,780,176,340      instructions              #    0.67  insns per cycle        
                                                  #    1.05  stalled cycles per insn  ( +-  0.05% ) [83.36%]
     2,506,722,383      branches                  #  457.823 M/sec                    ( +-  0.06% ) [83.35%]
        18,436,877      branch-misses             #    0.74% of all branches          ( +-  0.18% ) [83.32%]

       1.686877512 seconds time elapsed                                          ( +-  0.43% )

srcu is better as 2.3%

Srcu is better than down_read but I don't believe either because when I
did perf record, [up|down]_read and srcu_read_[lock|unlock] is really
minor (about 0.5%) so that I think it's really marginal.
(for example, if we removes srcu_read_[un]lock totally, we just enhance
about 1%) So, I don't think it's worth.

Okay, if you concerns on the data still, how about this?
Even, it would be smaller instructions than [up|down]_read so I guess
it could remove your performance concern. But I don't believe
it could make significant difference, either.
Hope it addresses your concern.

Thanks.
