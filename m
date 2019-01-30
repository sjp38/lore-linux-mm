Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD968C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:49:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 744C12083B
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:49:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 744C12083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF4708E0002; Wed, 30 Jan 2019 01:49:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7A978E0001; Wed, 30 Jan 2019 01:49:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F5868E0002; Wed, 30 Jan 2019 01:49:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FF888E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:49:06 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n39so27341632qtn.18
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 22:49:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=d1C9k7yPX3pP7ReCithAsC9izzMzAZ2txHGyt3W77P8=;
        b=J4uOQHkF8yVNy/InJAM13YgKkrv+F+mziCBIunaAZ/yp9V279QHJfr2x+udLSH+ZGI
         mapmT5m7/ALOylnt2eIfV1Jot3rKjyXuMXlvrYEHb98hKtGk5qleHL1XTfcYZJXQ/FKs
         WpudA1I+r/A0tl35Kj0m3RI6hxllQEqgEw0hzWezLO4bfKTQSZ7UnjPhh4C50tKt+IaP
         4qH3l/LgH9n7RiGgtwyG4uTRbGdMRNKbkudMJ8zkJGFeAvM5fStZH2xoj4JtG1LQ0XVJ
         YJ91tE91QS0RkFXtsZcss2ce8srcftSNVsCFz0/rTfTOW9wOEqYQZK4oKwn9s7Pm69af
         aLSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukdymPT7Y5FOETnSqCBEB6gj1mvXRo9X56rW9OuX9W5rZd+FGDnv
	soCfN5GoN6EtML+YDvIlPLG9uuRCEItJ7IcDTx2XCI78yoOM2Jy/td55qUThz8atYU3SRUKTg0R
	GroUMjgZqnmw2eNcXpK0KYt+XNSITMA5+V0TRCkss3NuT5Jn867n3Ydcb+WrwyiUVTQ==
X-Received: by 2002:ac8:32b2:: with SMTP id z47mr28394485qta.209.1548830946215;
        Tue, 29 Jan 2019 22:49:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6xeYP0n3t9UA2Z5jBw0t/mlsw8TfBVzq8RP/ACf33+0BbPvAcWo/IZ0/JbJyeBjBdweJbd
X-Received: by 2002:ac8:32b2:: with SMTP id z47mr28394457qta.209.1548830945555;
        Tue, 29 Jan 2019 22:49:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548830945; cv=none;
        d=google.com; s=arc-20160816;
        b=gXkqujzFdKyvn/MDekL18wTV/VgP7M5tnlHubuh3gcnD6T3MXUD2BeaT1n/u46Q/Iv
         KrfeMAv01ffJWrMpQoEJVLfZjz7Tp0Hgf4dhxTbbZdlyj9ngrlk9SH6LfX9shnIJvokG
         H6417fEtqU6kjigBY17axw9hSxcNAFdqdw5tkX6EQuTbb+sS3Gx+D3UKIQJ5/Vg5amfo
         804d5xuuAeTfCazqzz6eHAvF56QEnBgPrLjwx9AFcfpiwEvtlzN6tmEZ0RDiGK5LY8O6
         SPa4b7tjRIQK9yYadI0jYfjf3nIkGLJ29rZsQD0IBjQG3roXqN2rQsmdlp6tVPSo7yCB
         hmLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=d1C9k7yPX3pP7ReCithAsC9izzMzAZ2txHGyt3W77P8=;
        b=Sl3pQLOZgZV1rQ/w9ucBXngLvo3mbgVYhMVczy3zjq/9r6I886yGo9F640FR/Get+K
         ooHEAF3JS6LR3ScN56jUqdnyuWNPP+WaL049SwZJkBzerqz6j4X2SzbYCTpX40dwLc8r
         12+CmUAHvD/gq4BLaMtnxrwrzbghl+vGOUPxWviIF9y5i/TbEljydKPmGVYS5x9wltSv
         M9xfCp2oyzSQd+Zo/E+39dhOLHGAoQzwH0cdnsBRkldny41p78CFqyS/ldDPI3EqGSzq
         yGTPeY9SsKAUOg1QXDuTaRQOgRBmQJqHULku7sNKc7OWvXQz5pnvMgefkyXcCPICbg+a
         SBwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 38si465501qvi.108.2019.01.29.22.49.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 22:49:05 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0U6mQZj076549
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:49:05 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qb6e0hccs-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:49:04 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 30 Jan 2019 06:49:03 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 30 Jan 2019 06:48:59 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0U6mxWH6291890
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 30 Jan 2019 06:48:59 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F2824A4054;
	Wed, 30 Jan 2019 06:48:58 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 60BD1A405C;
	Wed, 30 Jan 2019 06:48:58 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.107])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 30 Jan 2019 06:48:58 +0000 (GMT)
Date: Wed, 30 Jan 2019 08:48:56 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154882453604.1338686.15108059741397800728.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154882453604.1338686.15108059741397800728.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19013006-0012-0000-0000-000002EEC23D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013006-0013-0000-0000-0000212607D6
Message-Id: <20190130064856.GB17937@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901300052
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 09:02:16PM -0800, Dan Williams wrote:
> Randomization of the page allocator improves the average utilization of
> a direct-mapped memory-side-cache. Memory side caching is a platform
> capability that Linux has been previously exposed to in HPC
> (high-performance computing) environments on specialty platforms. In
> that instance it was a smaller pool of high-bandwidth-memory relative to
> higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> be found on general purpose server platforms where DRAM is a cache in
> front of higher latency persistent memory [1].

[ ... ]
 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/list.h    |   17 ++++
>  include/linux/mmzone.h  |    4 +
>  include/linux/shuffle.h |   45 +++++++++++
>  init/Kconfig            |   23 ++++++
>  mm/Makefile             |    7 ++
>  mm/memblock.c           |    1 
>  mm/memory_hotplug.c     |    3 +
>  mm/page_alloc.c         |    6 +-
>  mm/shuffle.c            |  188 +++++++++++++++++++++++++++++++++++++++++++++++
>  9 files changed, 292 insertions(+), 2 deletions(-)
>  create mode 100644 include/linux/shuffle.h
>  create mode 100644 mm/shuffle.c

...

> diff --git a/mm/memblock.c b/mm/memblock.c
> index 022d4cbb3618..c0cfbfae4a03 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -17,6 +17,7 @@
>  #include <linux/poison.h>
>  #include <linux/pfn.h>
>  #include <linux/debugfs.h>
> +#include <linux/shuffle.h>

Nit: does not seem to be required

>  #include <linux/kmemleak.h>
>  #include <linux/seq_file.h>
>  #include <linux/memblock.h>

-- 
Sincerely yours,
Mike.

