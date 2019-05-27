Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF26AC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:16:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65DF620883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:16:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65DF620883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7D8F6B0271; Mon, 27 May 2019 06:16:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2D276B0272; Mon, 27 May 2019 06:16:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F46B6B0273; Mon, 27 May 2019 06:16:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64EE16B0271
	for <linux-mm@kvack.org>; Mon, 27 May 2019 06:16:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a21so3688738pgh.11
        for <linux-mm@kvack.org>; Mon, 27 May 2019 03:16:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=VoZU80vjMSHcUl+cQ95tumijcV0EGe9EpepwnMY8E1g=;
        b=j58dSF92z9heTD6kcVx/2ozwlF8/Iu42h74DDLrclSYeg0RPGxRB5jelrfBwM2UjUq
         CWl1klUi8c5bC7H63isjaGZjI0hTWGTpUKGryT2Zi9v/Iyv01BV0uQSvhvlVdSDzxxkG
         EPnoKj99Kt5swiEDrj3Wd7IpDkc9h3zDswnjy69QI9PXgTozNb7ggpLEhjVVNvgXqGuD
         yiam7iXR8nSaYMIXxkaqGkA4rGrmxq1h3Or5tYFL2RWQSkVhtDZmkZryEls6TTG6Gmpp
         yh8QopJFM1EBEx4F85lWdt+Z3kEQ2Nlil3cP9P1EFhqA7FP5v8eN5EXDpkSLF7iZ9p45
         Fs8g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWhu/NrnJ8kHgCSFW8OLpzCIpxhS6A2IiubpZcmpfdDIP9qOp9N
	IQFh3mdqJVTLGPdHj0KPlHxOn8AoF699bfHn2M4lXNQWZfV8JZAJAzsQcCdxOKFSyob5LSc4t3l
	CYQQ76dnRgaJtqhK2UBtIS1DXCU4DLpiFnh5mvnVcWVxJYc1H4YJUvjQbMFNXUAA=
X-Received: by 2002:a17:902:a81:: with SMTP id 1mr80960854plp.287.1558952218067;
        Mon, 27 May 2019 03:16:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2g0nt5ZaTHo/vTD+9Wwif1o7m0t6pOmVxzqelDtXLQFxAU8SPLV8rx5jcDomRjbPJdB+J
X-Received: by 2002:a17:902:a81:: with SMTP id 1mr80960768plp.287.1558952217110;
        Mon, 27 May 2019 03:16:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558952217; cv=none;
        d=google.com; s=arc-20160816;
        b=mmS7XM5upSaw4fNFFnuhLQhJRR04ZT8jHsnOsV/7SzW4pk5pAQ/utJ6wKPicQyZmvt
         rYPNK0Byisw+rqQs49VeBrJydIKUdLt7Kj/oGknO9SsDqOIKnX/z4kCa7ttPtiH8ktTI
         Vc9YzjIlXEQvbRQIoWOs3Qra82P408chVxk7n8qSm5Fghin+q5eCzk+DauQvwn/pU/bE
         5K8YPD7UFAFCC/mGMoZm5fiazzdmm05rCSV+N960ekqgvjFybZvlS1ktOdpUowDlgYoc
         246FbonWx3KvhirsyJ8dUuC7L2CpTgYHcYBQ89zIjJCUOdZUTgMuK9pqcjrvdida5hr4
         Vd4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:reply-to:subject:cc:to
         :from:date;
        bh=VoZU80vjMSHcUl+cQ95tumijcV0EGe9EpepwnMY8E1g=;
        b=Jy12q73u+EfKiFoqwuoCCGHwgDb2tLiucWB6kZh6kQ7B0iKPY1k8ZSL8gFt0U3ICP/
         ZBnIgBzObeNvSrztlRoQyHAwdAY86xvw1RkmijzQZHBX+3RuZVnOERQXvSwd3a6EaLPh
         mExONFh6Zc66DeK5PyI7lgfetrgeQIGVU6p9YBMG9PHJuN4RpXq6uzQ1S4oImDd3FlAI
         09QxLMgd29dtnr2peciS3feVyJyVvIlKEKqHdjx4xcopplZ99+GmabBjd17jApO5e0QC
         f5Z1CXwnJS7sMrAfFwr4Lq/6y7zRK75Hjfmp7bXFrb3iSBv/HSS7QAbv9v+cWa2TVQ4U
         80Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q20si20467813pfg.172.2019.05.27.03.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 03:16:57 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4RADNKY104722
	for <linux-mm@kvack.org>; Mon, 27 May 2019 06:16:56 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2srcf3wfm4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 May 2019 06:16:56 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 27 May 2019 11:16:55 +0100
Received: from b01cxnp22033.gho.pok.ibm.com (9.57.198.23)
	by e11.ny.us.ibm.com (146.89.104.198) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 27 May 2019 11:16:48 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4RAFWrv38928602
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 27 May 2019 10:15:33 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DFDC9B2065;
	Mon, 27 May 2019 10:15:32 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A8833B205F;
	Mon, 27 May 2019 10:15:32 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.80.199.73])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 27 May 2019 10:15:32 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 482C916C3573; Mon, 27 May 2019 03:15:36 -0700 (PDT)
Date: Mon, 27 May 2019 03:15:36 -0700
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
        Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        Tim Chen <tim.c.chen@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>,
        Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm] mm, swap: Simplify total_swapcache_pages() with
 get_swap_device()
Reply-To: paulmck@linux.ibm.com
References: <20190527082714.12151-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190527082714.12151-1-ying.huang@intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19052710-2213-0000-0000-000003965E56
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011171; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01209261; UDB=6.00635237; IPR=6.00990287;
 MB=3.00027069; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-27 10:16:53
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052710-2214-0000-0000-00005E99536B
Message-Id: <20190527101536.GI28207@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-27_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905270073
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 04:27:14PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> total_swapcache_pages() may race with swapper_spaces[] allocation and
> freeing.  Previously, this is protected with a swapper_spaces[]
> specific RCU mechanism.  To simplify the logic/code complexity, it is
> replaced with get/put_swap_device().  The code line number is reduced
> too.  Although not so important, the swapoff() performance improves
> too because one synchronize_rcu() call during swapoff() is deleted.

I am guessing that total_swapcache_pages() is not used on any
fastpaths, but must defer to others on this.  Of course, if the
performance/scalability of total_swapcache_pages() is important,
benchmarking is needed.

But where do I find get_swap_device() and put_swap_device()?  I do not
see them in current mainline.

							Thanx, Paul

> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
> Cc: Andrea Parri <andrea.parri@amarulasolutions.com>
> ---
>  mm/swap_state.c | 28 ++++++++++------------------
>  1 file changed, 10 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index f509cdaa81b1..b84c58b572ca 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -73,23 +73,19 @@ unsigned long total_swapcache_pages(void)
>  	unsigned int i, j, nr;
>  	unsigned long ret = 0;
>  	struct address_space *spaces;
> +	struct swap_info_struct *si;
> 
> -	rcu_read_lock();
>  	for (i = 0; i < MAX_SWAPFILES; i++) {
> -		/*
> -		 * The corresponding entries in nr_swapper_spaces and
> -		 * swapper_spaces will be reused only after at least
> -		 * one grace period.  So it is impossible for them
> -		 * belongs to different usage.
> -		 */
> -		nr = nr_swapper_spaces[i];
> -		spaces = rcu_dereference(swapper_spaces[i]);
> -		if (!nr || !spaces)
> +		/* Prevent swapoff to free swapper_spaces */
> +		si = get_swap_device(swp_entry(i, 1));
> +		if (!si)
>  			continue;
> +		nr = nr_swapper_spaces[i];
> +		spaces = swapper_spaces[i];
>  		for (j = 0; j < nr; j++)
>  			ret += spaces[j].nrpages;
> +		put_swap_device(si);
>  	}
> -	rcu_read_unlock();
>  	return ret;
>  }
> 
> @@ -611,20 +607,16 @@ int init_swap_address_space(unsigned int type, unsigned long nr_pages)
>  		mapping_set_no_writeback_tags(space);
>  	}
>  	nr_swapper_spaces[type] = nr;
> -	rcu_assign_pointer(swapper_spaces[type], spaces);
> +	swapper_spaces[type] = spaces;
> 
>  	return 0;
>  }
> 
>  void exit_swap_address_space(unsigned int type)
>  {
> -	struct address_space *spaces;
> -
> -	spaces = swapper_spaces[type];
> +	kvfree(swapper_spaces[type]);
>  	nr_swapper_spaces[type] = 0;
> -	rcu_assign_pointer(swapper_spaces[type], NULL);
> -	synchronize_rcu();
> -	kvfree(spaces);
> +	swapper_spaces[type] = NULL;
>  }
> 
>  static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
> -- 
> 2.20.1
> 

