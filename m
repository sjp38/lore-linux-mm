Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9967EC10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:58:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48E64217F9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:58:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48E64217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBCE58E0003; Tue, 26 Feb 2019 01:58:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6E988E0002; Tue, 26 Feb 2019 01:58:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5BC18E0003; Tue, 26 Feb 2019 01:58:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 93F6D8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:58:50 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 38so9144980pld.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:58:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=2WWzT3rz4bbXAxII1CGemZY98x+RjXqR2DFtssT5kCs=;
        b=rjZ03SL1m0nlYB3tW/MOO9CXuZM7PW1DnjZdf22I2DbSrKelRseJcVbNJg6USIePSH
         kTLx211wfePsUXhTreJiw9iJ6SXp6RLg7cdu/DaCqsiLzDy+5UKVqj1YFaZEggTXqWvs
         J58sRuxs2ra/UMOD2+xcBfTWVXz8jlvDbqyQkQ230Vwpg6V2Camyh01o/04LKmmlZjmx
         6BTDpn0DiVmPEA2VJqGmz0T5zNCk1o7uCTjOa4QwEWayPf16wLStWKDIfn6omY9raagN
         y/g+tA09uUhOHOVXLgXIT9ukQWA9fP2W//zV3BdeWpPM60H3N/cwP0LSGeMDJ7b+tJLo
         HoNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubqeZrHP2jinaysX9iTj0F6YGi5CHPu/ayRo+/wgdrP9xO2fSCo
	JngHiao/gNWDWvXF2cpUID03dlQylT+6NyDysp5pRHj5MhJYO/Gu+d+28j1fjY90qjUrgwOdakO
	V3fkKUmlHUOZG5LAiji6yDXOP53xoYiOPkbKk9oOIqKt8SsIhWuV4db88q7M22nBMrg==
X-Received: by 2002:a62:e086:: with SMTP id d6mr24543569pfm.247.1551164330253;
        Mon, 25 Feb 2019 22:58:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia77dv6IIp0r0YJFbQGTqJv8fKC3VXyhcxi2UqU8ta6Dop6sZAq4AUclJo0QdqOZNwLyNbC
X-Received: by 2002:a62:e086:: with SMTP id d6mr24543532pfm.247.1551164329204;
        Mon, 25 Feb 2019 22:58:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551164329; cv=none;
        d=google.com; s=arc-20160816;
        b=B5Wdr0gO15VwhyzHLJXnQrI3c4SYjbB7BIxwmAGRv+8ck21XB7NjxpgTcShxnEIegM
         ZZKrn0Fa/WrxneiAnZM0R7qN07S6ojE9CPmyPZL9GTcEiUURryBjjTpeMc3J7+bVCriR
         WADDBfcqQPaw1O3CWXKulojuCISCX5wVPZuIdu/A+SQJo37WuFNwzZaGZZcOZjvk6q7D
         L3RElrtbd/MX6VUXFCd5/D0wnekDBa4Q9fHRrGdbj/k7JaQIXPLjN88SZ1SQAzxZyQ1/
         Q9njTfPpbi+g8k1FujDKNMaypvMK/G5HTpodtuFWmrUepaVk1FuWUnef6aH4hPZ7BLs6
         aU5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=2WWzT3rz4bbXAxII1CGemZY98x+RjXqR2DFtssT5kCs=;
        b=O7S5m4mbQhvwd54NAg2JCw9VAyR4qUxrdyXIIKn1yGhksjIQNdX7McRRX+KZ3O6Fyo
         L12mCWRXyMqbC7LKN1CH8k+bolVVSJlH1uRayPMrfP4sNZDlTR+TSrr4mq5/xVsVYdgh
         RoXz9V+9G5meReSG7VLKh2kLtF0l1ZNpB3051bNRHycwqCFn2s3WmNAJcFIsLSSwbVwn
         KsPC1pPPwhWJmoCwh/THxugHG7mQNT7SfEAprtSt5Mw1L4BZfxwEpb7dbyAGxlE8WQSg
         +NSe8V/aQwtiaq/1+MMbzP/IT8SlR+W2GGXtqDcqow08ZrHfPf1EQ09eCob2PVdImdGE
         dG9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d9si8602908pln.403.2019.02.25.22.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:58:49 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q6wZ8g057070
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:58:48 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvx1veuwf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:58:48 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 06:58:45 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 06:58:41 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q6weTH30146636
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 06:58:40 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1301B52050;
	Tue, 26 Feb 2019 06:58:40 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 9DAC05204F;
	Tue, 26 Feb 2019 06:58:38 +0000 (GMT)
Date: Tue, 26 Feb 2019 08:58:36 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 26/26] userfaultfd: selftests: add write-protect test
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-27-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-27-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022606-0008-0000-0000-000002C4F51C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022606-0009-0000-0000-000022313CE8
Message-Id: <20190226065836.GD5873@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260053
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:32AM +0800, Peter Xu wrote:
> This patch adds uffd tests for write protection.
> 
> Instead of introducing new tests for it, let's simply squashing uffd-wp
> tests into existing uffd-missing test cases.  Changes are:
> 
> (1) Bouncing tests
> 
>   We do the write-protection in two ways during the bouncing test:
> 
>   - By using UFFDIO_COPY_MODE_WP when resolving MISSING pages: then
>     we'll make sure for each bounce process every single page will be
>     at least fault twice: once for MISSING, once for WP.
> 
>   - By direct call UFFDIO_WRITEPROTECT on existing faulted memories:
>     To further torture the explicit page protection procedures of
>     uffd-wp, we split each bounce procedure into two halves (in the
>     background thread): the first half will be MISSING+WP for each
>     page as explained above.  After the first half, we write protect
>     the faulted region in the background thread to make sure at least
>     half of the pages will be write protected again which is the first
>     half to test the new UFFDIO_WRITEPROTECT call.  Then we continue
>     with the 2nd half, which will contain both MISSING and WP faulting
>     tests for the 2nd half and WP-only faults from the 1st half.
> 
> (2) Event/Signal test
> 
>   Mostly previous tests but will do MISSING+WP for each page.  For
>   sigbus-mode test we'll need to provide standalone path to handle the
>   write protection faults.
> 
> For all tests, do statistics as well for uffd-wp pages.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  tools/testing/selftests/vm/userfaultfd.c | 154 ++++++++++++++++++-----
>  1 file changed, 126 insertions(+), 28 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
> index e5d12c209e09..57b5ac02080a 100644
> --- a/tools/testing/selftests/vm/userfaultfd.c
> +++ b/tools/testing/selftests/vm/userfaultfd.c
> @@ -56,6 +56,7 @@
>  #include <linux/userfaultfd.h>
>  #include <setjmp.h>
>  #include <stdbool.h>
> +#include <assert.h>
> 
>  #include "../kselftest.h"
> 
> @@ -78,6 +79,8 @@ static int test_type;
>  #define ALARM_INTERVAL_SECS 10
>  static volatile bool test_uffdio_copy_eexist = true;
>  static volatile bool test_uffdio_zeropage_eexist = true;
> +/* Whether to test uffd write-protection */
> +static bool test_uffdio_wp = false;
> 
>  static bool map_shared;
>  static int huge_fd;
> @@ -92,6 +95,7 @@ pthread_attr_t attr;
>  struct uffd_stats {
>  	int cpu;
>  	unsigned long missing_faults;
> +	unsigned long wp_faults;
>  };
> 
>  /* pthread_mutex_t starts at page offset 0 */
> @@ -141,9 +145,29 @@ static void uffd_stats_reset(struct uffd_stats *uffd_stats,
>  	for (i = 0; i < n_cpus; i++) {
>  		uffd_stats[i].cpu = i;
>  		uffd_stats[i].missing_faults = 0;
> +		uffd_stats[i].wp_faults = 0;
>  	}
>  }
> 
> +static void uffd_stats_report(struct uffd_stats *stats, int n_cpus)
> +{
> +	int i;
> +	unsigned long long miss_total = 0, wp_total = 0;
> +
> +	for (i = 0; i < n_cpus; i++) {
> +		miss_total += stats[i].missing_faults;
> +		wp_total += stats[i].wp_faults;
> +	}
> +
> +	printf("userfaults: %llu missing (", miss_total);
> +	for (i = 0; i < n_cpus; i++)
> +		printf("%lu+", stats[i].missing_faults);
> +	printf("\b), %llu wp (", wp_total);
> +	for (i = 0; i < n_cpus; i++)
> +		printf("%lu+", stats[i].wp_faults);
> +	printf("\b)\n");
> +}
> +
>  static int anon_release_pages(char *rel_area)
>  {
>  	int ret = 0;
> @@ -264,19 +288,15 @@ struct uffd_test_ops {
>  	void (*alias_mapping)(__u64 *start, size_t len, unsigned long offset);
>  };
> 
> -#define ANON_EXPECTED_IOCTLS		((1 << _UFFDIO_WAKE) | \
> -					 (1 << _UFFDIO_COPY) | \
> -					 (1 << _UFFDIO_ZEROPAGE))
> -
>  static struct uffd_test_ops anon_uffd_test_ops = {
> -	.expected_ioctls = ANON_EXPECTED_IOCTLS,
> +	.expected_ioctls = UFFD_API_RANGE_IOCTLS,
>  	.allocate_area	= anon_allocate_area,
>  	.release_pages	= anon_release_pages,
>  	.alias_mapping = noop_alias_mapping,
>  };
> 
>  static struct uffd_test_ops shmem_uffd_test_ops = {
> -	.expected_ioctls = ANON_EXPECTED_IOCTLS,
> +	.expected_ioctls = UFFD_API_RANGE_IOCTLS,

Isn't UFFD_API_RANGE_IOCTLS includes UFFDIO_WP which is not supported for
shmem?

>  	.allocate_area	= shmem_allocate_area,
>  	.release_pages	= shmem_release_pages,
>  	.alias_mapping = noop_alias_mapping,

...

-- 
Sincerely yours,
Mike.

