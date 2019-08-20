Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 294FDC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7DBD22DBF
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7DBD22DBF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12E306B000A; Tue, 20 Aug 2019 05:49:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B8A36B000C; Tue, 20 Aug 2019 05:49:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE7A56B000D; Tue, 20 Aug 2019 05:49:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id C81FA6B000A
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:49:38 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 74C31256FF
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:38 +0000 (UTC)
X-FDA: 75842334036.28.rice06_53ffddc471b27
X-HE-Tag: rice06_53ffddc471b27
X-Filterd-Recvd-Size: 6147
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com [115.124.30.130])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:36 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R471e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TZztT3d_1566294571;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0TZztT3d_1566294571)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 17:49:31 +0800
From: Alex Shi <alex.shi@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tejun Heo <tj@kernel.org>
Cc: Alex Shi <alex.shi@linux.alibaba.com>
Subject: [PATCH 00/14] per memcg lru_lock 
Date: Tue, 20 Aug 2019 17:48:23 +0800
Message-Id: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset move lru_lock into lruvec, give a lru_lock for each of
lruvec, thus bring a lru_lock for each of memcg.

Per memcg lru_lock would ease the lru_lock contention a lot in
this patch series.

In some data center, containers are used widely to deploy different kind
of services, then multiple memcgs share per node pgdat->lru_lock which
cause heavy lock contentions when doing lru operation.

On my 2 socket * 6 cores E5-2630 platform, 24 containers run aim9
simultaneously with mmtests' config:
        # AIM9
        export AIM9_TESTTIME=3D180
        export AIM9_TESTLIST=3Dpage_test,brk_test

perf lock report show much contentions on lru_lock in 20 second snapshot:
                        Name   acquired  contended   avg wait (ns) total =
wait (ns)   max wait (ns)   min wait (ns)
        &(ptlock_ptr(pag...         22          0               0       0=
               0               0
        ...
        &(&pgdat->lru_lo...          9          7           12728       8=
9096           26656            1597

With this patch series, lruvec->lru_lock show no contentions
        &(&lruvec->lru_l...          8          0               0       0=
               0               0

and aim9 page_test/brk_test performance increased 5%~50%.
BTW, Detailed results in aim9-pft.compare.log if needed,
All containers data are increased and pretty steady.

$for i in Max Min Hmean Stddev CoeffVar BHmean-50 BHmean-95 BHmean-99; do=
 echo "=3D=3D=3D=3D=3D=3D=3D=3D=3D $i page_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D"; cat aim9-pft.compare.log | grep "^$i.*page_test" | awk 'BEGIN=
 {a=3Db=3D0;}  { a+=3D$3; b+=3D$6 } END { print "5.3-rc4          " a/24;=
 print "5.3-rc4+lru_lock " b/24}' ; done
=3D=3D=3D=3D=3D=3D=3D=3D=3D Max page_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
5.3-rc4          34729.6
5.3-rc4+lru_lock 36128.3
=3D=3D=3D=3D=3D=3D=3D=3D=3D Min page_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
5.3-rc4          33644.2
5.3-rc4+lru_lock 35349.7
=3D=3D=3D=3D=3D=3D=3D=3D=3D Hmean page_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
5.3-rc4          34355.4
5.3-rc4+lru_lock 35810.9
=3D=3D=3D=3D=3D=3D=3D=3D=3D Stddev page_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
5.3-rc4          319.757
5.3-rc4+lru_lock 223.324
=3D=3D=3D=3D=3D=3D=3D=3D=3D CoeffVar page_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
5.3-rc4          0.93125
5.3-rc4+lru_lock 0.623333
=3D=3D=3D=3D=3D=3D=3D=3D=3D BHmean-50 page_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
5.3-rc4          34579.2
5.3-rc4+lru_lock 35977.1
=3D=3D=3D=3D=3D=3D=3D=3D=3D BHmean-95 page_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
5.3-rc4          34421.7
5.3-rc4+lru_lock 35853.6
=3D=3D=3D=3D=3D=3D=3D=3D=3D BHmean-99 page_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
5.3-rc4          34421.7
5.3-rc4+lru_lock 35853.6

$for i in Max Min Hmean Stddev CoeffVar BHmean-50 BHmean-95 BHmean-99; do=
 echo "=3D=3D=3D=3D=3D=3D=3D=3D=3D $i brk_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D"; cat aim9-pft.compare.log | grep "^$i.*brk_test" | awk 'BEGIN =
{a=3Db=3D0;}  { a+=3D$3; b+=3D$6 } END { print "5.3-rc4          " a/24; =
print "5.3-rc4+lru_lock " b/24}' ; done
=3D=3D=3D=3D=3D=3D=3D=3D=3D Max brk_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
5.3-rc4          96647.7
5.3-rc4+lru_lock 98960.3
=3D=3D=3D=3D=3D=3D=3D=3D=3D Min brk_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
5.3-rc4          91800.8
5.3-rc4+lru_lock 96817.6
=3D=3D=3D=3D=3D=3D=3D=3D=3D Hmean brk_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
5.3-rc4          95470
5.3-rc4+lru_lock 97769.6
=3D=3D=3D=3D=3D=3D=3D=3D=3D Stddev brk_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
5.3-rc4          1253.52
5.3-rc4+lru_lock 596.593
=3D=3D=3D=3D=3D=3D=3D=3D=3D CoeffVar brk_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
5.3-rc4          1.31375
5.3-rc4+lru_lock 0.609583
=3D=3D=3D=3D=3D=3D=3D=3D=3D BHmean-50 brk_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
5.3-rc4          96141.4
5.3-rc4+lru_lock 98194
=3D=3D=3D=3D=3D=3D=3D=3D=3D BHmean-95 brk_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
5.3-rc4          95818.5
5.3-rc4+lru_lock 97857.2
=3D=3D=3D=3D=3D=3D=3D=3D=3D BHmean-99 brk_test =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
5.3-rc4          95818.5
5.3-rc4+lru_lock 97857.2

Alex Shi (14):
  mm/lru: move pgdat lru_lock into lruvec
  lru/memcg: move the lruvec->pgdat sync out lru_lock
  lru/memcg: using per lruvec lock in un/lock_page_lru
  lru/compaction: use per lruvec lock in isolate_migratepages_block
  lru/huge_page: use per lruvec lock in __split_huge_page
  lru/mlock: using per lruvec lock in munlock
  lru/swap: using per lruvec lock in page_cache_release
  lru/swap: uer lruvec lock in activate_page
  lru/swap: uer per lruvec lock in pagevec_lru_move_fn
  lru/swap: use per lruvec lock in release_pages
  lru/vmscan: using per lruvec lock in lists shrinking.
  lru/vmscan: use pre lruvec lock in check_move_unevictable_pages
  lru/vmscan: using per lruvec lru_lock in get_scan_count
  mm/lru: fix the comments of lru_lock

 include/linux/memcontrol.h | 24 ++++++++++----
 include/linux/mm_types.h   |  2 +-
 include/linux/mmzone.h     |  6 ++--
 mm/compaction.c            | 48 +++++++++++++++++-----------
 mm/filemap.c               |  4 +--
 mm/huge_memory.c           |  9 ++++--
 mm/memcontrol.c            | 24 ++++++--------
 mm/mlock.c                 | 35 ++++++++++----------
 mm/mmzone.c                |  1 +
 mm/page_alloc.c            |  1 -
 mm/page_idle.c             |  4 +--
 mm/rmap.c                  |  2 +-
 mm/swap.c                  | 79 +++++++++++++++++++++++++---------------=
------
 mm/vmscan.c                | 63 ++++++++++++++++++------------------
 14 files changed, 166 insertions(+), 136 deletions(-)

--=20
1.8.3.1


