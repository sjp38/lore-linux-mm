Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50370C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:59:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E463206BA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:59:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E463206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6F468E001B; Mon, 11 Mar 2019 07:59:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1E848E0002; Mon, 11 Mar 2019 07:59:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90E6A8E001B; Mon, 11 Mar 2019 07:59:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFD68E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:59:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x17so5867937pfn.16
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 04:59:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=LVKsj2RASlREhHmMLDLyaiyuoK6HBltB58cGNLVvY90=;
        b=gFXDFzPM02FYRwKkWGJu02fWjfz7uaGsRD/bj66/ZLJCsJy59g8qQfzTx0WgFY9/0+
         fVttCFkCKEVUHG1SZuzjuXa/TANzTU0TsYLYyv0MhWJMlQFroziomaXWr6A2IiY3kCj3
         Q4+DjR34MD8DoIXr5WZgn8Fc+SfN9md3eL8/1TRkxFOFGPedI+FkO07hpsRcCReTsP+F
         dIATNNH7Y87v7ZeRvorDHMu40uiQvHBMmQXXW8i38G3oI7SooRCh8BtyHae/oaa6q2Cg
         m+8EMojoBV+kAnX9D5v88pGlFY6MaQhpvfe4rKSKbwqH+9zKPS+Su3ERU4vRM9El4RdU
         7xfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWFuVNmMMAI2YSYpbFXKYLWQv1pr+07n97fFQwQYoa/t1v0HK5W
	wSPmophclNR+shU8u9qo6QresxLMS6ujx2kvFWfWiLSfcPbarsYnMlYqPh+4kdInCq9KKMu7aAT
	f7p2missneAQHbq93ipdv9DPDr4w9k6/akqH2F9ty2t5XtRzMPTpZO9qHjsmacc4z6A==
X-Received: by 2002:a17:902:e50b:: with SMTP id ck11mr34223823plb.25.1552305560992;
        Mon, 11 Mar 2019 04:59:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzer1QthdqgZhyDxq+EoRziCHmzFwrfhNy7vI5FmX4YfI+BpBIO2o1guYXDQDRbY4C/YPq4
X-Received: by 2002:a17:902:e50b:: with SMTP id ck11mr34223774plb.25.1552305560063;
        Mon, 11 Mar 2019 04:59:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552305560; cv=none;
        d=google.com; s=arc-20160816;
        b=usqV5b007KXb2ugTPJqFL5vIn/AmDUsm/ta7WKxn/iwE+uZOc7tNjWPF8Ak7IHz6R0
         9qck+bhH4PIOx2JfGAGSiHc/dkXQ2ljFz1lGkJAdM/tVjHjfEP7YlNTU25yUVwt+UIl2
         QuqoXbfex9VLZSeqBPmmKAw0fcVe3YWPy5axvsPbHBrwUgCcN319SJFKAC9gqKYAnnSF
         TYLzLwPqfD09EpZmYyzti4HviNQn0BDzTux3x8IGqs71vTZYMTyT4ynPTCf+x2bl/SBm
         +MZOnl9GtWX9qL70A53Sbfr9voyXvb9uRMHaCoS2Aj2SyR6csx7SJuk8tA2c750WZdQX
         7ASw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=LVKsj2RASlREhHmMLDLyaiyuoK6HBltB58cGNLVvY90=;
        b=SkVzPpwSKFabr85rhGg0PdUOBHz+3Xm85K1zzP1ONvT2Gt2hed2w1pmlGF7A/VgD9x
         eGq6UER/xGGTyXGLPmptvcmovMOvUzelMaT9D6LumDkeekJdnaYqSXrm1MAPZA463nQY
         f53/pqDTFrj8ehtEt8UWKMMdn14bw1IyKg71JDa1xaf0wacraspTj39+mPPBm3pyQHLX
         y7jw9mZYoYkxRCGyCqWSkitKV/MAN5j4DcntCjEBbKPDEGEERBdzDyyrBuNvedVmNyqY
         rNDWk2Hn8mhH3xLq5u5IHElq7XItgNL8jm6bPbC/D65IUOV5JIDJExMI7r255J2oLxR0
         fxow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x7si5342050plr.73.2019.03.11.04.59.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 04:59:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2BBwr4B075827
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:59:19 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r5mn5y2cm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:59:18 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 11 Mar 2019 11:59:14 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 11 Mar 2019 11:59:11 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2BBxAMQ52166772
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Mar 2019 11:59:10 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3DE104C044;
	Mon, 11 Mar 2019 11:59:10 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A67F74C05A;
	Mon, 11 Mar 2019 11:59:07 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.35.189])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 11 Mar 2019 11:59:07 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>,
        Chandan Rajendra <chandan@linux.ibm.com>, Jan Kara <jack@suse.cz>,
        stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn()
In-Reply-To: <20190311084537.16029-1-jack@suse.cz>
References: <20190311084537.16029-1-jack@suse.cz>
Date: Mon, 11 Mar 2019 17:29:05 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19031111-0012-0000-0000-000003013D3F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031111-0013-0000-0000-000021385852
Message-Id: <874l89wrjq.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-11_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903110091
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Jan Kara <jack@suse.cz> writes:

> Aneesh has reported that PPC triggers the following warning when
> excercising DAX code:
>
> [c00000000007610c] set_pte_at+0x3c/0x190
> LR [c000000000378628] insert_pfn+0x208/0x280
> Call Trace:
> [c0000002125df980] [8000000000000104] 0x8000000000000104 (unreliable)
> [c0000002125df9c0] [c000000000378488] insert_pfn+0x68/0x280
> [c0000002125dfa30] [c0000000004a5494] dax_iomap_pte_fault.isra.7+0x734/0xa40
> [c0000002125dfb50] [c000000000627250] __xfs_filemap_fault+0x280/0x2d0
> [c0000002125dfbb0] [c000000000373abc] do_wp_page+0x48c/0xa40
> [c0000002125dfc00] [c000000000379170] __handle_mm_fault+0x8d0/0x1fd0
> [c0000002125dfd00] [c00000000037a9b0] handle_mm_fault+0x140/0x250
> [c0000002125dfd40] [c000000000074bb0] __do_page_fault+0x300/0xd60
> [c0000002125dfe20] [c00000000000acf4] handle_page_fault+0x18
>
> Now that is WARN_ON in set_pte_at which is
>
>         VM_WARN_ON(pte_hw_valid(*ptep) && !pte_protnone(*ptep));
>
> The problem is that on some architectures set_pte_at() cannot cope with
> a situation where there is already some (different) valid entry present.
>
> Use ptep_set_access_flags() instead to modify the pfn which is built to
> deal with modifying existing PTE.
>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

> CC: stable@vger.kernel.org
> Fixes: b2770da64254 "mm: add vm_insert_mixed_mkwrite()"
> Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/memory.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 47fe250307c7..ab650c21bccd 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1549,10 +1549,12 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  				WARN_ON_ONCE(!is_zero_pfn(pte_pfn(*pte)));
>  				goto out_unlock;
>  			}
> -			entry = *pte;
> -			goto out_mkwrite;
> -		} else
> -			goto out_unlock;
> +			entry = pte_mkyoung(*pte);
> +			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +			if (ptep_set_access_flags(vma, addr, pte, entry, 1))
> +				update_mmu_cache(vma, addr, pte);
> +		}
> +		goto out_unlock;
>  	}
>  
>  	/* Ok, finally just insert the thing.. */
> @@ -1561,7 +1563,6 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  	else
>  		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
>  
> -out_mkwrite:
>  	if (mkwrite) {
>  		entry = pte_mkyoung(entry);
>  		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> -- 
> 2.16.4

