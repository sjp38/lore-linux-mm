Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93BBBC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 03:01:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 090F220675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 03:01:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="sf6tcmEo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 090F220675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83FAB8E0003; Tue,  5 Mar 2019 22:01:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EFD08E0001; Tue,  5 Mar 2019 22:01:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6906C8E0003; Tue,  5 Mar 2019 22:01:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 33A8C8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 22:01:19 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 43so10117932qtz.8
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 19:01:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:subject:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=8MAEogDl/FExWMiULBUip8X7Z5JMIsMQ4SBw7koeufA=;
        b=KxGH+hYNkrcY8ZhEdZ+3fmDE6s6+I/MqfnaDh7uvwi5/aVR/ed4Z89e1Fg5LNpDxv0
         7LWQXYrPUwyR/VmPrPe2A024CECbVRUJxb9SgZNxhHCMvIYg38Eea2YgFRCT4vaFBvIM
         p23BsAr8sCu1LCiE88QcMFEl0r1kW4cNLR+28awxHEHGh0Nmjb8sS8zrDlsJ3DgX215R
         FfbEw5z+hSpIRbchpsIZeuJsniF6f6b0mjwsfeXrNq+DQ1Kj9didxxTN5nwETXX0kOM+
         fdThGd8dpFdIUmONAmOjvpbGjMmOx33ZpHhTLNDPzrOQ95Mhp8Jo4JBHwil0LuYpKWbr
         oAFQ==
X-Gm-Message-State: APjAAAU3HUFMLDg2yauGQYHfPW/t9nIRp1r/HgHDlkE7zkcfZpkUR2YM
	5TWWgnnBX9iSk3YdDNI6jICKndMH1+CuiPEzstoO8+Yz6HLmAj3dTR8OXeSURpRBLLaPNVku/DB
	ZXkBDMHSZBVyBsAOizvfeJpqIqUSDiult9QsbSg8xLc9njbB6uINb7PkQRanYD4Q+tFpF+wedSO
	evg2h34769epihRQiRgzIFUNTB/SWbo7SIbVplZokruLuAKouSeR6sJve+dhetInBC14XfwyZhH
	29TN8cr5RRTTH5HMtYWHmaBMmVPTrpIPPIWaVk4uNm3obetLMexHjgr/R5ttFmvhXfnQIuIkXm0
	4wVXE5ZFro/fv0HlFpkSv5p4N7AnW4X9gefG8zAnIpL22Ji+OQxCOQk2ybk6+iXn/2kgWnV3sqw
	a
X-Received: by 2002:ae9:ebd5:: with SMTP id b204mr4124261qkg.37.1551841278831;
        Tue, 05 Mar 2019 19:01:18 -0800 (PST)
X-Received: by 2002:ae9:ebd5:: with SMTP id b204mr4123970qkg.37.1551841272383;
        Tue, 05 Mar 2019 19:01:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551841272; cv=none;
        d=google.com; s=arc-20160816;
        b=ydglzreD/BRt3WEYbzUcEFD7WE/+spi6XSnS2DuZZ7zpsl8dRRd8bgYodzMGkf6ZNl
         h9mz2dV6pvZ+uj3s4Lgv6mR691sw5fnRSg9bOlyJBcAGrrxjwPu2CPzpd6PjC6xAdiG6
         Miuzjn8VJgjt68HUyfr/TFxJwB5pIjbycovDBn0hmnwBAQlMOB6MWLOUmTyM0oTUuwrL
         15aLMMtqvAhVbzJYZn/7iNCNNaGBNOsC354RGkalH+ve7KzXcjmgpI0IguFnAmXd9xyx
         S+Qi+Eb6gKiu/bERbx/w7p1SVvR1U8yMMNnp551TDdTlvVfKHI260TI15ZOJ+vCRNZ3a
         qM9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from
         :dkim-signature;
        bh=8MAEogDl/FExWMiULBUip8X7Z5JMIsMQ4SBw7koeufA=;
        b=zMxwhcOb6EZeIP74pMZxzRpwTlMGXhOhjT6xBsDX4Opaf8Maau7jxLCj+5PKwyg3cv
         b4edL2yhJYt5ZtHmCJE2OuE9FxnMt+Yyy39NeI5T9TPOtDYvel3Zft6iYFoao6FVl22+
         ksYOBQzqx55N7ikFo3t3qOMODjW2Ay+DLJn+jdT7hKaNZBf3bVWsRzG7qNMAQ+/mOY9p
         h8CvJbORJqBEmZ260E9dkAskIFahibqp58QfY2Fw3syS8HtWuhvvW69nqymeBh9i+Gp+
         Adti5aChIhJiKetowSHC0wf6ECgeXfBZhRmLOpMQ+OX856104XAWKyqDq0KQ0SV8r5il
         xWpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=sf6tcmEo;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z44sor362350qvg.49.2019.03.05.19.01.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 19:01:12 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=sf6tcmEo;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:subject:to:cc:references:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=8MAEogDl/FExWMiULBUip8X7Z5JMIsMQ4SBw7koeufA=;
        b=sf6tcmEoEJppxwCq2EQf5Zs/3nqZIqR0CLPfkfZOoH7tsBS2cPEaYbQ0bfwYNjwfnO
         KtAmqAOAY4akR3Q89bDKNHC+37CPvSzXP/k+w5tALwpEYC6EM9/H8ZjU/1R3R2AyFcz5
         0B4STzms/c9pOAxAflIk0NKbq1Fc5ue3GB7NU9JPYeuOBO8H496H9PCiQElh9xPdjU5G
         UfUpP8AHcs9ia4WLz3hbxmz39EhuC3YWJzQkEc26G6xLg3Bfm+jtqUHCng3cfp7dMKZo
         uIdCqlgPRJnsf7k1WU0I/wLR9nZsy4LYVZ7/2/bWkL3Ct7TiGDjjB0Fe0PJ0zUJhh9Ls
         2ctg==
X-Google-Smtp-Source: APXvYqzTsibM6U9mxtL/wUnh2MKq/d+Z0g2R6xM0beLS5oC+fSGHFHBSlu+FxmF3yQcXrfSfBWQhRA==
X-Received: by 2002:a0c:ecc5:: with SMTP id o5mr4671952qvq.106.1551841268064;
        Tue, 05 Mar 2019 19:01:08 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id r47sm271606qtc.48.2019.03.05.19.01.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 19:01:07 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: Re: low-memory crash with patch "capture a page under direct
 compaction"
To: Mel Gorman <mgorman@techsingularity.net>
Cc: vbabka@suse.cz, Linux-MM <linux-mm@kvack.org>
References: <604a92ae-cbbb-7c34-f9aa-f7c08925bedf@lca.pw>
 <20190305144234.GH9565@techsingularity.net> <1551798804.7087.7.camel@lca.pw>
 <20190305152759.GI9565@techsingularity.net>
Message-ID: <1d3a13fc-72b4-005a-7d73-2203b1ff25e4@lca.pw>
Date: Tue, 5 Mar 2019 22:01:03 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190305152759.GI9565@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-03-05 at 15:27 +0000, Mel Gorman wrote:
> > On Tue, Mar 05, 2019 at 10:13:24AM -0500, Qian Cai wrote:
>> > > On Tue, 2019-03-05 at 14:42 +0000, Mel Gorman wrote:
>>> > > > On Mon, Mar 04, 2019 at 10:55:04PM -0500, Qian Cai wrote:
>>>> > > > > Reverted the patches below from linux-next seems fixed a crash while>
>>>> > > > running
>>>> > > > > LTP
>>>> > > > > oom01.
>>>> > > > >
>>>> > > > > 915c005358c1 mm, compaction: Capture a page under direct compaction -fix
>>>> > > > > e492a5711b67 mm, compaction: capture a page under direct compaction
>>>> > > > >
>>>> > > > > Especially, just removed this chunk along seems fixed the problem.
>>>> > > > >
>>>> > > > > --- a/mm/compaction.c
>>>> > > > > +++ b/mm/compaction.c
>>>> > > > > @@ -2227,10 +2227,10 @@ compact_zone(struct compact_control *cc, struct
>>>> > > > > capture_control *capc)
>>>> > > > >                 }
>>>> > > > >
>>>> > > > >                 /* Stop if a page has been captured */
>>>> > > > > -               if (capc && capc->page) {
>>>> > > > > -                       ret = COMPACT_SUCCESS;
>>>> > > > > -                       break;
>>>> > > > > -               }
>>>> > > > >
>>> > > >
>>> > > > It's hard to make sense of how this is connected to the bug. The
>>> > > > out-of-bounds warning would have required page flags to be corrupted
>>> > > > quite badly or maybe the use of an uninitialised page. How reproducible
>>> > > > has this been for you? I just ran the test 100 times with UBSAN and page
>>> > > > alloc debugging enabled and it completed correctly.
>>> > > >
Well, 100 times would take a long time to run with swapping enabled.
BTW, if you are running the tests without a swap device, I just confirmed (tried
10 times) that it won't trigger it. It seems needing kswapd to play.
>> > >
>> > > I did manage to reproduce this every time by running oom01 within 3 tries on
>> > > this x86_64 server and was unable to reproduce on arm64 and ppc64le
>> servers> > so
>> > > far.
>> > >
> > 
> > Ok, so there is something specific about the machine or the kernel
> > config that is at play. You're seeing slub issues, page state issues
> > etc. Have you seen this on any other x86-based machine? Also please post
I have only one NUMA x86_64 server to test.
Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              48
On-line CPU(s) list: 0-47
Thread(s) per core:  2
Core(s) per socket:  12
Socket(s):           2
NUMA node(s):        2
Vendor ID:           GenuineIntel
CPU family:          6
Model:               63
Model name:          Intel(R) Xeon(R) CPU E5-2650L v3 @ 1.80GHz
Stepping:            2
CPU MHz:             2097.552
BogoMIPS:            3595.80
Virtualization:      VT-x
L1d cache:           32K
L1i cache:           32K
L2 cache:            256K
L3 cache:            30720K
NUMA node0 CPU(s):   0-11,24-35
NUMA node1 CPU(s):   12-23,36-47
> > your kernel config. Are you certain that removing the block from your
https://git.sr.ht/~cai/linux-debug/tree/master/config
> > first email avoids any issue triggering?
> > 
No, I tried again on the latest linux-next, and could trigger a memory
corruption below immediately with only that chunk of code removed.
However, I am still trigger NONE of these after reverted the above two commits.
This has been tested more than 10 times so far.
I don't understand this part.
@@ -2279,14 +2286,24 @@ static enum compact_result compact_zone_order(struct
zone *zone, int order, .ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY) }; + struct
capture_control capc = { + .cc = &cc, + .page = NULL, + }; + + if (capture) +
current->capture_control = &capc;
That check will always be true as it is,
struct page **capture;
*capture could be NULL, but not capture because in
__alloc_pages_direct_compact(), it does,
struct page *page = NULL;
[ 1337.354171] Tasks state (memory values in pages):
[ 1337.376691] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes
swapents oom_score_adj name
[ 1337.415473] [    842]     0   842    26405       18   212992      422
-1000 systemd-udevd
[ 1337.455205] [   1120]     0  1120    25103       44    94208       44
0 irqbalance
[ 1337.496195] [   1121]     0  1121    46184        9   368640      387
0 sssd
[ 1337.534072] [   1122]     0  1122    95328        0   245760      758
0 rngd
[ 1337.570370] [   1124]    81  1124    18353      104   167936       88
-900 dbus-daemon
[ 1337.609494] [   1125]     0  1125    97658       58   385024      545
0 NetworkManager
[ 1337.649637] [   1126]   998  1126  1325451        0   729088     2515
0 polkitd
[ 1337.687137] [   1134]   995  1134     7359        6    90112       68
0 chronyd
[ 1337.724754] [   1144]     0  1144    47800       17   385024      505
0 sssd_be
[ 1337.762143] [   1203]     0  1203    23592       22   208896      201
-1000 sshd
[ 1337.798337] [   1217]     0  1217     3780        0    69632       46
0 rhsmcertd
[ 1337.837743] [   1242]     0  1242    50092       66   417792      247
0 sssd_nss
[ 1337.875687] [   1254]     0  1254    23884       42   196608      204
0 systemd-logind
[ 1337.915916] [   1263]     0  1263    23263        1   221184      346
0 systemd
[ 1337.953124] [   1264]     0  1264     3917        0    65536       36
0 agetty
[ 1337.991199] [   1265]     0  1265     3275        0    69632       32
0 agetty
[ 1338.031884] [   1268]     0  1268    37093        0   307200      756
0 (sd-pam)
[ 1338.071161] [   1431]     0  1431    56279      135   192512      314
0 rsyslogd
[ 1338.110818] [   1467]     0  1467    37779        0   303104      293
0 sshd
[ 1338.147561] [   1477]     0  1477     9022       13   106496      207
0 crond
[ 1338.184215] [   1510]     0  1510     2424        0    65536       85
0 make
[ 1338.220461] [   1514]     0  1514     6312       39    90112       62
0 runtest.sh
[ 1338.260766] [   1530]     0  1530    37779        5   294912      289
0 sshd
[ 1338.297301] [   1537]     0  1537     6344       25    90112      138
0 bash
[ 1338.333662] [   1815]     0  1815    22774      849   196608        0
0 systemd-journal
[ 1338.375669] [   1822]     0  1822     2184        1    65536       21
0 oom01
[ 1338.413577] [   1823]     0  1823     2184        6    65536       25
0 oom01
[ 1338.451815] [   1831]     0  1831 37060791  3004590 40919040  2037460
0 oom01
[ 1338.490312] [   1882]     0  1882    18868       96   184320        0
0 sshd
[ 1338.530810] [   1884]     0  1884     6312       40    65536       61
0 runtest.sh
[ 1338.570643]
oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0-1,global_oom,task_memcg=/user.slice,task=oom01,pid=1831,uid=0
[ 1338.630662] Out of memory: Killed process 1831 (oom01)
total-vm:148243164kB, anon-rss:12018360kB, file-rss:0kB, shmem-rss:0kB
[ 1338.871046] pagealloc: memory corruption
[ 1338.888610] 00000000fe6aab78: 07 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1338.927858] 000000000e5b758b: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1338.967042] 000000007be27dd4: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.006041] 00000000adc52ca0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.049599] 000000001b14ef55: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.088801] 0000000085aaa5be: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.127998] 00000000bff7bf43: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.170213] 0000000021489d04: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.212549] 000000000830d1fc: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.253430] 000000009e7738ad: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.294248] 000000006ceefc4b: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.335126] 000000003c957eb9: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.376173] 000000007e1a9b3c: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.416998] 000000008360db50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.457628] 000000004382d7a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.498205] 000000005c7468cf: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.539740] 0000000007128978: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.583374] 00000000ef6a7c8d: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.624196] 00000000fdb1a596: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.665038] 000000009d2b4871: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.705904] 00000000f64101ae: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.746724] 000000005932f1c3: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.787103] 000000006f387d61: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.827995] 00000000b4e9bac0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.868804] 000000003a67e0cc: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.909348] 00000000d1b415d7: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.950163] 000000006696703f: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1339.990887] 000000007236a552: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.031484] 00000000ced67fc2: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.074633] 00000000eacb00b5: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.115769] 00000000cd762b0f: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.156785] 000000002c5bed3a: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.197483] 00000000df97bd05: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.237216] 000000006c8bcd34: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.277982] 0000000056769a33: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.318833] 00000000b3a8b011: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.359718] 00000000fb93777f: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.400749] 00000000ed72f51b: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.441546] 000000000f0a9c06: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.483011] 0000000058acc3cd: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.523274] 00000000b4d019be: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.564549] 000000009f8786cc: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.607931] 00000000df5ef2ee: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.648340] 00000000702ccf47: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.688788] 0000000099b19e48: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.729510] 0000000039f02ec9: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.770114] 0000000083addea3: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.810756] 0000000037edee75: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.851188] 000000000e4c2e2d: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.891941] 000000008d149b07: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.932548] 00000000909f66ff: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1340.974102] 0000000081df28c7: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.014377] 00000000b84b7870: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.057578] 0000000010b3382a: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.101431] 0000000057ffa361: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.142096] 0000000038a61326: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.183669] 000000006587b87c: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.225377] 00000000ef60f1bf: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.267021] 00000000c744bb03: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.307789] 0000000044b4fdb1: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.348610] 00000000531f189e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.389665] 000000001b8a4714: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.433146] 000000004bffa794: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.473933] 000000009f2b6148: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.514885] 0000000042c62fd1: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.555589] 0000000059c01744: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.597952] 00000000478c3d29: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.639360] 000000000eea2248: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.679780] 00000000c5ed98a7: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.720502] 0000000074bbce1d: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.761500] 0000000097880cb2: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.802288] 000000008b79b1fb: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.843276] 00000000defe452a: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.884060] 00000000bde4c4b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.924744] 000000008e846c70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1341.965668] 000000007336d83e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.006371] 00000000eb55a3a2: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.047310] 00000000b1c967a3: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.089204] 00000000d2f1e1d9: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.133340] 0000000028b653d5: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.173945] 0000000049ee0f29: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.214806] 000000009444ab05: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.255680] 0000000023df52aa: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.296482] 000000001f3595e2: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.335955] 00000000f6b3d57b: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.376908] 000000002d4fb3ee: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.417942] 000000002c32aaa8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.458733] 000000000f7db7b7: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.497855] 000000008f107ca2: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.537396] 00000000ab15fa75: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.577357] 000000004f3e42cc: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.620410] 00000000ddcdfc4b: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.661380] 00000000006f449e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.702263] 00000000ed65b70a: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.743280] 00000000904810ad: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.783915] 000000004fab9e3c: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.824915] 000000002b2c24c2: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.865700] 000000006240fcfd: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.906510] 00000000257e52b5: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.947344] 00000000157a76e2: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1342.988142] 000000005475a4da: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.028494] 0000000069a7362e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.069200] 000000004ac4c37a: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.111084] 00000000d941b898: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.153683] 00000000cf25dfd6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.194468] 000000002d010c45: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.235185] 000000001f8523c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.276074] 0000000026283d91: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.316850] 00000000f8dc3d4c: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.357643] 00000000de3d6424: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.398590] 00000000ed7571c6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.439336] 000000000c87eccd: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.480140] 000000007610d962: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.520697] 000000008f8e1aa2: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.561460] 00000000fd77596e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.602090] 00000000389c7804: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.646002] 000000004737fa15: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.687710] 000000001e5634f1: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.728605] 00000000183f96e4: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.769326] 00000000b20a94b4: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.809754] 000000007bef215e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.850500] 00000000816c1095: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.891288] 00000000b28c77f6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.932026] 00000000a3305056: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1343.972942] 00000000c446739e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.013677] 00000000f5113aae: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.054482] 000000004da60f75: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.095128] 00000000467f0c89: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.137676] 00000000c7e72d81: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.181239] 00000000d41dfd91: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.222144] 0000000090dc57ca: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.262891] 00000000a0f8a9d6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.302856] 0000000047f123e5: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.343124] 0000000056e37cd5: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.383321] 0000000089111e42: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.423507] 00000000d71db9b3: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.462497] 00000000148c17ae: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.501416] 000000006075ced4: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.540392] 000000006aa48b77: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.579454] 000000005043d7f8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.618613] 0000000012833cdb: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.661629] 00000000055b9f9f: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.701222] 0000000052ce91c9: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.740252] 00000000b350a135: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.779144] 00000000bb07a85c: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.818149] 0000000081c6e075: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.857128] 00000000cba53c42: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.896097] 00000000d18e908a: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.934712] 00000000f0c0c0da: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1344.975040] 00000000de3dc587: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.014881] 00000000c89cf5dd: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.054538] 0000000014407b3f: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.093740] 000000000f63ef05: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.132836] 0000000034d2338e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.176310] 0000000062639f04: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.215712] 000000004a3abf19: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.254786] 0000000061600a22: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.294000] 00000000dc954953: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.333751] 000000002d41f5ad: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.372762] 0000000030f1d334: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.412011] 0000000029fdc061: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.451606] 0000000051767b56: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.490638] 000000008f9bc2dc: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.529637] 000000001f1014dd: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.568600] 00000000a4ddbf38: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.607936] 00000000b7ff4e85: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.646965] 00000000833025ba: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.691013] 0000000009442d5a: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.730149] 00000000f0c4b940: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.769263] 000000001c9e0352: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.808782] 000000005e255711: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.847775] 00000000d10d0f01: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.887154] 000000007ac060e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.926696] 00000000b4130121: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1345.965597] 0000000045f7e909: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.004777] 000000003960506e: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.044231] 000000005cd63cf7: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.083894] 0000000008fca843: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.123674] 000000004c10d2f6: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.162463] 00000000a8d87809: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.205525] 000000000425101d: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.244122] 00000000946a8e9c: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.282831] 000000000abd7e72: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.322372] 000000008b7d9850: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.361332] 00000000df8a3a2a: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.400825] 0000000042bc7e5a: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.441100] 00000000b9f9dbb4: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.480853] 00000000c34370c9: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.520052] 000000000a103ceb: 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00  ................
[ 1346.559063]
==================================================================
[ 1346.591444] BUG: KASAN: use-after-free in hex_dump_to_buffer+0xb23/0xb80
[ 1346.621622] Read of size 1 at addr ffff8881d21c0bd0 by task
kcompactd0/263
[ 1346.652610] 
[ 1346.659268] CPU: 25 PID: 263 Comm: kcompactd0 Tainted: G        W
5.0.0-next-20190305+ #50
[ 1346.702988] Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9,
BIOS U20 10/25/2017
[ 1346.741280] Call Trace:
[ 1346.752240]  dump_stack+0x62/0x9a
[ 1346.767064]  print_address_description.cold.2+0x9/0x28b
[ 1346.790596]  kasan_report.cold.3+0x7a/0xb5
[ 1346.828218]  __asan_report_load1_noabort+0x19/0x20
[ 1346.849644]  hex_dump_to_buffer+0xb23/0xb80
[ 1346.889066]  print_hex_dump+0xf5/0x180
[ 1346.979759]  kernel_poison_pages.cold.2+0x4f/0x89
[ 1347.001003]  post_alloc_hook+0x186/0x290
[ 1347.018600]  split_map_pages+0x1e5/0x530
[ 1347.094053]  compaction_alloc+0x1050/0x25f0
[ 1347.173674]  unmap_and_move+0x37/0x1e70
[ 1347.214386]  migrate_pages+0x2ca/0xb20
[ 1347.295869]  compact_zone.isra.2+0x19ee/0x3680
[ 1347.373747]  kcompactd_do_work+0x2dd/0x670
[ 1347.445953]  kcompactd+0x1d8/0x6c0
[ 1347.534669]  kthread+0x32c/0x3f0
[ 1347.585440]  ret_from_fork+0x35/0x40
[ 1347.601437] 
[ 1347.608134] The buggy address belongs to the page:
[ 1347.629255] page:ffffea0007487000 count:0 mapcount:-128
mapping:0000000000000000 index:0x1
[ 1347.665980] flags: 0x5fffe000000000()
[ 1347.682319] raw: 005fffe000000000 ffffea000694c008 ffffea000708fc08
0000000000000000
[ 1347.720574] raw: 0000000000000001 0000000000000003 00000000ffffff7f
0000000000000000
[ 1347.757115] page dumped because: kasan: bad access detected
[ 1347.805210] 
[ 1347.811839] Memory state around the buggy address:
[ 1347.833245]  ffff8881d21c0a80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff
[ 1347.865547]  ffff8881d21c0b00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff
[ 1347.897911] >ffff8881d21c0b80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff
[ 1347.930255]                                                  ^
[ 1347.956325]  ffff8881d21c0c00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff
[ 1347.988841]  ffff8881d21c0c80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff
[ 1348.021259]
==================================================================
[ 1348.053236] Disabling lock debugging due to kernel taint
[ 1348.077109] BUG: unable to handle kernel paging request at
ffff8881d21c0bd0
[ 1348.108458] #PF error: [normal kernel read fault]
[ 1348.129480] PGD 40aa01067 P4D 40aa01067 PUD 47f546067 PMD 47f4b5067 PTE
800ffffe2de3f060
[ 1348.167122] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
[ 1348.191286] CPU: 25 PID: 263 Comm: kcompactd0 Tainted: G    B   W
5.0.0-next-20190305+ #50
[ 1348.234674] Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9,
BIOS U20 10/25/2017
[ 1348.272578] RIP: 0010:hex_dump_to_buffer+0xe0/0xb80
[ 1348.294479] Code: 00 00 fc ff df 48 8b 5d c0 48 89 da 48 c1 ea 03 0f b6
04 02 48 89 da 83 e2 07 38 d0 7f 08 84 c0 0f 85 3b 0a 00 00 48 8b 45 c0
<44> 0f b6 38 b8 01 00 00 00 48 2d a0 1a b2 b7 4c 89 fb 48 89 45 a8
[ 1348.379540] RSP: 0000:ffff8881f56df578 EFLAGS: 00010286
[ 1348.403349] RAX: ffff8881d21c0bd0 RBX: ffff8881d21c0bd0 RCX:
ffffffffb67fb779
[ 1348.436156] RDX: 0000000000000000 RSI: 0000000000000004 RDI:
ffffffffb80d0fa0
[ 1348.468254] RBP: ffff8881f56df5f8 R08: fffffbfff701a1f5 R09:
0000000000000083
[ 1348.500185] R10: fffffbfff701a1f4 R11: ffffffffb80d0fa3 R12:
ffff8881f56df658
[ 1348.533403] R13: 0000000000000001 R14: ffff8881d21c0bd0 R15:
0000000000000420
[ 1348.565942] FS:  0000000000000000(0000) GS:ffff8881f7c80000(0000)
knlGS:0000000000000000
[ 1348.602616] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1348.628422] CR2: ffff8881d21c0bd0 CR3: 0000000408816005 CR4:
00000000001606a0
[ 1348.660521] Call Trace:
[ 1348.692079]  print_hex_dump+0xf5/0x180
[ 1348.787020]  kernel_poison_pages.cold.2+0x4f/0x89
[ 1348.808089]  post_alloc_hook+0x186/0x290
[ 1348.825648]  split_map_pages+0x1e5/0x530
[ 1348.901010]  compaction_alloc+0x1050/0x25f0
[ 1348.979691]  unmap_and_move+0x37/0x1e70
[ 1349.016289]  migrate_pages+0x2ca/0xb20
[ 1349.096343]  compact_zone.isra.2+0x19ee/0x3680
[ 1349.174128]  kcompactd_do_work+0x2dd/0x670
[ 1349.248832]  kcompactd+0x1d8/0x6c0
[ 1349.339390]  kthread+0x32c/0x3f0
[ 1349.390109]  ret_from_fork+0x35/0x40
[ 1349.406571] Modules linked in: nls_iso8859_1 nls_cp437 vfat fat
kvm_intel kvm irqbypass efivars ip_tables x_tables xfs sd_mod ahci libahci
igb libata i2c_algo_bit i2c_core dm_mirror dm_region_hash dm_log dm_mod
efivarfs
[ 1349.494917] CR2: ffff8881d21c0bd0
[ 1349.509747] ---[ end trace a3cd895b8ad403bc ]---
[ 1349.530429] RIP: 0010:hex_dump_to_buffer+0xe0/0xb80
[ 1349.552222] Code: 00 00 fc ff df 48 8b 5d c0 48 89 da 48 c1 ea 03 0f b6
04 02 48 89 da 83 e2 07 38 d0 7f 08 84 c0 0f 85 3b 0a 00 00 48 8b 45 c0
<44> 0f b6 38 b8 01 00 00 00 48 2d a0 1a b2 b7 4c 89 fb 48 89 45 a8
[ 1349.636407] RSP: 0000:ffff8881f56df578 EFLAGS: 00010286
[ 1349.659450] RAX: ffff8881d21c0bd0 RBX: ffff8881d21c0bd0 RCX:
ffffffffb67fb779
[ 1349.691330] RDX: 0000000000000000 RSI: 0000000000000004 RDI:
ffffffffb80d0fa0
[ 1349.723362] RBP: ffff8881f56df5f8 R08: fffffbfff701a1f5 R09:
0000000000000083
[ 1349.758554] R10: fffffbfff701a1f4 R11: ffffffffb80d0fa3 R12:
ffff8881f56df658
[ 1349.792071] R13: 0000000000000001 R14: ffff8881d21c0bd0 R15:
0000000000000420
[ 1349.824033] FS:  0000000000000000(0000) GS:ffff8881f7c80000(0000)
knlGS:0000000000000000
[ 1349.860332] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1349.886064] CR2: ffff8881d21c0bd0 CR3: 0000000408816005 CR4:
00000000001606a0
[ 1349.918002] Kernel panic - not syncing: Fatal exception
[ 1349.941390] Kernel Offset: 0x35600000 from 0xffffffff81000000
(relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[ 1349.989812] ---[ end Kernel panic - not syncing: Fatal exception ]---

