Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A702BC31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 18:24:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EF6F2166E
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 18:24:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=apple.com header.i=@apple.com header.b="f4Qnm3OD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EF6F2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=apple.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E04E16B0003; Sat,  3 Aug 2019 14:24:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB58F6B0005; Sat,  3 Aug 2019 14:24:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA61C6B0006; Sat,  3 Aug 2019 14:24:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id ABDE46B0003
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 14:24:46 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id f15so58277957ywb.5
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 11:24:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=TsJz3OUo2WROq2nv/KDSlpoFx4edCT2XPw2Br1eBQ6Q=;
        b=E0GLwrHKPIjW4d3DXehaDePy1MzUvsz29kqk6LMl3CjY1kATutGRLTOOHh1cpkS1vT
         tp3QxG4VBFgvScI1tbPvj/LjMmbfKZWsQBunrnuAPyrl8xyLZ/i1oSXghlwrLFlyE47s
         V8NWEH3OSVPPOBraIpI0rN98btitfB3GqUwSj2jTRQNmR7D1ea5VMJ1Z1S5WqgRu4CnJ
         WiTvh74GvlvtviSmORcwi1ptx4D4FjQkWSl0ybme6IoqsnVeECHEKkzudlTvBX72lsI4
         BOwU+NIT5JItczWKbZjkFvJZ4wCDHHgqsP4v1YdjE3ys/uGmlPgb+w7sBtubRQnWI/xE
         tVuA==
X-Gm-Message-State: APjAAAWcIK90sgkY6MBKOLTHTN9OrX533/Pmu79GJ2ps1pHgIn/ZEFRD
	o73eagdfCY77B7qUOCdJaYNDhSAbzqya7gFWKWCGn0UCdZ8jlLAX7ZcppD9uFu8y9rVcqKskJnS
	H4TwyzqTP6+b/wOWu3S+nstPECozJg3VamuDVFRCM6CUYuOg/DZXOoSmSGW/6hEQ2Sw==
X-Received: by 2002:a81:4fd4:: with SMTP id d203mr82590913ywb.166.1564856686348;
        Sat, 03 Aug 2019 11:24:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXDdnoqjcv8c1W5vAvrU+W94F6Dd0oRiNRqji1y92nQiQsa/PPsejRrtjuOprJOE1UAKk9
X-Received: by 2002:a81:4fd4:: with SMTP id d203mr82590894ywb.166.1564856685505;
        Sat, 03 Aug 2019 11:24:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564856685; cv=none;
        d=google.com; s=arc-20160816;
        b=sxfREzIPqGNyyYx67yxo7y32FucHxhMvnGlnXQGctJXjx8YxfNqsOs9uvJ6pqKoq6v
         m8q8ydtK7LbWl366ddVLy+Vv7X01f0y4KsBdA0dQB85jEda9Trn1eMwCVM4hZaB1rB67
         lCSTO7vJztDalG5gLOyLFVMTk3Qm0/dOqcKFbdfZZEWVdGEcuKa8/sYalxMArJlH1Hpx
         xdrGoqJw+5FJVvSj9GneQvMifQptvwJXfnWvygJfp6qTS/j5FcswGfp7b3rqTfNkWycm
         LfAnHD0kBf8vOeoILdfbt91UKyb/iHa3j1TDSKdUP+A9zBeodZdR8oHxhFtwGDL7E/ly
         Hm/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:sender:dkim-signature;
        bh=TsJz3OUo2WROq2nv/KDSlpoFx4edCT2XPw2Br1eBQ6Q=;
        b=HMTgm3CqwXidzHFKFwIx+GWTcaeKoR2LD+XeHSHr0PiHZbOcaStZ6qx9J1ANNG/Hio
         6lM3n+YeXsu6xQsl+sI3Ak4xXleWN5l4avDWneQ9vU11j+vlqrVM5KN92XMvEb8o/uHt
         n8kY7o2+kpCYVwdeo9T7jQ6fk4IKjfKKdc1jpGTiN/XTivdEC6yOBM73FWl+4mFPjxjB
         ZhN2R3TQomRhDXauU6Av0NYnIHi7P8HOyG+uc5UIYs0qr4gykVYvfKdtibwxHUPlRkzV
         mQb9YKxp88xE0UVBFJaPBkN9p0IyDV9Na/o38O3UDSC1ZtiePJmgYyzLWDFzTo7lwPtH
         vTIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@apple.com header.s=20180706 header.b=f4Qnm3OD;
       spf=pass (google.com: domain of msharbiani@apple.com designates 17.151.62.67 as permitted sender) smtp.mailfrom=msharbiani@apple.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=apple.com
Received: from nwk-aaemail-lapp02.apple.com (nwk-aaemail-lapp02.apple.com. [17.151.62.67])
        by mx.google.com with ESMTPS id m78si30132034ybm.408.2019.08.03.11.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 11:24:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of msharbiani@apple.com designates 17.151.62.67 as permitted sender) client-ip=17.151.62.67;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@apple.com header.s=20180706 header.b=f4Qnm3OD;
       spf=pass (google.com: domain of msharbiani@apple.com designates 17.151.62.67 as permitted sender) smtp.mailfrom=msharbiani@apple.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=apple.com
Received: from pps.filterd (nwk-aaemail-lapp02.apple.com [127.0.0.1])
	by nwk-aaemail-lapp02.apple.com (8.16.0.27/8.16.0.27) with SMTP id x73IMIEi044183;
	Sat, 3 Aug 2019 11:24:39 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=apple.com; h=sender : content-type
 : mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to; s=20180706;
 bh=TsJz3OUo2WROq2nv/KDSlpoFx4edCT2XPw2Br1eBQ6Q=;
 b=f4Qnm3ODL1wAWmRXb6oQDjtVtLketIu79BacRVZ073C/QBz0u0+yFkjxkLQPfwN2B7cI
 glQ6sdc6r/rXbX+d/HS/8p79FYdQwiedwSE06/76VVqvAHHMD1RW0PFKhBVQaqTudXwZ
 1haM67pSkIDoYgzKGDdMzvJE6ltHsGMQmtLdolSuXZru862QBb0ygHAjQnvDmGPnJqlE
 T5HPQfNredWYW+ftIBSBlAPg7x+hSh8po4YtUc63xENMDOMjG+v4XttMJkQhCAnvRtH/
 VwHZDPCmnyorabSVSWKgvB8lsXWoKY3BW6XMyBENROIG+AXXBuA+90QEJzEAXQCClzK/ MA== 
Received: from mr2-mtap-s01.rno.apple.com (mr2-mtap-s01.rno.apple.com [17.179.226.133])
	by nwk-aaemail-lapp02.apple.com with ESMTP id 2u56ujxkmw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO);
	Sat, 03 Aug 2019 11:24:39 -0700
Received: from nwk-mmpp-sz11.apple.com
 (nwk-mmpp-sz11.apple.com [17.128.115.155]) by mr2-mtap-s01.rno.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) with ESMTPS id <0PVO00AK2B52XB40@mr2-mtap-s01.rno.apple.com>; Sat,
 03 Aug 2019 11:24:39 -0700 (PDT)
Received: from process_milters-daemon.nwk-mmpp-sz11.apple.com by
 nwk-mmpp-sz11.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) id <0PVO00J00B3Y2V00@nwk-mmpp-sz11.apple.com>; Sat,
 03 Aug 2019 11:24:38 -0700 (PDT)
X-Va-A: 
X-Va-T-CD: 2af4e3c096f98bec7d308668f2184085
X-Va-E-CD: b03d5acee32fc9f0c9dfd3776592dc73
X-Va-R-CD: 1835f3c54d533384876758843bc94ede
X-Va-CD: 0
X-Va-ID: 05f595ff-0561-4b61-9c78-29a92582d91d
X-V-A: 
X-V-T-CD: 2af4e3c096f98bec7d308668f2184085
X-V-E-CD: b03d5acee32fc9f0c9dfd3776592dc73
X-V-R-CD: 1835f3c54d533384876758843bc94ede
X-V-CD: 0
X-V-ID: d3ac2986-9aa4-4db4-bc76-2493a767f397
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,,
 definitions=2019-08-03_09:,, signatures=0
Received: from [17.150.210.108] (unknown [17.150.210.108])
 by nwk-mmpp-sz11.apple.com
 (Oracle Communications Messaging Server 8.0.2.4.20190507 64bit (built May  7
 2019)) with ESMTPSA id <0PVO0087WB52JO80@nwk-mmpp-sz11.apple.com>; Sat,
 03 Aug 2019 11:24:38 -0700 (PDT)
Content-type: text/plain; charset=utf-8
MIME-version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
From: Masoud Sharbiani <msharbiani@apple.com>
In-reply-to: <77568CFC-280C-4C0F-85FC-92F1212BC6FC@apple.com>
Date: Sat, 03 Aug 2019 11:24:37 -0700
Cc: Michal Hocko <mhocko@kernel.org>, Greg KH <gregkh@linuxfoundation.org>,
        hannes@cmpxchg.org, vdavydov.dev@gmail.com, linux-mm@kvack.org,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org
Content-transfer-encoding: quoted-printable
Message-id: <9B718E2A-FE3B-453E-9426-1E1880351765@apple.com>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
 <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
 <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
 <77568CFC-280C-4C0F-85FC-92F1212BC6FC@apple.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: Apple Mail (2.3445.104.11)
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-03_09:,,
 signatures=0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 3, 2019, at 10:41 AM, Masoud Sharbiani <msharbiani@apple.com> =
wrote:
>=20
>=20
>=20
>> On Aug 3, 2019, at 8:51 AM, Tetsuo Handa =
<penguin-kernel@I-love.SAKURA.ne.jp> wrote:
>>=20
>> Masoud, will you try this patch?
>=20
> Gladly.
> It looks like it is working (and OOMing properly).
>=20
>=20
>>=20
>> By the way, is /sys/fs/cgroup/memory/leaker/memory.usage_in_bytes =
remains non-zero
>> despite /sys/fs/cgroup/memory/leaker/tasks became empty due to memcg =
OOM killer expected?
>> Deleting big-data-file.bin after memcg OOM killer reduces some, but =
still remains
>> non-zero.
>=20
> Yes. I had not noticed that:
>=20
> [ 1114.190477] oom_reaper: reaped process 1942 (leaker), now =
anon-rss:0kB, file-
> rss:0kB, shmem-rss:0kB
> ./test-script.sh: line 16:  1942 Killed                  ./leaker -p =
10240 -c 100000
>=20
> [root@localhost laleaker]# cat  =
/sys/fs/cgroup/memory/leaker/memory.usage_in_bytes
> 3194880
> [root@localhost laleaker]# cat  =
/sys/fs/cgroup/memory/leaker/memory.limit_in_bytes
> 536870912
> [root@localhost laleaker]# rm -f big-data-file.bin
> [root@localhost laleaker]# cat  =
/sys/fs/cgroup/memory/leaker/memory.usage_in_bytes
> 2838528
>=20
> Thanks!
> Masoud
>=20
> PS: Tried hand-back-porting it to 4.19-y and it didn=E2=80=99t work. I =
think there are other patches between 4.19.0 and 5.3 that could be =
necessary=E2=80=A6
>=20

Please ignore this last part. It works on 4.19-y branch as well.=20

Masoud

>=20
>>=20
>> ----------------------------------------
>> =46rom 2f92c70f390f42185c6e2abb8dda98b1b7d02fa9 Mon Sep 17 00:00:00 =
2001
>> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Date: Sun, 4 Aug 2019 00:41:30 +0900
>> Subject: [PATCH] memcg, oom: don't require __GFP_FS when invoking =
memcg OOM killer
>>=20
>> Masoud Sharbiani noticed that commit 29ef680ae7c21110 ("memcg, oom: =
move
>> out_of_memory back to the charge path") broke memcg OOM called from
>> __xfs_filemap_fault() path. It turned out that try_chage() is =
retrying
>> forever without making forward progress because =
mem_cgroup_oom(GFP_NOFS)
>> cannot invoke the OOM killer due to commit 3da88fb3bacfaa33 ("mm, =
oom:
>> move GFP_NOFS check to out_of_memory"). Regarding memcg OOM, we need =
to
>> bypass GFP_NOFS check in order to guarantee forward progress.
>>=20
>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Reported-by: Masoud Sharbiani <msharbiani@apple.com>
>> Bisected-by: Masoud Sharbiani <msharbiani@apple.com>
>> Fixes: 29ef680ae7c21110 ("memcg, oom: move out_of_memory back to the =
charge path")
>> ---
>> mm/oom_kill.c | 5 +++--
>> 1 file changed, 3 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index eda2e2a..26804ab 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -1068,9 +1068,10 @@ bool out_of_memory(struct oom_control *oc)
>> 	 * The OOM killer does not compensate for IO-less reclaim.
>> 	 * pagefault_out_of_memory lost its gfp context so we have to
>> 	 * make sure exclude 0 mask - all other users should have at =
least
>> -	 * ___GFP_DIRECT_RECLAIM to get here.
>> +	 * ___GFP_DIRECT_RECLAIM to get here. But mem_cgroup_oom() has =
to
>> +	 * invoke the OOM killer even if it is a GFP_NOFS allocation.
>> 	 */
>> -	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
>> +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS) && =
!is_memcg_oom(oc))
>> 		return true;
>>=20
>> 	/*
>> --=20
>> 1.8.3.1
>>=20
>>=20
>=20

