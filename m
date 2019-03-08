Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E010C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 23:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23C5920645
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 23:09:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LhpYaZ+C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23C5920645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B861C8E0003; Fri,  8 Mar 2019 18:09:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0EB08E0002; Fri,  8 Mar 2019 18:09:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B0528E0003; Fri,  8 Mar 2019 18:09:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E02B8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 18:09:14 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id h6so17279917qke.18
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 15:09:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MlrqfkIJzhllHP39N+GxECtianeHnH71ODnNMXPX7j0=;
        b=DanyZ5hzKlIueX8y0AvsvwVNp9qAhQoWOLJ39ZJfaTFR2n++ICEKbeZuFNj/HK3ZVW
         xb+j45RXAmM/7Bz19eLRHaGFBxw9Q/VyDuARJ+aRLZq08WyOoxHwad/bMIe/UAXyt4a5
         SJABbduM8tej3rNNfpToLTMBRTrPq/7Hqj5wSgq+eanXy7Xba5qGt18hQ5jljnPSbbvH
         LcKFFqXPTX69RmcQ8dz/ARsJ21rwV1mb3kpb0HSvSxkUC5FAZ3WEyagRjjh7GTZPldrz
         RFubAazsKl1xOANRfJSKOE8nsbQ+Ul8SxVLzxFu5gnwJ6Bwf8i/2DPhOKBr8YYxI7/f0
         latA==
X-Gm-Message-State: APjAAAVmhXOx0q+nbXyhlXygvg2Aa4OgGkf1nkNc6LWD9xMBcjtvt67R
	lhWg0g+pLF6kuk7DTlLO1VRBt55/yc+J2y04cmALKW9cU0UoupxGNVLcNva/9YWPAuIJxFnF2gV
	zWDDogo2kostCpjt5x+5plka/LmKuN0T9WlWHp3x2ntFIpyQTfOc7Z0vCUOvXFOrAOg==
X-Received: by 2002:a37:370c:: with SMTP id e12mr15838824qka.64.1552086554151;
        Fri, 08 Mar 2019 15:09:14 -0800 (PST)
X-Google-Smtp-Source: APXvYqwYK/6GYir29ZRU+vWEFcrMgaYoXoYq2SHpDzOc9EFBdHRjBfSrolEPIeSGyNFvJqvmxPC8
X-Received: by 2002:a37:370c:: with SMTP id e12mr15838792qka.64.1552086553391;
        Fri, 08 Mar 2019 15:09:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552086553; cv=none;
        d=google.com; s=arc-20160816;
        b=GoCPF4vE7PtF+1VJ5+KUqlHZm3wmzGUHi+y8eywLeEhKt6y1i/kxiL7A3rCpSCMwGM
         yS1b6J7LM8acxBeiTw+FlPE3e3rdIbeX5h0u9H8GSNpyrmcphhOZvSzy/nmTysAlTdYZ
         q5KQCzd3vjGD9Zn0sad82ujo10v35OLfR8FshgC71Bd58HEvwXjl7Vemv95VPkiQvCLM
         jQSQQKtWQAXT7nV3E0cCZjCsUP+MGGSrAACC8lM2TjnOfwEt03XaOTFVsp4tXs4Y/dJw
         LJsYb76aMzGrxQlK/NR4mjt3aPPBXFx/fp/JgMCJAzWTCGtW8dpPQyNij5X+q9A59s4v
         tsYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=MlrqfkIJzhllHP39N+GxECtianeHnH71ODnNMXPX7j0=;
        b=X9L9AtVxwxTUtDCO3At0sdqmphJytdcBSeJvlzZFaUjccioyZHYp6Gbb5LIYfmsa/K
         npeZlqflbErk+nMk/OvdEL9ghmSkq9rsRIfoCT8omz/CqUhl+tIxsmYC70OExlyg+YpR
         Xa3nNX98MpPtk0ocg9pnpXUtmC5GuR+zYgX5wOvaCy+MLPOMlPPIPFvDYCqG0TESQS8F
         7m2upqL5VuyWIVVRt5hybAmYe4y5uUJzJmRw9JJmhzqqBOSTAh9s/2ttQ07PtJi2e8M6
         yHjUgyCD//GcBKHtkxlphC13vdtiSh21MpPOaH4TMUzsEbB/ouuHoWwkgppp5eQ16DKS
         /e0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LhpYaZ+C;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j37si5662389qtb.186.2019.03.08.15.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 15:09:13 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LhpYaZ+C;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x28Mxf6F034820;
	Fri, 8 Mar 2019 23:09:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=MlrqfkIJzhllHP39N+GxECtianeHnH71ODnNMXPX7j0=;
 b=LhpYaZ+Cto/lOfYldn+yp+D/UxbGdR5bCd2Bvox/AruamCjVdbBiyYAVFlcourm04krB
 IRhYETgocaxPaGyG+Ncw/3WdLztXJjDCDw1dEgyjiPLWgUydc2Mcoptm9PHcXtI+GiSo
 pE2qLZLFdKQiGuSQb8Wl4YmBFhx3dFQ1qPiauV9iZO6DAAqSuJ2wjSqHxoRpzWp/pq5L
 i4z5fsCxb/tq7ki1RN3PZ6r/iH1v7EnD417dQqj00EnR3NRN4ljJEf6umS6nCnmk/sUc
 HzoIb6/lcC3LttflgYPCJAF1Eh3Lu12zZjKds173TcPnKmMoYuIgsyph648c96bLNTpp cw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2qyh8utx7d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 08 Mar 2019 23:09:08 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x28N915f031222
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 8 Mar 2019 23:09:02 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x28N8xpB016212;
	Fri, 8 Mar 2019 23:08:59 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 08 Mar 2019 15:08:59 -0800
Subject: Re: [PATCH 2/2] hugetlb: use same fault hash key for shared and
 private mappings
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190308224823.15051-1-mike.kravetz@oracle.com>
 <20190308224823.15051-3-mike.kravetz@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <b3741e5a-2421-1f86-b688-58dc9bd501d2@oracle.com>
Date: Fri, 8 Mar 2019 15:08:57 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190308224823.15051-3-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9189 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=796 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903080159
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/8/19 2:48 PM, Mike Kravetz wrote:
>  mm/hugetlb.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 64ef640126cd..0527732c71f0 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3904,13 +3904,8 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
>  	unsigned long key[2];
>  	u32 hash;
>  
> -	if (vma->vm_flags & VM_SHARED) {
> -		key[0] = (unsigned long) mapping;
> -		key[1] = idx;
> -	} else {
> -		key[0] = (unsigned long) mm;
> -		key[1] = address >> huge_page_shift(h);
> -	}
> +	key[0] = (unsigned long) mapping;
> +	key[1] = idx;
>  
>  	hash = jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);

Duh!

If we no longer use mm and address they can be dropped from the function
arguments and all callers.  Before doing that, let's see if there is any
objection to using the same key for shared and private mappings.

-- 
Mike Kravetz

