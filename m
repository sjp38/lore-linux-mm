Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C389C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 03:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6C082081B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 03:32:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="0YHZ2hC0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6C082081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29E598E0071; Mon,  4 Feb 2019 22:32:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24F378E001C; Mon,  4 Feb 2019 22:32:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13F028E0071; Mon,  4 Feb 2019 22:32:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id DAA238E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 22:32:38 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id l69so1659450ywb.7
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 19:32:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=y85zs9UGaDCwwFujUVF8P4zph5S0V/iR+3TmStl4CvE=;
        b=e5jwGNndENztMbbFAJn5QBHLLzH6N90nhEGA0i79Hi84xudkD5knUpTskbGdHIzLK5
         YSZft2XkEqRrrzkGGxmoFF18VNBQljmY6lzLA1Nym+KthltO7jkbOX21CDOPDVpsOgAD
         BPtjpZyUxJEOzJGaSQCfdV/fhDaTbXN25jGZ1vM2mRgWDEpq5Ck9rDwI7DDFVmVlUG7E
         BCua80dzLgK94bAhQKSNItBIRDTC9Ho7DYCiNH0AVwJDtTSvHdZQhNrRVD3QJL//7MCw
         RidSGJHVi8BszCWGLalgBVPMjIPIqSPmFAdVgcF0SefR/Ec/lKcEeEFEnHys9BPDhpw1
         l8bw==
X-Gm-Message-State: AHQUAuZgRpgLV43T9uczhi0/wOcGNfrdAJa+j05VUsZxszP0YeFxECRD
	ceEx6xpK6HXhndWHejM+L1OLJRfWpNEWMUYQ24sGvy+YZ2b7nrbv5kGjKq0soyo1weh7hGajMWX
	ctGdoUhpxJbpw+4eYe6iUZR90q3y9jQXVe181JpDewxtYAfK4op7dWLEql6gudAQYuA==
X-Received: by 2002:a81:3e05:: with SMTP id l5mr2247371ywa.508.1549337558519;
        Mon, 04 Feb 2019 19:32:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYUMA4Ir92rC2c23pLfsnMhzlJkjOoTlvtqJen/m5q7YyNKw51z+92JHgoOP7cdAL6Y20GC
X-Received: by 2002:a81:3e05:: with SMTP id l5mr2247343ywa.508.1549337557758;
        Mon, 04 Feb 2019 19:32:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549337557; cv=none;
        d=google.com; s=arc-20160816;
        b=wmoU+EEe4d1gx6vSVVhSt8fecEmx4ZDQwu7DEOw43OAfdb1YpFGc303g3na2gTMhJD
         U3VCwkEI186NCvNK/QQ3TglSuCZsc9LhsJlcBreJaXfdVSKi2AhgZFPRQa9IJckbLnZM
         ddlyaVnY4BOZZ/fDKIkdvQKekg6pJ0HNmQlwzdH1BNYPR6p50mDq12JRyT4CUHQjX1FK
         IidK6jWN4kAUFzYxwb/rBH0VDILtz9l/GpkK3iUsL8ZjVDpQRrYcX2b2HCymtVVIziSc
         u7FpB2qMxP/ocxdJECumoII8X/ATzhRGvWvgkujZpeFGetvabEhIz61gihkl4Covzujq
         Tt1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=y85zs9UGaDCwwFujUVF8P4zph5S0V/iR+3TmStl4CvE=;
        b=otNEKHTwPp1CAsm7GIHLEUOCbuiB6Gf2EHFp1KCIAX+Z+qe23jEdf0n00+GyiX6h+P
         iPC0Vc1bR8Lfu5rka2sC3/82/3Xgda6gl+PAXRi5JeoXqn3BKuN9+SRMbXRbNA/xgIG9
         jIHALWFVqYid6AMgfeqLdEir1Duvi9FDkJfTlRVkaCApIv/FrNruUVGYhaE5IqyhQ/0F
         wf0lgHrbMeKc4QLd8ORMtuw3iBdot3/IuV5vdXwVhGwX7wNyiQXq8H6YaZFgKa/ijaWN
         B3OF2am523aT8HHTGTdzpkHj3aXUn9AqVDL+UwmcRLi0dab85mBNK6uDvuwkIlJR5cai
         xuNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0YHZ2hC0;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i11si1185198ybq.378.2019.02.04.19.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 19:32:37 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0YHZ2hC0;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x153STN3084138;
	Tue, 5 Feb 2019 03:32:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=y85zs9UGaDCwwFujUVF8P4zph5S0V/iR+3TmStl4CvE=;
 b=0YHZ2hC0P2YndbBnJu4LdDavIcqssytST9ziURfDZoVQtM79pAWPudRr6YIeuqP31Znb
 0b8IdGiDWSB3CqruZsSCV3H3gcYGwbKDM5c7SBwg3vMbSxZeG9us8ZcP8vsjnGBlJj2D
 SQ3w7HwScOsb3HCPzG5OYbchO9XLMKiTOfWidbocwliDLrgKg/imC2bdvfebvXDRINak
 qb1lV1xshPJ7XYfDfyEemEt5bUjfigkcVQCB6HPmg2nf5V4vEx8+e/JvQMOtYJOHoRyf
 l16ABx9HE/NLsJYQcTEeDFYWuPar/0uaBJZc/9SFrr6RP/e8jdHQq/hQBrANNk6fSkNX zA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2qd98n0q5b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 05 Feb 2019 03:32:35 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x153WZUA028028
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 5 Feb 2019 03:32:35 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x153WX8r009311;
	Tue, 5 Feb 2019 03:32:34 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 05 Feb 2019 03:32:33 +0000
Subject: Re: [PATCH -next] hugetlbfs: a terminator for hugetlb_param_specs[]
To: Qian Cai <cai@lca.pw>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
References: <20190205012224.65672-1-cai@lca.pw>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ce8d60c2-5166-6c40-011f-4dff8dc25ebe@oracle.com>
Date: Mon, 4 Feb 2019 19:32:32 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190205012224.65672-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9157 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902050025
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/4/19 5:22 PM, Qian Cai wrote:
> Booting up an arm64 server with CONFIG_VALIDATE_FS_PARSER=n triggers a
> out-of-bounds error below, due to the commit 2284cf59cbce ("hugetlbfs:
> Convert to fs_context") missed a terminator for hugetlb_param_specs[],
> and causes this loop in fs_lookup_key(),
> 
> for (p = desc->specs; p->name; p++)
> 
> could not exit properly due to p->name is never be NULL.
> 
> [   91.575203] BUG: KASAN: global-out-of-bounds in fs_lookup_key+0x60/0x94
> [   91.581810] Read of size 8 at addr ffff200010deeb10 by task mount/2461
> [   91.597350] Call trace:
> [   91.597357]  dump_backtrace+0x0/0x2b0
> [   91.597361]  show_stack+0x24/0x30
> [   91.597373]  dump_stack+0xc0/0xf8
> [   91.623263]  print_address_description+0x64/0x2b0
> [   91.627965]  kasan_report+0x150/0x1a4
> [   91.627970]  __asan_report_load8_noabort+0x30/0x3c
> [   91.627974]  fs_lookup_key+0x60/0x94
> [   91.627977]  fs_parse+0x104/0x990
> [   91.627986]  hugetlbfs_parse_param+0xc4/0x5e8
> [   91.651081]  vfs_parse_fs_param+0x2e4/0x378
> [   91.658118]  vfs_parse_fs_string+0xbc/0x12c
> [   91.658122]  do_mount+0x11f0/0x1640
> [   91.658125]  ksys_mount+0xc0/0xd0
> [   91.658129]  __arm64_sys_mount+0xcc/0xe4
> [   91.658137]  el0_svc_handler+0x28c/0x338
> [   91.681740]  el0_svc+0x8/0xc
> 
> Fixes: 2284cf59cbce ("hugetlbfs: Convert to fs_context")
> Signed-off-by: Qian Cai <cai@lca.pw>

Thanks for fixing this.  Looks like a simple oversight when 2284cf59cbce
was added.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

I just started looking at the new mount API now.  It would be good if
David also took a look to make sure everything else is OK.

FYI David, the fs_parameter_spec example in the documentation (mount_api.txt)
is also missing a terminator.
-- 
Mike Kravetz

> ---
>  fs/hugetlbfs/inode.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index abf0c2eb834e..4f352743930f 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -81,6 +81,7 @@ static const struct fs_parameter_spec hugetlb_param_specs[] = {
>  	fsparam_string("pagesize",	Opt_pagesize),
>  	fsparam_string("size",		Opt_size),
>  	fsparam_u32   ("uid",		Opt_uid),
> +	{}
>  };
>  
>  static const struct fs_parameter_description hugetlb_fs_parameters = {
> 

