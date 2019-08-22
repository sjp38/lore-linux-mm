Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56209C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 13:26:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2162D233A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 13:26:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2162D233A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C179D6B031C; Thu, 22 Aug 2019 09:26:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA1D86B031D; Thu, 22 Aug 2019 09:26:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A68AE6B031E; Thu, 22 Aug 2019 09:26:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 7CEE26B031C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:26:17 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0F295180AD801
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:26:17 +0000 (UTC)
X-FDA: 75850137594.24.kite90_36c9476b68137
X-HE-Tag: kite90_36c9476b68137
X-Filterd-Recvd-Size: 4323
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:26:16 +0000 (UTC)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7MDPGdc045905
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:26:12 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uhuce1pk5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:26:11 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 22 Aug 2019 14:26:08 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 22 Aug 2019 14:26:06 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7MDQ5uY47710246
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 22 Aug 2019 13:26:05 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 78A7D4C04E;
	Thu, 22 Aug 2019 13:26:05 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 12A4D4C050;
	Thu, 22 Aug 2019 13:26:05 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.59])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 22 Aug 2019 13:26:04 +0000 (GMT)
Date: Thu, 22 Aug 2019 16:26:03 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/init-mm.c: use CPU_BITS_NONE to initialize .cpu_bitmap
References: <20190822075207.26400-1-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822075207.26400-1-linux@rasmusvillemoes.dk>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19082213-0012-0000-0000-0000034182BA
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082213-0013-0000-0000-0000217BAE03
Message-Id: <20190822132602.GF18872@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-22_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908220143
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Aug 22, 2019 at 09:52:07AM +0200, Rasmus Villemoes wrote:
> init_mm is sizeof(long) larger than it needs to be. Use the
> CPU_BITS_NONE macro meant for this, which will initialize just the
> indices 0...(BITS_TO_LONGS(NR_CPUS)-1) and hence make the array size
> actually BITS_TO_LONGS(NR_CPUS).

I've sent a similar patch [1] a week or so ago, it's in -mm tree.

[1] https://lore.kernel.org/linux-mm/1565703815-8584-1-git-send-email-rppt@linux.ibm.com/
 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  mm/init-mm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/init-mm.c b/mm/init-mm.c
> index a787a319211e..fb1e15028ef0 100644
> --- a/mm/init-mm.c
> +++ b/mm/init-mm.c
> @@ -35,6 +35,6 @@ struct mm_struct init_mm = {
>  	.arg_lock	=  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
>  	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
>  	.user_ns	= &init_user_ns,
> -	.cpu_bitmap	= { [BITS_TO_LONGS(NR_CPUS)] = 0},
> +	.cpu_bitmap	= CPU_BITS_NONE,
>  	INIT_MM_CONTEXT(init_mm)
>  };
> -- 
> 2.20.1
> 
> 

-- 
Sincerely yours,
Mike.


