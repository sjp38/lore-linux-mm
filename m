Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05ACDC31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 17:42:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D7AF2087C
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 17:42:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=apple.com header.i=@apple.com header.b="atDS6def"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D7AF2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=apple.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB0736B0003; Sat,  3 Aug 2019 13:42:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D12826B0005; Sat,  3 Aug 2019 13:42:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD9CD6B0006; Sat,  3 Aug 2019 13:42:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94B956B0003
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 13:42:47 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id a2so46804633ybb.14
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 10:42:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=bRkkC/ntl093lal8PH707LIzyeDQRUxXglb6XCpCp5g=;
        b=GelquUVAVJjkzYzAbqKEug+YV6MoCOhJFm5IRzASNQz5TPO2mOgkqEclwXnK2tHS7c
         Tbo4Kv9mJvEOwAn3bzZgZGbQJtVx6Di9sD1qdt87RO6ZwiX8mUDsXMCElwmuhpG/eMhD
         auTM3qFLX8xe3jSH7kX+5ZqtPF1HS0Vwg0nQfVRXuOTjfMHfc+LEeCMfaXs+7aVOkaGx
         twHZHwa8/W5mFdAiI4619IPDfdUClGO9sciZeSeB3YoR7aZxo2zMo54bW94FGcnymgl1
         gDCQLVJAdjkOvaYjhW//l2BejLSmbRblYp8I7MGywjzfk1rDJxEsCkGZ3F3KiT+s5jL/
         ty+Q==
X-Gm-Message-State: APjAAAXOnBmVR7iKvCsheCnKnIEZ73D9Cbr60XVwYQlHYIaFQupxMHAR
	g0k1vFNFbThCXw2MwE5Uldh8wp7tEQA/GoCCegDrdc6zx+5q/RPhPX3S47UISKBgniSa4oMpi83
	wXSpXaY/bpPCCbFO+7YP4NhGx1DycZo3E0aBaDf2Pk1ZpXjKX2J9xVy3TgNk4xl5e3Q==
X-Received: by 2002:a25:73c3:: with SMTP id o186mr5352298ybc.463.1564854167283;
        Sat, 03 Aug 2019 10:42:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfEtY9W0Qe9hzLcmq61vPtH7Kzt4E0EnpRPB5es0bfhop+4aHBS3fIGUmay/+Lj8q5CSJw
X-Received: by 2002:a25:73c3:: with SMTP id o186mr5352257ybc.463.1564854166371;
        Sat, 03 Aug 2019 10:42:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564854166; cv=none;
        d=google.com; s=arc-20160816;
        b=BlbJYTkYEi8l7EWdabVzqlAAKPvFGP/1msx6FwD2xILi3jkqiOMfW44/31Yb9aYe7C
         GeDV3E9DEXELQG4cUQqq+G/tBy5lxUYzdsfUE792Hv4ktXt4Pvstzvb5oQyuJQLc84Yi
         MZi7x2zczjV8+90OSIDYeToZI60i62MDuM2MF1uuVfYxp6r0vFXiSOnjsjSeoObiZGT7
         O1nffwmKBTwBur5o1PNsz/ApwM7OyeqZKxuLo5SX3j24yRwdzGmJJr+Lzhkd8D9F0d5e
         qYAQ5NnC6k0Zo07rz3KCkRDsBXKpUkdWS4o9slzep7hpYXXISBr871aQ9eArvZ9RPel3
         1w4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:sender:dkim-signature;
        bh=bRkkC/ntl093lal8PH707LIzyeDQRUxXglb6XCpCp5g=;
        b=z0Hfc4LDIx2Nl1vJS3Z/BnEiBsHmEmcgKBc9m0Egknm3Q0N2Y13uZHQ6ASCm3Eu8Vx
         szUHeBRNj8wxqCUrg1r6Na87MhzkABdEtcApU+asbYBF9ejVa9seFAtFC00G9MDjPRDn
         JRhobGzTt92KNCSP/xV4YqTnKq022uwbfaX3GYr0m47VS+7v5AfZwsSvQNG6A0C2QwS9
         IdOZeIK3YPGkIu4tdOyq5+pDCCoguzxR0xSoAbV6AJ/FI94TogaR/k1L6CREswtv5ApL
         pw1qpozLTNdHh2jsu3CobxkvoYNhWA+22wdB053tQjsUrcR08syLM048o0M0eIdG10/O
         mVjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@apple.com header.s=20180706 header.b=atDS6def;
       spf=pass (google.com: domain of msharbiani@apple.com designates 17.151.62.67 as permitted sender) smtp.mailfrom=msharbiani@apple.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=apple.com
Received: from nwk-aaemail-lapp02.apple.com (nwk-aaemail-lapp02.apple.com. [17.151.62.67])
        by mx.google.com with ESMTPS id t81si27864222ywb.392.2019.08.03.10.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 10:42:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of msharbiani@apple.com designates 17.151.62.67 as permitted sender) client-ip=17.151.62.67;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@apple.com header.s=20180706 header.b=atDS6def;
       spf=pass (google.com: domain of msharbiani@apple.com designates 17.151.62.67 as permitted sender) smtp.mailfrom=msharbiani@apple.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=apple.com
Received: from pps.filterd (nwk-aaemail-lapp02.apple.com [127.0.0.1])
	by nwk-aaemail-lapp02.apple.com (8.16.0.27/8.16.0.27) with SMTP id x73Hg31I061797;
	Sat, 3 Aug 2019 10:42:40 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=apple.com; h=sender : content-type
 : mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to; s=20180706;
 bh=bRkkC/ntl093lal8PH707LIzyeDQRUxXglb6XCpCp5g=;
 b=atDS6defcl+FOy7rii078Ax6ErNtRNuaV05osswNbt377/LhCv9iReo3Ig5SL0oohxEX
 34pTSV/vqUCGQjeDwxeQ9bto2hQzvkBJOJy+mJXEXlHfamDJ+U/phgU8vC8qwq5rgzWT
 CKQFCVwA7VKDxEFHTZuQwmuf+jA14sKY/gDZuuvJ/IrER4xGmxld46m0Vn/x6/KYLiYP
 9ONqVEcP4T97iAIRtBVlRqKRHUppPyreqPgx9S3A6wCJhKDrxjIFd/FXQXJy7tqcc2tM
 EGLJe05byUEnw0MN+z4t155hWgN3dE5X5nyKqTLt1Ir5nNyl7bvu1cUsvEnefiY+9aHs TQ== 
Received: from ma1-mtap-s01.corp.apple.com (ma1-mtap-s01.corp.apple.com [17.40.76.5])
	by nwk-aaemail-lapp02.apple.com with ESMTP id 2u56ujx5h7-17
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO);
	Sat, 03 Aug 2019 10:42:40 -0700
Received: from nwk-mmpp-sz11.apple.com
 (nwk-mmpp-sz11.apple.com [17.128.115.155]) by ma1-mtap-s01.corp.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) with ESMTPS id <0PVO00L5I96Z2T40@ma1-mtap-s01.corp.apple.com>; Sat,
 03 Aug 2019 10:42:38 -0700 (PDT)
Received: from process_milters-daemon.nwk-mmpp-sz11.apple.com by
 nwk-mmpp-sz11.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) id <0PVO00K0095HH200@nwk-mmpp-sz11.apple.com>; Sat,
 03 Aug 2019 10:42:37 -0700 (PDT)
X-Va-A: 
X-Va-T-CD: 2af4e3c096f98bec7d308668f2184085
X-Va-E-CD: b03d5acee32fc9f0c9dfd3776592dc73
X-Va-R-CD: 1835f3c54d533384876758843bc94ede
X-Va-CD: 0
X-Va-ID: 25033930-1b8f-487f-8f89-4f239138e815
X-V-A: 
X-V-T-CD: 2af4e3c096f98bec7d308668f2184085
X-V-E-CD: b03d5acee32fc9f0c9dfd3776592dc73
X-V-R-CD: 1835f3c54d533384876758843bc94ede
X-V-CD: 0
X-V-ID: 8093249f-89b7-424f-898d-6a35440e7308
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,,
 definitions=2019-08-03_09:,, signatures=0
Received: from [17.150.210.108] (unknown [17.150.210.108])
 by nwk-mmpp-sz11.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) with ESMTPSA id <0PVO008PZ95GJO50@nwk-mmpp-sz11.apple.com>; Sat,
 03 Aug 2019 10:41:41 -0700 (PDT)
Content-type: text/plain; charset=utf-8
MIME-version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
From: Masoud Sharbiani <msharbiani@apple.com>
In-reply-to: <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
Date: Sat, 03 Aug 2019 10:41:40 -0700
Cc: Michal Hocko <mhocko@kernel.org>, Greg KH <gregkh@linuxfoundation.org>,
        hannes@cmpxchg.org, vdavydov.dev@gmail.com, linux-mm@kvack.org,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org
Content-transfer-encoding: quoted-printable
Message-id: <77568CFC-280C-4C0F-85FC-92F1212BC6FC@apple.com>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
 <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
 <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: Apple Mail (2.3445.104.11)
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-03_09:,,
 signatures=0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 3, 2019, at 8:51 AM, Tetsuo Handa =
<penguin-kernel@I-love.SAKURA.ne.jp> wrote:
>=20
> Masoud, will you try this patch?

Gladly.
It looks like it is working (and OOMing properly).


>=20
> By the way, is /sys/fs/cgroup/memory/leaker/memory.usage_in_bytes =
remains non-zero
> despite /sys/fs/cgroup/memory/leaker/tasks became empty due to memcg =
OOM killer expected?
> Deleting big-data-file.bin after memcg OOM killer reduces some, but =
still remains
> non-zero.

Yes. I had not noticed that:

[ 1114.190477] oom_reaper: reaped process 1942 (leaker), now =
anon-rss:0kB, file-
rss:0kB, shmem-rss:0kB
./test-script.sh: line 16:  1942 Killed                  ./leaker -p =
10240 -c 100000

[root@localhost laleaker]# cat  =
/sys/fs/cgroup/memory/leaker/memory.usage_in_bytes
3194880
[root@localhost laleaker]# cat  =
/sys/fs/cgroup/memory/leaker/memory.limit_in_bytes
536870912
[root@localhost laleaker]# rm -f big-data-file.bin
[root@localhost laleaker]# cat  =
/sys/fs/cgroup/memory/leaker/memory.usage_in_bytes
2838528

Thanks!
Masoud

PS: Tried hand-back-porting it to 4.19-y and it didn=E2=80=99t work. I =
think there are other patches between 4.19.0 and 5.3 that could be =
necessary=E2=80=A6


>=20
> ----------------------------------------
> =46rom 2f92c70f390f42185c6e2abb8dda98b1b7d02fa9 Mon Sep 17 00:00:00 =
2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 4 Aug 2019 00:41:30 +0900
> Subject: [PATCH] memcg, oom: don't require __GFP_FS when invoking =
memcg OOM killer
>=20
> Masoud Sharbiani noticed that commit 29ef680ae7c21110 ("memcg, oom: =
move
> out_of_memory back to the charge path") broke memcg OOM called from
> __xfs_filemap_fault() path. It turned out that try_chage() is retrying
> forever without making forward progress because =
mem_cgroup_oom(GFP_NOFS)
> cannot invoke the OOM killer due to commit 3da88fb3bacfaa33 ("mm, oom:
> move GFP_NOFS check to out_of_memory"). Regarding memcg OOM, we need =
to
> bypass GFP_NOFS check in order to guarantee forward progress.
>=20
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: Masoud Sharbiani <msharbiani@apple.com>
> Bisected-by: Masoud Sharbiani <msharbiani@apple.com>
> Fixes: 29ef680ae7c21110 ("memcg, oom: move out_of_memory back to the =
charge path")
> ---
> mm/oom_kill.c | 5 +++--
> 1 file changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index eda2e2a..26804ab 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1068,9 +1068,10 @@ bool out_of_memory(struct oom_control *oc)
> 	 * The OOM killer does not compensate for IO-less reclaim.
> 	 * pagefault_out_of_memory lost its gfp context so we have to
> 	 * make sure exclude 0 mask - all other users should have at =
least
> -	 * ___GFP_DIRECT_RECLAIM to get here.
> +	 * ___GFP_DIRECT_RECLAIM to get here. But mem_cgroup_oom() has =
to
> +	 * invoke the OOM killer even if it is a GFP_NOFS allocation.
> 	 */
> -	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
> +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS) && =
!is_memcg_oom(oc))
> 		return true;
>=20
> 	/*
> --=20
> 1.8.3.1
>=20
>=20

