Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE72EC76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:35:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8286B21951
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:35:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8286B21951
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 214AD6B0003; Thu, 25 Jul 2019 13:35:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C6AC6B0005; Thu, 25 Jul 2019 13:35:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B4718E0002; Thu, 25 Jul 2019 13:35:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C87336B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:35:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 191so31343359pfy.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:35:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=IwuKRGvGvPiwanIZKOikAk0StAjB83W6Ptv7A4KuTe8=;
        b=ipD0YQF8GLXWajheOvQKyOA5atesK1194OV7RlsLJsxTqPZRyKGCHu/+ZJ2pinRlhu
         O5fZsZ6Up4vf3iOR5fQnPdRFJu9mz1bgq0RMey90P/bd4jy87CcrAiymeiakGBWhhzWc
         3QqqWLCHy7WYOcfsRnVDnxfti/0Ec1KAjq1QlKwwungvxdTx/kNMD6b/q2BWjS1+DFzn
         KktmE1v3/Qh2O5D4YsP+wAgUyld7FQ6I96lRIPSqzhpvLQ3EkR31BAtCdh4KG+qZLzzf
         1JjGKoFZZ9X1n5qwOg4kpqo3pnKLwPz6f0leQHIOmWF/OyG0ZotPif9l7EjlG8VTTohZ
         zTuQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWNde513gkkgwjNZ+XjZr14NX92zLs94HfOdZ79X9IrOc0/bvge
	Zb3hK7xv/MvNyqePOwOquZZTUTeiKiCSzotyBL0hMPt/+cMo8IF9IaxqthlS3EyRVwpQX0fhlo/
	yg/vo9TLJ44XlFJHF/LR1LSn9/NAztM8qztgrKtcpIKtl2O+/TDTAFrD7EhXhn9k=
X-Received: by 2002:a63:1c22:: with SMTP id c34mr86836910pgc.56.1564076129224;
        Thu, 25 Jul 2019 10:35:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWNxqYHupjXgCClAVKk0pR56xTUprIKQsXb3bnk9hsp3Hl7+UWrJ9Fj4MGCHOLafc6sxwz
X-Received: by 2002:a63:1c22:: with SMTP id c34mr86836863pgc.56.1564076128368;
        Thu, 25 Jul 2019 10:35:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564076128; cv=none;
        d=google.com; s=arc-20160816;
        b=paR5/LbF0UD3fRdRW23liHJicKJZ9+z+JLWAkebPuuNZhXj16oLxwMv8Nv0v3QSA90
         JiWL5gL19fibNCd9Q5MdlQ0ndtDBk/WPmYFjq4yUvU+1eqq+wFzdZlBQJnrgBu5riI+n
         m6o13HPVNEgJ+bkOk7+kbEkb1QXMmJz3qVwozZlzi76Pv8Gazk250VFkzeiaV7sQiARG
         iqvissIS7Bug5BZcC/DUVCbQtHyUFZnvQEJfMCUM6yeft8N308zqpp8/shQSiHzNWQo1
         eeRP4YSa5jNPFDEx+x81R9Xb184iA9URKYEaQpEmreDimvgbh7FFmuDyIw1pxZGrbUMe
         QjpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=IwuKRGvGvPiwanIZKOikAk0StAjB83W6Ptv7A4KuTe8=;
        b=dDRpvm1KUqcCn3jOuhhgnA+ZHFqFRYRI/AX5/J2pFuzZeXVYr88bohEDG9c5pait3i
         llWe5DClQKHq34QPpPXKPiXrws9TEHSNO72NEQFKqEWydKaFXBlghmMbDYvO+NjgTECV
         nq57L/kD0myKYecxeF55ZZxnmpEpMCfG2n475AbYp/J0U2/2hs3ljRN0fsjlZRf2rINO
         4wUVsdZzCcuP689Glc+ImR30yBxDWihyGsd3YkNz+4VcIRtTEPHGGMo140kJdutvdT3f
         mjwp7/OarUYjbHNYxMB+nZiXoamjeE3CbZV6wAviAdZhhG3fmZzlOhuu+iFCA9EicW5O
         kevQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 3si16394092plx.412.2019.07.25.10.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 10:35:28 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6PGYcYC121303
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:35:27 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tyg2pj6ek-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:35:27 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 25 Jul 2019 18:35:24 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Jul 2019 18:35:20 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6PHZJOf56951024
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 17:35:19 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 535D35204F;
	Thu, 25 Jul 2019 17:35:19 +0000 (GMT)
Received: from linux.vnet.ibm.com (unknown [9.126.150.29])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with SMTP id 6D34E5204E;
	Thu, 25 Jul 2019 17:35:17 +0000 (GMT)
Date: Thu, 25 Jul 2019 23:05:16 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>,
        jhladky@redhat.com, lvenanci@redhat.com,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] autonuma: Fix scan period updating
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20190725080124.494-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190725080124.494-1-ying.huang@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-TM-AS-GCONF: 00
x-cbid: 19072517-0012-0000-0000-00000336397E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072517-0013-0000-0000-0000216FD20C
Message-Id: <20190725173516.GA16399@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-25_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907250188
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Huang, Ying <ying.huang@intel.com> [2019-07-25 16:01:24]:

> From: Huang Ying <ying.huang@intel.com>
> 
> From the commit log and comments of commit 37ec97deb3a8 ("sched/numa:
> Slow down scan rate if shared faults dominate"), the autonuma scan
> period should be increased (scanning is slowed down) if the majority
> of the page accesses are shared with other processes.  But in current
> code, the scan period will be decreased (scanning is speeded up) in
> that situation.
> 
> The commit log and comments make more sense.  So this patch fixes the
> code to make it match the commit log and comments.  And this has been
> verified via tracing the scan period changing and /proc/vmstat
> numa_pte_updates counter when running a multi-threaded memory
> accessing program (most memory areas are accessed by multiple
> threads).
> 

Lets split into 4 modes.
More Local and Private Page Accesses:
We definitely want to scan slowly i.e increase the scan window.

More Local and Shared Page Accesses:
We still want to scan slowly because we have consolidated and there is no
point in scanning faster. So scan slowly + increase the scan window.
(Do remember access on any active node counts as local!!!)

More Remote + Private page Accesses:
Most likely the Private accesses are going to be local accesses.

In the unlikely event of the private accesses not being local, we should
scan faster so that the memory and task consolidates.

More Remote + Shared page Accesses: This means the workload has not
consolidated and needs to scan faster. So we need to scan faster.

So I would think we should go back to before 37ec97deb3a8.

i.e 

	int slot = lr_ratio - NUMA_PERIOD_THRESHOLD;

	if (!slot)
		slot = 1;
	diff = slot * period_slot;


No?

> Fixes: 37ec97deb3a8 ("sched/numa: Slow down scan rate if shared faults dominate")
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: jhladky@redhat.com
> Cc: lvenanci@redhat.com
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  kernel/sched/fair.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 036be95a87e9..468a1c5038b2 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1940,7 +1940,7 @@ static void update_task_scan_period(struct task_struct *p,
>  			unsigned long shared, unsigned long private)
>  {
>  	unsigned int period_slot;
> -	int lr_ratio, ps_ratio;
> +	int lr_ratio, sp_ratio;
>  	int diff;
>  
>  	unsigned long remote = p->numa_faults_locality[0];
> @@ -1971,22 +1971,22 @@ static void update_task_scan_period(struct task_struct *p,
>  	 */
>  	period_slot = DIV_ROUND_UP(p->numa_scan_period, NUMA_PERIOD_SLOTS);
>  	lr_ratio = (local * NUMA_PERIOD_SLOTS) / (local + remote);
> -	ps_ratio = (private * NUMA_PERIOD_SLOTS) / (private + shared);
> +	sp_ratio = (shared * NUMA_PERIOD_SLOTS) / (private + shared);
>  
> -	if (ps_ratio >= NUMA_PERIOD_THRESHOLD) {
> +	if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
>  		/*
> -		 * Most memory accesses are local. There is no need to
> -		 * do fast NUMA scanning, since memory is already local.
> +		 * Most memory accesses are shared with other tasks.
> +		 * There is no point in continuing fast NUMA scanning,
> +		 * since other tasks may just move the memory elsewhere.

With this change, I would expect that with Shared page accesses,
consolidation to take a hit.

>  		 */
> -		int slot = ps_ratio - NUMA_PERIOD_THRESHOLD;
> +		int slot = sp_ratio - NUMA_PERIOD_THRESHOLD;
>  		if (!slot)
>  			slot = 1;
>  		diff = slot * period_slot;
>  	} else if (lr_ratio >= NUMA_PERIOD_THRESHOLD) {
>  		/*
> -		 * Most memory accesses are shared with other tasks.
> -		 * There is no point in continuing fast NUMA scanning,
> -		 * since other tasks may just move the memory elsewhere.
> +		 * Most memory accesses are local. There is no need to
> +		 * do fast NUMA scanning, since memory is already local.

Comment wise this make sense.

>  		 */
>  		int slot = lr_ratio - NUMA_PERIOD_THRESHOLD;
>  		if (!slot)
> @@ -1998,7 +1998,7 @@ static void update_task_scan_period(struct task_struct *p,
>  		 * yet they are not on the local NUMA node. Speed up
>  		 * NUMA scanning to get the memory moved over.
>  		 */
> -		int ratio = max(lr_ratio, ps_ratio);
> +		int ratio = max(lr_ratio, sp_ratio);
>  		diff = -(NUMA_PERIOD_THRESHOLD - ratio) * period_slot;
>  	}
>  
> -- 
> 2.20.1
> 

-- 
Thanks and Regards
Srikar Dronamraju

