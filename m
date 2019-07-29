Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C52CCC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 07:28:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70FC3216F4
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 07:28:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70FC3216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3D8A8E0003; Mon, 29 Jul 2019 03:28:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEE368E0002; Mon, 29 Jul 2019 03:28:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDCBF8E0003; Mon, 29 Jul 2019 03:28:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5948E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 03:28:56 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j144so44673471ywa.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 00:28:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=qTZTybzfZhK0hys4XCURiYnQR/pybix+iJpWbeXQVJE=;
        b=qsoLSiPhhFZ3+NKAbHGXe2f1vxxOUv4ccisZs5yB2VSniHthgK+ZY7n6Gcmis29L1f
         YCZzYExu6Kgsa9yjt2MoccK7STognf4h8q9AiuLVpzYmbPU7AyGBI19Ryxynpdl8hvyW
         V3N4G75Lv71kTY/vidmnKLY0TU2sGsgfiKvMZ94YhuFbyCMvNh8Gnr9tUHDS6Sq6qiDN
         d6zW7sDTKQG/clSsvfR6GAkWSctXo2DTLS6K/zuCJ0U6fKukDtY6abJHkT21OLEWL5Te
         gs8CLq288yd0ozcN8Itw0Bn6c+dEw2C9pNZ53S9JCY+H81eqjH0Asq2+NIgZ3LCtNScx
         ewnQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXSERBoeBQehJ/THouho/0YXmFGOKaEBMnaBW+azyZY/pbpTWC+
	oaTTvcGCNZ+zZ6D50WpMRbDLXNmRdGfB8sR5WaQrHQOkjWScm2kaZJPnDgr7qW3qKiC5cFzwC8s
	S8dW9ZcI1NkmBO8P6WmMX0LZTRfscahv30Oj4OzJeI2jaPnMCx1GqH2ypCo0JvDQ=
X-Received: by 2002:a25:8186:: with SMTP id p6mr53452127ybk.374.1564385336347;
        Mon, 29 Jul 2019 00:28:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyly+SNn8dtM5VJ6fWlMeLcWKyBnqKF0feP17D3GTxD2vSGeCal46cjFyEcCW4tB0tqI84n
X-Received: by 2002:a25:8186:: with SMTP id p6mr53452112ybk.374.1564385335871;
        Mon, 29 Jul 2019 00:28:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564385335; cv=none;
        d=google.com; s=arc-20160816;
        b=VTgBVt+JmiSL++pp0MJZfiOKcd/proOGqgU0VC9AUJ8apb1Ucw/cch/TDbnqaTgg1R
         1gY0d7tDDcVCwZr8rkPORLWUisqdb93xPBV5NQZfswHXvK5YipLvyuJqEyicUJ8PjH2l
         FAzbrK7rq04qvXr89qMwKlgVp+gCXTqbpSXSFDAxvzCJKPDmZm+KbZ8VanCJgfiHSC+F
         ZTacZZE3DFvnxJkB0A8s30711RIwFWx4dKNSMIVx8E1snO9FpqUHGHfv3FzFoGErf91W
         Ee7eOwSgEbkGVeqj+3yRgve/nkzy5FEDmC02yHTcsDJfDwHgVngGn0VtZ0K7OwoNHUJo
         rhSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=qTZTybzfZhK0hys4XCURiYnQR/pybix+iJpWbeXQVJE=;
        b=niPHoYhoo4YRIrqJGlZkMK1Lahxcu4LVzRTHspuL2hmfxWn3UNiMz+XVjBG2KQZeD6
         FZ4ffkRBHHmTGkDcudmAtWMfO3V5Zm/1m4UqiRs+ZfYTmAxaiwUxFJ8zrsYcAAnbHv6L
         2BLhf3wnV5SJpeJCLIxoXStC1j1olceuYI8PeZIulCG4c8JdlPPAHb3AkIk0AUImlG44
         OgEWO+szV/p1BlMtSR+3rHb2IP9Paz0myPxM1Y1WWl0UkrMzlc4rsp8ZeP2cOY47o6n/
         KGYVNN/lFLxSRd226VgBl0CAV+9Ukc9g26J4QpGA1TpmbvXYwU0mhJ22ia0DZPd8noXo
         x5tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d30si1150935ybi.136.2019.07.29.00.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 00:28:55 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of srikar@linux.vnet.ibm.com) smtp.mailfrom=srikar@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6T7NU21126820
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 03:28:55 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2u1tkbcf48-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 03:28:55 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 29 Jul 2019 08:28:53 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 29 Jul 2019 08:28:49 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6T7SmVX43254160
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Jul 2019 07:28:48 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2AC5052063;
	Mon, 29 Jul 2019 07:28:48 +0000 (GMT)
Received: from linux.vnet.ibm.com (unknown [9.126.150.29])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with SMTP id 59ED252050;
	Mon, 29 Jul 2019 07:28:46 +0000 (GMT)
Date: Mon, 29 Jul 2019 12:58:45 +0530
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
 <20190725173516.GA16399@linux.vnet.ibm.com>
 <87y30l5jdo.fsf@yhuang-dev.intel.com>
 <20190726092021.GA5273@linux.vnet.ibm.com>
 <87ef295yn9.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <87ef295yn9.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-TM-AS-GCONF: 00
x-cbid: 19072907-0012-0000-0000-000003373501
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072907-0013-0000-0000-00002170D528
Message-Id: <20190729072845.GC7168@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-29_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=975 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907290087
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> >> 
> >> if (lr_ratio >= NUMA_PERIOD_THRESHOLD)
> >>     slow down scanning
> >> else if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
> >>     if (NUMA_PERIOD_SLOTS - lr_ratio >= NUMA_PERIOD_THRESHOLD)
> >>         speed up scanning
> 
> Thought about this again.  For example, a multi-threads workload runs on
> a 4-sockets machine, and most memory accesses are shared.  The optimal
> situation will be pseudo-interleaving, that is, spreading memory
> accesses evenly among 4 NUMA nodes.  Where "share" >> "private", and
> "remote" > "local".  And we should slow down scanning to reduce the
> overhead.
> 
> What do you think about this?

If all 4 nodes have equal access, then all 4 nodes will be active nodes.

From task_numa_fault()

	if (!priv && !local && ng && ng->active_nodes > 1 &&
				numa_is_active_node(cpu_node, ng) &&
				numa_is_active_node(mem_node, ng))
		local = 1;

Hence all accesses will be accounted as local. Hence scanning would slow
down.

-- 
Thanks and Regards
Srikar Dronamraju

