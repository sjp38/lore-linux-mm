Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CAD2C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:41:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67125208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:41:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67125208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 054008E0002; Thu, 13 Jun 2019 17:41:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0033D6B026B; Thu, 13 Jun 2019 17:41:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E33998E0002; Thu, 13 Jun 2019 17:41:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A93B76B026A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:41:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f25so196566pfk.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:41:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qG/WQkwXePAB+gyLAH/PvDiSByYyw286H7U6qXxIHyk=;
        b=Mr7H4KlckqWmJVYV0+uSuEUPvhQ6sKg4Gn6ADk1/yTZhlbWwKoawApNo+E4jkFrKRU
         D68UTZjB27VRUaUWG4xrCQqvez/KF0SM6EKR3JIlXT19UyT9NwGapqLybZvyqRWQLjb2
         9d7XGD7mDk29OE8bh8VcNn/Peb0aFj2QY1FvepT5+OUtaUDeMaIngssG5R2Z24nuBr+r
         Ns7xnFrFRRTjnKlrYsY3tWePGIcoL/gcsDnDoNsRT4wrMOYtObvEnwxRZcd2lA5rHQGr
         Hi5SdFhvfUaEVd25txS12c+y72suBpJvjBrFqt/2ClHqJeLzWsC4VcAnKNLe97sD9/ey
         74Wg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVVPejo5qrcOg42AO4oaRfaRcUAnvVhlPIJiECnOLnJ+QcMcC2o
	88nG2h8PgCc2GZu5RB0QMpBsv3j960pltdfXrI4l2A1eACTxnf8vmAlmKXCJP126hujupbynKRh
	hsVMF0nSPz3RPfjNul6R64BGrp6fNht3gCC5TjP5VtFed/smX3pRDhO6sh39YBwVIFg==
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr7493589pje.125.1560462087318;
        Thu, 13 Jun 2019 14:41:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKO629nwIBco8na3UthW4VW46lZ9dlDM7hIY1k5kBJjYVfDFr3e87OROCuQlZvaUiR8AdE
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr7493551pje.125.1560462086569;
        Thu, 13 Jun 2019 14:41:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560462086; cv=none;
        d=google.com; s=arc-20160816;
        b=V1K2mBEnxwEIgbPrDrEjizomaVVhWhnqpwuzhSuI6wtXMBYBnL3EQOG2u+N7+aim+b
         IRVTnMeme3mNOCGEnfbEniE69ok+1c96xLIxYWQh8eKzVYHqQGYN0N4Rwx196aeUOtjO
         oXPXHBK4/4XQ/Gy0UoLWf51kcIEqMxGReMd177x2wVxj/m/0ZR3tZs0zRrd+dFu2RSck
         eyOuDXcaTE+bj7K/yiOHP21ABGq0coxiG1ssSk2CL/Aaq534/ecGaWnZzn50BP/Jk8ta
         pYuTK6LIxzjHuzYSIHm+8qxAupJuCfkPZ+fEF/GqXfzrLOb8InbjJagx0y6YBjPaZFYV
         mPUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qG/WQkwXePAB+gyLAH/PvDiSByYyw286H7U6qXxIHyk=;
        b=OfpbyDdn11RUkrAdf8en6K1eVmLNGnU72LJ6GnqB/Ug2IKlpbSGPY2lxTNHFM/AyQK
         BhsnPiex3t2rwasr6TuvXao3Dj0u8EFKBXcB6E7XhckN8Sh/qg3tC+4MPDDqsAn/D5M2
         Gyuaj3j4reODWvDcv3byEp/14lm/HjKH87VHsG9B+EX6zNpbiKwx4ASlBT4VsY4ONkX8
         JGDgLSej/+zQYwEOf5F4i5afIV/yOAVZYRqXy7k1nibMFg16lNnL9OrqdgRcrbpdpY7s
         mVyOTOFhTnX+oQpVbGSztAVQMFEr5/A+98mnDtAq7DQlQA5vHZsORW+ZpTtIlHG37XGV
         SOpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h9si674178pgs.397.2019.06.13.14.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 14:41:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 14:41:26 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 13 Jun 2019 14:41:25 -0700
Date: Thu, 13 Jun 2019 14:42:47 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	Shuah Khan <shuah@kernel.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv4 3/3] mm/gup_benchemark: add LONGTERM_BENCHMARK test in
 gup fast path
Message-ID: <20190613214247.GF32404@iweiny-DESK2.sc.intel.com>
References: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
 <1560422702-11403-4-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560422702-11403-4-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 06:45:02PM +0800, Pingfan Liu wrote:
> Introduce a GUP_LONGTERM_BENCHMARK ioctl to test longterm pin in gup fast
> path.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Keith Busch <keith.busch@intel.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Shuah Khan <shuah@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/gup_benchmark.c                         | 11 +++++++++--
>  tools/testing/selftests/vm/gup_benchmark.c | 10 +++++++---
>  2 files changed, 16 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
> index 7dd602d..83f3378 100644
> --- a/mm/gup_benchmark.c
> +++ b/mm/gup_benchmark.c
> @@ -6,8 +6,9 @@
>  #include <linux/debugfs.h>
>  
>  #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
> -#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> -#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
> +#define GUP_FAST_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> +#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 3, struct gup_benchmark)
> +#define GUP_BENCHMARK		_IOWR('g', 4, struct gup_benchmark)

But I really like this addition!  Thanks!

But why not just add GUP_FAST_LONGTERM_BENCHMARK to the end of this list (value
4)?  I know the user space test program is probably expected to be lock step
with this code but it seems odd to redefine GUP_LONGTERM_BENCHMARK and
GUP_BENCHMARK with this change.

Ira

>  
>  struct gup_benchmark {
>  	__u64 get_delta_usec;
> @@ -53,6 +54,11 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
>  			nr = get_user_pages_fast(addr, nr, gup->flags & 1,
>  						 pages + i);
>  			break;
> +		case GUP_FAST_LONGTERM_BENCHMARK:
> +			nr = get_user_pages_fast(addr, nr,
> +					(gup->flags & 1) | FOLL_LONGTERM,
> +					 pages + i);
> +			break;
>  		case GUP_LONGTERM_BENCHMARK:
>  			nr = get_user_pages(addr, nr,
>  					    (gup->flags & 1) | FOLL_LONGTERM,
> @@ -96,6 +102,7 @@ static long gup_benchmark_ioctl(struct file *filep, unsigned int cmd,
>  
>  	switch (cmd) {
>  	case GUP_FAST_BENCHMARK:
> +	case GUP_FAST_LONGTERM_BENCHMARK:
>  	case GUP_LONGTERM_BENCHMARK:
>  	case GUP_BENCHMARK:
>  		break;
> diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
> index c0534e2..ade8acb 100644
> --- a/tools/testing/selftests/vm/gup_benchmark.c
> +++ b/tools/testing/selftests/vm/gup_benchmark.c
> @@ -15,8 +15,9 @@
>  #define PAGE_SIZE sysconf(_SC_PAGESIZE)
>  
>  #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
> -#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> -#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
> +#define GUP_FAST_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> +#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 3, struct gup_benchmark)
> +#define GUP_BENCHMARK		_IOWR('g', 4, struct gup_benchmark)
>  
>  struct gup_benchmark {
>  	__u64 get_delta_usec;
> @@ -37,7 +38,7 @@ int main(int argc, char **argv)
>  	char *file = "/dev/zero";
>  	char *p;
>  
> -	while ((opt = getopt(argc, argv, "m:r:n:f:tTLUSH")) != -1) {
> +	while ((opt = getopt(argc, argv, "m:r:n:f:tTlLUSH")) != -1) {
>  		switch (opt) {
>  		case 'm':
>  			size = atoi(optarg) * MB;
> @@ -54,6 +55,9 @@ int main(int argc, char **argv)
>  		case 'T':
>  			thp = 0;
>  			break;
> +		case 'l':
> +			cmd = GUP_FAST_LONGTERM_BENCHMARK;
> +			break;
>  		case 'L':
>  			cmd = GUP_LONGTERM_BENCHMARK;
>  			break;
> -- 
> 2.7.5
> 

