Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17904C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:12:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA94120880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:12:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="TQQ9v9pE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA94120880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5557C6B0005; Mon,  5 Aug 2019 13:12:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52C126B0006; Mon,  5 Aug 2019 13:12:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41B536B0007; Mon,  5 Aug 2019 13:12:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2043F6B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:12:13 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q26so76453640qtr.3
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:12:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=M9bY9Pzah3vwaWk6X2k5w90BuewkWsP/a3iHmuqn4vU=;
        b=lH61GshVvwET+zlZwitNTrO4AOReXGOJBCvAU/73qse/HqII+a7r/G/eV8d9XlWvGr
         XmhOnUw0d+Lu5zKkAVzM++aMK7EdXHVTj2jKHX5fJzLZzU82VszU9yqDYCeqyHFHFgwY
         aMbsqSGgq4tjQwG4+cjqSunfZOc49SRySrjYcZkuI/g53RYjznsdNVs4kj2pCKfXZ4cH
         g1x2g/uf2TVk4XOYEGTxD4D9bmkHLEEL6JBYvs8r6DbYmY7jnRH1yhKXt7zHqcuBNTTo
         Oof4kOwE0IQp/rKE7BDwWTRoEV01UkCRk0A6qtjTVXDe9UAl6LcTJ99m5vrxnEYQ1fl3
         EIfA==
X-Gm-Message-State: APjAAAUkE0VmS1p+6b6pWa908uyH4BrfARXEge/gSmROkX1Mqk4JSvU0
	IdAzlCS/WqY2B6qCTEDj+ux56M3Dh9ro1Eb/mN6o/QC3Sihnc/BIF740veZ9KDULxhEa7bYEY+C
	WicHLx0H6/DE+FnnybextyDszc1W/+1Q0W8i9jDk+iAnx2bqB8Yw3dy3vTjHksnyUcw==
X-Received: by 2002:a37:dc45:: with SMTP id v66mr100487106qki.24.1565025132905;
        Mon, 05 Aug 2019 10:12:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwb8LMhswt61FU+MeDvafPz3ibD6R4PkAXmU8gmU2XqveFwr8e3QgT/Jx1pdbQ5YaydkCU5
X-Received: by 2002:a37:dc45:: with SMTP id v66mr100487063qki.24.1565025132355;
        Mon, 05 Aug 2019 10:12:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565025132; cv=none;
        d=google.com; s=arc-20160816;
        b=iQUuI0Up6+EKeVt4y966GS0vPEiIh4dhxJqYjW4Gu8hCFEZEoz8nUnjLBlLdFH6YAG
         Ibak/YsCRytvXoWCQw6CJW4fd5rZ+FyGSzaz+LopDMtc3xFzthoeXsbk089i7haA6Naj
         kp3FHPMmkVTI4te2Fvb/JkfKxKM8Wm0o6jksrw9P+4hzsgsUMrdvumMCi//9jb3Em77B
         6KIs3ytDzuZgC/40WZDuBYrSk+iLX4iF8mA+CI5WUdsyggqjJr7nYEOpicjIm52uEsTU
         XXTpmleaL/n+F3KC/UC7tBm+aGDVIVEzkwFRRdQ8DU8v9NDcsOs0wJD97Cmk5ojiri0c
         rUYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=M9bY9Pzah3vwaWk6X2k5w90BuewkWsP/a3iHmuqn4vU=;
        b=kvZ5bI3X2MVDF7yB4/R4ne+HWaehBQn3V8rHKkPi72rRSdVoIfROuf7pPRiKrgqbQf
         aEaMWfSaczchyw4rOGajDalnuyvhTaLCjLABcqC1YpQCmlKtKP3HAu2zN/h5Tfydhz3d
         dAQtHaZo8LeaB5s6TyvUXBU7Ust5AcSB+GVbhYpfnPHhwlKL/b4GOO56A3izHocPUgDV
         VVNRmZljopYtXE7z4RZqFyjRRgySXFaZsZRufKUREL2athZjGDNmaHs6WlzvEg3eBTSW
         ZNXXdMwHC3qDTtH7mBsmgHvKcDWKrdGL8oMO0o9jQC90XrlwyucYexsKMmB5e6o1RpGu
         u5rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=TQQ9v9pE;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v54si51215317qvc.169.2019.08.05.10.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 10:12:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=TQQ9v9pE;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75H3sjK061339;
	Mon, 5 Aug 2019 17:12:07 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=M9bY9Pzah3vwaWk6X2k5w90BuewkWsP/a3iHmuqn4vU=;
 b=TQQ9v9pEOnPEMUzjiwi5MhXEN+ROGs4/CPuW+WytrSx8AuAaSlFVE4Bov/MLshh3lxHo
 AM6p325OZus1x8S7qc2Ogvcl4fXYJGFl7w1156tSSoQhiPnUOu0Du3jCINBxd6ouU8S/
 IDAnhP9a4LttZwTBzvaGEmBZmTa1E0DZOu0+1ejqANDXzNe9o+WK2AK+mGZ9ftkJGo7H
 iqMf2OWXmw1WYLaEq6RfVUum3HiBeHCE7cvpSfFIC+hfdIfTzJAb5yG2ZgRMtvFyzXN5
 V3m7WZ1YzF4Qicfm+Srafye8yBK3uErKDqugpWUTkBCCAqvP+S6doBwMw8tN/v8yhtJP UQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2u51ptrpd9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 17:12:06 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75H6WBe000838;
	Mon, 5 Aug 2019 17:12:06 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2u50abxx9v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 17:12:05 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x75HC1OG030472;
	Mon, 5 Aug 2019 17:12:01 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 10:12:01 -0700
Subject: Re: [PATCH 3/3] hugetlbfs: don't retry when pool page allocations
 start to fail
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes
 <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190802223930.30971-1-mike.kravetz@oracle.com>
 <20190802223930.30971-4-mike.kravetz@oracle.com>
 <b7cb558b-ae88-ae87-425a-18f9f1553f00@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <dfb0f20f-7a2d-3228-5c0d-9da4793f575c@oracle.com>
Date: Mon, 5 Aug 2019 10:12:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <b7cb558b-ae88-ae87-425a-18f9f1553f00@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908050185
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908050185
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/5/19 2:28 AM, Vlastimil Babka wrote:
> On 8/3/19 12:39 AM, Mike Kravetz wrote:
>> When allocating hugetlbfs pool pages via /proc/sys/vm/nr_hugepages,
>> the pages will be interleaved between all nodes of the system.  If
>> nodes are not equal, it is quite possible for one node to fill up
>> before the others.  When this happens, the code still attempts to
>> allocate pages from the full node.  This results in calls to direct
>> reclaim and compaction which slow things down considerably.
>>
>> When allocating pool pages, note the state of the previous allocation
>> for each node.  If previous allocation failed, do not use the
>> aggressive retry algorithm on successive attempts.  The allocation
>> will still succeed if there is memory available, but it will not try
>> as hard to free up memory.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Looks like only part of the (agreed with) suggestions were implemented?

My bad, I pulled in the wrong patch.

> - set_max_huge_pages() returns -ENOMEM if nodemask can't be allocated,
> but hugetlb_hstate_alloc_pages() doesn't.

That is somewhat intentional.  The calling context of the two routines is
significantly different.   hugetlb_hstate_alloc_pages is called at boot time
to handle command line parameters.  And, hugetlb_hstate_alloc_pages does not
return a value as it is of type void.

We 'could' print out a warning here.  But, if we can't allocate a node mask
I am pretty sure we will not be able to boot.  I will add a comment.

> - there's still __GFP_NORETRY in nodemask allocations
> - (cosmetics) Mel pointed out that NODEMASK_FREE() works fine with NULL
> pointers

-- 
Mike Kravetz

