Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92A16C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:47:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F474218C9
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:47:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F474218C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E74208E0003; Mon, 17 Jun 2019 02:47:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E24F18E0001; Mon, 17 Jun 2019 02:47:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D13828E0003; Mon, 17 Jun 2019 02:47:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id B191A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:47:08 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id y3so9844821ybp.23
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:47:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=cBzeiA0IaY8MwOTgArNgolw2queOIY9drPMnvBWU7ds=;
        b=kk3CLc5IVryY5CtRzazOX4R7SVt0WnqHNUdb+n5nACMV8VS1Dkp6Ehhjl9jkFdA/uw
         yKJMtDPkd8T9oBq3depXuqXYGZikCKz97dpEi3L1xvppaoADzGFrUuWPyhzAoX8GDsbF
         4saC6OWLSmNU4kdcb4cyvLC4UMcfiO07aVCp9/lHCc9RaHex6mO4+udCA3cyXHfLsmdD
         sip1rtIOsuxb1dYHQ9T6QLxlR2kzi3FxYX32ewXjYNS7/VyJg/vb/MwhMb+iN3ZsXy7A
         xf2EkIXeG9IwkuqsDcmNMMhxh4zdv8XdQ16qfDugqY/ENVC/v7awjtxAx0Mg3LD/Z/R1
         y/XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX98c4NpJu0MM8mjSlOEORbjugMdGJ53ekboniE5sbhdZY6Vvqd
	O04OeUlMunfNmkGCcthre5HmVMy7p3Y6X30IxSE3XwRrOsxzCr8rqUuQDymaXWed5BT9oV60g3y
	gmowDXJkuwMe3yITZlpS8McOc23TFkFAGt7xsfnO7UANtmBxd186Hc4tKgu52ASidew==
X-Received: by 2002:a81:1090:: with SMTP id 138mr59907462ywq.422.1560754028480;
        Sun, 16 Jun 2019 23:47:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4Hb6KQPbA4HKESpwHLcIVTVvCGXQm3fDBW90tx5sekCALm6YR2bd2v1WGTk/5l+hCVJQA
X-Received: by 2002:a81:1090:: with SMTP id 138mr59907455ywq.422.1560754027977;
        Sun, 16 Jun 2019 23:47:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560754027; cv=none;
        d=google.com; s=arc-20160816;
        b=tT3aQXKj/rArFrG5ky6+RgohpXLjG2eKfvw3dBH/tKJ+xiGiRnvqEhRFiZ0JXKPv7Y
         tWYvXdYhQfqMWCROtj1m94EHE6h4HjJTeyKncKPVbDCNUvinmzxa5hF5jBS7a/xEfmzn
         NHdoU56oZyRd4EWoF+6QVsFbrZnlctO557MRA0LT74Z81o2Qciu/sqRrLLO/VVZne1zt
         LVbbLy3H2MiZMt7qG5qPLItJ+/oQjVWb13CxEvuEjvbcA+bBngHmL0cOZqu8yMR6OAcZ
         BhlRTKbuibX3pe+8wPg3CFOTRQNKihke36mAjMKtfBGStHAl+tJdGm2c3X2Rdi3YfvGm
         J+MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=cBzeiA0IaY8MwOTgArNgolw2queOIY9drPMnvBWU7ds=;
        b=kor1XInK3S4l9B8RheE41ae0fa9yEuJOGGGZfKxnuAj5gT2l3kqY4aTw6B2H0CeCzT
         YKTO/4PgCJIvUmoAAiRZr8ouTW6bjhvl8JkY7HIvCcSyygkfKGfa/brUCqmqurhtl2n4
         NYsuzunK7JXcI1pKZJHdlboW6zKl5sJ8P3dic/Rdn15Kg2BFAf3K19Q9V0bEF6Mi8A0C
         Oy40Q9LJ3GUH7kiLoM+JHOdcsMDE0nHmRPytkOYjP0zPJTDci6SNdxYnkj/6Smvd6RKw
         pnRHZ5H1Gw2JLuvKKkA0tQ32i7c1eJOdr1r8bXxc00CNXCdNtYiTMdvjA98MJ1Dw3k6W
         drkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 133si3767518ywk.359.2019.06.16.23.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 23:47:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H6hkxc162111
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:47:07 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t63k6mhb8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:47:07 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 17 Jun 2019 07:47:05 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 07:46:58 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H6kvaZ37486936
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 06:46:57 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 869A5A405B;
	Mon, 17 Jun 2019 06:46:57 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ED690A4064;
	Mon, 17 Jun 2019 06:46:55 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 17 Jun 2019 06:46:55 +0000 (GMT)
Date: Mon, 17 Jun 2019 09:46:54 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: "Alastair D'Silva" <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>,
        Josh Poimboeuf <jpoimboe@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Jiri Kosina <jkosina@suse.cz>, Mukesh Ojha <mojha@codeaurora.org>,
        Arun KS <arunks@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/5] mm: Trigger bug on if a section is not found in
 __section_nr
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-2-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617043635.13201-2-alastair@au1.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19061706-0020-0000-0000-0000034AB4D6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061706-0021-0000-0000-0000219DF855
Message-Id: <20190617064653.GA16810@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170062
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 02:36:27PM +1000, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> If a memory section comes in where the physical address is greater than
> that which is managed by the kernel, this function would not trigger the
> bug and instead return a bogus section number.
> 
> This patch tracks whether the section was actually found, and triggers the
> bug if not.
> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> ---
>  mm/sparse.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index fd13166949b5..104a79fedd00 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -105,20 +105,23 @@ static inline int sparse_index_init(unsigned long section_nr, int nid)
>  int __section_nr(struct mem_section* ms)
>  {
>  	unsigned long root_nr;
> -	struct mem_section *root = NULL;
> +	struct mem_section *found = NULL;
> +	struct mem_section *root;
> 
>  	for (root_nr = 0; root_nr < NR_SECTION_ROOTS; root_nr++) {
>  		root = __nr_to_section(root_nr * SECTIONS_PER_ROOT);
>  		if (!root)
>  			continue;
> 
> -		if ((ms >= root) && (ms < (root + SECTIONS_PER_ROOT)))
> -		     break;
> +		if ((ms >= root) && (ms < (root + SECTIONS_PER_ROOT))) {
> +			found = root;
> +			break;
> +		}
>  	}
> 
> -	VM_BUG_ON(!root);
> +	VM_BUG_ON(!found);

Isn't it enough to check for root_nr == NR_SECTION_ROOTS?

> 
> -	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
> +	return (root_nr * SECTIONS_PER_ROOT) + (ms - found);

It'll still return a bogus section number with CONFIG_DEBUG_VM=n

>  }
>  #else
>  int __section_nr(struct mem_section* ms)
> -- 
> 2.21.0
> 

-- 
Sincerely yours,
Mike.

